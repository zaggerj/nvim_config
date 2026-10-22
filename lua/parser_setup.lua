-- 日常启动与原生parser构建分开；此清单是支持语言的部署来源。
local M = {}
M.languages = { 'c', 'lua', 'go', 'python', 'css', 'scss', 'typescript', 'tsx',
  'html', 'http', 'javascript', 'jsdoc', 'json', 'vue' }
function M.install()
  require('lazy').load({ plugins = { 'nvim-treesitter' } })
  -- TSInstallSync 对已安装语言逐个问是否重装；部署采用无交互、只补缺失语义。
  require('nvim-treesitter.install').ensure_installed_sync(M.languages)
  for _, language in ipairs(M.languages) do
    local ok, loaded = pcall(vim.treesitter.language.add, language)
    assert(ok and loaded, 'parser未能加载：' .. language .. '；请检查本平台构建日志')
  end
  print('全部支持语言parser已在本平台部署并可加载；请完整重启Neovim。')
end
function M.setup()
  vim.api.nvim_create_user_command('ParserInstall', M.install,
    { desc = '显式构建本平台支持语言parser', force = true })
end
return M
