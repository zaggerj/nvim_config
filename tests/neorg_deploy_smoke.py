"""Missing parser must not trigger an editor-time installation or traceback."""
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
vim.defer_fn(function()
 local ok,err=xpcall(function()
  -- Remove only parser-bearing runtime entries, keeping the real plugin code.
  require('lazy').load({plugins={'nvim-treesitter'}})
  local retained={}
  for _,path in ipairs(vim.opt.runtimepath:get()) do
   if vim.fn.filereadable(path..'/parser/norg.so')==0 then retained[#retained+1]=path end
  end
  vim.opt.runtimepath=retained
  local notes={}
  vim.notify=function(message) notes[#notes+1]=message end
  -- Invoke the configured setup boundary without lazy restoring parser-bearing dependencies.
  local plugin=require('lazy.core.config').plugins.neorg
  local opts=require('lazy.core.plugin').values(plugin,'opts',false)
  plugin.config(plugin,opts)
  assert(not package.loaded['neorg.core'],'Missing parser still initialized Neorg')
  assert(vim.wait(1000,function() return table.concat(notes,'\n'):find('provision_neorg.py',1,true)~=nil end,10),'Missing explicit deployment guidance')
  print('PASS missing parser reports deployment; no automatic install or Neorg initialization')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,400)
'''

def main():
 with tempfile.TemporaryDirectory(prefix='nvim-neorg-deploy-') as directory:
  script=Path(directory)/'verify.lua'
  script.write_text(LUA,encoding='utf-8')
  result=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(script)],timeout=10)
  print(result.stdout)
  assert result.returncode==0,result.stdout

if __name__=='__main__':main()
