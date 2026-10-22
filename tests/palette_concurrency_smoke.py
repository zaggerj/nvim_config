"""Concurrent independent editors must retain every command usage update."""
from concurrent.futures import ThreadPoolExecutor
import json
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA = r'''
vim.defer_fn(function()
 local ok,err=xpcall(function()
  local directory=vim.env.NVIM_PALETTE_DATA
  vim.fn.writefile({'ready'},directory..'/ready-'..vim.env.NVIM_PALETTE_WORKER)
  assert(vim.wait(5000,function()
   for i=1,4 do if vim.fn.filereadable(directory..'/ready-'..i)==0 then return false end end
   return true
  end,10),'editors did not reach barrier')
  for _=1,20 do vim.cmd('CommandPalette PaletteFixture') end
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,200)
'''

def main():
 with tempfile.TemporaryDirectory(prefix='nvim-palette-concurrent-') as directory:
  root=Path(directory); script=root/'verify.lua';script.write_text(LUA,encoding='utf-8')
  def editor(number):
   env=os.environ.copy();env['NVIM_PALETTE_DATA']=root.as_posix();env['NVIM_PALETTE_WORKER']=str(number)
   return run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0',
    '--cmd','command! PaletteFixture let g:palette_calls = get(g:, "palette_calls", 0) + 1','+luafile '+str(script)],env=env,timeout=15)
  with ThreadPoolExecutor(max_workers=4) as pool:
   results=list(pool.map(editor,range(1,5)))
  assert all(result.returncode==0 for result in results),'\n'.join(result.stdout for result in results)
  usage=json.loads((root/'usage.json').read_text(encoding='utf-8'))
  assert usage['PaletteFixture']['count']==80,usage
  assert len(usage['PaletteFixture']['timestamps'])==10
  assert not list(root.glob('*.lock'))
  print('PASS four concurrent editors preserve all 80 usage updates')

if __name__=='__main__':main()
