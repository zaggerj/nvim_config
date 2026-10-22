"""Run rewritten Treesitter in isolation; never updates the daily parser directory."""
import json
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim
import http.server
import threading

LUA=r'''
local data=vim.fn.stdpath('data')
local candidate=data..'/tools/evaluations/nvim-treesitter-main'
local site=data..'/tools/evaluations/treesitter-site'
vim.opt.rtp:prepend(candidate)
local windows=vim.fn.has('win32')==1
local extension=windows and '.exe' or ''
vim.env.PATH=data..'/tools/evaluations/tree-sitter'..(windows and ';' or ':')..vim.env.PATH
vim.env.CC=vim.fn.exepath('gcc')
require('nvim-treesitter').setup({install_dir=site})
vim.treesitter.language.register('javascript', 'javascriptreact')
vim.treesitter.language.register('tsx', 'typescriptreact')
vim.opt.rtp:append(vim.env.NVIM_TS_CONFIG)
for _,name in ipairs({'nvim-treesitter-context','nvim-ts-autotag','nvim-ts-context-commentstring','Comment.nvim'}) do
  vim.opt.rtp:append(data..'/lazy/'..name)
end
local integrations={}
for _,name in ipairs({'treesitter-context','nvim-ts-autotag'}) do
  local ok,err=pcall(function() require(name).setup({}) end)
  integrations[name]={setup_ok=ok,error=not ok and tostring(err) or nil}
end
require('large_file')
vim.cmd('runtime plugin/nvim-treesitter.lua')
local result={candidate=vim.fn.system({'git','-C',candidate,'rev-parse','HEAD'}):gsub('%s+$',''),
  cli=vim.fn.system({data..'/tools/evaluations/tree-sitter/tree-sitter'..extension,'--version'}),cases={}}
local langs={'javascript','typescript','tsx','vue','go','python','lua','http','html','css'}
local install_ok,install_err=pcall(function()
  require('nvim-treesitter').install(langs):wait(180000)
end)
result.install_ok=install_ok
result.install_error=not install_ok and tostring(install_err) or nil
vim.cmd('filetype plugin indent on')
local cases={
  {'sample.js','javascript','const value = 1;'},
  {'sample.ts','typescript','const value: number = 1;'},
  {'sample.jsx','javascriptreact','const V = () => <div>Hello</div>;'},
  {'sample.tsx','typescriptreact','const V = () => <div>Hello</div>;'},
  {'vue2.vue','vue','<template>\n<div>{{ message }}</div>\n</template>\n<script>\nexport default {data(){return {message:"hi"}}}\n</script>'},
  {'vue3.vue','vue','<template>\n<div>{{ message }}</div>\n</template>\n<script setup lang="ts">\nconst message: string = "hi"\n</script>'},
  {'main.go','go','package main\nfunc main() { println("hi") }'},
  {'main.py','python','def hello():\n    return "hi"'},
  {'main.lua','lua','local function hello()\n  return "hi"\nend'},
  {'request.http','http','GET https://example.com\nAccept: application/json\n'},
}
for _,case in ipairs(cases) do
  vim.cmd.enew({bang=true})
  vim.api.nvim_buf_set_name(0,vim.env.NVIM_TS_ROOT..'/'..case[1])
  vim.bo.filetype=case[2]
  vim.api.nvim_buf_set_lines(0,0,-1,false,vim.split(case[3],'\n'))
  local begin=vim.uv.hrtime()
  local ok,err=pcall(function()
    local parser=vim.treesitter.get_parser()
    parser:parse(true)
    assert(not parser:trees()[1]:root():has_error(),'parse has ERROR nodes')
    vim.treesitter.start()
    assert(vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()],'highlighter inactive')
    vim.bo.indentexpr="v:lua.require'nvim-treesitter'.indentexpr()"
    vim.cmd('normal! gg=G')
  end)
  result.cases[#result.cases+1]={file=case[1],ok=ok,error=not ok and tostring(err) or nil,ready_ms=(vim.uv.hrtime()-begin)/1e6}
end
result.integrations=integrations
result.old_configs_present=pcall(require,'nvim-treesitter.configs')
vim.cmd.enew({bang=true})
vim.api.nvim_buf_set_name(0,vim.env.NVIM_TS_ROOT..'/autotag.jsx')
vim.api.nvim_buf_set_lines(0,0,-1,false,{'const V = () => <div'})
vim.bo.filetype='javascriptreact'
vim.treesitter.start()
vim.treesitter.get_parser():parse(true)
vim.api.nvim_win_set_cursor(0,{1,#vim.api.nvim_get_current_line()-1})
vim.api.nvim_feedkeys('a>'..vim.api.nvim_replace_termcodes('<Esc>',true,false,true),'xt',false)
vim.wait(200)
result.autotag_output=vim.api.nvim_get_current_line()
result.autotag_closed=result.autotag_output:find('</div>',1,true)~=nil
local context_lines={'local function outer()'}
for i=1,70 do context_lines[#context_lines+1]='  local value'..i..' = '..i end
context_lines[#context_lines+1]='end'
local context_path=vim.env.NVIM_TS_ROOT..'/context.lua'
vim.fn.writefile(context_lines,context_path)
vim.cmd.edit({args={context_path},bang=true})
vim.treesitter.start()
vim.treesitter.get_parser():parse(true)
vim.api.nvim_win_set_cursor(0,{60,2})
vim.cmd('normal! zt')
vim.cmd.redraw()
result.context_view=vim.fn.winsaveview()
local context_ranges,context_text=require('treesitter-context.context').get(vim.api.nvim_get_current_win())
result.context_detected=context_text and #context_text>0 or false
vim.api.nvim_exec_autocmds('CursorMoved',{buffer=0})
result.context_window=vim.wait(1000,function()
  for _,win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative~='' then
      local lines=vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win),0,-1,false)
      if table.concat(lines,'\n'):find('local function outer()',1,true) then return true end
    end
  end
  return false
end,20)
vim.cmd.enew({bang=true})
vim.api.nvim_buf_set_name(0,vim.env.NVIM_TS_ROOT..'/growth.js')
vim.bo.filetype='javascript'
vim.api.nvim_buf_set_lines(0,0,-1,false,{'const value = 1;'})
vim.treesitter.start()
vim.api.nvim_buf_set_lines(0,0,-1,false,{string.rep('x',21000)})
vim.api.nvim_exec_autocmds('TextChanged',{buffer=0})
result.large_line_protected=vim.b.large_file==true and vim.bo.filetype=='bigfile'
local rocks=data..'/lazy-rocks/rest.nvim'
package.path=rocks..'/share/lua/5.1/?.lua;'..rocks..'/share/lua/5.1/?/init.lua;'..package.path
package.cpath=rocks..'/lib/lua/5.1/?'..(windows and '.dll' or '.so')..';'..package.cpath
vim.opt.rtp:append(data..'/lazy/rest.nvim')
vim.cmd('runtime plugin/rest-nvim.lua')
require('rest_compat').setup()
vim.cmd.enew({bang=true})
vim.bo.filetype='http'
vim.api.nvim_buf_set_lines(0,0,-1,false,{'GET http://127.0.0.1:'..vim.env.NVIM_TS_PORT..'/candidate'})
vim.api.nvim_win_set_cursor(0,{1,0})
local response
vim.api.nvim_create_autocmd('User',{pattern='RestResponse',callback=function()response=vim.deepcopy(_G.rest_response)end})
local request_ok,request_err=pcall(function()
  vim.cmd('Rest run')
  assert(vim.wait(10000,function()return response~=nil end,20),'HTTP timed out')
  assert(response.status.code==200,vim.inspect(response.status))
  assert(response.body=='candidate parser request passed','unexpected response')
end)
result.http_request={ok=request_ok,error=not request_ok and tostring(request_err) or nil}
vim.fn.writefile({vim.json.encode(result)},vim.env.NVIM_TS_OUTPUT)
vim.cmd('qa!')
'''

def main():
    config=Path(__file__).resolve().parents[1]
    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            body=b'candidate parser request passed'
            self.send_response(200);self.send_header('Content-Length',str(len(body)));self.end_headers();self.wfile.write(body)
        def log_message(self,*args):pass
    server=http.server.ThreadingHTTPServer(('127.0.0.1',0),Handler)
    threading.Thread(target=server.serve_forever,daemon=True).start()
    with tempfile.TemporaryDirectory(prefix='nvim-ts-eval-') as directory:
        root=Path(directory);probe=root/'probe.lua';probe.write_text(LUA,encoding='utf-8')
        output=root/'output.json'
        env=os.environ.copy();env.update(NVIM_TS_ROOT=root.as_posix(),NVIM_TS_OUTPUT=output.as_posix(),NVIM_TS_CONFIG=config.as_posix(),NVIM_TS_PORT=str(server.server_address[1]))
        process=run_nvim(['nvim','--clean','--headless','-n','-S',str(probe)],cwd=root,env=env,timeout=230)
        assert process.returncode==0,process.stdout
        result=json.loads(output.read_text(encoding='utf-8'))
        result['build_log']=process.stdout
    server.shutdown();server.server_close()
    target=config/'docs/evaluations/treesitter-comparison.json'
    target.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
