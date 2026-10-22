local M = {}

function M.manifest()
  local file = vim.g.nvim_config_root .. '/coc-extensions.json'
  return vim.json.decode(table.concat(vim.fn.readfile(file), '\n'))
end

function M.register()
  require('languages').setup()
  vim.api.nvim_create_user_command('CocProvision', function()
    require('lazy').load({ plugins = { 'coc.nvim' } })
    local packages = {}
    for name, version in pairs(M.manifest().extensions) do
      table.insert(packages, name .. '@' .. version)
    end
    table.sort(packages)
    -- 交给 Coc 自身安装器，避免 npm 顶层 hoist 破坏扩展的嵌套依赖。
    vim.cmd('CocInstall ' .. table.concat(packages, ' '))
  end, { desc = '按仓库清单显式安装 Coc 扩展', force = true })
end

return M
