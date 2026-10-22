"""Isolated native LSP + blink prototype; never imported by daily configuration.

Run after language fixture provisioning. --prepare explicitly downloads candidates.
No Coc, Mason or language-server auto-installer runs in the prototype.
"""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import urllib.request
import zipfile
import io
from nvim_process import run_nvim

BLINK_REF = "v1.10.2"
GO_REF = "5622d97078b30d853a0dfaf8cba204263a60c99a"

LUA = r'''
local root=vim.env.NVIM_NATIVE_EVALUATION
local case=vim.json.decode(table.concat(vim.fn.readfile(root..'/case.json'),'\n'))
vim.opt.runtimepath:prepend(case.blink)
local blink=require('blink.cmp')
blink.setup({fuzzy={implementation='lua'},sources={default={'lsp'}},completion={documentation={auto_show=false}}})
vim.bo.filetype=case.filetype
local started=vim.uv.hrtime()
local config={name='isolated-'..case.language,cmd=case.cmd,root_dir=vim.fn.getcwd(),
  capabilities=blink.get_lsp_capabilities(),settings=case.settings or {},init_options=case.init_options or {}}
local client_id=vim.lsp.start(config)
local function finish(ok,value)
  for _,c in ipairs(vim.lsp.get_clients()) do c:stop() end
  vim.fn.writefile({vim.json.encode({ok=ok,result=value})},root..'/result.json')
  vim.defer_fn(function() vim.cmd(ok and 'qa!' or 'cquit 1') end,300)
end
vim.defer_fn(function()
  local ok,result=pcall(function()
    assert(client_id,'Native LSP did not start')
    local client=vim.lsp.get_client_by_id(client_id)
    assert(vim.wait(25000,function() return client.initialized end,50),'initialize timed out')
    local ready_ms=(vim.uv.hrtime()-started)/1e6
    vim.api.nvim_win_set_cursor(0,{case.line,case.column})
    local function request(method,params)
      local t=vim.uv.hrtime()
      local response=client:request_sync(method,params,15000,0)
      assert(response and not response.err,method..': '..vim.inspect(response))
      return response.result,(vim.uv.hrtime()-t)/1e6
    end
    local doc={uri=vim.uri_from_bufnr(0)}
    local pos={line=case.line-1,character=case.column}
    local defs=request('textDocument/definition',{textDocument=doc,position=pos})
    assert(type(defs)=='table' and not vim.tbl_isempty(defs),'Definition missing')
    local refs=request('textDocument/references',{textDocument=doc,position=pos,context={includeDeclaration=true}})
    assert(type(refs)=='table' and #refs>=2,'References missing')
    local rename=request('textDocument/rename',{textDocument=doc,position=pos,newName=case.renamed})
    assert(vim.inspect(rename):find(case.renamed,1,true),'Rename edit missing')
    local completion,completion_ms=request('textDocument/completion',{textDocument=doc,
      position={line=(case.completion_line or case.line)-1,character=case.completion_column or case.column},context={triggerKind=1}})
    assert(vim.inspect(completion):find(case.symbol,1,true),'Completion symbol missing: '..vim.inspect(completion))
    local blink_ok=false
    vim.api.nvim_win_set_cursor(0,{case.completion_line or case.line,case.completion_column or case.column})
    blink.show({providers={'lsp'},callback=function() blink_ok=true end})
    assert(vim.wait(5000,function() return blink_ok end,25),'blink menu callback missing')
    assert(vim.inspect(blink.get_items()):find(case.symbol,1,true),'blink list lacks language symbol')
    blink.hide()
    local intentional={python='typed_error: str = 42',lua='missing_native_evaluation_global()',go='var typedError string = 42'}
    if intentional[case.language] then vim.api.nvim_buf_set_lines(0,-1,-1,false,{intentional[case.language]}) end
    assert(vim.wait(15000,function() return #vim.diagnostic.get(0)>0 end,50),'Native diagnostics missing')
    return {language=case.language,diagnostics=true,native_initialize_ms=ready_ms,completion_request_ms=completion_ms,
      definition=true,references=true,rename=true,completion=true,
      blink_setup=true,blink_menu_callback=blink_ok,matcher='lua'}
  end)
  finish(ok,result)
end,100)
'''


COC_LUA = r'''
local root=vim.env.NVIM_NATIVE_EVALUATION
local case=vim.json.decode(table.concat(vim.fn.readfile(root..'/case.json'),'\n'))
local started=vim.uv.hrtime()
vim.defer_fn(function()
  local ok,result=pcall(function()
    assert(vim.wait(25000,function()
      local ok,value=pcall(vim.fn.CocHasProvider,'definition');return ok and value==true
    end,25),'Coc provider missing')
    local ready_ms=(vim.uv.hrtime()-started)/1e6
    vim.api.nvim_win_set_cursor(0,{case.line,case.column})
    local service=({python='pyright',lua='lua',go='go'})[case.language]
    assert(service,'Timing comparison supports Python/Lua/Go')
    local doc={uri=vim.uri_from_bufnr(0)}
    local pos={line=case.line-1,character=case.column}
    local function warm(method,params)
      local done,value,error=false,nil,nil
      vim.fn.CocRequestAsync(service,method,params,function(e,r) error=e;value=r;done=true end)
      assert(vim.wait(15000,function() return done end,10),method..' timed out')
      assert(error==nil or error==vim.NIL,vim.inspect(error))
      return value
    end
    assert(not vim.tbl_isempty(warm('textDocument/definition',{textDocument=doc,position=pos})),'Coc definition missing')
    assert(#warm('textDocument/references',{textDocument=doc,position=pos,context={includeDeclaration=true}})>=2,'Coc refs missing')
    assert(vim.inspect(warm('textDocument/rename',{textDocument=doc,position=pos,newName=case.renamed})):find(case.renamed,1,true),'Coc rename missing')
    local completed,value,failure=false,nil,nil
    local t=vim.uv.hrtime()
    vim.fn.CocRequestAsync(service,'textDocument/completion',{
      textDocument={uri=vim.uri_from_bufnr(0)},position={line=(case.completion_line or case.line)-1,character=case.completion_column or case.column},context={triggerKind=1}
    },function(e,r) failure=e;value=r;completed=true end)
    assert(vim.wait(15000,function() return completed end,10),'Coc completion timed out')
    assert(failure==nil or failure==vim.NIL,vim.inspect(failure))
    assert(vim.inspect(value):find(case.symbol,1,true),'Coc completion symbol missing')
    return {language=case.language,coc_provider_ms=ready_ms,completion_request_ms=(vim.uv.hrtime()-t)/1e6,stack='coc'}
  end)
  vim.fn.writefile({vim.json.encode({ok=ok,result=result})},root..'/result.json')
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,100)
'''


def prepare(base):
    base.mkdir(parents=True, exist_ok=True)
    for name, repo, ref in (("blink", "Saghen/blink.cmp", BLINK_REF), ("go.nvim", "ray-x/go.nvim", GO_REF)):
        target=base/name
        marker=target/'nvim-evaluation-source.json'
        if target.exists():
            assert marker.is_file() and json.loads(marker.read_text())=={'repo':repo,'ref':ref},'Candidate source differs or has no provenance: '+str(target)
            continue
        with urllib.request.urlopen("https://api.github.com/repos/"+repo+"/zipball/"+ref,timeout=60) as response:
            data=response.read()
        with tempfile.TemporaryDirectory(prefix="candidate-stage-",dir=base) as directory:
            stage=Path(directory)
            with zipfile.ZipFile(io.BytesIO(data)) as package:
                for member in package.namelist():
                    assert (stage/member).resolve().is_relative_to(stage.resolve()),"Unsafe candidate archive"
                package.extractall(stage)
            shutil.move(str(next(stage.iterdir())),str(target))
            marker.write_text(json.dumps({'repo':repo,'ref':ref}),encoding='utf-8')
    npm=base/'typescript'
    npm.mkdir(exist_ok=True)
    (npm/'package.json').write_text(json.dumps({'private':True,'dependencies':{'typescript-language-server':'6.0.2','typescript':'5.7.3'}}))
    subprocess.run(['npm.cmd' if os.name=='nt' else 'npm','install','--ignore-scripts','--no-audit','--no-fund'],cwd=npm,check=True,timeout=240)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data',required=True,type=Path)
    parser.add_argument('--prepare',action='store_true')
    parser.add_argument('--stack',choices=['native','coc'],default='native')
    parser.add_argument('--language',choices=['python','lua','go','vue26','vue27','vue3','javascript','typescript','javascriptreact','typescriptreact'],default='python')
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    data=args.data.resolve();base=data/'evaluations';ext=data/'coc/extensions/node_modules'
    if args.prepare:prepare(base)
    assert (base/'blink/lua/blink/cmp/init.lua').is_file(),'Explicitly deploy candidates with --prepare'
    node=shutil.which('node');suffix='.exe' if os.name=='nt' else ''
    with tempfile.TemporaryDirectory(prefix='native-language-evaluation-') as directory:
        root=Path(directory);cwd=root
        case={'language':args.language,'blink':(base/'blink').as_posix(),'renamed':'welcome'}
        if args.language=='python':
            (root/'helper.py').write_text('def greet(name: str) -> str:\n    return name\n')
            filename='main.py';(root/filename).write_text('from helper import greet\nprint(greet("world"))\n')
            case.update(filetype='python',cmd=[node,str(ext/'coc-pyright/node_modules/pyright/dist/pyright-langserver.js'),'--stdio'],line=2,column=7,symbol='greet')
        elif args.language=='lua':
            filename='main.lua';(root/filename).write_text('local function greet(name) return name end\nprint(greet("world"))\ngre\n')
            case.update(filetype='lua',cmd=[str(data/('coc/extensions/coc-lua-data/lua-language-server/bin/lua-language-server'+suffix))],line=2,column=7,completion_line=3,completion_column=3,symbol='greet',settings={'Lua':{'runtime':{'version':'LuaJIT'},'diagnostics':{'globals':['vim']}}})
        elif args.language=='go':
            filename='main.go';(root/'go.mod').write_text('module example.com/evaluate\n\ngo 1.26.0\n')
            (root/filename).write_text('package main\nfunc Greet() string { return "hello" }\nfunc main() { println(Greet()) }\n')
            case.update(filetype='go',cmd=[str(data/('tools/languages/bin/gopls'+suffix))],line=3,column=24,symbol='Greet',renamed='Welcome')
        else:
            cwd=data/'language-fixtures'/args.language
            assert (cwd/'case.json').is_file(),'Run language_services_smoke.py --language '+args.language+' --prepare first'
            old=json.loads((cwd/'case.json').read_text())
            case.update(line=old['line'],column=old['column'],symbol=old['symbol'],renamed=old['renamed'])
            if args.language.startswith('vue'):
                filename='App.vue'
                case.update(filetype='vue',cmd=[node,str(ext/'@yaegassy/coc-volar/node_modules/@vue/language-server/bin/vue-language-server.js'),'--stdio'],init_options={'typescript':{'tsdk':str(cwd/'node_modules/typescript/lib')},'vue':{'hybridMode':False}})
            else:
                filename='main.'+{'javascript':'js','typescript':'ts','javascriptreact':'jsx','typescriptreact':'tsx'}[args.language]
                case.update(filetype=args.language,cmd=[node,str(base/'typescript/node_modules/typescript-language-server/lib/cli.mjs'),'--stdio'])
        (root/'case.json').write_text(json.dumps(case),encoding='utf-8')
        (root/'verify.lua').write_text(LUA if args.stack=='native' else COC_LUA,encoding='utf-8')
        env=os.environ.copy();env['NVIM_NATIVE_EVALUATION']=root.as_posix();env['GOTOOLCHAIN']='local'
        argv=['nvim','--headless','-n']
        if args.stack=='native':argv+=['-u','NONE']
        argv += [filename,'+lua dofile(vim.env.NVIM_NATIVE_EVALUATION.."/verify.lua")']
        proc=run_nvim(argv,cwd=cwd,env=env,timeout=65)
        report=json.loads((root/'result.json').read_text())
        if args.output:args.output.write_text(json.dumps(report,indent=2),encoding='utf-8')
        assert report['ok'] and proc.returncode==0,str(report)+'\n'+proc.stdout
        print(json.dumps(report))


if __name__=='__main__':main()
