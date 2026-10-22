-- 只在操作系统边界转换路径和命令，编辑器配置不依赖安装盘符。
local M = { windows = vim.fn.has('win32') == 1 }

function M.home()
  return (M.windows and vim.env.USERPROFILE) or (vim.uv or vim.loop).os_homedir()
end

function M.executable(candidates)
  if type(candidates) == 'string' then candidates = { candidates } end
  local search = vim.list_extend({}, candidates)
  -- MSYS登录脚本可能只保留POSIX PATH。标准Windows安装根作为后备，
  -- 仍优先用户PATH；不扫描磁盘、不启动shell、不固定盘符。
  if M.windows then
    for _, name in ipairs(candidates) do
      if name == 'node' and vim.env.ProgramFiles then
        search[#search + 1] = vim.env.ProgramFiles .. '/nodejs/node.exe'
      elseif name == 'rg' and vim.env.LOCALAPPDATA then
        search[#search + 1] = vim.env.LOCALAPPDATA .. '/Microsoft/WinGet/Links/rg.exe'
      end
    end
  end
  for _, name in ipairs(search) do
    if M.windows and not name:find('[/\\]') and not name:match('%.%w+$') then
      name = name .. '.exe'
    end
    if name ~= '' and vim.fn.executable(name) == 1 then
      local path = vim.fn.exepath(name)
      -- Windows executable() 可能认可MSYS中的无扩展名PE，但exepath()
      -- 无法按本机启动规则解析它。继续寻找可供插件字面node调用的.exe。
      if path == '' and M.windows and not name:find('[/\\]') then
        path = nil
      end
      if path then
        -- Scoop 的 exe shim 不改变父进程 PATH；优先还原无附加参数的真实工具路径。
        local shim = path:gsub('%.[eE][xX][eE]$', '') .. '.shim'
        if vim.fn.filereadable(shim) == 1 then
          local content = table.concat(vim.fn.readfile(shim), '\n')
          local target = content:match('path%s*=%s*"([^"]+)"')
          if target and not content:match('args%s*=') and vim.fn.executable(target) == 1 then
            path = target
          end
        end
        return path ~= '' and path or name
      end
    end
  end
end

function M.shell_argv(system_shell)
  local preferred = vim.env.SHELL or ''
  if M.windows and preferred:match('^/') then
    -- MSYS2 的 /usr/bin/zsh 不能直接传给 Windows CreateProcess。
    preferred = vim.fn.fnamemodify(preferred, ':t')
  end
  local candidates = system_shell and M.windows
      and { vim.env.COMSPEC or '', 'cmd.exe' }
    or { vim.env.NVIM_TERMINAL or '', preferred, 'zsh', 'bash', 'pwsh', 'powershell',
      vim.env.COMSPEC or '', 'sh' }
  local shell = M.executable(candidates)
  if not shell then error('找不到可用的终端 shell，请检查 PATH 或设置 NVIM_TERMINAL') end
  local name = vim.fn.fnamemodify(shell, ':t'):lower():gsub('%.exe$', '')
  if name == 'bash' or name == 'zsh' then return { shell, '-l', '-i' } end
  if name == 'pwsh' or name == 'powershell' then return { shell, '-NoLogo' } end
  return { shell }
end

function M.open_terminal(opts)
  opts = opts or {}
  local argv = opts.argv or M.shell_argv(opts.system_shell)
  if opts.split ~= false then
    local height = math.max(1, math.floor(vim.api.nvim_win_get_height(0) * 0.4))
    vim.cmd(height .. 'split')
  end
  vim.cmd.enew()
  local job = vim.fn.termopen(argv, { cwd = opts.cwd or vim.fn.getcwd() })
  if job <= 0 then error('终端进程启动失败：' .. argv[1]) end
  vim.cmd.startinsert()
  return job
end

function M.close_terminal()
  local job = vim.b.terminal_job_id
  if job then vim.fn.jobstop(job) end
end

function M.open_target(target)
  local _, err = vim.ui.open(target or vim.fn.expand('<cfile>'))
  if err then vim.notify(err, vim.log.levels.ERROR) end
end

function M.change_to_file_dir()
  local path = vim.api.nvim_buf_get_name(0)
  if path == '' then return end
  vim.cmd.tcd(vim.fn.fnameescape(vim.fn.fnamemodify(path, ':h')))
end

local function required(names)
  local command = M.executable(names)
  if not command then error('未找到运行工具：' .. table.concat(names, ' / '), 0) end
  return command
end

local function command_for(action, ft, file)
  local stem = vim.fn.fnamemodify(file, ':r')
  local binary = stem .. (M.windows and '.exe' or '')
  if action == 'compile' then
    if ft == 'c' then return { required({ 'clang', 'gcc', 'cc' }), '-o', binary, file } end
    if ft == 'cpp' then return { required({ 'clang++', 'g++', 'c++' }), '-o', binary, file } end
    if ft == 'java' then return { required({ 'javac' }), '-encoding', 'utf-8', file } end
    if ft == 'go' then return { required({ 'go' }), 'build' } end
  else
    if ft == 'c' or ft == 'cpp' then return { required({ binary }) } end
    if ft == 'go' then return { required({ 'go' }), 'run', file } end
    if ft == 'javascript' then return { required({ 'node' }), file } end
    if ft == 'typescript' then return { required({ 'node' }), stem .. '.js' } end
    if ft == 'java' then
      return { required({ 'java' }), '-cp', vim.fn.fnamemodify(file, ':h'), vim.fn.fnamemodify(stem, ':t') }
    end
    if ft == 'rust' then return { required({ 'cargo' }), 'run' } end
    if ft == 'python' then
      return { require('bootstrap').python(), file }
    end
    if ft == 'ps1' then return { required({ 'pwsh', 'powershell' }), '-NoProfile', '-File', file } end
  end
  error('暂不支持此文件类型的' .. (action == 'compile' and '编译' or '运行') .. '：' .. ft, 0)
end

local function execute_current(action)
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then vim.notify('请先给当前文件命名', vim.log.levels.WARN); return end
  if action == 'run' and vim.bo.filetype == 'html' then
    vim.cmd.write()
    return M.open_target(file)
  end
  local ok, argv = pcall(command_for, action, vim.bo.filetype, file)
  if not ok then vim.notify(argv, vim.log.levels.ERROR); return end
  if action == 'compile' then vim.cmd.wall() else vim.cmd.write() end
  return M.open_terminal({ argv = argv })
end

function M.compile_current() return execute_current('compile') end
function M.run_current() return execute_current('run') end

return M
