"""Missing parsers must not trigger installation when normal code loads."""
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
vim.defer_fn(function()
 local ok,err=xpcall(function()
  require('lazy').load({plugins={'nvim-treesitter'}})
  assert(not vim.g.unrequested_parser_install,'Plugin startup requested parser installation')
  assert(vim.fn.exists(':ParserInstall')==2,'Explicit parser deployment entry missing')
  print('PASS parser installation requires explicit command')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,400)
'''

def main():
 with tempfile.TemporaryDirectory(prefix='nvim-parser-policy-') as directory:
  script=Path(directory)/'verify.lua';script.write_text(LUA,encoding='utf-8')
  install="lua package.preload['nvim-treesitter.install']=function() return {ensure_installed=function() vim.g.unrequested_parser_install=true end,ensure_installed_sync=function() vim.g.unrequested_parser_install=true end} end"
  result=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','--cmd',install,'+luafile '+str(script)],timeout=10)
  assert result.returncode==0,result.stdout
  print(result.stdout)

if __name__=='__main__':main()
