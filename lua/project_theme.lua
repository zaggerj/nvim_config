-- 项目身份来自文件系统；不在切换buffer时启动Git进程。
local M = {}
local roots = {}
local warned = {}
local uv = vim.uv or vim.loop
local markers = { 'package.json', 'go.work', 'go.mod', 'pyproject.toml', 'Cargo.toml' }

local function normalized(path)
  local value = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ':p')):gsub('/+$', '')
  if vim.fn.has('win32') == 1 then value = value:lower() end
  return value
end

local function project_root(file)
  local start = vim.fs.dirname(file)
  if roots[start] then return roots[start] end
  local visited, current, workspace = {}, start, nil
  while current do
    visited[#visited + 1] = current
    if uv.fs_stat(current .. '/.git') then
      for _, dir in ipairs(visited) do roots[dir] = current end
      return current
    end
    if not workspace then
      for _, marker in ipairs(markers) do
        if uv.fs_stat(current .. '/' .. marker) then workspace = current; break end
      end
    end
    local parent = vim.fs.dirname(current)
    if parent == current then break end
    current = parent
  end
  local fallback = workspace or vim.fn.getcwd()
  roots[start] = fallback
  return fallback
end

local function theme_for(root, file)
  local identity = normalized(root)
  local active = file ~= '' and normalized(file) or identity
  local best, background, score = nil, nil, -1
  for _, rule in ipairs(vim.g.nvim_project_themes or {}) do
    local rank
    if rule.root then
      local value = rule.root:gsub('\\', '/'):gsub('/+$', '')
      if value:sub(1, 1) == '~' or value:sub(1, 1) == '/' or value:match('^%a:/') then
        if normalized(value) == identity then rank = 300 end
      else
        if vim.fn.has('win32') == 1 then value = value:lower() end
        if identity == value or identity:sub(-#value - 1) == '/' .. value then rank = 200 end
      end
    end
    if rank then
      local subdir = (rule.subdir or ''):gsub('\\', '/'):gsub('^/+', ''):gsub('/+$', '')
      local target = subdir == '' and identity or normalized(root .. '/' .. subdir)
      if active == target or active:sub(1, #target + 1) == target .. '/' then
        local priority = rank * 10000 + #subdir
        if priority > score then best, background, score = rule.theme, rule.background, priority end
      end
    end
  end
  if best then return best, background end
  if identity:find('_oem', 1, true) then return 'onelight' end
  if identity:find('_bug', 1, true) then return 'everforest' end
  return 'catppuccin-latte', 'light'
end

function M.apply()
  if vim.bo.buftype ~= '' then return end
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' and vim.v.vim_did_enter == 0 and vim.fn.argc() > 0 then
    file = vim.fn.fnamemodify(vim.fn.argv(0), ':p')
  end
  local root = file ~= '' and project_root(file) or vim.fn.getcwd()
  local theme, background = theme_for(root, file)
  -- 先确定背景模式；主题插件可能在深浅切换时重选变体（如Latte/Mocha）。
  if (background == 'light' or background == 'dark') and vim.o.background ~= background then
    vim.o.background = background
  end
  if theme and vim.g.colors_name ~= theme then
    local ok, err = pcall(vim.cmd.colorscheme, theme)
    if not ok and not warned[theme] then
      warned[theme] = true
      vim.notify('项目主题 ' .. theme .. ' 无法加载，请检查 nvim_project_themes：' .. tostring(err), vim.log.levels.WARN)
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('ProjectTheme', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', { group = group, nested = true, callback = M.apply })
  vim.api.nvim_create_autocmd('DirChanged', { group = group, nested = true, callback = function()
    roots = {}
    M.apply()
  end })
  M.apply()
end

return M
