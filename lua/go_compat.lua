-- vim-go 关闭 gopls 后仍注册 DidOpen/DidChange，并同步探测工作区。
-- Coc 管理语言服务时，解除这些残留事件，保留 vim-go 的构建、测试和格式化。
local M = {}

local function detach_lsp_events(ev)
  local events = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ group = 'vim-go-buffer', buffer = ev.buf })) do
    local list = events[autocmd.event] or {}
    events[autocmd.event] = list
    list[#list + 1] = autocmd
  end
  -- Vimscript autocmd 没有可删除的 API id；按事件重建，保留同事件的格式化/检查回调。
  for event, list in pairs(events) do
    local remove = false
    for _, autocmd in ipairs(list) do
      if autocmd.command:find('go#lsp#', 1, true) then remove = true end
    end
    if remove then
      vim.api.nvim_clear_autocmds({ group = 'vim-go-buffer', event = event, buffer = ev.buf })
      for _, autocmd in ipairs(list) do
        if not autocmd.command:find('go#lsp#', 1, true) then
          vim.api.nvim_create_autocmd(event, {
            group = 'vim-go-buffer', buffer = ev.buf, command = autocmd.command,
          })
        end
      end
    end
  end
end

function M.setup()
  if vim.g.go_gopls_enabled ~= 0 then return end
  -- 锁定版本的此组仅有一个 FileType 回调：s:register -> DidOpen。
  vim.api.nvim_clear_autocmds({ group = 'vim-go', event = 'FileType' })
  local group = vim.api.nvim_create_augroup('GoCocCompatibility', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group, pattern = 'go', callback = detach_lsp_events,
  })
end

return M
