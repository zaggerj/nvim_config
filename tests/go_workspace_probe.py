"""Read-only real-project Go navigation probe; never edits source or Go settings."""
import argparse
import json
import os
from pathlib import Path
import re
import tempfile
from nvim_process import run_nvim

LUA = r'''
local result={ok=false}
local function request(method,params)
  local done,value,failure=false,nil,nil
  vim.fn.CocRequestAsync('go',method,params,function(e,r)
    failure=e;value=r;done=true
  end)
  if not vim.wait(10000,function() return done end,50) then return nil,'request timed out' end
  if failure~=nil and failure~=vim.NIL then return nil,vim.inspect(failure) end
  return value
end
vim.defer_fn(function()
  local ok,err=pcall(function()
    if vim.env.NVIM_PROBE_RESTART=='1' then
      assert(vim.wait(30000,function() return vim.g.coc_service_initialized==1 end,100),'Coc not initialized')
      vim.cmd('CocRestart')
      vim.wait(1000,function() return false end,100)
    end
    assert(vim.wait(30000,function()
      local ready,available=pcall(vim.fn.CocHasProvider,'definition')
      return ready and (available==true or available==1)
    end,100),'Go definition provider unavailable')
    local symbol=vim.env.NVIM_PROBE_SYMBOL
    local lines=vim.api.nvim_buf_get_lines(0,0,-1,false)
    local call,declaration
    for i,line in ipairs(lines) do
      local column=line:find(symbol,1,true)
      if column then
        if line:match('^func%s+'..symbol..'%(') then declaration=i-1
        elseif not call then call={line=i-1,character=column} end
      end
    end
    assert(call and declaration,'Need a function declaration and call for '..symbol)
    local params={textDocument={uri=vim.uri_from_bufnr(0)},position=call}
    local last_error
    assert(vim.wait(120000,function()
      local locations,failure=request('textDocument/definition',params)
      last_error=failure or vim.inspect(locations)
      if type(locations)~='table' then return false end
      for _,location in ipairs(locations) do
        local range=location.range or location.targetSelectionRange
        if range and range.start.line==declaration then
          result.definition=locations
          return true
        end
      end
      return false
    end,500),'Definition failed: '..tostring(last_error))
    local hover,failure=request('textDocument/hover',params)
    assert(hover and hover~=vim.NIL and hover.contents,'Hover failed: '..tostring(failure))
    local refs,refs_error=request('textDocument/references',vim.tbl_extend('force',params,{context={includeDeclaration=true}}))
    assert(type(refs)=='table' and #refs>=2,'References failed: '..tostring(refs_error))
    result.references=#refs
    result.hover=true
    vim.fn.CocActionAsync('runCommand','workspace.showOutput','go',function() end)
    local output_buffer
    assert(vim.wait(5000,function()
      for _,buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find('output:///go',1,true) then
          output_buffer=buf;return vim.api.nvim_buf_is_loaded(buf)
        end
      end
      return false
    end,50),'gopls output channel unavailable')
    local output=table.concat(vim.api.nvim_buf_get_lines(output_buffer,0,-1,false),'\n')
    assert(not output:find('Error loading workspace folders',1,true), 'Workspace load error in gopls output')
    assert(not output:find('inconsistent vendoring',1,true), 'Vendor mismatch in gopls output')
    result.workspace_output_checked=#output>0
    assert(result.workspace_output_checked,'gopls output channel empty')
  end)
  result.ok=ok
  if not ok then result.error=tostring(err) end
  result.messages=vim.fn.execute('messages')
  -- Gracefully stop gopls before exiting while it may still be checking modules.
  local stopped=false
  pcall(vim.fn.CocActionAsync,'toggleService','go',function() stopped=true end)
  vim.wait(5000,function() return stopped end,50)
  vim.fn.writefile({vim.json.encode(result)},vim.env.NVIM_PROBE_RESULT)
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,500)
'''


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,required=True)
    parser.add_argument('--file',type=Path,required=True)
    parser.add_argument('--symbol',required=True)
    parser.add_argument('--goflags')
    parser.add_argument('--goproxy')
    parser.add_argument('--restart',action='store_true')
    args=parser.parse_args()
    module=next(parent for parent in args.file.resolve().parents if (parent/'go.mod').is_file())
    protected={module/name:(module/name).read_bytes() if (module/name).exists() else None
               for name in ('go.mod','go.sum')}
    env=os.environ.copy()
    for name,value in [('GOFLAGS',args.goflags),('GOPROXY',args.goproxy)]:
        if value is not None: env[name]=value
    with tempfile.TemporaryDirectory(prefix='nvim-go-workspace-') as directory:
        root=Path(directory)
        (root/'probe.lua').write_text(LUA,encoding='utf-8')
        env.update(NVIM_PROBE_SYMBOL=args.symbol,NVIM_PROBE_RESULT=(root/'result.json').as_posix(),
                   NVIM_PROBE_SCRIPT=(root/'probe.lua').as_posix(),NVIM_PROBE_RESTART='1' if args.restart else '0')
        lifecycle_error=None
        try:
            completed=run_nvim(['nvim','--headless','-n',str(args.file.resolve()),
                                '+lua dofile(vim.env.NVIM_PROBE_SCRIPT)'],cwd=args.root,env=env,timeout=180)
        except AssertionError as error:
            lifecycle_error=str(error)
        report_path=root/'result.json'
        report=json.loads(report_path.read_text(encoding='utf-8')) if report_path.exists() else {'ok':False}
        if lifecycle_error:
            report.update(ok=False,lifecycle_error=lifecycle_error)
        changed=[str(path) for path,before in protected.items()
                 if (path.read_bytes() if path.exists() else None)!=before]
        if changed:
            report.update(ok=False,modified_project_files=changed)
        # Signed dependency URLs must never escape into diagnostic artifacts.
        safe=re.sub(r'(https?://[^\s?"<>]+)\?[^\s"<>]+',r'\1?<query-redacted>',json.dumps(report,ensure_ascii=False))
        print(safe)
        raise SystemExit(0 if report['ok'] and not lifecycle_error and completed.returncode==0 else 1)


if __name__=='__main__':
    main()
