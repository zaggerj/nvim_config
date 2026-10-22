"""Exercise real Coc activation, shared state and the screenshot's TLS failure path.

Run after deployment: python3 tests/coc_smoke.py
Launch this command from each supported shell; no extension/network mocks are used.
"""
import os
from pathlib import Path
import subprocess
import tempfile


LUA = r'''
local restarted=false
local function finish(ok, message)
  vim.fn.writefile({vim.json.encode({ok=ok, message=message})},vim.env.NVIM_COC_TEST .. '/result.json')
  vim.cmd(ok and 'qa!' or 'cquit 1')
end
local function check()
  if vim.fn.exists('*CocActionAsync') ~= 1 then finish(false,'Coc did not start'); return end
  vim.fn.CocActionAsync('extensionStats',function(err,stats)
    local ok,message=pcall(function()
      assert(err==vim.NIL or err==nil,vim.inspect(err))
      local expected=vim.fs.normalize(vim.fn.stdpath('data') .. '/coc'):lower()
      local actual=vim.fs.normalize(vim.fn['coc#util#get_data_home']()):lower()
      assert(actual==expected,'Coc state split: ' .. actual .. ' vs ' .. expected)
      assert(vim.tbl_isempty(vim.g.coc_global_extensions),'Unexpected startup auto-install list')
      local found=false
      for _,s in ipairs(stats) do
        if s.id=='coc-tabnine' then assert(s.state=='disabled','Retired Tabnine was activated') end
        if s.id=='coc-tsserver' then found=true end
      end
      assert(found,'Coc TypeScript extension was not provisioned')
      return 'shared Coc data, provisioned extensions and retired Tabnine policy'
    end)
    if ok and not restarted then
      restarted=true
      vim.cmd('CocRestart')
      vim.defer_fn(check,4000)
    else
      finish(ok,tostring(message) .. '; CocRestart rechecked')
    end
  end)
end
vim.defer_fn(check,8000)
vim.defer_fn(function() finish(false,'Coc activation/restart timed out') end,18000)
'''


def main():
    import json
    with tempfile.TemporaryDirectory(prefix="nvim-coc-smoke-") as directory:
        root = Path(directory)
        (root / "verify.lua").write_text(LUA, encoding="utf-8")
        (root / "sample.ts").write_text('const sharedState = true;\n', encoding='utf-8')
        env = os.environ.copy()
        env["NVIM_COC_TEST"] = root.as_posix()
        env["NVIM_COC_LOG_FILE"] = (root / "coc.log").as_posix()
        result = subprocess.run(["nvim", "--headless", "-n", "sample.ts",
                                 "+lua dofile(vim.env.NVIM_COC_TEST .. '/verify.lua')"],
                                cwd=root, env=env, capture_output=True, text=True, timeout=22)
        report = json.loads((root / "result.json").read_text(encoding="utf-8"))
        captured = result.stdout + result.stderr
        log = (root / "coc.log").read_text(encoding="utf-8") if (root / "coc.log").exists() else ""
        assert report["ok"], report["message"] + "\n" + captured
        assert result.returncode == 0, captured
        assert "UnhandledRejection" not in captured, captured
        assert "secure TLS connection was established" not in log + captured, log + captured
        print("PASS " + report["message"] + "; no TLS rejection")


if __name__ == "__main__":
    main()
