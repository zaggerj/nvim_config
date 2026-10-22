-- 原生parser只在显式部署时构建；打开笔记绝不触发下载和编译。
local M = {}

function M.ready()
  for _, language in ipairs({'norg','norg_meta'}) do
    local ok, added = pcall(vim.treesitter.language.add, language)
    if not ok or not added then return false end
  end
  return true
end

function M.setup(_, opts)
  require('lazy').load({plugins={'nvim-treesitter'}})
  if not M.installing and not M.ready() then
    vim.schedule(function()
      vim.notify('Neorg缺少本平台norg/norg_meta parser。请在配置目录显式执行：'
        .. '\npython scripts/provision_neorg.py --apply\n完成后完整重启Neovim。', vim.log.levels.WARN)
    end)
    return
  end
  require('neorg').setup(opts)
end

function M.install()
  M.installing = true
  local ok, err = xpcall(function()
    require('lazy').load({plugins={'neorg'}})
    vim.cmd('Neorg sync-parsers')
    assert(M.ready(), 'Neorg parser构建失败，请检查编译器/curl/tar及上面的构建输出')
    print('PASS Neorg norg/norg_meta parsers built for this platform')
  end, debug.traceback)
  M.installing = false
  if not ok then error(err) end
end

return M
