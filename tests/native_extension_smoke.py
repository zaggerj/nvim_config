"""Surface native-library failures through the actual SearchHealth command."""
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r"""
local ffi=require('ffi')
if vim.env.NVIM_FZF_FAILURE=='1' then
 local load=ffi.load
 ffi.load=function(path,...)
  if tostring(path):find('libfzf',1,true) then error('fixture dynamic library unavailable') end
  return load(path,...)
 end
end
vim.defer_fn(function()
 local ok,err=xpcall(function()
  require('lazy').load({plugins={'telescope.nvim'}})
  local success,message=pcall(vim.api.nvim_exec2,'SearchHealth',{output=true})
  if vim.env.NVIM_FZF_FAILURE=='1' then
   assert(not success and tostring(message):find('fixture dynamic library unavailable',1,true),
    'missing actionable native failure: '..tostring(message))
  else
   assert(success and message.output:find('fzf native: loaded',1,true),'native extension not working')
  end
  print('PASS SearchHealth '..vim.env.NVIM_FZF_FAILURE)
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,200)
"""
def main():
 with tempfile.TemporaryDirectory(prefix='nvim-native-') as d:
  p=Path(d)/'probe.lua';p.write_text(LUA)
  for fail in ['0','1']:
   env=os.environ.copy();env['NVIM_FZF_FAILURE']=fail
   r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(p)],env=env,timeout=10)
   assert r.returncode==0,r.stdout
   print(r.stdout)
if __name__=='__main__':main()
