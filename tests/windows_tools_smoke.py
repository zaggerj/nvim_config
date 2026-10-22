"""MSYS shells can omit Windows installer paths; discover canonical tool roots."""
import os
from pathlib import Path
import shutil
import tempfile
from nvim_process import run_nvim

def main():
 if os.name!='nt':
  print('SKIP Windows installer discovery on this platform');return
 with tempfile.TemporaryDirectory(prefix='nvim-windows-tools-') as directory:
  root=Path(directory)
  node=root/'programs/nodejs/node.exe';node.parent.mkdir(parents=True);node.write_bytes(b'MZ')
  rg=root/'local/Microsoft/WinGet/Links/rg.exe';rg.parent.mkdir(parents=True);rg.write_bytes(b'MZ')
  extensionless=root/'posix/node';extensionless.parent.mkdir()
  source=Path(shutil.which('node'))
  try: os.link(source,extensionless)
  except OSError: shutil.copyfile(source,extensionless)
  script=root/'verify.lua'
  script.write_text(r'''
vim.defer_fn(function()
 local ok,err=xpcall(function()
  vim.env.ProgramFiles=vim.env.NVIM_TOOL_FIXTURE..'/programs'
  vim.env.LOCALAPPDATA=vim.env.NVIM_TOOL_FIXTURE..'/local'
  vim.env.PATH=vim.env.NVIM_TOOL_FIXTURE..'/posix;'..vim.env.SystemRoot..'/System32'
  require('bootstrap').init(vim.g.nvim_config_root)
  for tool,path in pairs({node=vim.env.ProgramFiles..'/nodejs/node.exe',rg=vim.env.LOCALAPPDATA..'/Microsoft/WinGet/Links/rg.exe'}) do
   assert(vim.fs.normalize(vim.fn.exepath(tool)):lower()==vim.fs.normalize(path):lower(),tool..' not discovered: '..vim.fn.exepath(tool)..' expected '..path..' PATH='..vim.env.PATH)
  end
  print('PASS Windows installer roots discovered with stripped MSYS PATH')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,400)
''',encoding='utf-8')
  env=os.environ.copy();env['NVIM_TOOL_FIXTURE']=root.as_posix()
  result=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(script)],env=env,timeout=10)
  assert result.returncode==0,result.stdout
  print(result.stdout)

if __name__=='__main__':main()
