"""Verify project themes through real buffers, filesystem roots and colorschemes."""
import os
from pathlib import Path
import tempfile
from nvim_process import run_nvim


LUA = r'''
local root = vim.env.NVIM_THEME_TEST
vim.defer_fn(function()
  local ok, err = xpcall(function()
    local a = root .. '/client/app/src/a.js'
    local b = root .. '/other/app/src/b.js'
    vim.g.nvim_project_themes = {
      { root = root .. '/client/app', theme = 'onelight' },
      { root = root .. '/other/app', theme = 'everforest' },
    }
    vim.cmd('edit ' .. vim.fn.fnameescape(a))
    assert(vim.g.colors_name == 'onelight', 'active repository must select configured theme')
    vim.cmd('edit ' .. vim.fn.fnameescape(b))
    assert(vim.g.colors_name == 'everforest', 'same-name repository must respect exact root')
    print('PASS absolute files and same-name Git/worktree roots select separate themes')
    vim.g.nvim_project_themes = {
      { root = 'mono', theme = 'everforest' },
      { root = 'mono', subdir = 'packages/ui', theme = 'onelight' },
      { root = 'loose/tool', theme = 'onelight' },
    }
    vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/mono/packages/ui/src/view.js'))
    assert(vim.g.colors_name == 'onelight', 'portable root and monorepo subproject must match')
    vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/mono/src/main.js'))
    assert(vim.g.colors_name == 'everforest', 'Git root must outrank nested package marker')
    vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/loose/tool/src/main.js'))
    assert(vim.g.colors_name == 'onelight', 'non-Git workspace marker must identify root')
    print('PASS portable suffix roots, monorepo override and non-Git project marker')
    local changes = 0
    vim.api.nvim_create_autocmd('ColorScheme', {callback = function() changes = changes + 1 end})
    vim.api.nvim_exec_autocmds('BufEnter', {buffer = 0})
    vim.api.nvim_exec_autocmds('BufEnter', {buffer = 0})
    assert(changes == 0, 'unchanged project must not reapply colorscheme')
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, true))
    vim.cmd('cd ' .. vim.fn.fnameescape(root .. '/mono'))
    assert(vim.g.colors_name == 'onelight', 'special buffer or cwd change must retain last active project theme')
    vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/mono/src/main.js'))
    assert(vim.g.colors_name == 'everforest', 'returning from special buffer must select active project theme')
    vim.cmd.tabnew()
    vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/loose/tool/src/main.js'))
    assert(vim.g.colors_name == 'onelight', 'theme follows active tab file globally')
    vim.cmd.tabprevious()
    assert(vim.g.colors_name == 'everforest', 'returning tab applies its active file globally')
    assert(vim.o.laststatus == 3, 'theme switch must preserve global statusline')
    vim.g.nvim_project_themes = {{root = 'client/app', theme = 'missing-neovim-test-theme'}}
    local entered, failure = pcall(vim.cmd, 'edit ' .. vim.fn.fnameescape(a))
    assert(entered, 'invalid configured theme must not break file entry: ' .. tostring(failure))
    assert(vim.g.colors_name == 'everforest', 'invalid theme must keep last working colorscheme')
    assert(vim.fn.execute('messages'):find('missing%-neovim%-test%-theme'), 'invalid theme needs actionable diagnostic')
    print('PASS stable theme, special buffers, global tab switching and invalid-theme diagnostic')
  end, debug.traceback)
  if not ok then io.stderr:write(err .. '\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end, 100)
'''


def main():
    with tempfile.TemporaryDirectory(prefix='nvim-theme-smoke-') as directory:
        root = Path(directory)
        for name in ('client/app', 'other/app'):
            project = root / name
            (project / 'src').mkdir(parents=True)
            (project / 'src' / ('a.js' if name.startswith('client') else 'b.js')).write_text('const value = 1;\n', encoding='utf-8')
        (root / 'client/app/.git').mkdir()
        (root / 'other/app/.git').write_text('gitdir: ../worktrees/app\n', encoding='utf-8')
        for name in ('mono/packages/ui/src/view.js', 'mono/src/main.js', 'loose/tool/src/main.js'):
            file = root / name
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text('const value = 1;\n', encoding='utf-8')
        (root / 'mono/.git').mkdir()
        (root / 'mono/packages/ui/package.json').write_text('{}', encoding='utf-8')
        (root / 'loose/tool/pyproject.toml').write_text('[project]\nname="tool"\n', encoding='utf-8')
        (root / 'verify.lua').write_text(LUA, encoding='utf-8')
        env = os.environ.copy()
        env['NVIM_THEME_TEST'] = root.as_posix()
        result = run_nvim(['nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0',
                           '+lua dofile(vim.env.NVIM_THEME_TEST .. "/verify.lua")'],
                          cwd=root, env=env, timeout=30)
        print(result.stdout)
        assert result.returncode == 0, 'project theme regression failed'


if __name__ == '__main__':
    main()
