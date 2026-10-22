-- 现有Telescope承接命令面板；使用记录存JSON，原legendary数据库保留。
local M = {}
local custom = {
  { 'Lazy', '打开插件管理器' }, { 'Lazy sync', '同步插件' },
  { 'Lazy update', '更新插件' }, { 'NvimTreeFindFileToggle', '切换文件树' },
  { 'Vista!!', '切换代码大纲' }, { 'Tutor zh', '启动中文教程' }, { 'Tutor en', '启动英文教程' },
  { 'Telescope keymaps', '查看全部模式快捷键' }, { 'Telescope commands', '查看全部命令及说明' },
}
local function location()
  local directory = vim.env.NVIM_PALETTE_DATA or (vim.fn.stdpath('data') .. '/command-palette')
  return directory, directory .. '/usage.json'
end
local function history()
  local directory, path = location()
  local usage = {}
  if vim.fn.filereadable(path) == 1 then
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), '\n'))
    if not ok then error('命令面板使用记录损坏，已保留原文：' .. path) end
    usage = data
  end
  return directory, path, usage
end
local function score(entry)
  local thresholds = { {240,100}, {1440,80}, {4320,60}, {10080,40}, {43200,20}, {129600,10} }
  local recency = 0
  for _, timestamp in ipairs(entry.timestamps or {}) do
    local age = (os.time() - timestamp) / 60
    for _, threshold in ipairs(thresholds) do
      if age <= threshold[1] then recency = recency + threshold[2]; break end
    end
  end
  return (entry.count or 0) * recency / 10
end
local function execute(command)
  local directory, path = location()
  vim.fn.mkdir(directory, 'p')
  local uv = vim.uv or vim.loop
  local lock = path .. '.lock'
  local descriptor, lock_error
  vim.wait(2000, function()
    descriptor, lock_error = uv.fs_open(lock, 'wx', 384)
    return descriptor ~= nil or not (lock_error or ''):find('EEXIST', 1, true)
  end, 10)
  if not descriptor then
    error('无法锁定命令使用记录：' .. tostring(lock_error)
      .. '\n若其他编辑器已关闭，请核对并移除遗留锁：' .. lock)
  end
  uv.fs_write(descriptor, tostring(vim.fn.getpid()), 0)
  local ok, err = xpcall(function()
    -- 获得跨进程锁后重新读，避免多个编辑器覆盖彼此计数。
    local _, _, usage = history()
    local entry = usage[command] or { count = 0, timestamps = {} }
    entry.count = entry.count + 1
    entry.timestamps[#entry.timestamps + 1] = os.time()
    while #entry.timestamps > 10 do table.remove(entry.timestamps, 1) end
    usage[command] = entry
    local staged = path .. '.new'
    vim.fn.writefile({ vim.json.encode(usage) }, staged)
    assert(uv.fs_rename(staged, path))
  end, debug.traceback)
  uv.fs_close(descriptor)
  uv.fs_unlink(lock)
  if not ok then error(err) end
  vim.cmd(command)
end
function M.open(command)
  if command and command ~= '' then execute(command); return end
  local _, _, usage = history()
  local entries, seen = {}, {}
  local function add(cmd, description)
    if seen[cmd] then return end
    seen[cmd] = true
    entries[#entries + 1] = { command = cmd, description = description or '',
      score = score(usage[cmd] or {}) }
  end
  for _, item in ipairs(custom) do add(item[1], item[2]) end
  for _, cmd in ipairs(vim.fn.getcompletion('', 'command')) do add(cmd) end
  table.sort(entries, function(a,b)
    if a.score ~= b.score then return a.score > b.score end
    return a.command < b.command
  end)
  local actions = require('telescope.actions')
  local state = require('telescope.actions.state')
  require('telescope.pickers').new({}, {
    prompt_title = '命令面板（频率与最近使用）',
    finder = require('telescope.finders').new_table({ results = entries,
      entry_maker = function(item) return { value = item,
        display = item.command .. '  ' .. item.description, ordinal = item.command .. ' ' .. item.description } end }),
    sorter = require('telescope.config').values.generic_sorter({}),
    attach_mappings = function(prompt)
      actions.select_default:replace(function()
        local entry = state.get_selected_entry()
        actions.close(prompt)
        if entry then execute(entry.value.command) end
      end)
      return true
    end,
  }):find()
end
function M.setup()
  for _, name in ipairs({ 'CommandPalette', 'Legendary' }) do
    vim.api.nvim_create_user_command(name, function(args) M.open(args.args) end,
      { nargs = '*', desc = '命令面板（保留Legendary入口）', force = true })
  end
  -- 旧配置 db_root 没有尾斜杠，上游直接拼接文件名，两种位置都要识别。
  local data = vim.fn.stdpath('data')
  if vim.fn.filereadable(data .. '/command-palette/usage.json') == 0 then
    for _, path in ipairs({ data .. '/legendary/legendary_frecency.sqlite3', data .. '/legendarylegendary_frecency.sqlite3' }) do
      if vim.fn.filereadable(path) == 1 then
        vim.schedule(function()
          vim.notify('发现保留的 Legendary 使用记录：' .. path
            .. '\n请运行 scripts/import_palette_history.py 显式迁移；说明见 docs/implementation-2026-10-22.md。', vim.log.levels.WARN)
        end)
      end
    end
  end
end
return M
