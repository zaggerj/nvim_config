"""Exercise long-line growth through configured Neovim and temporary files."""
import os
from pathlib import Path
import tempfile
import sys
from nvim_process import run_nvim


LUA = r'''
local root = vim.env.NVIM_GROWTH_TEST
local function run()
  for _, event in ipairs({'TextChanged', 'TextChangedI'}) do
    vim.cmd('edit! ' .. vim.fn.fnameescape(root .. '/' .. event .. '.js'))
    local buf = vim.api.nvim_get_current_buf()
    assert(vim.wait(3000, function() return vim.treesitter.highlighter.active[buf] ~= nil end, 20), 'ordinary JS highlighter missing')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {string.rep('x', 30000)})
    vim.api.nvim_exec_autocmds(event, {buffer = buf, modeline = false})
    assert(vim.bo[buf].filetype == 'bigfile', event .. ': edited long line was not protected')
    assert(not vim.treesitter.highlighter.active[buf], event .. ': expensive highlighter remains')
    assert(vim.b[buf].coc_enabled == 0 and vim.b[buf].copilot_enabled == false, 'services remain enabled')
    print('PASS long-line growth via ' .. event)
  end
  vim.cmd('edit! ' .. vim.fn.fnameescape(root .. '/threshold.js'))
  local threshold = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(threshold, 0, -1, false, {string.rep('x', 20000)})
  vim.api.nvim_exec_autocmds('TextChanged', {buffer = threshold})
  assert(vim.bo.filetype == 'javascript', 'exact 20000-byte line must stay normal')
  vim.api.nvim_win_set_cursor(0, {1, 19999})
  vim.api.nvim_paste('xy', false, -1)
  vim.api.nvim_exec_autocmds('TextChanged', {buffer = threshold})
  assert(vim.bo.filetype == 'bigfile', 'pasting beyond line threshold must protect')
  vim.cmd('undo')
  assert(vim.bo.filetype == 'bigfile', 'undo must not prematurely restart expensive services')
  vim.api.nvim_buf_set_lines(threshold, 0, -1, false, {'const restored = 1;'})
  vim.cmd.write()
  vim.cmd.bwipeout()
  vim.cmd('edit ' .. vim.fn.fnameescape(root .. '/threshold.js'))
  local restored = vim.api.nvim_get_current_buf()
  assert(vim.bo.filetype == 'javascript', 'saved small file must reopen normally')
  assert(vim.wait(3000, function() return vim.treesitter.highlighter.active[restored] ~= nil end, 20), 'reopened small file lost highlighter')
  print('PASS exact line threshold, real paste, undo and save/close/reopen')

  vim.cmd('edit! ' .. vim.fn.fnameescape(root .. '/bytes.js'))
  local bytes = vim.api.nvim_get_current_buf()
  assert(vim.bo.filetype == 'javascript', 'exact 1MiB file must stay normal')
  vim.api.nvim_buf_set_text(bytes, 0, 0, 0, 0, {'x'})
  vim.api.nvim_exec_autocmds('TextChangedI', {buffer = bytes})
  assert(vim.bo.filetype == 'bigfile', '1MiB plus one byte must protect')
  vim.cmd('edit! ' .. vim.fn.fnameescape(root .. '/lines.js'))
  local lines = vim.api.nvim_get_current_buf()
  assert(vim.bo.filetype == 'javascript', 'exact 20000 lines must stay normal')
  vim.api.nvim_buf_set_lines(lines, 0, 0, false, {''})
  vim.api.nvim_exec_autocmds('TextChanged', {buffer = lines})
  assert(vim.bo.filetype == 'bigfile', '20001 lines must protect')
  print('PASS exact byte and line-count thresholds')

  vim.cmd('edit! ' .. vim.fn.fnameescape(root .. '/ordinary.js'))
  local ordinary = vim.api.nvim_get_current_buf()
  local ordinary_win = vim.api.nvim_get_current_win()
  assert(vim.wait(3000, function() return vim.treesitter.highlighter.active[ordinary] ~= nil end, 20), 'ordinary buffer lost highlighter')
  vim.cmd.vsplit()
  vim.cmd('buffer ' .. bytes)
  assert(not vim.wo.foldenable, 'large-file split must disable folds')
  vim.api.nvim_set_current_win(ordinary_win)
  assert(vim.bo.filetype == 'javascript' and vim.treesitter.highlighter.active[ordinary], 'other buffer must retain code features')
  assert(vim.b.coc_enabled ~= 0 and vim.b.copilot_enabled ~= false, 'other buffer inherited disabled services')
  local started = (vim.uv or vim.loop).hrtime()
  for n = 1, 500 do
    vim.api.nvim_buf_set_lines(ordinary, n, n + 1, false, {'const value = ' .. n .. ';'})
    vim.api.nvim_exec_autocmds('TextChanged', {buffer = ordinary})
  end
  local elapsed = ((vim.uv or vim.loop).hrtime() - started) / 1e6
  assert(vim.bo.filetype == 'javascript', 'small edits must not trigger protection')
  print(string.format('PASS independent windows and 500 edits in 19000-line file: %.1fms', elapsed))
end
vim.defer_fn(function()
  local ok, err = xpcall(run, debug.traceback)
  if not ok then io.stderr:write(err .. '\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end, 100)
'''

NORMAL_FILE_LUA = r'''
vim.defer_fn(function()
  local ok, err = xpcall(function()
    local files = {}
    vim.api.nvim_create_autocmd('User', {pattern = 'NormalFile', callback = function()
      files[#files + 1] = vim.api.nvim_buf_get_name(0)
    end})
    vim.cmd.enew()
    vim.api.nvim_exec_autocmds('BufEnter', {buffer = 0})
    vim.wait(50)
    assert(#files == 0, 'unnamed empty buffer must not trigger code plugins')
    vim.cmd('edit ' .. vim.fn.fnameescape(vim.env.NVIM_GROWTH_TEST .. '/notes.txt'))
    vim.wait(50)
    assert(#files == 0, 'plain text must not trigger code plugins')
    vim.cmd('edit ' .. vim.fn.fnameescape(vim.env.NVIM_GROWTH_TEST .. '/ordinary.js'))
    local named = vim.api.nvim_get_current_buf()
    vim.cmd.enew()
    vim.wait(50)
    assert(#files == 0, 'scheduled event must not run against a different current buffer')
    vim.cmd('buffer ' .. named)
    assert(vim.wait(1000, function() return #files > 0 end, 20), 'named code file must trigger normal-file behavior')
    assert(files[#files]:match('ordinary%.js$'), 'normal-file context is not the current named buffer')
    print('PASS empty, plain-text and switched-away buffers skipped; named code buffer activates')
  end, debug.traceback)
  if not ok then io.stderr:write(err .. '\n') end
  vim.cmd(ok and 'qa!' or 'cquit 1')
end, 100)
'''


def main():
    with tempfile.TemporaryDirectory(prefix='nvim-growth-smoke-') as directory:
        root = Path(directory)
        for name in ('TextChanged.js', 'TextChangedI.js'):
            (root / name).write_text('const value = 42;\n', encoding='utf-8')
        (root / 'threshold.js').write_text('const value = 1;\n', encoding='utf-8')
        (root / 'bytes.js').write_bytes((('x' * 8191 + '\n') * 128).encode())
        (root / 'lines.js').write_text('\n' * 20000, encoding='utf-8')
        (root / 'ordinary.js').write_text('const value = 1;\n' * 19000, encoding='utf-8')
        (root / 'notes.txt').write_text('plain text\n', encoding='utf-8')
        (root / 'verify.lua').write_text(NORMAL_FILE_LUA if '--events-only' in sys.argv else LUA, encoding='utf-8')
        env = os.environ.copy()
        env['NVIM_GROWTH_TEST'] = root.as_posix()
        result = run_nvim(['nvim', '--headless', '-n', '--cmd', 'let g:coc_start_at_startup=0',
                           '+lua dofile(vim.env.NVIM_GROWTH_TEST .. "/verify.lua")'],
                          cwd=root, env=env, timeout=30)
        print(result.stdout)
        assert result.returncode == 0, 'configured Neovim growth regression failed'


if __name__ == '__main__':
    main()
