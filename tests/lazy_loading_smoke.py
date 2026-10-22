"""Empty and plain-text buffers must not load unrelated code consumers."""
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
vim.defer_fn(function()
 local ok,err=xpcall(function()
  local plugins=require('lazy.core.config').plugins
  for _,name in ipairs({'coc.nvim','nvim-treesitter','nvim-ufo','neorg','nvim-nio','lua-utils.nvim','pathlib.nvim','nui.nvim','telescope.nvim','rest.nvim','copilot.vim'}) do
   assert(not plugins[name] or not plugins[name]._.loaded, 'Loaded unrelated component: '..name)
  end
  vim.cmd('Telescope buffers')
  assert(plugins['telescope.nvim']._.loaded,'Telescope command did not lazy-load')
  print('PASS isolated empty/text buffers and on-demand Telescope')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,600)
'''

def main():
 with tempfile.TemporaryDirectory(prefix='nvim-lazy-') as directory:
  root=Path(directory); script=root/'verify.lua'; script.write_text(LUA,encoding='utf-8')
  plain=root/'notes.txt'; plain.write_text('plain text\n',encoding='utf-8')
  for target in ([], [str(plain)]):
   result=run_nvim(['nvim','--headless','-n',*target,'+luafile '+str(script)],cwd=root,timeout=12)
   assert result.returncode==0,result.stdout
   print(result.stdout)

if __name__=='__main__':main()
