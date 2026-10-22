"""Verify the real bundled Copilot server and large-file guards without signing in."""
import os
from pathlib import Path
import subprocess
import tempfile


LUA = r'''
local function run()
  assert(vim.b.large_file and vim.b.copilot_enabled == false,'Large-file AI guard missing')
  assert(not require('lazy.core.config').plugins['copilot.vim']._.loaded,'AI loaded during large-file startup')
  vim.api.nvim_exec_autocmds('InsertEnter',{})
  assert(vim.fn['copilot#Enabled']()==0,'AI enabled for large file')
  assert(#vim.lsp.get_clients({name='GitHub Copilot'})==0,'Large-file startup spawned AI server')
  vim.cmd.edit(vim.env.NVIM_AI_TEST .. '/small.py')
  vim.api.nvim_exec_autocmds('InsertEnter',{})
  assert(vim.wait(10000,function()
    local clients=vim.lsp.get_clients({name='GitHub Copilot'})
    return #clients==1 and clients[1].initialized
  end,30),'Bundled Copilot server did not initialize')
  local client=vim.lsp.get_clients({name='GitHub Copilot'})[1]
  local command=table.concat(client.config.cmd,' ')
  assert(command:find('copilot-language-server/dist/language-server.js',1,true),'Not using bundled server')
  assert(not command:find('npx',1,true),'Unexpected startup npx download')
  assert(vim.g.copilot_version==false,'Floating server version configured')
  assert(vim.fn.maparg('<Tab>','i'):find('coc',1,true),'Coc Tab mapping was replaced')
  assert(vim.fn.maparg('<C-j>','i'):find('copilot#Accept',1,true),'AI acceptance mapping missing')
  assert(vim.fn['copilot#Enabled']()==1,'AI disabled for normal Python file')
  vim.api.nvim_buf_set_lines(0,0,-1,false,vim.fn['repeat']({'# growth'},20001))
  vim.api.nvim_exec_autocmds('TextChanged',{})
  assert(vim.b.copilot_enabled==false and vim.fn['copilot#Enabled']()==0,'Growth did not disable AI')
  assert(not vim.lsp.buf_is_attached(0,client.id),'Growing large file still attached to AI LSP')
  print('PASS bundled Copilot initialized; Coc keys preserved; large-file startup and growth guarded')
end
vim.defer_fn(function()
  local ok,err=xpcall(run,debug.traceback)
  if not ok then io.stderr:write(tostring(err)..'\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end,300)
'''


def main():
    with tempfile.TemporaryDirectory(prefix="nvim-ai-smoke-") as directory:
        root = Path(directory)
        (root / "large.ts").write_text("x" * (1024 * 1024 + 1), encoding="utf-8")
        (root / "small.py").write_text("def hello():\n    return 'world'\n", encoding="utf-8")
        (root / "verify.lua").write_text(LUA, encoding="utf-8")
        env = os.environ.copy()
        env["NVIM_AI_TEST"] = root.as_posix()
        subprocess.run(["nvim", "--headless", "-n", "--cmd", "let g:coc_start_at_startup=0",
                        str(root / "large.ts"), "+lua dofile(vim.env.NVIM_AI_TEST .. '/verify.lua')"],
                       env=env, check=True, timeout=20)


if __name__ == "__main__":
    main()
