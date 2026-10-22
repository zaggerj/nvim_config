-- 扫描范围在ripgrep输入端控制，结果层不按目录名称丢弃合法源码。
local M = {}
local function exclusions()
  return { '--glob=!.git/**', '--glob=!**/.git/**', '--glob=!**/node_modules/**',
    '--glob=!**/__pycache__/**', '--glob=!**/.pnpm-store/**' }
end
local function files(hidden, ignored)
  local args = { 'rg', '--files', '--color=never' }
  if hidden then args[#args + 1] = '--hidden' end
  if ignored then args[#args + 1] = '--no-ignore-vcs' end
  vim.list_extend(args, exclusions())
  return args
end
function M.options()
  local grep = { 'rg', '--color=never', '--no-heading', '--with-filename',
    '--line-number', '--column', '--smart-case', '--hidden' }
  vim.list_extend(grep, exclusions())
  return {
    defaults = { vimgrep_arguments = grep, file_ignore_patterns = {},
      mappings = { i = { ['<C-u>'] = false } } },
    pickers = { find_files = { find_command = files(false, false) } },
    extensions = { fzf = { fuzzy = true, override_generic_sorter = true,
      override_file_sorter = true, case_mode = 'smart_case' } },
  }
end
function M.setup(_, opts)
  local telescope = require('telescope')
  telescope.setup(opts)
  local ok, err = pcall(telescope.load_extension, 'fzf')
  M.fzf_error = not ok and tostring(err) or nil
  if not ok then
    vim.notify('Telescope fzf原生扩展加载失败：' .. M.fzf_error
      .. '\n请检查本平台make/编译器并显式执行 :Lazy build telescope-fzf-native.nvim；使用 :SearchHealth 查看状态。', vim.log.levels.ERROR)
  end
  vim.api.nvim_create_user_command('SearchHealth', function()
    if M.fzf_error then error('fzf unavailable: ' .. M.fzf_error) end
    print('fzf native: loaded; ripgrep: ' .. vim.fn.exepath('rg'))
  end, { desc = '检查搜索原生依赖', force = true })
  vim.api.nvim_create_user_command('FindFilesWithHidden', function()
    require('telescope.builtin').find_files({ find_command = files(true, false) })
  end, { desc = '找隐藏文件（尊重gitignore）', force = true })
  vim.api.nvim_create_user_command('FindFilesIgnored', function()
    require('telescope.builtin').find_files({ find_command = files(true, true) })
  end, { desc = '显式找gitignore忽略文件', force = true })
  vim.api.nvim_create_user_command('GrepIgnored', function(args)
    require('telescope.builtin').live_grep({ default_text = args.args,
      additional_args = { '--no-ignore-vcs' } })
  end, { nargs = '*', desc = '显式搜索gitignore忽略文件', force = true })
  vim.api.nvim_create_user_command('GrepPCRE', function(args)
    -- 仅明确调用时探测；普通中文搜索无需PCRE2或额外进程。
    local result = vim.system({ 'rg', '--pcre2-version' }, { text = true }):wait(3000)
    if result.code ~= 0 then
      error('当前 ripgrep 未提供 PCRE2：' .. (result.stderr or '') .. '\n请安装带 PCRE2 的 ripgrep，普通中文仍可使用 Telescope live_grep。')
    end
    require('telescope.builtin').live_grep({ default_text = args.args,
      additional_args = { '--pcre2' } })
  end, { nargs = '*', desc = '显式使用PCRE2高级正则', force = true })
end
return M
