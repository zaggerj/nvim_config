-- Coc 负责语言服务；Copilot 只提供代码行内建议，二者使用独立键位。
local M = {}

function M.init()
  vim.g.copilot_version = false -- 官方支持：使用随插件提交内嵌的服务，不调用 npx。
  vim.g.copilot_no_tab_map = true
  vim.g.copilot_no_maps = true
  vim.g.copilot_filetypes = {
    ['*'] = false,
    javascript = true, javascriptreact = true,
    typescript = true, typescriptreact = true, vue = true,
    go = true, python = true, lua = true, c = true, cpp = true,
    java = true, rust = true, sh = true, zsh = true, ps1 = true,
    bigfile = false,
  }
end

function M.setup()
  vim.keymap.set('i', '<C-j>', 'copilot#Accept("")',
    { expr = true, replace_keycodes = false, silent = true, desc = '接受 AI 建议' })
  vim.keymap.set('i', '<M-]>', '<Cmd>call copilot#Next()<CR>', { desc = '下一个 AI 建议' })
  vim.keymap.set('i', '<M-[>', '<Cmd>call copilot#Previous()<CR>', { desc = '上一个 AI 建议' })
  -- C-g 是 nvim-surround 的插入前缀，单独占用会让 s/S 等待 timeoutlen。
  vim.keymap.set('i', '<C-g>d', '<Cmd>call copilot#Dismiss()<CR>', { desc = '隐藏 AI 建议' })
  if vim.fn['copilot#Enabled']() == 1 then
    -- InsertEnter 时延迟加载，显式补上已错过的 VimEnter/FileType 初始化。
    vim.fn['copilot#Init']()
    vim.fn['copilot#OnFileType']()
  end
end

return M
