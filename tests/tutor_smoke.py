"""Chinese and English tutorials keep edits and position across reopening."""
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim
LUA=r"""
vim.defer_fn(function()
 local ok,err=xpcall(function()
  vim.cmd('Tutor zh')
  assert(vim.bo.filetype=='tutor','Chinese tutorial did not open')
  assert(table.concat(vim.api.nvim_buf_get_lines(0,0,30,false),' '):find('教程',1,true),'not Chinese text')
  vim.api.nvim_buf_set_lines(0,4,5,false,{'my saved exercise'})
  vim.api.nvim_win_set_cursor(0,{12,0})
  vim.cmd('Tutor en')
  assert(vim.bo.filetype=='tutor','English tutorial did not open')
  assert(table.concat(vim.api.nvim_buf_get_lines(0,0,30,false),' '):find('Tutor',1,true),'not English text')
  vim.cmd('Tutor zh')
  assert(vim.api.nvim_buf_get_lines(0,4,5,false)[1]=='my saved exercise','exercise progress lost')
  assert(vim.api.nvim_win_get_cursor(0)[1]==12,'position lost')
  print('PASS Chinese/English builtin Tutor and preserved progress')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,300)
"""
def main():
 with tempfile.TemporaryDirectory(prefix='nvim-tutor-') as d:
  p=Path(d)/'verify.lua';p.write_text(LUA,encoding='utf-8')
  env=os.environ.copy();env['NVIM_TUTOR_TEST_DATA']=(Path(d)/'progress').as_posix()
  r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(p)],env=env,timeout=12)
  assert r.returncode==0,r.stdout
  print(r.stdout)
if __name__=='__main__':main()
