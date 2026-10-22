"""Search through actual Telescope UI pickers over a real ignored Git fixture."""
import os
from pathlib import Path
import subprocess
import tempfile
from nvim_process import run_nvim

LUA = r"""
vim.defer_fn(function()
 local ok,err=xpcall(function()
  local builtin=require('telescope.builtin')
  local actions=require('telescope.actions')
  local state=require('telescope.actions.state')
  local function search(ignore,query,advanced,cwd)
   if advanced then vim.cmd('GrepPCRE '..query)
   elseif ignore then vim.cmd('GrepIgnored '..(query or 'NEEDLE'))
   else builtin.live_grep({default_text=query or 'NEEDLE',cwd=cwd}) end
   local picker=state.get_current_picker(vim.api.nvim_get_current_buf())
   local completed=false
   picker:register_completion_callback(function() completed=true end)
   assert(vim.wait(4000,function() return completed and picker.manager and picker.manager:num_results()>0 end,20),'search never completed')
   local paths={}
   for entry in picker.manager:iter() do paths[#paths+1]=(entry.filename or entry.value):gsub('\\','/') end
   table.sort(paths)
   actions.close(picker.prompt_bufnr)
   return table.concat(paths,'\n')
  end
  local results=search(false)
  assert(results:find('src/lib/legitimate.ts',1,true),'legitimate lib source was hidden: '..results)
  assert(not results:find('ignored/cache.ts',1,true),'default search scanned ignored file: '..results)
  assert(not results:find('node_modules',1,true),'dependency scanned')
  local ignored=search(true)
  assert(ignored:find('ignored/cache.ts',1,true),'explicit ignored search lost target: '..ignored)
  assert(search(false,'中文'):find('src/lib/legitimate.ts',1,true),'Unicode search failed')
  assert(search(false,'(?<=const )NEEDLE',true):find('src/lib/legitimate.ts',1,true),'explicit PCRE2 failed')
  local slash=search(false,'NEEDLE',false,vim.fn.getcwd():gsub('\\','/'))
  local backslash=search(false,'NEEDLE',false,vim.fn.getcwd():gsub('/','\\'))
  assert(slash==backslash,'path separator changed actual picker results')
  print('PASS default and explicit ignored searches; legitimate lib source preserved')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,500)
"""

def main():
 with tempfile.TemporaryDirectory(prefix='nvim-search-') as d:
  root=Path(d)
  for name in ['src/lib/legitimate.ts','src/rebuild/code.ts','ignored/cache.ts','node_modules/dependency.ts']:
   p=root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('const NEEDLE = "中文";\n')
  (root/'.gitignore').write_text('ignored/\nnode_modules/\nprobe.lua\n')
  subprocess.run(['git','init','-q',str(root)],check=True,timeout=15)
  probe=root/'probe.lua';probe.write_text(LUA,encoding='utf-8')
  result=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(probe)],cwd=root,timeout=15)
  assert result.returncode==0,result.stdout
  print(result.stdout)

if __name__=='__main__':main()
