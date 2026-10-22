"""Opening Python avoids interpreter probing and retains real :python3 support."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from nvim_process import run_nvim

LUA = r'''
local ok,err=xpcall(function()
  assert(vim.fn.filereadable(vim.env.NVIM_PROVIDER_PROBE)==0,
    'Opening Python synchronously probed an unrelated PATH interpreter')
  assert(vim.g.python3_host_prog and vim.g.python3_host_prog~='',
    'Python provider has no explicit executable')
  if vim.env.NVIM_PROVIDER_OVERRIDE=='1' then
    assert(vim.g.python3_host_prog:find('/../',1,true),'Explicit user host was replaced')
  end
  assert(vim.fn.py3eval('6 * 7')==42,'Python provider cannot execute real code')
  assert(vim.fn.py3eval('__import__("sys").prefix')~=vim.env.VIRTUAL_ENV,
    'Project venv replaced the editor provider')
  print('PASS Python opening skips PATH probes; real py3eval works outside project venv')
end,debug.traceback)
if not ok then print(err) end
vim.cmd(ok and 'qa!' or 'cquit 1')
'''


def main():
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
    from bootstrap_rocks import build_environment
    build_env, _ = build_environment()
    compiler = shutil.which('gcc', path=build_env['PATH']) or shutil.which('cc', path=build_env['PATH'])
    assert compiler, 'Test requires a native C compiler'
    with tempfile.TemporaryDirectory(prefix='nvim provider ') as directory:
        root = Path(directory)
        source = root / 'probe.c'
        source.write_text(
            '#include <stdio.h>\n#include <stdlib.h>\n#ifdef _WIN32\n#include <windows.h>\n'
            '#define pause_probe() Sleep(2000)\n#else\n#include <unistd.h>\n'
            '#define pause_probe() sleep(2)\n#endif\nint main(void) {\n'
            'FILE *f=fopen(getenv("NVIM_PROVIDER_PROBE"),"w");'
            'if(f){fputs("called",f);fclose(f);} pause_probe();puts("3.14");return 2;}\n', encoding='utf-8')
        probe = root / ('python3.exe' if os.name == 'nt' else 'python3')
        subprocess.run([compiler, str(source), '-o', str(probe)], env=build_env, check=True, timeout=30)
        shutil.copyfile(probe, root / ('python.exe' if os.name == 'nt' else 'python'))
        (root / 'main.py').write_text('print(42)\n', encoding='utf-8')
        script = root / 'verify.lua'
        script.write_text(LUA, encoding='utf-8')
        env = dict(os.environ, NVIM_PROVIDER_PROBE=str(root / 'called'), VIRTUAL_ENV=str(root / '.venv'))
        env['PATH'] = str(root) + os.pathsep + env.get('PATH', '')
        for override in (False, True, False):
            command = ['nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0']
            env['NVIM_PROVIDER_OVERRIDE'] = '1' if override else '0'
            if override:
                suffix = '/Scripts/../Scripts/python.exe' if os.name == 'nt' else '/bin/../bin/python'
                command += ['--cmd', "lua vim.g.python3_host_prog = vim.fn.stdpath('data') .. '/tools/python-provider" + suffix + "'"]
            result = run_nvim([*command, str(root / 'main.py'), '+luafile ' + str(script)],
                              cwd=root, env=env, timeout=15)
            assert result.returncode == 0, result.stdout
            print(result.stdout)


if __name__ == '__main__':
    main()
