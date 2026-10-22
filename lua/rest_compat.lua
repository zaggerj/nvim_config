-- Neovim 0.12 的 get_node() 不再隐式解析；rest.nvim 必须先建立 HTTP 语法树。
local M = {}

function M.setup()
  if vim.fn.has('nvim-0.12') == 0 then return end
  local parser = require('rest-nvim.parser')
  local get_request = parser.get_request_node_by_cursor
  parser.get_request_node_by_cursor = function()
    require('rest-nvim.utils').ts_parse_source(vim.api.nvim_get_current_buf())
    return get_request()
  end
end

return M
