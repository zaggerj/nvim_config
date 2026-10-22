"""Opening Go code must not query/download a toolchain through disabled vim-go LSP."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
from nvim_process import run_nvim


def main():
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
    from bootstrap_rocks import build_environment
    build_env, _ = build_environment()
    compiler = shutil.which('gcc', path=build_env['PATH']) or shutil.which('cc', path=build_env['PATH'])
    with tempfile.TemporaryDirectory(prefix='nvim-go-startup-') as directory:
        root = Path(directory)
        (root / 'main.go').write_text('package main\nfunc main() {}\n')
        (root / 'other.go').write_text('package main\n')
        (root / 'go.mod').write_text('module example.com/startup\n\ngo 1.26.9\n')
        (root / 'go.c').write_text(
            '#include <stdio.h>\n#ifdef _WIN32\n#include <windows.h>\n'
            '#define pause() Sleep(8000)\n#else\n#include <unistd.h>\n'
            '#define pause() sleep(8)\n#endif\n'
            'int main(void) { FILE *f=fopen("go-called", "a"); '
            'if(f){fputs("called\\n",f);fclose(f);} pause(); return 1; }\n')
        binary = root / ('go.exe' if os.name == 'nt' else 'go')
        subprocess.run([compiler, str(root / 'go.c'), '-o', str(binary)], env=build_env,
                       check=True, timeout=30)
        probe = root / 'probe.lua'
        probe.write_text('''
vim.schedule(function()
  local ok, err = pcall(function()
    assert(vim.g.go_gopls_enabled == 0, 'Coc must own the language service')
    assert(vim.fn.exists(':GoBuild') == 2, 'vim-go commands were removed')
    for _, name in ipairs({'main.go', 'other.go', 'main.go'}) do
      vim.cmd.edit(name)
      local commands = ''
      for _, a in ipairs(vim.api.nvim_get_autocmds({group='vim-go-buffer',buffer=0})) do
        commands = commands .. a.command .. '\\n'
        assert(not a.command:find('go#lsp#',1,true), 'Disabled LSP event survived')
      end
      assert(commands:find('go#auto#fmt_autosave',1,true), 'Formatting event lost')
      assert(commands:find('go#auto#metalinter_autosave',1,true), 'Lint event lost')
      for _, event in ipairs({'BufWritePost', 'CursorHold', 'CursorHoldI', 'FileChangedShellPost', 'BufDelete'}) do
        vim.api.nvim_exec_autocmds(event, {buffer=0, modeline=false})
      end
    end
  end)
  print(ok and 'GO_SCREEN_READY' or tostring(err))
  vim.cmd(ok and 'qa!' or 'cquit')
end)
''')
        env = os.environ.copy()
        env['PATH'] = str(root) + os.pathsep + env.get('PATH', '')
        started = time.monotonic()
        result = run_nvim(['nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0',
                                 'main.go', '+luafile ' + str(probe)],
                                cwd=root, env=env, timeout=8)
        elapsed = time.monotonic() - started
        if (root / 'go-called').exists():
            print(result.stdout + result.stderr)
        assert not (root / 'go-called').exists(), f'Disabled vim-go LSP ran Go before/after first screen ({elapsed:.2f}s)'
        assert result.returncode == 0 and 'GO_SCREEN_READY' in result.stdout + result.stderr, result.stdout + result.stderr
        assert elapsed < 3, f'Go file startup blocked: {elapsed:.2f}s'
        print(f'PASS Go file and disabled-LSP lifecycle do not run Go; commands preserved: {elapsed:.2f}s')


if __name__ == '__main__':
    main()
