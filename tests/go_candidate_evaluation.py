"""Exercise pinned go.nvim in an isolated Neovim without changing daily plugins."""
import argparse
import json
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim

LUA=r'''
local root=vim.env.NVIM_GO_CANDIDATE
vim.opt.runtimepath:prepend(vim.env.NVIM_GO_CANDIDATE_PLUGIN)
local exits={}
local started=vim.uv.hrtime()
require('go').setup({lsp_cfg=false,textobjects=false,lsp_codelens=false,luasnip=false,
  gofmt='gofmt',goimports='goimports',log_path=root..'/candidate.log',
  on_exit=function(event,data)
    exits[#exits+1]=type(event)=='number' and event or tonumber(data)
  end})
local setup_ms=(vim.uv.hrtime()-started)/1e6
vim.defer_fn(function()
  local ok,result=pcall(function()
    local function task(command,want_success)
      local count=#exits
      vim.cmd(command)
      assert(vim.wait(30000,function() return #exits>count end,50),command..' did not exit')
      assert((exits[#exits]==0)==want_success,command..' exit='..tostring(exits[#exits]))
    end
    vim.cmd('GoFmt')
    assert(vim.wait(5000,function() return #vim.fn.readfile(root..'/main.go')>2 end,25),'Candidate GoFmt did not update file')
    task('GoBuild',true)
    task('GoTest',true)
    vim.api.nvim_buf_set_lines(0,-1,-1,false,{'var broken string = 1'})
    vim.cmd.write()
    task('GoBuild',false)
    local errors=vim.fn.getqflist()
    if #errors==0 then errors=vim.fn.getloclist(0) end
    assert(#errors>0,'Candidate build failure lost diagnostics')
    vim.cmd('wincmd p')
    vim.cmd('edit '..vim.fn.fnameescape(root..'/main.go'))
    vim.api.nvim_buf_set_lines(0,0,-1,false,{'package main','func main() { println("ok") }'})
    vim.cmd.write()
    task('GoBuild',true)
    vim.fn.writefile({'package main','import "testing"','func TestMainFixture(t *testing.T) { t.Fatal("intentional") }'},root..'/main_test.go')
    task('GoTest',false)
    assert(#vim.lsp.get_clients()==0,'Candidate unexpectedly started another LSP')
    return {setup_ms=setup_ms,build=true,test=true,format=true,failing_test=true,failing_build=true,error_list=true,
      repaired_build=true,started_native_lsp=false,toolchain=vim.fn.system({'go','version'})}
  end)
  vim.fn.writefile({vim.json.encode({ok=ok,result=result})},root..'/result.json')
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,100)
'''


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data',required=True,type=Path)
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    plugin=args.data.resolve()/'evaluations/go.nvim'
    assert plugin.is_dir(),'Prepare pinned candidates using language_stack_evaluation.py --prepare'
    with tempfile.TemporaryDirectory(prefix='go-candidate-') as directory:
        root=Path(directory)
        (root/'go.mod').write_text('module example.com/candidate\n\ngo 1.26.0\n')
        (root/'main.go').write_text('package main\nfunc main() { println("ok") }\n')
        (root/'main_test.go').write_text('package main\nimport "testing"\nfunc TestMainFixture(t *testing.T) {}\n')
        (root/'verify.lua').write_text(LUA)
        env=os.environ.copy();env['NVIM_GO_CANDIDATE']=root.as_posix();env['NVIM_GO_CANDIDATE_PLUGIN']=plugin.as_posix();env['GOTOOLCHAIN']='local'
        proc=run_nvim(['nvim','--headless','-n','-u','NONE','main.go','+lua dofile(vim.env.NVIM_GO_CANDIDATE.."/verify.lua")'],cwd=root,env=env,timeout=100)
        report=json.loads((root/'result.json').read_text())
        if args.output:args.output.write_text(json.dumps(report,indent=2),encoding='utf-8')
        assert report['ok'] and proc.returncode==0,str(report)+'\n'+proc.stdout
        print(json.dumps(report))


if __name__=='__main__':main()
