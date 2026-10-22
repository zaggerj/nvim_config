-- Git导航不修改内容；丢弃未暂存修改必须经用户确认。
local M = {}

function M.navigate(direction)
  if vim.wo.diff then
    vim.cmd.normal({ args = { direction == 'next' and ']c' or '[c' }, bang = true })
    return
  end
  require('gitsigns').nav_hunk(direction)
end

function M.reset_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  vim.ui.select({ '取消', '重置当前文件未暂存修改' }, {
    prompt = '确认丢弃当前文件全部未暂存修改？',
  }, function(_, choice)
    if choice ~= 2 then return end
    if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_buf_get_changedtick(buf) ~= tick then
      vim.notify('文件已变化，请重新确认重置', vim.log.levels.WARN)
      return
    end
    vim.api.nvim_buf_call(buf, function() require('gitsigns').reset_buffer() end)
  end)
end

return M
