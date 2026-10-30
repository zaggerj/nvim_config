"""Check project-specific gopls env before Coc starts, without workspace files."""
import json
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim


LUA = r'''
local ok, err = xpcall(function()
  local config = vim.g.coc_user_config
  local options = config['go.goplsOptions']
  assert(config['suggest.noselect'] == true, 'existing Coc settings lost')
  assert(options.staticcheck == true, 'existing gopls options lost')
  assert(options.env.PROJECT_ENV_TEST == 'retained', 'existing gopls env lost')
  if vim.env.NVIM_EXPECT_AIPAAS == '1' then
    assert(options.env.GOFLAGS == '-mod=readonly', 'AIPaaS module mode missing')
    assert(options.env.GOPROXY == 'https://goproxy.cn,direct', 'AIPaaS proxy missing')
  else
    assert(options.env.GOFLAGS == nil, 'AIPaaS module mode leaked to ordinary project')
    assert(options.env.GOPROXY == nil, 'AIPaaS proxy leaked to ordinary project')
  end
  assert(vim.env.GOFLAGS == '-tags=nvim_env_probe', 'process Go flags changed')
  assert(vim.env.GOPROXY == 'https://example.invalid', 'process Go proxy changed')
end, debug.traceback)
if not ok then io.stderr:write(err .. '\n') end
vim.cmd(ok and 'qa!' or 'cquit 1')
'''


def main():
    with tempfile.TemporaryDirectory(prefix='nvim-go-project-env-') as directory:
        root = Path(directory)
        aipaas = root / 'renamed-checkout'
        ordinary = root / 'aipaas'
        nested = aipaas / 'tools/ordinary'
        for module, name in [(aipaas / 'backend', 'github.com/aipaas/aipaas'),
                             (ordinary, 'example.com/ordinary'),
                             (nested, 'example.com/nested')]:
            (module / 'internal').mkdir(parents=True)
            (module / 'go.mod').write_text(f'module {name}\n\ngo 1.26\n', encoding='utf-8')
            (module / 'internal/main.go').write_text('package main\n', encoding='utf-8')
        (root / 'verify.lua').write_text(LUA, encoding='utf-8')
        before = {path: path.read_bytes() for path in root.rglob('*') if path.is_file()}
        initial = 'let g:coc_user_config=' + json.dumps({
            'suggest.noselect': True,
            'go.goplsOptions': {'staticcheck': True, 'env': {'PROJECT_ENV_TEST': 'retained'}},
        }).replace('true', 'v:true')
        cases = [
            ('ordinary module', ordinary, None, False),
            ('AIPaaS root', aipaas, None, True),
            ('AIPaaS backend', aipaas / 'backend', None, True),
            ('AIPaaS nested cwd', aipaas / 'backend/internal', None, True),
            ('absolute file from unrelated cwd', ordinary, aipaas / 'backend/internal/main.go', True),
            ('relative file from root', aipaas, Path('backend/internal/main.go'), True),
            ('ordinary argv overrides AIPaaS cwd', aipaas, ordinary / 'internal/main.go', False),
            ('nested independent module', nested, None, False),
        ]
        failures = []
        for name, cwd, file, expected in cases:
            env = os.environ.copy()
            env.update(NVIM_ENV_PROBE=(root / 'verify.lua').as_posix(),
                       NVIM_EXPECT_AIPAAS='1' if expected else '0',
                       GOFLAGS='-tags=nvim_env_probe', GOPROXY='https://example.invalid')
            argv = ['nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0',
                    '--cmd', initial]
            if file is not None:
                argv.append(str(file))
            argv.append('+lua dofile(vim.env.NVIM_ENV_PROBE)')
            result = run_nvim(argv, cwd=cwd, env=env, timeout=30)
            print(f'{"PASS" if result.returncode == 0 else "FAIL"} {name} (exit {result.returncode})')
            if result.returncode:
                failures.append(name)
                print(result.stdout)
        assert not list(root.rglob('.vim')), 'startup created project .vim files'
        after = {path: path.read_bytes() for path in root.rglob('*') if path.is_file()}
        assert before == after, 'startup changed project fixture files'
        assert not failures, 'project environment regression: ' + ', '.join(failures)


if __name__ == '__main__':
    main()
