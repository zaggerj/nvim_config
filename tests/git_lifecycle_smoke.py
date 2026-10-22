"""Rapid buffer changes and writes must not leave inherited Git process handles."""
import tempfile
from pathlib import Path
from nvim_process import run_nvim


def main():
    with tempfile.TemporaryDirectory(prefix="nvim-git-lifecycle-", ignore_cleanup_errors=True) as d:
        root = Path(d)
        (root / "a.go").write_text("package main\n")
        (root / "b.go").write_text("package main\n")
        probe = root / "probe.lua"
        probe.write_text("""
vim.defer_fn(function()
  for i=1,15 do
    vim.cmd.edit(i%2==0 and 'a.go' or 'b.go')
    vim.api.nvim_exec_autocmds('BufWritePost',{buffer=0})
  end
  print('EXIT_READY')
  vim.cmd('qa!')
end,300)
""")
        for _ in range(3):
            result = run_nvim(['nvim','--headless','-n','--cmd',
                              'let g:coc_start_at_startup=0','a.go','+luafile '+str(probe)],
                             cwd=root,timeout=6)
            assert result.returncode == 0 and 'EXIT_READY' in result.stdout, result.stdout
        print('PASS rapid buffer/write lifecycle, process exit and output handle cleanup')


if __name__ == '__main__':
    main()
