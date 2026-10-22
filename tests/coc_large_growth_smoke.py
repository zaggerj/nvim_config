"""Observe the real Coc document lifecycle via a temporary public-API extension."""
import json
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim

OBSERVER = r'''
const {workspace, commands} = require('coc.nvim');
exports.activate = context => {
  const events = {opened: [], closed: [], changed: []};
  context.subscriptions.push(
    workspace.onDidOpenTextDocument(d => events.opened.push(d.uri)),
    workspace.onDidCloseTextDocument(d => events.closed.push(d.uri)),
    workspace.onDidChangeTextDocument(e => events.changed.push(e.textDocument.uri)),
    commands.registerCommand('nvimGrowth.snapshot', ids => ({
      documents: workspace.documents.map(d => ({bufnr:d.bufnr, uri:d.uri})),
      buffers: ids.map(id => {
        const doc = workspace.getDocument(id);
        return {bufnr:id, attached: !!(doc && doc.attached), lines:doc ? doc.lines.length : 0};
      }),
      events: JSON.parse(JSON.stringify(events))
    }))
  );
};
'''

LUA = r'''
local function run()
 local root=vim.env.NVIM_COC_GROWTH
 local function action(...)
  local done,result,failure=false,nil,nil
  local args={...}
  args[#args+1]=function(e,r) failure=e;result=r;done=true end
  vim.fn.CocActionAsync(unpack(args))
  assert(vim.wait(12000,function() return done end,20),'Coc action timed out')
  assert(failure==nil or failure==vim.NIL,vim.inspect(failure))
  return result
 end
 assert(vim.wait(20000,function() return vim.g.coc_service_initialized==1 end,30),'Coc not initialized')
 action('registerExtensions',root..'/observer')
 local big=vim.api.nvim_get_current_buf()
 local function snapshot() return action('runCommand','nvimGrowth.snapshot',{big}) end
 local initial=snapshot()
 assert(initial.buffers[1].attached,'First real Coc document not attached')
 local uri
 for _,document in ipairs(initial.documents) do if document.bufnr==big then uri=document.uri end end
 assert(uri,'First document URI missing')
 vim.cmd('edit '..vim.fn.fnameescape(root..'/other.ts'))
 local other=vim.api.nvim_get_current_buf()
 assert(vim.wait(20000,function() return vim.fn.CocHasProvider('definition') end,50),'Other buffer definition provider unavailable')
 local function state() return action('runCommand','nvimGrowth.snapshot',{big,other}) end
 local function poll(timeout,predicate,read)
  local deadline=vim.uv.hrtime()+timeout*1e6
  while vim.uv.hrtime()<deadline do
   if predicate((read or state)()) then return true end
   vim.wait(60,function() return false end,20)
  end
  return false
 end
 assert(poll(5000,function(s) return s.buffers[1].attached and s.buffers[2].attached end),'Two real documents not attached')
 vim.api.nvim_set_current_buf(big)
 vim.api.nvim_buf_set_lines(big,0,-1,false,{string.rep('x',30000)})
 vim.api.nvim_exec_autocmds('TextChangedI',{buffer=big})
 assert(vim.b[big].large_file,'Growth protection not active')
 assert(poll(4000,function(s) return not s.buffers[1].attached end),
   'Already attached Coc document remains tracked after large-file growth')
 local after=state()
 assert(after.buffers[1].lines==0,'Detached document retained buffer lines')
 assert(after.buffers[2].attached,'Growth detached unrelated buffer')
 local closed=0
 for _,value in ipairs(after.events.closed) do if value==uri then closed=closed+1 end end
 assert(closed==1,'Expected exactly one real document-close notification')
 local changed=#after.events.changed
 for n=1,3 do
  vim.api.nvim_buf_set_lines(big,0,-1,false,{string.rep('y',30000+n)})
  vim.api.nvim_exec_autocmds('TextChanged',{buffer=big})
  vim.api.nvim_set_current_buf(other)
  vim.api.nvim_set_current_buf(big)
 end
 vim.wait(600,function() return false end,30)
 local later=state()
 assert(not later.buffers[1].attached and later.buffers[1].lines==0,'Large buffer reattached on BufEnter')
 assert(#later.events.changed==changed,'Detached large buffer still sends document changes')
 vim.api.nvim_set_current_buf(other)
 vim.api.nvim_win_set_cursor(0,{2,2})
 local locations=action('definitions')
 assert(type(locations)=='table' and #locations>0,'Other buffer language service stopped working')
 local prior=state()
 vim.api.nvim_buf_set_lines(other,0,-1,false,{'function greet(){return 2}','greet();'})
 vim.api.nvim_exec_autocmds('TextChanged',{buffer=other})
 assert(poll(3000,function(s) return #s.events.changed>#prior.events.changed end),'Other buffer changes not tracked')
 vim.api.nvim_set_current_buf(big)
 vim.api.nvim_buf_set_lines(big,0,-1,false,{'const restored = 1;'})
 vim.cmd.write()
 vim.cmd.bwipeout()
 vim.cmd('edit '..vim.fn.fnameescape(root..'/growth.ts'))
 local reopened=vim.api.nvim_get_current_buf()
 assert(vim.bo.filetype=='typescript','Small saved file did not reopen normally')
 assert(poll(5000,function(s) return s.buffers[1].attached and s.buffers[2].attached end,
  function() return action('runCommand','nvimGrowth.snapshot',{reopened,other}) end),'Saved-small reopened buffer did not reattach alongside other buffer')
 print('PASS real Coc per-buffer close, empty lines, no subsequent changes; other buffer definition/edit; saved-small reopen reattaches')
end
vim.defer_fn(function()
 local ok,err=xpcall(run,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end,500)
'''

def main():
    with tempfile.TemporaryDirectory(prefix='nvim coc growth ') as directory:
        root=Path(directory)
        extension=root/'observer'
        extension.mkdir()
        (extension/'package.json').write_text(json.dumps({
            'name':'nvim-growth-observer','version':'1.0.0','engines':{'coc':'^0.0.82'},
            'main':'index.js','activationEvents':['*']}),encoding='utf-8')
        (extension/'index.js').write_text(OBSERVER,encoding='utf-8')
        (root/'growth.ts').write_text('const initial = 1;\n',encoding='utf-8')
        (root/'other.ts').write_text('function greet(){return 1}\ngreet();\n',encoding='utf-8')
        (root/'tsconfig.json').write_text('{"compilerOptions":{"strict":true}}',encoding='utf-8')
        script=root/'verify.lua'
        script.write_text(LUA,encoding='utf-8')
        env=os.environ.copy()
        env['NVIM_COC_GROWTH']=root.as_posix()
        result=run_nvim(['nvim','--headless','-n','growth.ts','+luafile '+str(script)],
                        cwd=root,env=env,timeout=65)
        print(result.stdout)
        assert result.returncode==0,result.stdout

if __name__=='__main__':main()
