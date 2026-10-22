"""Surround user mappings keep add/change/delete semantics."""
from pathlib import Path
import tempfile
from nvim_process import run_nvim
LUA=r"""
vim.defer_fn(function()
 local function finish(ok,err)
  if not ok then print(err) end
  vim.cmd(ok and 'qa!' or 'cquit 1')
 end
 vim.api.nvim_buf_set_lines(0,0,-1,false,{'hello'})
 vim.api.nvim_win_set_cursor(0,{1,0})
 require('lazy').load({plugins={'nvim-surround','which-key.nvim'}})
 local function keys(s) vim.api.nvim_input(vim.api.nvim_replace_termcodes(s,true,false,true)) end
 keys('ysiw)')
 vim.defer_fn(function()
  if vim.api.nvim_get_current_line()~='(hello)' then finish(false,'add surround failed: '..vim.api.nvim_get_current_line());return end
  keys('cs)"')
  vim.defer_fn(function()
   if vim.api.nvim_get_current_line()~='"hello"' then finish(false,'change surround failed');return end
   keys('ds"')
   vim.defer_fn(function()
    if vim.api.nvim_get_current_line()~='hello' then finish(false,'delete surround failed');return end
    assert(vim.fn.exists(':WhichKey')==2,'which-key command missing')
    print('PASS surround add/change/delete and which-key entry')
    finish(true)
   end,150)
  end,150)
 end,150)
end,400)
"""
def main():
 with tempfile.TemporaryDirectory(prefix='nvim-surround-') as d:
  p=Path(d)/'verify.lua';p.write_text(LUA)
  r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(p)],timeout=10)
  assert r.returncode==0,r.stdout
  print(r.stdout)
if __name__=='__main__':main()
