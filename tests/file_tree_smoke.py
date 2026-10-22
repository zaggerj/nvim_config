"""File-tree public actions operate on an isolated project with spaces."""
from pathlib import Path
import tempfile
from nvim_process import run_nvim
LUA=r"""
vim.defer_fn(function()
 local ok,err=xpcall(function()
  vim.cmd('NvimTreeFindFileToggle')
  local api=require('nvim-tree.api')
  assert(api.tree.is_visible(),'tree not visible')
  api.tree.find_file({buf=vim.fn.getcwd()..'/sample.txt',open=true,focus=true})
  local node=api.tree.get_node_under_cursor()
  assert(node and node.name=='sample.txt','cannot locate file')
  api.node.open.vertical(node)
  assert(vim.api.nvim_buf_get_name(0):find('sample.txt',1,true),'split did not open file')
  api.tree.focus()
  api.tree.toggle_hidden_filter()
  api.tree.reload()
  local input=vim.ui.input
  vim.ui.input=function(_,cb) cb(vim.fn.getcwd()..'/created.txt') end
  api.fs.create()
  assert(vim.fn.filereadable('created.txt')==1,'create failed')
  api.tree.find_file({buf=vim.fn.getcwd()..'/created.txt',open=true,focus=true})
  node=api.tree.get_node_under_cursor()
  vim.ui.input=function(_,cb) cb(vim.fn.getcwd()..'/renamed.txt') end
  api.fs.rename_full(node)
  assert(vim.fn.filereadable('renamed.txt')==1,'rename failed')
  vim.ui.input=function(_,cb) cb(nil) end
  api.tree.find_file({buf=vim.fn.getcwd()..'/renamed.txt',open=true,focus=true})
  node=api.tree.get_node_under_cursor()
  api.fs.remove(node)
  assert(vim.fn.filereadable('renamed.txt')==1,'cancel removed file')
  vim.ui.input=input
  api.tree.close()
  assert(not api.tree.is_visible(),'close failed')
  print('PASS tree locate/split/hidden/create/rename/cancel/close')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,300)
"""
def main():
 with tempfile.TemporaryDirectory(prefix='nvim tree ') as d:
  root=Path(d);(root/'sample.txt').write_text('hello\n');(root/'.hidden').write_text('hidden\n')
  p=root/'probe.lua';p.write_text(LUA)
  r=run_nvim(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(p)],cwd=root,timeout=12)
  assert r.returncode==0,r.stdout
  print(r.stdout)
if __name__=='__main__':main()
