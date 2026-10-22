"""Check advertised actions against live mappings, including insert-mode prefixes."""
import argparse
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
local function run()
  require('lazy').load({plugins={'which-key.nvim','nvim-surround','copilot.vim'}})
  assert(vim.wait(2000,function() return require('which-key.config').loaded end,10),'Which-key setup did not finish')
  local count = 0
  for _, item in ipairs(require('which-key.config').mappings) do
    if item.desc and not item.group and not item.preset then
      local map = vim.fn.maparg(item.lhs, item.mode or 'n', false, true)
      local native = item.lhs == 'zR' or item.lhs == 'zM'
      assert(native or map.callback or (map.rhs and map.rhs ~= ''),
        'Advertised action missing: '..item.lhs..' ('..tostring(item.desc)..')')
      count = count + 1
    end
  end
  assert(count >= 17, 'Which-key action inventory unexpectedly empty: '..count)
  -- zR/zM are native actions, verify real folding rather than requiring a mapping.
  vim.wo.foldmethod='manual'
  vim.api.nvim_buf_set_lines(0,0,-1,false,{'one','two','three'})
  vim.cmd('1,3fold')
  vim.cmd.normal('zR')
  assert(vim.fn.foldclosed(1)==-1, 'Native zR did not open fold')
  vim.cmd.normal('zM')
  assert(vim.fn.foldclosed(1)==1, 'Native zM did not close fold')
  vim.cmd.normal('zR')
  for _, key in ipairs({'<leader>b','<leader>w','<leader>n'}) do
    assert(vim.fn.maparg(key,'n')=='','Action shadows group prefix '..key)
  end
  assert(vim.fn.maparg('<C-j>','i'):find('copilot#Accept',1,true),'AI acceptance missing')
  assert(vim.fn.maparg('<C-g>','i')=='','AI dismissal delays surround insert prefix')
  assert(vim.fn.maparg('<C-g>d','i'):find('copilot#Dismiss',1,true),'AI dismissal missing')
  assert(vim.fn.maparg('<C-g>s','i')~='','Insert surround missing')
  assert(vim.fn.maparg('<C-g>S','i')~='','Insert line surround missing')
  vim.api.nvim_buf_set_lines(0,0,-1,false,{''})
  vim.api.nvim_win_set_cursor(0,{1,0})
  vim.api.nvim_input(vim.api.nvim_replace_termcodes('i<C-g>s)<Esc>',true,false,true))
  vim.defer_fn(function()
    local ok,err=pcall(function()
      assert(vim.api.nvim_get_current_line()=='()', 'Actual insert surround failed: '..vim.api.nvim_get_current_line())
      print('PASS '..count..' advertised actions; native folds; AI/surround prefixes and actual insert')
    end)
    if not ok then print(err) end
    vim.cmd(ok and 'qa!' or 'cquit 1')
  end,350)
end

local function norg()
  assert(vim.bo.filetype=='norg','Norg filetype missing')
  local neorg=require('neorg.core')
  assert(neorg.modules.get_module('core.keybinds'),'Real Neorg keybind module not loaded')
  assert(vim.g.maplocalleader==',','Neorg localleader conflicts with global leader')
  local count=0
  for _, map in ipairs(vim.api.nvim_buf_get_keymap(0,'n')) do
    if map.lhs:sub(1,1)==',' then
      assert(map.callback or (map.rhs and map.rhs~=''),'Empty Neorg mapping')
      count=count+1
    end
  end
  assert(count>0,'Neorg localleader mappings absent')
  print('PASS real Neorg loaded; '..count..' localleader actions')
  vim.cmd('qa!')
end

vim.defer_fn(function()
  local ok,err=xpcall(vim.env.NVIM_KEYMAP_CASE=='norg' and norg or run, debug.traceback)
  if not ok then print(err);vim.cmd('cquit 1') end
end,600)
'''

def main():
    import os
    parser=argparse.ArgumentParser()
    parser.add_argument('--case',choices=['all','code','go','norg'],default='all')
    args=parser.parse_args()
    cases=['code','go','norg'] if args.case=='all' else [args.case]
    with tempfile.TemporaryDirectory(prefix='nvim key inventory ') as directory:
        root=Path(directory)
        script=root/'verify.lua'
        script.write_text(LUA,encoding='utf-8')
        for case in cases:
            file=root/({'code':'sample.py','go':'sample.go','norg':'sample.norg'}[case])
            file.write_text({'code':'value = 1\n','go':'package main\n','norg':'* Notes\n'}[case],encoding='utf-8')
            env=os.environ.copy()
            env['NVIM_KEYMAP_CASE']=case
            result=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0',str(file),
                             '+luafile '+str(script)],env=env,timeout=15)
            print(case+': '+result.stdout.strip())
            assert result.returncode==0,result.stdout
            assert 'Error in ' not in result.stdout,result.stdout

if __name__=='__main__': main()
