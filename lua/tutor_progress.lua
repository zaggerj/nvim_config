-- 使用宿主内置教程；练习副本和位置放在运行数据目录，永不写宿主原文。
local M = {}
function M.setup()
  vim.api.nvim_create_user_command('Tutor', function(args)
    local language = args.args ~= '' and args.args or 'zh'
    if language ~= 'zh' and language ~= 'en' then
      vim.fn['tutor#TutorCmd'](language)
      return
    end
    local name = 'vim-01-beginner.tutor'
    local source = vim.env.VIMRUNTIME .. '/tutor/' .. language .. '/' .. name
    if vim.fn.filereadable(source) == 0 then error('宿主缺少教程：' .. source) end
    local directory = vim.env.NVIM_TUTOR_TEST_DATA or (vim.fn.stdpath('data') .. '/tutor-progress')
    vim.fn.mkdir(directory, 'p')
    local path = directory .. '/' .. language .. '-' .. name
    if vim.fn.filereadable(path) == 0 then
      vim.fn.writefile(vim.fn.readfile(source), path)
    end
    vim.cmd('hide edit ' .. vim.fn.fnameescape(path))
    vim.bo.filetype = 'tutor'
    local metadata = source .. '.json'
    if vim.fn.filereadable(metadata) == 1 then
      vim.b.tutor_metadata = vim.json.decode(table.concat(vim.fn.readfile(metadata), '\n'))
    end
    vim.fn['tutor#EnableInteractive'](true)
    vim.fn['tutor#ApplyTransform']()
    local position = path .. '.position'
    if vim.fn.filereadable(position) == 1 then
      local row = tonumber(vim.fn.readfile(position)[1]) or 1
      vim.api.nvim_win_set_cursor(0, { math.min(row, vim.api.nvim_buf_line_count(0)), 0 })
    end
    local group = vim.api.nvim_create_augroup('TutorProgress' .. vim.api.nvim_get_current_buf(), { clear = true })
    vim.api.nvim_create_autocmd({ 'BufLeave', 'VimLeavePre' }, {
      group = group, buffer = 0, callback = function(ev)
        if not vim.api.nvim_buf_is_valid(ev.buf) then return end
        if vim.bo[ev.buf].modified then
          vim.fn.writefile(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false), path)
          vim.bo[ev.buf].modified = false
        end
        -- VimLeavePre 也可能从其他buffer退出，不能覆盖教程最后的位置。
        if vim.api.nvim_get_current_buf() == ev.buf then
          local row = vim.api.nvim_win_get_cursor(0)[1]
          vim.fn.writefile({ tostring(row) }, position)
        end
      end,
    })
  end, { nargs = '?', desc = '内置中文/英文教程（保留练习和位置）', force = true })
end
return M
