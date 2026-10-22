"""Compare current Comment.nvim and stock gc in isolated real parsed buffers."""
import json
import os
import subprocess
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
local data = vim.fn.stdpath('data')
for _, plugin in ipairs({'nvim-treesitter', 'nvim-ts-context-commentstring', 'Comment.nvim'}) do
  if plugin~='nvim-treesitter' or vim.env.NVIM_COMMENT_MAIN~='1' then
    vim.opt.rtp:append(data .. '/lazy/' .. plugin)
  end
end
vim.cmd('filetype plugin on')
if vim.env.NVIM_COMMENT_MAIN=='1' then
  vim.opt.rtp:prepend(data..'/tools/evaluations/nvim-treesitter-main')
  require('nvim-treesitter').setup({install_dir=data..'/tools/evaluations/treesitter-site'})
  vim.treesitter.language.register('javascript','javascriptreact')
  vim.treesitter.language.register('tsx','typescriptreact')
else
  require('nvim-treesitter.configs').setup({highlight={enable=true}})
end
if vim.env.NVIM_COMMENT_VARIANT == 'plugin' then
  vim.cmd('runtime plugin/Comment.lua')
  require('Comment').setup({pre_hook=require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()})
end
local function run()
  local cases = {
    {name='basic.lua',lines={'local value = 1'},line=1,kind='lua'},
    {name='view.jsx',lines={'const View = () => (','  <div>','    <span>Hello</span>','  </div>',')'},line=3,kind='jsx'},
    {name='view.tsx',lines={'const View = () => (','  <div>','    <span>Hello</span>','  </div>',')'},line=3,kind='tsx'},
  }
  local vue = {'<template>','  <div>Hello</div>','</template>','<script>','const value = 1;','</script>','<style>','.a { color: red }','</style>'}
  for _, pair in ipairs({{2,'vue-template'},{5,'vue-script'},{8,'vue-style'}}) do
    cases[#cases+1]={name=pair[2]..'.vue',lines=vue,line=pair[1],kind=pair[2]}
  end
  local results = {}
  for _, case in ipairs(cases) do
    vim.cmd.enew()
    vim.api.nvim_buf_set_name(0, vim.env.NVIM_COMMENT_ROOT .. '/' .. case.name)
    vim.api.nvim_buf_set_lines(0,0,-1,false,case.lines)
    vim.bo.filetype=vim.filetype.match({filename=case.name})
    vim.treesitter.get_parser():parse(true)
    vim.api.nvim_win_set_cursor(0,{case.line, 4})
    vim.cmd('normal gcc')
    assert(vim.api.nvim_buf_get_lines(0,case.line-1,case.line,false)[1]~=case.lines[case.line], 'first toggle unchanged: '..case.kind)
    results[#results+1]={kind=case.kind,commented=vim.api.nvim_buf_get_lines(0,case.line-1,case.line,false)[1]}
    vim.cmd('normal gcc')
    assert(vim.api.nvim_buf_get_lines(0,case.line-1,case.line,false)[1]==case.lines[case.line], 'round trip changed source: '..case.kind)
    vim.bo.modified=false
  end
  vim.cmd.enew()
  vim.bo.filetype='lua'
  vim.api.nvim_buf_set_lines(0,0,-1,false,{'local a = 1','local b = 2','local c = 3'})
  vim.api.nvim_win_set_cursor(0,{1,0})
  vim.cmd('normal gcj')
  results[#results+1]={kind='motion',commented=table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'\n')}
  vim.cmd('normal Vjgc')
  results[#results+1]={kind='selection',commented=table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'\n')}
  vim.fn.writefile({vim.json.encode(results)},vim.env.NVIM_COMMENT_OUTPUT)
end
vim.defer_fn(function()
  local ok,err=xpcall(run,debug.traceback)
  if not ok then print(err) end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,100)
'''

def main():
    results = {}
    data_query=subprocess.run(['nvim','--clean','--headless','-n','+lua print(vim.fn.stdpath("data"))','+qa!'],capture_output=True,text=True,check=True,timeout=10)
    data_root=Path((data_query.stdout+data_query.stderr).strip())
    with tempfile.TemporaryDirectory(prefix='nvim-comment-eval-') as directory:
        root=Path(directory)
        probe=root/'probe.lua';probe.write_text(LUA,encoding='utf-8')
        for variant in ('plugin','native'):
            output=root/f'{variant}.json'
            env=os.environ.copy();env.update(NVIM_COMMENT_VARIANT=variant,NVIM_COMMENT_ROOT=root.as_posix(),NVIM_COMMENT_OUTPUT=output.as_posix())
            result=run_nvim(['nvim','--clean','--headless','-n','-S',str(probe)],env=env,cwd=root,timeout=20)
            assert result.returncode==0,result.stdout
            results[variant]=json.loads(output.read_text(encoding='utf-8'))
    expected = {'lua':'-- local value = 1', 'jsx':'    {/* <span>Hello</span> */}',
                'tsx':'    {/* <span>Hello</span> */}', 'vue-template':'  <!-- <div>Hello</div> -->',
                'vue-script':'// const value = 1;', 'vue-style':'/* .a { color: red } */'}
    for row in results['plugin']:
        if row['kind'] in expected:
            assert row['commented'] == expected[row['kind']], row
    results['environment'] = {'neovim': subprocess.check_output(['nvim','--version'],text=True).splitlines()[0],
        'plugins':{plugin:subprocess.check_output(['git','-C',str(data_root/('tools/evaluations/nvim-treesitter-main' if plugin=='nvim-treesitter' and os.environ.get('NVIM_COMMENT_MAIN')=='1' else 'lazy/'+plugin)),'rev-parse','HEAD'],text=True).strip()
                   for plugin in ('Comment.nvim','nvim-treesitter','nvim-ts-context-commentstring')}}
    target=Path(__file__).resolve().parents[1]/('docs/evaluations/comment-main-comparison.json' if os.environ.get('NVIM_COMMENT_MAIN')=='1' else 'docs/evaluations/comment-comparison.json')
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(results,ensure_ascii=False,indent=2))

if __name__=='__main__':main()
