"""Isolated real-picker probes, sharing the repository's ripgrep exclusions."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import pynvim
import time
import argparse
import platform
import statistics
import hashlib

LUA = r'''
local data=vim.fn.stdpath('data')
local root=vim.env.NVIM_PICKER_CONFIG
vim.opt.rtp:append(root)
for _,name in ipairs({'plenary.nvim','telescope.nvim','telescope-fzf-native.nvim','nvim-web-devicons'}) do
  vim.opt.rtp:append(data..'/lazy/'..name)
end
local variant=vim.env.NVIM_PICKER_VARIANT
local eval=data..'/tools/evaluations/'
local windows=vim.fn.has('win32')==1
local extension=windows and '.exe' or ''
vim.env.PATH=eval..'fzf'..(windows and ';' or ':')..vim.env.PATH
local search=require('search').options()
local output={variant=variant,results={}}
local messages={}
vim.notify=function(message,level) messages[#messages+1]={message=tostring(message),level=level} end
local repo=variant=='telescope' and data..'/lazy/telescope.nvim' or eval..(variant=='fzf' and 'fzf-lua' or 'snacks.nvim')
output.revision=vim.fn.system({'git','-C',repo,'rev-parse','HEAD'}):gsub('%s+$','')
output.nvim=vim.version().major..'.'..vim.version().minor..'.'..vim.version().patch
vim.o.lines=40
vim.o.columns=120
if variant=='telescope' then
  require('search').setup(nil, search)
elseif variant=='fzf' then
  vim.opt.rtp:append(eval..'fzf-lua')
  require('fzf-lua').setup({fzf_bin=eval..'fzf/fzf'..extension,fzf_opts={['--info']='inline'},winopts={preview={hidden=true}},
    actions={files={['ctrl-q']=require('fzf-lua.actions').file_sel_to_qf}},
    files={cmd=table.concat(search.pickers.find_files.find_command,' ')},
    grep={rg_opts=table.concat(vim.list_slice(search.defaults.vimgrep_arguments,2),' ')}})
else
  vim.opt.rtp:append(eval..'snacks.nvim')
  require('snacks').setup({picker={enabled=true,matcher={frecency=false},
    sources={files={cmd='rg',hidden=false,ignored=false,exclude={'.git','node_modules','__pycache__','.pnpm-store'}}}}})
end
local kinds={'files','grep','buffers','oldfiles','help','commands','keymaps','filter','quickfix'}
local function finish()
  output.messages=messages
  vim.rpcnotify(1,'picker_done',output)
end
vim.defer_fn(function() vim.rpcnotify(1,'picker_timeout','75 second limit exceeded') end,75000)
local function step(index)
  local kind=kinds[index]
  if not kind then finish(); return end
  local source=(kind=='filter' or kind=='quickfix') and 'files' or kind
    local before=vim.uv.hrtime()
    local opened,err=pcall(function()
      if variant=='telescope' then
        local names={files='find_files',grep='live_grep',help='help_tags'}
        require('telescope.builtin')[names[source] or source]({default_text=kind=='grep' and 'PICKER_NEEDLE' or nil})
      elseif variant=='snacks' then
        local names={oldfiles='recent'}
        Snacks.picker[names[source] or source]({search=kind=='grep' and 'PICKER_NEEDLE' or nil,show_delay=0,
          args=kind=='grep' and {'--glob=!.git/**','--glob=!**/node_modules/**','--glob=!**/__pycache__/**','--glob=!**/.pnpm-store/**'} or nil})
      else
        local names={grep='live_grep',help='helptags'}
        require('fzf-lua')[names[source] or source]({search=kind=='grep' and 'PICKER_NEEDLE' or nil})
      end
    end)
    local count=0
    local terminal
    local sent=false
    if kind=='filter' or kind=='quickfix' then
      vim.defer_fn(function()
        before=vim.uv.hrtime()
        if kind=='filter' then
          if variant=='fzf' then
            vim.api.nvim_chan_send(vim.bo.channel,'file0999')
          else vim.api.nvim_input('file0999') end
        else
          vim.fn.setqflist({})
          if variant=='telescope' then
            local actions=require('telescope.actions')
            local p=require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf())
            actions.toggle_selection(p.prompt_bufnr);actions.move_selection_next(p.prompt_bufnr)
            actions.toggle_selection(p.prompt_bufnr);actions.send_selected_to_qflist(p.prompt_bufnr)
          elseif variant=='snacks' then
            local p=Snacks.picker.get()[1]
            p.list:select(p.list:get(1));p.list:select(p.list:get(2))
            require('snacks.picker.actions').qflist(p)
          else vim.api.nvim_chan_send(vim.bo.channel,'\t\t'..string.char(17)) end
        end
        sent=true
      end,500)
    end
    local function poll()
      if (kind=='filter' or kind=='quickfix') and not sent then vim.defer_fn(poll,10);return end
      if kind=='quickfix' then
        count=#vim.fn.getqflist()
      elseif variant=='telescope' then
        local ok,p=pcall(require('telescope.actions.state').get_current_picker,vim.api.nvim_get_current_buf())
        count=ok and p and p.manager and p.manager:num_results() or 0
      elseif variant=='snacks' then
        local p=Snacks.picker.get()[1];count=p and (kind=='filter' and #p:items() or p:count()) or 0
      else
        for _,b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[b].buftype=='terminal' and vim.api.nvim_buf_is_loaded(b) then
            local lines=vim.api.nvim_buf_get_lines(b,0,-1,false)
            for _,line in ipairs(lines) do
              if line:match('[%d,]+/[%d,]+') then
                count=tonumber((line:match('([%d,]+)/'):gsub(',',''))) or 0
                terminal=b
              elseif kind=='buffers' and line:match('%[%d+%].*needle.py') then
                count=1
              end
            end
          end
        end
      end
      local good=kind=='filter' and count==1 or kind=='quickfix' and count==2 or kind~='filter' and kind~='quickfix' and count>0
      if opened and not good and (vim.uv.hrtime()-before)/1e6<8000 then
        vim.defer_fn(poll,10);return
      end
    local ready=opened and good
    local snapshot={}
    if variant=='fzf' and not ready then
      for _,b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].buftype=='terminal' and vim.api.nvim_buf_is_loaded(b) then
          vim.list_extend(snapshot,vim.api.nvim_buf_get_lines(b,0,math.min(5,vim.api.nvim_buf_line_count(b)),false))
        end
      end
    end
    output.results[#output.results+1]={kind=kind,ready=ready,count=count,first_result_ms=(vim.uv.hrtime()-before)/1e6,error=not opened and tostring(err) or nil,snapshot=#snapshot>0 and snapshot or nil}
    vim.defer_fn(function()
    if variant=='telescope' then
      local ok,p=pcall(require('telescope.actions.state').get_current_picker,vim.api.nvim_get_current_buf())
      if ok and p then require('telescope.actions').close(p.prompt_bufnr) end
    elseif variant=='snacks' then
      for _,p in ipairs(Snacks.picker.get()) do p:close() end
    else
      local win=require('fzf-lua.win').__SELF()
      if win then win:close() end
    end
    vim.defer_fn(function() step(index+1) end,300)
    end,300)
  end
  vim.defer_fn(poll,10)
end
vim.defer_fn(function()
  vim.cmd.cd(vim.env.NVIM_PICKER_ROOT)
  vim.cmd.edit('needle.py')
  vim.v.oldfiles={vim.env.NVIM_PICKER_ROOT..'/needle.py',vim.env.NVIM_PICKER_ROOT..'/file0001.py'}
  step(1)
end,100)
'''


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runs',type=int,default=3)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    assert args.runs>0,'--runs must be positive'
    config=Path(__file__).resolve().parents[1]
    evidence=[]
    with tempfile.TemporaryDirectory(prefix='picker-evaluation-') as directory:
        root=Path(directory)
        for n in range(1000):
            (root/f'file{n:04d}.py').write_text(f'PICKER_NEEDLE={n}\n',encoding='utf-8')
        (root/'needle.py').write_text('PICKER_NEEDLE=42\n',encoding='utf-8')
        (root/'.gitignore').write_text('ignored/\n',encoding='utf-8')
        (root/'ignored').mkdir();(root/'ignored/cache.py').write_text('PICKER_NEEDLE=0\n')
        subprocess.run(['git','init','-q',str(root)],check=True,timeout=15)
        probe=root/'probe.lua';probe.write_text(LUA,encoding='utf-8')
        for run,variant in ((run,variant) for run in range(1,args.runs+1) for variant in ('telescope','fzf','snacks')):
            output=root/f'{variant}.json'
            env=os.environ.copy();env.update(NVIM_PICKER_CONFIG=config.as_posix(),NVIM_PICKER_ROOT=root.as_posix(),NVIM_PICKER_VARIANT=variant,NVIM_PICKER_OUTPUT=output.as_posix())
            oldenv=os.environ.copy()
            os.environ.update(env)
            before=time.perf_counter()
            nvim=pynvim.attach('child',argv=['nvim','--clean','--embed','-n','-S',str(probe)])
            row={}
            def notice(name,args):
                if name=='picker_done':
                    row.update(args[0]);nvim.stop_loop()
                elif name=='picker_timeout':
                    row['timeout']=args[0];nvim.stop_loop()
                elif name=='redraw' and 'first_ui_flush_wall_ms' not in row and any(event[0]=='flush' for event in args):
                    row['first_ui_flush_wall_ms']=(time.perf_counter()-before)*1000
            try:
                nvim.ui_attach(120,40,rgb=True)
                nvim.run_loop(None,notice)
                try:nvim.command('qa!')
                except (OSError,EOFError):pass
            finally:
                nvim.close()
                os.environ.clear();os.environ.update(oldenv)
            row['process_wall_ms']=(time.perf_counter()-before)*1000
            row.update(run=run,cache_state='first-observed' if run==1 else 'warm-repeated')
            evidence.append(row)
            print(json.dumps(row,ensure_ascii=False),flush=True)
    summary={}
    for variant in ('telescope','fzf','snacks'):
        summary[variant]={}
        rows=[row for row in evidence if row.get('variant')==variant]
        metrics={'first_ui_flush_wall_ms':[row['first_ui_flush_wall_ms'] for row in rows if 'first_ui_flush_wall_ms' in row]}
        for kind in ('files','grep','buffers','oldfiles','help','commands','keymaps','filter','quickfix'):
            metrics[kind+'_ms']=[result['first_result_ms'] for row in rows for result in row.get('results',[]) if result['kind']==kind and result['ready']]
        for metric,samples in metrics.items():
            summary[variant][metric]=dict(samples=len(samples),median=statistics.median(samples),minimum=min(samples),maximum=max(samples)) if samples else None
    report=dict(platform=platform.platform(),python=platform.python_version(),
        method='RPC UI attach 120x40. Process wall to first UI flush includes process creation and minimal isolated setup; excludes shell startup and physical terminal paint. Files/grep begin at picker invocation. Filter begins at actual input after 500ms picker settling. Quickfix selects exactly two real entries.',
        sequence='Same generated fixture; telescope/fzf/snacks repeated per round; no user cache cleared; first-observed is not certified cold.',
        fixture=dict(files=1000,source_sha256=hashlib.sha256(LUA.encode()).hexdigest()),
        runs=evidence,summary_ms=summary)
    target=args.output or config/'docs/evaluations/picker-comparison.json'
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    assert len(evidence)==args.runs*3,'missing measurement samples'
    for row in evidence:
        assert not row.get('timeout'),row
        assert len(row.get('results',[]))==9,row
        assert all(result['ready'] for result in row['results']),row
        assert row.get('first_ui_flush_wall_ms',0)>0,row
    print(json.dumps(summary,ensure_ascii=False,indent=2))


if __name__=='__main__':main()
