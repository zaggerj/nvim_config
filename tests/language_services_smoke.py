"""Exercise real language navigation through configured Coc, using isolated projects."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import tempfile
from nvim_process import run_nvim

LUA = r'''
local root=vim.env.NVIM_LANGUAGE_TEST
local function finish(ok,message)
  vim.fn.writefile({vim.json.encode({ok=ok,message=message})},root..'/result.json')
  vim.cmd(ok and 'qa!' or 'cquit 1')
end
vim.defer_fn(function()
  local ok,err=pcall(function()
    assert(vim.wait(18000,function()
      if vim.fn.exists('*CocHasProvider')~=1 then return false end
      local ready,available=pcall(vim.fn.CocHasProvider,'definition')
      return ready and (available==true or available==1)
    end,50),'No definition provider for '..vim.bo.filetype)
    vim.api.nvim_win_set_cursor(0,{2,6})
    local done,result,request_error=false,nil,nil
    vim.fn.CocActionAsync('definitions',function(e,r) request_error=e;result=r;done=true end)
    assert(vim.wait(15000,function() return done end,30),'Definition request timed out')
    assert(request_error==nil or request_error==vim.NIL,vim.inspect(request_error))
    assert(type(result)=='table' and #result>0,'No actual definition location')
    assert(vim.inspect(result):find('helper.py',1,true),'Definition did not resolve imported function: '..vim.inspect(result))
    local function request(method,params)
      local completed,value,failure=false,nil,nil
      vim.fn.CocRequestAsync('pyright',method,params,function(e,r) failure=e;value=r;completed=true end)
      assert(vim.wait(10000,function() return completed end,50),method..' timed out')
      assert(failure==nil or failure==vim.NIL,vim.inspect(failure))
      return value
    end
    local document={uri=vim.uri_from_bufnr(0)}
    local position={line=1,character=7}
    local refs=request('textDocument/references',{textDocument=document,position=position,context={includeDeclaration=true}})
    assert(type(refs)=='table' and #refs>=2,'References missing declaration or call')
    local rename=request('textDocument/rename',{textDocument=document,position=position,newName='welcome'})
    assert(vim.inspect(rename):find('welcome',1,true),'Rename did not return workspace edits')
    local completions=request('textDocument/completion',{textDocument=document,position={line=2,character=3},context={triggerKind=1}})
    assert(vim.inspect(completions):find('greet',1,true),'Python completion lacks greet')
    assert(vim.wait(10000,function()
      local ready,diagnostics=pcall(vim.fn.CocAction,'diagnosticList')
      return ready and vim.inspect(diagnostics):find('str',1,true)~=nil
    end,100),'Expected typed argument diagnostic is missing')
    finish(true,'Python definition, references, rename, completion and typed diagnostics')
  end)
  if not ok then finish(false,tostring(err)) end
end,500)
'''

FRONTEND_LUA = r'''
local root=vim.env.NVIM_LANGUAGE_TEST
local function finish(ok,message)
  vim.fn.writefile({vim.json.encode({ok=ok,message=message})},root..'/result.json')
  vim.cmd(ok and 'qa!' or 'cquit 1')
end
vim.defer_fn(function()
  local ok,message=pcall(function()
    assert(vim.wait(25000,function()
      local ready,available=pcall(vim.fn.CocHasProvider,'definition')
      return ready and (available==true or available==1)
    end,100),'No real definition provider for '..vim.bo.filetype)
    local case=vim.json.decode(table.concat(vim.fn.readfile(root..'/case.json'),'\n'))
    vim.api.nvim_win_set_cursor(0,{case.line,case.column})
    local resolved=false
    local function resolve()
      vim.fn.CocActionAsync('definitions',function(e,r)
        if type(r)=='table' and #r>0 and vim.inspect(r):find(case.expected,1,true) then
          resolved=true
        elseif not resolved then
          vim.defer_fn(resolve,250)
        end
      end)
    end
    resolve()
    assert(vim.wait(25000,function() return resolved end,50),'No definition resolved to '..case.expected)
    do
      local completed,items,failure=false,nil,nil
      -- Volar hybrid mode sends template expressions through coc-tsserver's Vue TS plugin.
      vim.fn.CocActionAsync('runCommand','typescript.tsserverRequest','completionInfo',{
        file=vim.api.nvim_buf_get_name(0),line=case.line,offset=case.column+1,includeExternalModuleExports=false,
      },{},function(e,r) failure=e;items=r;completed=true end)
      assert(vim.wait(10000,function() return completed end,50),'Vue completion timed out')
      assert(failure==nil or failure==vim.NIL,vim.inspect(failure))
      assert(vim.inspect(items):find(case.symbol,1,true),'Completion lacks fixture symbol: '..vim.inspect(items))
      local refs_done,refs=false,nil
      vim.fn.CocActionAsync('references',function(e,r) refs=r;refs_done=true end)
      assert(vim.wait(10000,function() return refs_done end,50),'Vue references timed out')
      assert(type(refs)=='table' and #refs>0,'References missing')
      local renamed,rename_failure=false,nil
      vim.fn.CocActionAsync('rename',case.renamed,function(e,r) rename_failure=e;renamed=true end)
      assert(vim.wait(10000,function() return renamed end,50),'Rename timed out')
      assert(rename_failure==nil or rename_failure==vim.NIL,vim.inspect(rename_failure))
      local contents=table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'\n')
      local _,count=contents:gsub(case.renamed,'')
      assert(count>=2,'Rename did not update definition and reference: '..contents)
    end
    -- Validate diagnostics independently from parser colours.
    assert(vim.wait(15000,function()
      local ready,diagnostics=pcall(vim.fn.CocAction,'diagnosticList')
      return ready and type(diagnostics)=='table' and #diagnostics>0
    end,100),'Expected language diagnostic missing')
    return 'Real '..vim.bo.filetype..' definition, diagnostics, completion, references and rename'..': '..case.label
  end)
  finish(ok,tostring(message))
end,1000)
'''

def frontend(args):
    # These are persistent, explicit fixture dependencies; runtime config never uses them.
    cache=Path(os.environ.get('LOCALAPPDATA',Path.home()/'.local/share'))/'nvim-data/language-fixtures'
    root=cache/args.language
    root.mkdir(parents=True,exist_ok=True)
    version={'vue26':'2.6.14','vue27':'2.7.16','vue3':'3.5.13'}.get(args.language)
    dependencies={'typescript':'5.7.3'}
    if version:dependencies['vue']=version
    else:dependencies.update({'react':'18.3.1','@types/react':'18.3.18'})
    package={'name':'nvim-'+args.language+'-fixture','private':True,'version':'1.0.0','dependencies':dependencies}
    (root/'package.json').write_text(json.dumps(package,indent=2),encoding='utf-8')
    if args.prepare:
        subprocess.run(['npm.cmd' if os.name=='nt' else 'npm','install','--ignore-scripts','--no-audit','--no-fund'],cwd=root,check=True,timeout=240)
    assert (root/'node_modules/typescript/package.json').is_file(),'Run with --prepare to explicitly install fixture dependencies'
    tsconfig={'compilerOptions':{'target':'ES2020','module':'ESNext','moduleResolution':'node','strict':True,'jsx':'react-jsx','allowJs':True,'checkJs':True,'skipLibCheck':True},'include':['**/*.vue','**/*.ts','**/*.tsx','**/*.js','**/*.jsx']}
    if version:tsconfig['vueCompilerOptions']={'target':float('.'.join(version.split('.')[:2]))}
    (root/'tsconfig.json').write_text(json.dumps(tsconfig,indent=2),encoding='utf-8')
    case={'label':args.language}
    if version:
        filename='App.vue'
        if args.language=='vue26':
            text='<template><div>{{ message }} {{ missingValue }}</div></template>\n<script lang="ts">\nimport Vue from "vue"\nexport default Vue.extend({data() { return { message: "hello" } }})\n</script>\n'
        else:
            text='<template><div>{{ message }} {{ missingValue }}</div></template>\n<script setup lang="ts">\nconst message: string = "hello"\n</script>\n'
        case.update(line=1,column=21,expected='App.vue',symbol='message',renamed='renamedMessage')
    else:
        extensions={'javascript':'js','typescript':'ts','javascriptreact':'jsx','typescriptreact':'tsx'}
        ext=extensions[args.language]
        filename='main.'+ext
        helper='helper.ts' if ext in ('ts','tsx') else 'helper.js'
        (root/helper).write_text('export function greet(name'+(': string' if ext in ('ts','tsx') else '')+') { return name }\n',encoding='utf-8')
        text='import { greet } from "./helper"\nconst answer = greet("world")\nconst invalid: number = "wrong"\n' if ext in ('ts','tsx') else 'import { greet } from "./helper"\nconst answer = greet("world")\nmissingValue()\n'
        if ext in ('jsx','tsx'):text+='export const View = () => <div>{answer}</div>\n'
        case.update(line=2,column=17,expected=helper,symbol='greet',renamed='welcome')
    (root/filename).write_text(text,encoding='utf-8')
    (root/'case.json').write_text(json.dumps(case),encoding='utf-8')
    (root/'verify.lua').write_text(FRONTEND_LUA,encoding='utf-8')
    env=os.environ.copy();env['NVIM_LANGUAGE_TEST']=root.as_posix();env['NVIM_COC_LOG_FILE']=(root/'coc.log').as_posix()
    result=run_nvim(['nvim','--headless','-n',filename,'+lua dofile(vim.env.NVIM_LANGUAGE_TEST .. "/verify.lua")'],cwd=root,env=env,timeout=65)
    report=json.loads((root/'result.json').read_text(encoding='utf-8'))
    assert report['ok'] and result.returncode==0,report['message']+'\n'+result.stdout+'\n'+(root/'coc.log').read_text(encoding='utf-8')[-3000:]
    print('PASS '+report['message'])


def go_test():
    with tempfile.TemporaryDirectory(prefix='nvim-go-language-') as directory:
        root=Path(directory)
        (root/'go.mod').write_text('module example.com/language\n\ngo 1.26.0\n',encoding='utf-8')
        (root/'greeting').mkdir()
        (root/'greeting/greeting.go').write_text('package greeting\nfunc Hello(name string) string { return "hello " + name }\n',encoding='utf-8')
        (root/'greeting/greeting_test.go').write_text('package greeting\nimport "testing"\nfunc TestHello(t *testing.T) { if Hello("world") != "hello world" { t.Fatal("wrong greeting") } }\n',encoding='utf-8')
        (root/'main.go').write_text('package main\nimport "example.com/language/greeting"\nfunc main() { println(greeting.Hello("world")) }\n',encoding='utf-8')
        script=LUA.replace('welcome','Welcome').replace("'pyright'","'go'").replace('helper.py','greeting.go').replace('{2,6}','{3,33}').replace('line=1,character=7','line=2,character=33')
        start=script.index('    local completions=')
        end=script.index('    finish(true,',start)
        script=script[:start]+r"""    local hover=request('textDocument/hover',{textDocument=document,position=position})
    assert(vim.inspect(hover):find('Hello',1,true),'Go hover lacks symbol signature')
    local completion=request('textDocument/completion',{textDocument=document,position={line=2,character=31},context={triggerKind=1}})
    assert(vim.inspect(completion):find('Hello',1,true),'Go member completion lacks Hello')
    local format=request('textDocument/formatting',{textDocument=document,options={tabSize=4,insertSpaces=false}})
    assert(type(format)=='table' and #format>0,'Go formatting did not return edits for compact fixture')
    vim.cmd.write()
    local saved=table.concat(vim.fn.readfile(vim.api.nvim_buf_get_name(0)),'\n')
    assert(saved..'\n'==vim.fn.system({'gofmt',vim.api.nvim_buf_get_name(0)}),'Saving Go file did not apply gofmt')
    local function task(command,state)
      vim.cmd(command)
      assert(vim.wait(30000,function()
        return vim.fn['go#statusline#Show']():find(state,1,true)~=nil
      end,50),command..' did not finish with '..state..': '..vim.fn['go#statusline#Show']())
    end
    task('GoBuild!','success')
    task('GoTest! ./...','success')
    vim.api.nvim_buf_set_lines(0,-1,-1,false,{'var broken string = 1'})
    vim.cmd.write()
    assert(vim.wait(10000,function()
      local ok,ds=pcall(vim.fn.CocAction,'diagnosticList')
      return ok and vim.inspect(ds):find('string',1,true)~=nil
    end,100),'Go typed error diagnostic missing')
    task('GoBuild!','failed')
    local errors=vim.fn.getqflist()
    if #errors==0 then errors=vim.fn.getloclist(0) end
    assert(#errors>0,'GoBuild failure did not populate an error list')
    -- Remove the intentional type error, preserving gofmt's other lines.
    for index,line in ipairs(vim.api.nvim_buf_get_lines(0,0,-1,false)) do
      if line:find('var broken',1,true) then vim.api.nvim_buf_set_lines(0,index-1,index,false,{}) break end
    end
    vim.cmd.write()
    task('GoBuild!','success')
"""+script[end:]
        script=script.replace('Python definition, references, rename, completion and typed diagnostics','Go cross-package definition, references, rename, hover, completion, save formatting, GoBuild/GoTest and failure diagnostics')
        (root/'verify.lua').write_text(script,encoding='utf-8')
        env=os.environ.copy();env['NVIM_LANGUAGE_TEST']=root.as_posix();env['GOTOOLCHAIN']='local';env['NVIM_COC_LOG_FILE']=(root/'coc.log').as_posix()
        result=run_nvim(['nvim','--headless','-n','main.go','+lua dofile(vim.env.NVIM_LANGUAGE_TEST .. "/verify.lua")'],cwd=root,env=env,timeout=65)
        report=json.loads((root/'result.json').read_text(encoding='utf-8'))
        assert report['ok'] and result.returncode==0,report['message']+'\n'+result.stdout+'\n'+(root/'coc.log').read_text(encoding='utf-8')[-3000:]
        for command in (['go','build','./...'],['go','test','./...']):
            built=subprocess.run(command,cwd=root,env=env,capture_output=True,text=True,timeout=60)
            assert built.returncode==0,built.stdout+built.stderr
        print('PASS '+report['message']+'; actual go build ./... and go test ./...')


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--prepare',action='store_true',help='Explicitly install pinned fixture dependencies')
    parser.add_argument('--language',default='python',choices=['python','python-venv','lua','vue26','vue27','vue3','javascript','typescript','javascriptreact','typescriptreact','go'])
    args=parser.parse_args()
    if args.language.startswith('vue') or args.language in ('javascript','typescript','javascriptreact','typescriptreact'):
        return frontend(args)
    if args.language=='go':
        return go_test()
    with tempfile.TemporaryDirectory(prefix='nvim-language-') as directory:
        root=Path(directory)
        (root/'helper.py').write_text('def greet(name: str) -> str:\n    return "Hello " + name\n',encoding='utf-8')
        (root/'main.py').write_text('from helper import greet\nprint(greet(42))\ngre\n',encoding='utf-8')
        (root/'pyproject.toml').write_text('[project]\nname = "language-fixture"\nversion = "0.1.0"\n',encoding='utf-8')
        script=LUA
        filename='main.py'
        if args.language=='python-venv':
            import sys
            subprocess.run([sys.executable,'-m','venv','--without-pip',str(root/'.venv')],check=True,timeout=30)
            site=root/'.venv'/('Lib/site-packages' if os.name=='nt' else f'lib/python{sys.version_info.major}.{sys.version_info.minor}/site-packages')
            site.mkdir(parents=True,exist_ok=True)
            (site/'venv_marker.py').write_text('def answer() -> int:\n    return 42\n',encoding='utf-8')
            (root/'main.py').write_text('from venv_marker import answer\nprint(answer())\n',encoding='utf-8')
            script=LUA[:LUA.index('    local function request')]+"    finish(true,'Project .venv import resolves without activating the shell')\n  end)\n  if not ok then finish(false,tostring(err)) end\nend,500)\n"
            script=script.replace('helper.py','venv_marker.py')
        if args.language=='lua':
            filename='main.lua'
            (root/filename).write_text('local function greet(name) return name end\nprint(greet("world"))\nlocal sample = vim.api\ngre\nmissing_global_language_test()\n',encoding='utf-8')
            script=LUA.replace('helper.py','main.lua').replace("'pyright'","'lua'").replace('greet(42)','greet("world")')
            script=script.replace('line=2,character=3','line=3,character=3')
            script=script.replace("return ready and vim.inspect(diagnostics):find('str',1,true)~=nil","return ready and vim.inspect(diagnostics):find('missing_global_language_test',1,true)~=nil and not vim.inspect(diagnostics):find('Undefined global `vim`',1,true)")
            script=script.replace('Expected typed argument diagnostic is missing','Expected unknown-global diagnostic missing or vim unexpectedly diagnosed').replace('Python','Lua').replace('typed diagnostics','unknown-global diagnostics and vim global recognition')
            restart="    vim.cmd('CocRestart')\n    assert(vim.wait(18000,function() local ok,has=pcall(vim.fn.CocHasProvider,'definition');return ok and has==true end,100),'Lua provider did not recover after CocRestart')\n"
            script=script.replace("    finish(true,'Lua",restart+"    finish(true,'Lua")
        (root/'verify.lua').write_text(script,encoding='utf-8')
        env=os.environ.copy();env['NVIM_LANGUAGE_TEST']=root.as_posix()
        env['NVIM_COC_LOG_FILE']=(root/'coc.log').as_posix()
        proc=run_nvim(['nvim','--headless','-n',filename,'+lua dofile(vim.env.NVIM_LANGUAGE_TEST .. "/verify.lua")'],cwd=root,env=env,timeout=40)
        (root/'output.log').write_text(proc.stdout,encoding='utf-8')
        report=json.loads((root/'result.json').read_text(encoding='utf-8'))
        assert report['ok'] and proc.returncode==0,report['message']+'\n'+(root/'output.log').read_text(encoding='utf-8')+'\n'+((root/'coc.log').read_text(encoding='utf-8')[-2500:] if (root/'coc.log').exists() else 'No Coc log')
        print('PASS '+report['message'])

if __name__=='__main__':main()
