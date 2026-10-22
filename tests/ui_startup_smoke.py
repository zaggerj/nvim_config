"""Check that statusline initializes once after theme selection, and dashboard stays usable."""
from pathlib import Path
import os
import subprocess
import tempfile


PRELOAD = r'''
local original = require
_G.require = function(name)
  local module = original(name)
  if name == 'lualine' and not module._startup_test then
    module._startup_test = true
    local setup = module.setup
    module.setup = function(...)
      vim.g.statusline_setup_count = (vim.g.statusline_setup_count or 0) + 1
      return setup(...)
    end
  end
  return module
end
'''

VERIFY = r'''
-- Headless 没有 UIEnter；显式走 lazy 的同一事件入口，真实 TUI 另测首屏。
vim.schedule(function() vim.api.nvim_exec_autocmds('UIEnter', {modeline=false}) end)
vim.defer_fn(function()
  local ok, err = pcall(function()
    local plugins = require('lazy.core.config').plugins
    assert(plugins['lualine.nvim']._.loaded, 'statusline did not load')
    assert(vim.g.statusline_setup_count == 1,
      'statusline setup ran '..tostring(vim.g.statusline_setup_count)..' times instead of once')
    assert(vim.g.colors_name == vim.env.NVIM_UI_EXPECTED_THEME, 'directory theme changed')
    assert(vim.o.statusline:find('lualine', 1, true), 'statusline is not active')
    assert(vim.o.laststatus == 3, 'global statusline contract is inconsistent')
    if vim.fn.argc() > 0 then
      assert(not plugins['alpha-nvim']._.loaded, 'dashboard loaded while opening a file')
      vim.cmd('Alpha')
      assert(plugins['alpha-nvim']._.loaded, 'explicit dashboard command failed')
    else
      assert(plugins['alpha-nvim']._.loaded, 'empty startup lost dashboard')
    end
    print('PASS one statusline setup, final theme, dashboard loading')
  end)
  if not ok then
    vim.api.nvim_err_writeln(tostring(err))
    vim.cmd('cquit 1')
  else
    vim.cmd('qa!')
  end
end, 1200)
'''


def main():
    with tempfile.TemporaryDirectory(prefix='nvim-ui-startup-') as directory:
        root = Path(directory)
        (root / 'preload.lua').write_text(PRELOAD, encoding='utf-8')
        (root / 'verify.lua').write_text(VERIFY, encoding='utf-8')
        (root / 'sample.go').write_text('package main\nfunc main() {}\n', encoding='utf-8')
        cases = [(root, [str(root / 'sample.go')], 'catppuccin-latte'),
                 (root, [], 'catppuccin-latte')]
        for suffix, theme in [('_oem', 'onelight'), ('_bug', 'everforest')]:
            cwd = root / suffix
            cwd.mkdir()
            cases.append((cwd, [str(root / 'sample.go')], theme))
        for cwd, args, theme in cases:
            env = os.environ.copy()
            env['NVIM_UI_EXPECTED_THEME'] = theme
            subprocess.run([
                'nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0',
                '--cmd', 'lua dofile(' + repr((root / 'preload.lua').as_posix()) + ')',
                '-S', str(root / 'verify.lua'), *args,
            ], cwd=cwd, env=env, check=True, timeout=20)


if __name__ == '__main__':
    main()
