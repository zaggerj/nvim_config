"""通过真实终端任务和临时Git项目验证安全按键。"""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

TERMINAL = r'''
local root=vim.env.NVIM_KEYS_TEST
local function fail(err)
  io.stderr:write(tostring(err).."\n")
  vim.cmd('cquit 1')
end
local function step(delay, fn)
  vim.defer_fn(function()
    local ok,err=xpcall(fn,debug.traceback)
    if not ok then fail(err) end
  end,delay)
end
vim.schedule(function()
  vim.cmd.enew()
  local job=require('platform').open_terminal({argv={vim.env.NVIM_KEYS_PYTHON,'-u',root..'/echo.py',root..'/received.txt'},split=vim.env.NVIM_KEYS_LAYOUT=='split'})
  vim.cmd.startinsert()
  step(350,function()
    assert(vim.fn.jobwait({job},0)[1]==-1,'fixture exited '..job..' status '..vim.fn.jobwait({job},0)[1]..': '..table.concat(vim.api.nvim_buf_get_lines(0,0,-1,false),'|'))
    assert(vim.fn.mode()=='t','terminal did not enter input mode')
    vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Esc>',true,false,true))
    step(200,function()
      assert(vim.fn.mode()=='n','Esc did not leave terminal input')
      assert(vim.fn.jobwait({job},0)[1]==-1,'Esc terminated foreground program')
      assert(vim.fn.readfile(root..'/received.txt')[1]==nil,'Esc sent text to foreground program')
      vim.api.nvim_input('i')
      step(100,function()
        vim.api.nvim_input('ping'..vim.api.nvim_replace_termcodes('<CR>',true,false,true))
        step(150,function()
          assert(vim.fn.readfile(root..'/received.txt')[1]=='ping','terminal cannot resume input')
          vim.api.nvim_input('fj')
          step(150,function()
            assert(vim.fn.mode()=='n','fj did not leave terminal input')
            assert(vim.fn.jobwait({job},0)[1]==-1,'fj terminated foreground program')
            vim.fn.jobstop(job)
            print('PASS terminal '..vim.env.NVIM_KEYS_LAYOUT..' Esc/fj preserve foreground task and resumed input')
            vim.cmd('qa!')
          end)
        end)
      end)
    end)
  end)
end)
'''


IDLE_TERMINAL = r'''
vim.schedule(function()
  local opts={split=false}
  if vim.env.NVIM_KEYS_CLEAN_SHELL=='1' then
    local argv=require('platform').shell_argv()
    local name=vim.fn.fnamemodify(argv[1],':t'):lower()
    if name:find('zsh',1,true) then opts.argv={argv[1],'-f','-i'} end
    if name:find('bash',1,true) then opts.argv={argv[1],'--noprofile','--norc','-i'} end
  end
  local job=require('platform').open_terminal(opts)
  local buf=vim.api.nvim_get_current_buf()
  vim.defer_fn(function()
    local ok,err=xpcall(function()
      assert(vim.fn.jobwait({job},0)[1]==-1,'idle shell exited before test')
      vim.api.nvim_input(vim.api.nvim_replace_termcodes('<Esc>',true,false,true))
      vim.defer_fn(function()
        local ok2,err2=xpcall(function()
          assert(vim.fn.mode()=='n','idle shell Esc did not leave input')
          assert(vim.fn.jobwait({job},0)[1]==-1,'idle shell was terminated by Esc')
          vim.api.nvim_input('i')
          vim.defer_fn(function()
            local received=vim.env.NVIM_KEYS_TEST..'/nvim-shell-response.txt'
            vim.api.nvim_input('echo NVIM_SHELL_STILL_ALIVE > "'..received..'"'..vim.api.nvim_replace_termcodes('<CR>',true,false,true))
            vim.defer_fn(function()
              local ok3,err3=xpcall(function()
                assert(vim.fn.jobwait({job},0)[1]==-1,'idle shell cannot resume')
                local received=vim.env.NVIM_KEYS_TEST..'/nvim-shell-response.txt'
                assert(vim.wait(30000,function()
                  -- Windows PowerShell 5.1 redirection writes UTF-16LE; readfile represents NUL as NL.
                  return vim.fn.filereadable(received)==1 and table.concat(vim.fn.readfile(received),''):gsub('[%z\n]',''):find('NVIM_SHELL_STILL_ALIVE',1,true)~=nil
                end,50),'shell did not execute resumed input: '..table.concat(vim.api.nvim_buf_get_lines(buf,0,-1,false),'\n'))
                vim.fn.jobstop(job)
                print('PASS idle shell Esc preserves shell and resumed command')
              end,debug.traceback)
              if not ok3 then io.stderr:write(err3..'\n');vim.fn.jobstop(job) end
              vim.cmd(ok3 and 'qa!' or 'cquit 1')
            end,450)
          end,100)
        end,debug.traceback)
        if not ok2 then io.stderr:write(err2..'\n');vim.fn.jobstop(job);vim.cmd('cquit 1') end
      end,150)
    end,debug.traceback)
    if not ok then io.stderr:write(err..'\n');vim.fn.jobstop(job);vim.cmd('cquit 1') end
  end,700)
end)
'''


GIT = r'''
local function verify()
  vim.cmd.cd(vim.env.NVIM_KEYS_TEST)
  vim.cmd.edit('sample.txt')
  assert(vim.wait(5000,function()
    local ok,gs=pcall(require,'gitsigns')
    return ok and gs.get_hunks() and #gs.get_hunks()==2
  end,25),'two Git hunks did not attach')
  local before=vim.api.nvim_buf_get_lines(0,0,-1,false)
  vim.api.nvim_win_set_cursor(0,{1,0})
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(']c',true,false,true),'xt',false)
  assert(vim.wait(1500,function() return vim.fn.line('.')==3 end,20),']c did not navigate to first hunk')
  assert(vim.deep_equal(before,vim.api.nvim_buf_get_lines(0,0,-1,false)),']c changed file contents')
  vim.api.nvim_feedkeys(']c','xt',false)
  assert(vim.wait(1500,function() return vim.fn.line('.')==50 end,20),']c did not navigate to next hunk')
  vim.api.nvim_feedkeys('[c','xt',false)
  assert(vim.wait(1500,function() return vim.fn.line('.')==3 end,20),'[c did not navigate backwards')
  assert(vim.deep_equal(before,vim.api.nvim_buf_get_lines(0,0,-1,false)),'navigation changed contents')
  print('PASS Git hunk navigation leaves contents unchanged')
  local original=vim.api.nvim_get_current_win()
  vim.api.nvim_feedkeys(' gd','xt',false)
  assert(vim.wait(2000,function() return #vim.api.nvim_tabpage_list_wins(0)==2 end,20),'Git diff key did not open real diff')
  vim.api.nvim_set_current_win(original)
  vim.cmd.diffupdate()
  vim.api.nvim_win_set_cursor(0,{1,0})
  vim.api.nvim_feedkeys(']c','xt',false)
  assert(vim.fn.line('.')==3,'native diff forward navigation failed')
  vim.api.nvim_win_set_cursor(0,{60,0})
  vim.api.nvim_feedkeys('[c','xt',false)
  assert(vim.fn.line('.')==50,'native diff backward navigation failed')
  assert(vim.deep_equal(before,vim.api.nvim_buf_get_lines(0,0,-1,false)),'native diff navigation changed contents')
  for _,win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win~=original then vim.api.nvim_win_close(win,true) end
  end
  vim.cmd('diffoff!')
  print('PASS native diff navigation leaves contents unchanged')
  local stage_error
  local function staged()
    local out=vim.system({'git','diff','--cached','--numstat'},{text=true}):wait(3000)
    -- gitsigns正在异步替换index时，Windows读者可能暂时无法打开它。
    -- 未能读取不是已暂存/未暂存；在现有就绪期限内继续观察真实Git结果。
    if out.code~=0 then stage_error=out.stderr; return nil end
    stage_error=nil
    return out.stdout~=''
  end
  vim.api.nvim_feedkeys(' hS','xt',false)
  local stage_ready=vim.wait(2000,function() return staged()==true end,30)
  assert(stage_ready,'explicit stage-buffer key did not stage changes: '..tostring(stage_error))
  vim.api.nvim_feedkeys(' hU','xt',false)
  local unstage_ready=vim.wait(2000,function() return staged()==false end,30)
  assert(unstage_ready,'explicit unstage-buffer key did not unstage: '..tostring(stage_error))
  assert(vim.wait(2500,function() local h=require('gitsigns').get_hunks(); return h and #h==2 end,20),'unstaged hunks did not become ready')
  local pending
  -- User choice is the external UI boundary; no Git/internal action is mocked.
  local original_select=vim.ui.select
  vim.ui.select=function(items,options,choose) pending={items=items,choose=choose} end
  vim.api.nvim_feedkeys(' hR','xt',false)
  assert(pending,'reset key did not request confirmation')
  pending.choose(pending.items[1],1)
  assert(vim.deep_equal(before,vim.api.nvim_buf_get_lines(0,0,-1,false)),'cancelled reset changed contents')
  assert(staged()==false,'cancelled reset changed staging: '..tostring(stage_error))
  pending=nil
  vim.api.nvim_feedkeys(' hR','xt',false)
  assert(pending,'reset key lost confirmation')
  pending.choose(pending.items[2],2)
  assert(vim.wait(2000,function() return vim.api.nvim_buf_get_lines(0,2,3,false)[1]=='line 3' end,20),'confirmed reset did not restore contents')
  vim.ui.select=original_select
  assert(staged()==false,'reset changed staging: '..tostring(stage_error))
  vim.api.nvim_feedkeys(' gd','xt',false)
  assert(vim.wait(2000,function() return #vim.api.nvim_tabpage_list_wins(0)==2 end,20),'Git diff key did not open real diff')
  assert(vim.wo.diff,'Git diff key did not enable diff mode')
  print('PASS explicit staging, cancelling/confirming reset and real Git diff entry')
end
vim.defer_fn(function()
  local ok,err=xpcall(verify,debug.traceback)
  if not ok then io.stderr:write(tostring(err).."\n") end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,200)
'''


LARGE_KEYS = r'''
vim.defer_fn(function()
  local ok,err=xpcall(function()
    assert(vim.b.large_file,'large fixture not protected')
    local start=vim.fn.line('.')
    vim.v.errmsg=''
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-f>',true,false,true),'xt',false)
    assert(vim.v.errmsg=='','C-f failed before Coc loaded: '..vim.v.errmsg)
    assert(vim.fn.line('.')>start,'C-f did not page forward')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-b>',true,false,true),'xt',false)
    assert(vim.v.errmsg=='','C-b failed before Coc loaded: '..vim.v.errmsg)
    print('PASS bigfile paging works without Coc')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i<CR><Tab><S-Tab><Esc>',true,false,true),'xt',false)
    assert(vim.v.errmsg=='','largefile editing failed before Coc loaded: '..vim.v.errmsg)
    print('PASS bigfile Enter/Tab/Shift-Tab work without Coc')
  end,debug.traceback)
  if not ok then io.stderr:write(tostring(err).."\n") end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,200)
'''


LAYOUT = r'''
vim.defer_fn(function()
  local ok,err=xpcall(function()
    vim.cmd.split()
    local height=vim.api.nvim_win_get_height(0)
    vim.api.nvim_feedkeys(' w+','xt',false)
    assert(vim.api.nvim_win_get_height(0)>height,'window-height prefix does not resize')
    vim.cmd.vsplit()
    local width=vim.api.nvim_win_get_width(0)
    vim.api.nvim_feedkeys(' w>','xt',false)
    assert(vim.api.nvim_win_get_width(0)>width,'window-width prefix does not resize')
    assert(vim.fn.maparg(' b','n')=='','buffer group remains shadowed by resize action')
    assert(vim.fn.maparg(' w','n')=='','window group remains shadowed by resize action')
    assert(vim.fn.maparg(' n','n')=='','notes group remains shadowed by nohighlight action')
    vim.fn.setreg('/','line')
    vim.cmd('set hlsearch')
    vim.api.nvim_feedkeys(' sn','xt',false)
    assert(vim.v.hlsearch==0,'explicit nohighlight key failed')
    assert(vim.fn.maparg('gD','n')=='<Plug>(coc-type-definition)','type definition key missing')
    assert(vim.fn.maparg('<C-]>','n')=='<Plug>(coc-definition)','tag-style definition key missing')
    print('PASS grouped resize/nohighlight and unified navigation entries')
  end,debug.traceback)
  if not ok then io.stderr:write(tostring(err).."\n") end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,200)
'''


def run_lua(root, lua, layout="current", initial="sample.txt", tui=False):
    script=root/'verify.lua'
    script.write_text(lua,encoding='utf-8')
    env=os.environ.copy()
    env.update(NVIM_KEYS_TEST=root.as_posix(), NVIM_KEYS_PYTHON=sys.executable, NVIM_KEYS_LAYOUT=layout)
    command=['nvim','-n','--cmd','let g:coc_start_at_startup=0',str(root/initial),
             '+lua dofile(vim.env.NVIM_KEYS_TEST .. "/verify.lua")']
    if tui:
        import psutil,time
        process=subprocess.Popen(command,cwd=root,env=env)
        parent=psutil.Process(process.pid)
        descendants={}
        deadline=time.monotonic()+40
        try:
            while process.poll() is None:
                try:
                    for child in parent.children(recursive=True):
                        descendants[(child.pid,child.create_time())]=child
                except psutil.Error: pass
                if time.monotonic()>deadline:
                    raise AssertionError('TUI shell check timed out after 40s')
                time.sleep(.02)
            assert process.returncode==0,'TUI shell check failed'
        finally:
            for child in descendants.values():
                try:
                    if child.is_running():child.kill()
                except psutil.Error:pass
            if process.poll() is None:process.kill()
            process.wait(timeout=3)
        return
    command.insert(1,'--headless')
    with (root/'nvim.log').open('w',encoding='utf-8') as log:
        result=subprocess.run(command,cwd=root,env=env,stdout=log,stderr=log,timeout=15)
    output=(root/'nvim.log').read_text(encoding='utf-8')
    print(output.strip())
    assert result.returncode==0,output
    assert 'Error in ' not in output and 'E749:' not in output,output



def run_case(case):
    with tempfile.TemporaryDirectory(prefix='nvim keys ') as directory:
        root=Path(directory)
        (root/'received.txt').write_text('',encoding='utf-8')
        (root/'echo.py').write_text('import sys,time\nfrom pathlib import Path\np=Path(sys.argv[1])\nstream=open("CONIN$","r") if sys.platform=="win32" else sys.stdin\nwhile True:\n    line=stream.readline()\n    if not line:\n        time.sleep(0.02)\n        continue\n    with p.open("a",encoding="utf-8") as f: f.write(line)\n',encoding='utf-8')
        if case=='idle-tui':
            run_lua(root,IDLE_TERMINAL,tui=True)
        elif case=='git':
            def git(*args):
                subprocess.run(['git','-C',str(root),*args],check=True,capture_output=True,timeout=15)
            git('init','-q')
            git('config','core.autocrlf','false')
            lines=[f'line {i}' for i in range(1,65)]
            (root/'sample.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
            git('add','sample.txt')
            git('-c','user.name=Neovim Regression','-c','user.email=nvim-test@example.invalid',
                '-c','commit.gpgsign=false','commit','-qm','Fixture')
            lines[2]='changed first'
            lines[49]='changed second'
            (root/'sample.txt').write_text('\n'.join(lines)+'\n',encoding='utf-8')
            run_lua(root,GIT)
        elif case=='layout':
            run_lua(root,LAYOUT)
        elif case=='largekeys':
            (root/'large.ts').write_text('const value = 1;\n'*22000,encoding='utf-8')
            run_lua(root,LARGE_KEYS,initial='large.ts')
        else:
            for layout in ['current','split']:
                (root/'received.txt').write_text('',encoding='utf-8')
                run_lua(root,TERMINAL,layout=layout)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--case',choices=['all','terminal','idle-tui','git','largekeys','layout'],default='all')
    args=parser.parse_args()
    cases=['terminal','git','largekeys','layout'] if args.case=='all' else [args.case]
    for case in cases:
        run_case(case)


if __name__=='__main__':
    main()
