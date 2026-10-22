"""The command palette keeps custom actions and persistent usage ordering."""
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim
LUA=r"""
vim.defer_fn(function()
 local ok,err=xpcall(function()
  vim.cmd('CommandPalette')
  assert(vim.wait(2000,function() local p=require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf()); return p and p.manager and p.manager:num_results()>5 end,20),'palette not ready')
  local state=require('telescope.actions.state')
  local picker=state.get_current_picker(vim.api.nvim_get_current_buf())
  local entries={}
  for e in picker.manager:iter() do entries[e.value.command]=e end
  for _,command in ipairs({'Lazy','Lazy sync','Lazy update','NvimTreeFindFileToggle','Vista!!','Tutor zh','Tutor en'}) do
   assert(entries[command],'custom action lost: '..command)
  end
  assert(entries['PaletteFixture'],'user command missing')
  require('telescope.actions').close(picker.prompt_bufnr)
  vim.cmd('CommandPalette PaletteFixture')
  assert(vim.g.palette_fixture==1,'palette selection did not execute')
  vim.cmd('CommandPalette')
  assert(vim.wait(2000,function() local p=require('telescope.actions.state').get_current_picker(vim.api.nvim_get_current_buf()); return p and p.manager and p.manager:num_results()>5 end,20),'palette not ready')
  picker=state.get_current_picker(vim.api.nvim_get_current_buf())
  assert(picker.manager:get_entry(1).value.command=='PaletteFixture','usage ordering not persisted')
  require('telescope.actions').close(picker.prompt_bufnr)
  assert(vim.fn.filereadable(vim.env.NVIM_PALETTE_DATA..'/usage.json')==1,'usage data not saved')
  print('PASS command palette actions, execution and persistent usage ranking')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,400)
"""
def main():
 with tempfile.TemporaryDirectory(prefix='nvim-palette-') as d:
  root=Path(d);p=root/'verify.lua';p.write_text(LUA,encoding='utf-8')
  env=os.environ.copy();env['NVIM_PALETTE_DATA']=(root/'usage').as_posix()
  r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0',
   '--cmd',"command! PaletteFixture let g:palette_fixture = get(g:, 'palette_fixture', 0) + 1",'+luafile '+str(p)],env=env,timeout=12)
  assert r.returncode==0,r.stdout
  print(r.stdout)
  # A second Neovim process reads the same persisted history.
  r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0',
   '--cmd',"command! PaletteFixture let g:palette_fixture = get(g:, 'palette_fixture', 0) + 1",'+luafile '+str(p)],env=env,timeout=12)
  assert r.returncode==0,r.stdout
  print('PASS usage survives a fresh Neovim process')
if __name__=='__main__':main()
