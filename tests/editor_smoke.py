"""Check configured language highlighting, real blame and large-file guards."""
import os
from pathlib import Path
import subprocess
import tempfile


LUA = r'''
local root=vim.env.NVIM_EDITOR_TEST
local function check()
  vim.cmd.cd(root)
  local cases={
    {'sample.js','javascript'}, {'sample.ts','typescript'},
    {'sample.jsx','javascriptreact'}, {'sample.tsx','typescriptreact'},
    {'vue2.vue','vue'}, {'vue3.vue','vue'}, {'sample.go','go'}, {'sample.py','python'},
  }
  for _,case in ipairs(cases) do
    vim.cmd.edit(case[1])
    local buf=vim.api.nvim_get_current_buf()
    assert(vim.bo.filetype==case[2],case[1]..': filetype mismatch')
    assert(vim.wait(3000,function() return vim.treesitter.highlighter.active[buf]~=nil end,20),case[1]..': no highlighter')
    local parser=assert(vim.treesitter.get_parser(buf))
    local trees=parser:parse()
    local query=assert(vim.treesitter.query.get(parser:lang(),'highlights'))
    local count=0
    for _ in query:iter_captures(trees[1]:root(),buf,0,-1) do count=count+1 end
    assert(count>0,case[1]..': no syntax captures')
    print('PASS highlight '..case[1])
  end
  vim.api.nvim_win_set_cursor(0,{1,0})
  assert(vim.wait(6000,function() return vim.b.gitsigns_blame_line_dict~=nil end,25),'No real Git blame')
  assert(vim.b.gitsigns_blame_line_dict.author=='Neovim Regression','Unexpected blame author')
  print('PASS real Git blame')
  for _,name in ipairs({'bytes.ts','lines.ts','longline.ts'}) do
    vim.cmd.edit(name)
    local buf=vim.api.nvim_get_current_buf()
    assert(vim.b.large_file and vim.bo.filetype=='bigfile',name..': guard missing')
    assert(vim.b.coc_enabled==0 and vim.b.copilot_enabled==false,name..': services enabled')
    assert(not vim.treesitter.highlighter.active[buf],name..': highlighter attached')
    print('PASS large-file '..name)
  end
end
vim.defer_fn(function()
  local ok,err=pcall(check)
  if not ok then io.stderr:write(tostring(err)..'\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,100)
'''


def main():
    with tempfile.TemporaryDirectory(prefix='nvim-editor-smoke-') as directory:
        root=Path(directory)
        samples={
            'sample.js':'const value = 42;\n', 'sample.ts':'const value: number = 42;\n',
            'sample.jsx':'const View = () => <div>Hello</div>;\n',
            'sample.tsx':'const View = (): JSX.Element => <div>Hello</div>;\n',
            'vue2.vue':'<template><div>{{ msg }}</div></template>\n<script>export default { data() { return {msg: "hello"} } }</script>\n',
            'vue3.vue':'<template><div>{{ msg }}</div></template>\n<script setup lang="ts">const msg: string = "hello"</script>\n',
            'sample.go':'package main\nfunc main() {}\n', 'sample.py':'value = 42\n',
        }
        for name,content in samples.items(): (root/name).write_text(content,encoding='utf-8')
        def git(*args):
            subprocess.run(['git','-C',str(root),*args],check=True,capture_output=True,timeout=20)
        git('init','-q')
        git('add','.')
        git('-c','user.name=Neovim Regression','-c','user.email=nvim-test@example.invalid',
            '-c','commit.gpgsign=false','commit','-qm','Fixture')
        (root/'bytes.ts').write_text(('// padding\n'*100000),encoding='utf-8')
        (root/'lines.ts').write_text('\n'*20002,encoding='utf-8')
        (root/'longline.ts').write_text('x'*20001+'\n',encoding='utf-8')
        (root/'verify.lua').write_text(LUA,encoding='utf-8')
        env=os.environ.copy()
        env['NVIM_EDITOR_TEST']=root.as_posix()
        subprocess.run(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0',
                        '+lua dofile(vim.env.NVIM_EDITOR_TEST .. "/verify.lua")'],
                       cwd=root,env=env,check=True,timeout=40)


if __name__=='__main__':
    main()
