-- 语言工具运行位置动态计算；下载与编译仅由显式部署命令执行。
local M = {}

function M.setup()
  local data = vim.fn.stdpath('data')
  local suffix = vim.fn.has('win32') == 1 and '.exe' or ''
  local bin = data .. '/tools/languages/bin'
  local separator = vim.fn.has('win32') == 1 and ';' or ':'
  local paths = vim.split(vim.env.PATH or '', separator, { plain = true })
  if not vim.tbl_contains(paths, bin) then vim.env.PATH = bin .. separator .. (vim.env.PATH or '') end
  local gopls = bin .. '/gopls' .. suffix
  local goimports = bin .. '/goimports' .. suffix
  local lua_ls = data .. '/coc/extensions/coc-lua-data/lua-language-server/bin/lua-language-server' .. suffix
  local config = vim.g.coc_user_config or {}
  -- coc-go 在未配置路径时会隐式 go install；指定路径后缺工具只提示，不下载。
  config['go.goplsPath'] = gopls
  -- coc-lua 在 Windows 上的内置安装器不能解包zip；只使用显式部署后的官方产物。
  config['lua.enable'] = vim.fn.executable(lua_ls) == 1
  vim.g.coc_user_config = config
  vim.api.nvim_create_user_command('LanguageToolsInfo', function()
    local lines = {
      'gopls: ' .. gopls .. (vim.fn.executable(gopls) == 1 and ' [OK]' or ' [缺失]'),
      'goimports: ' .. goimports .. (vim.fn.executable(goimports) == 1 and ' [OK]' or ' [缺失]'),
      'LuaLS: ' .. lua_ls .. (vim.fn.executable(lua_ls) == 1 and ' [OK]' or ' [缺失]'),
      '部署: python scripts/provision_languages.py --data "' .. data .. '" --lua --go --apply',
      '完成后完整重启Neovim；扩展安装使用 :CocProvision。',
    }
    print(table.concat(lines, '\n'))
  end, { desc = '检查语言工具与显式部署入口', force = true })
  local group = vim.api.nvim_create_augroup('LanguageToolDiagnostics', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group, pattern = { 'go', 'lua' }, callback = function(ev)
      local tool = ev.match == 'go' and gopls or lua_ls
      if vim.fn.executable(tool) == 0 then
        vim.schedule(function()
          vim.notify('语言工具未部署: ' .. tool .. '；执行 :LanguageToolsInfo 查看安装命令。', vim.log.levels.WARN)
        end)
      end
    end,
  })
end

return M
