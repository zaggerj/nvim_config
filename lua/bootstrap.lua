-- 启动边界：源码位置和运行产物位置分别计算，不依赖启动终端的 HOME。
local M = {}

function M.init(root)
  root = (vim.uv or vim.loop).fs_realpath(root) or root
  vim.g.nvim_config_root = root
  vim.opt.runtimepath:prepend(root)
  if vim.fn.has('win32') == 1 and vim.env.USERPROFILE then
    -- 仅规范化 Neovim 子进程环境，不更改 Git Bash/zsh 的登录配置。
    vim.env.HOME = vim.env.USERPROFILE
    -- Copilot 等原生工具也读取 XDG_CONFIG_HOME；统一到源码所在的配置根。
    vim.env.XDG_CONFIG_HOME = vim.fs.dirname(root)
  end
  local sep = vim.fn.has('win32') == 1 and ';' or ':'
  if vim.fn.has('win32') == 1 then
    -- jobstop 只能可靠地终止直接子进程。Scoop 的 git.exe shim 会额外
    -- 启动真实 Git，快速切换 buffer 时 shim 被停止而 Git 遗留并持有日志句柄。
    -- 让所有插件的字面 git 命令直接解析到已发现的原生可执行文件。
    local git = require('platform').executable('git')
    if git then
      vim.env.PATH = vim.fn.fnamemodify(git, ':h') .. sep .. vim.env.PATH
    end
    local gcc = require('platform').executable('gcc')
    if gcc then
      -- 启动只发现路径；编译器目标由显式构建脚本检查，不能在首屏等待外部命令。
      -- 优先真实 GCC 目录，避免 zsh 的 MSYS DLL 覆盖编译器依赖。
      vim.env.PATH = vim.fn.fnamemodify(gcc, ':h') .. sep .. vim.env.PATH
    end
    for _, name in ipairs({ 'node', 'rg' }) do
      local tool = require('platform').executable(name)
      if tool then vim.env.PATH = vim.fn.fnamemodify(tool, ':h') .. sep .. vim.env.PATH end
    end
  end
  local data = vim.fn.stdpath('data')
  -- Coc 默认还受 XDG_CONFIG_HOME 影响，仅统一 HOME 无法共享扩展状态。
  vim.g.coc_data_home = data .. '/coc'
  vim.g.coc_config_home = root
  vim.env.PATH = data .. '/lazy-rocks/hererocks/bin' .. sep
    .. data .. '/tools/tree-sitter/bin' .. sep .. vim.env.PATH
end

function M.python()
  local names = vim.fn.has('win32') == 1 and { 'python', 'python3' } or { 'python3', 'python' }
  for _, name in ipairs(names) do
    if vim.fn.executable(name) == 1 then
      local path = vim.fn.exepath(name)
      local check = vim.system({ path, '--version' }, { text = true }):wait(5000)
      local minor = ((check.stdout or '') .. (check.stderr or '')):match('Python 3%.(%d+)')
      if check.code == 0 and minor and tonumber(minor) >= 9 then
        return path
      end
    end
  end
  error('安装依赖需要 Python 3.9+，请先安装并加入 PATH')
end

function M.build_rocks(plugin, rest)
  local command = { M.python(), vim.g.nvim_config_root .. '/scripts/bootstrap_rocks.py',
    '--data', vim.fn.stdpath('data'), '--hererocks', plugin.dir }
  if rest then vim.list_extend(command, { '--rest', rest.dir }) end
  local result = vim.system(command, { text = true }):wait()
  if result.code ~= 0 then
    error((result.stdout or '') .. '\n' .. (result.stderr or ''))
  end
end

function M.lazy_options()
  return {
    lockfile = vim.g.nvim_config_root .. '/lazy-lock.json',
    -- 使用本仓库固定版本的隔离工具链；不调用 lazy 内置的 latest 下载器。
    rocks = { enabled = true, hererocks = true },
    install = { missing = false },
    -- 下载、编译只在缺少依赖或明确更新时执行；正常编辑不检查远程更新。
    checker = { enabled = false },
    change_detection = { notify = false },
  }
end

return M
