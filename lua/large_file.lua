local M = { max_bytes = 1024 * 1024, max_lines = 20000, max_line = 20000 }
local group = vim.api.nvim_create_augroup('LargeFileProtection', { clear = true })
local changed_lines = {}

local function watch_changes(buf)
  if changed_lines[buf] or vim.bo[buf].buftype ~= '' then return end
  changed_lines[buf] = {}
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function(_, current, _, first, old_last, new_last)
      local dirty = changed_lines[current]
      if not dirty then return true end
      -- 只记范围；回调处于textlock中，昂贵功能的解除留到编辑事件。
      dirty.first = math.min(dirty.first or first, first)
      dirty.last = math.max((dirty.last or old_last) + new_last - old_last, new_last)
    end,
    on_detach = function(_, current) changed_lines[current] = nil end,
  })
end

function M.is_large(buf)
  return vim.b[buf or 0].large_file == true
end

local function window_options(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    for name, value in pairs({ foldmethod = 'manual', foldenable = false,
      wrap = false, spell = false, list = false, cursorline = false,
      relativenumber = false, colorcolumn = '' }) do
      local saved = vim.w[win].large_file_options or {}
      if saved[name] == nil then saved[name] = vim.wo[win][name] end
      vim.w[win].large_file_options = saved
      vim.wo[win][name] = value
    end
  end
end

local function protect(buf, reason)
  if not M.is_large(buf) then
    vim.b[buf].large_file = true
    vim.b[buf].large_file_reason = reason
    vim.b[buf].original_filetype = vim.bo[buf].filetype
    -- 在 FileType 事件前切换类型，避免语言插件读取完整文件或启动服务。
    vim.b[buf].coc_enabled = 0
    vim.b[buf].coc_suggest_disable = 1
    vim.b[buf].coc_diagnostic_disable = 1
    vim.b[buf].coc_disable_autoformat = 1
    vim.b[buf].copilot_enabled = false
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if client.name == 'GitHub Copilot' then vim.lsp.buf_detach_client(buf, client.id) end
    end
    vim.b[buf].ibl_enabled = false
    vim.bo[buf].filetype = 'bigfile'
    vim.bo[buf].syntax = ''
    vim.bo[buf].synmaxcol = 200
    vim.bo[buf].indentexpr = ''
    vim.bo[buf].formatexpr = ''
    pcall(vim.treesitter.stop, buf)
    for module, method in pairs({ gitsigns = 'detach', ufo = 'detach' }) do
      if package.loaded[module] then pcall(package.loaded[module][method], buf) end
    end
    if package.loaded.ibl then package.loaded.ibl.setup_buffer(buf, { enabled = false }) end
  end
  window_options(buf)
end

local function check(buf)
  if vim.bo[buf].buftype ~= '' then return end
  watch_changes(buf)
  if M.is_large(buf) then window_options(buf); return end
  local lines = vim.api.nvim_buf_line_count(buf)
  if lines > M.max_lines then protect(buf, '超过 20000 行'); return end
  if vim.api.nvim_buf_get_offset(buf, lines) > M.max_bytes then
    protect(buf, '超过 1 MiB'); return
  end
  local dirty = changed_lines[buf]
  if dirty and dirty.first then
    local first, last = dirty.first, math.min(dirty.last, lines)
    dirty.first, dirty.last = nil, nil
    for start = first, last - 1, 256 do
      for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, start, math.min(start + 256, last), false)) do
        if #line > M.max_line then protect(buf, '单行超过 20000 字节'); return end
      end
    end
  end
end

vim.api.nvim_create_autocmd('BufReadPre', {
  group = group,
  callback = function(ev)
    local stat = (vim.uv or vim.loop).fs_stat(vim.api.nvim_buf_get_name(ev.buf))
    if stat and stat.size > M.max_bytes then protect(ev.buf, '超过 1 MiB') end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = group,
  callback = function(ev)
    check(ev.buf)
    if M.is_large(ev.buf) then
      vim.api.nvim_buf_call(ev.buf, function() vim.cmd('setfiletype bigfile') end)
      vim.bo[ev.buf].filetype = 'bigfile'
      vim.bo[ev.buf].syntax = ''
    end
    if not M.is_large(ev.buf) then
      -- 文件已被限制在 1 MiB 内，按块检查压缩代码的超长行。
      local count = vim.api.nvim_buf_line_count(ev.buf)
      for start = 0, count - 1, 256 do
        for _, line in ipairs(vim.api.nvim_buf_get_lines(ev.buf, start, math.min(start + 256, count), false)) do
          if #line > M.max_line then protect(ev.buf, '单行超过 20000 字节'); return end
        end
      end
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  callback = function(ev)
    if M.is_large(ev.buf) then
      vim.bo[ev.buf].filetype = 'bigfile'
      vim.bo[ev.buf].syntax = ''
      vim.bo[ev.buf].indentexpr = ''
      window_options(ev.buf)
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'TextChanged', 'TextChangedI' }, {
  group = group, callback = function(ev)
    check(ev.buf)
    if not M.is_large(ev.buf) then
      for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
        local saved = vim.w[win].large_file_options
        if saved then
          for name, value in pairs(saved) do vim.wo[win][name] = value end
          vim.w[win].large_file_options = nil
        end
      end
    end
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'FocusGained', 'InsertLeave' }, {
  group = group,
  callback = function(ev)
    if M.is_large(ev.buf) then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then window_options(ev.buf) end
      end)
    end
  end,
})

-- 大文件首次启动时不加载这些插件；切回普通文件后再按需加载。
local function normal_code_file(buf)
  return vim.api.nvim_buf_is_valid(buf) and not M.is_large(buf)
    and vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) ~= ''
    and vim.bo[buf].filetype ~= '' and vim.bo[buf].filetype ~= 'text'
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'VimEnter' }, {
  group = group,
  callback = function(ev)
    watch_changes(ev.buf)
    if not normal_code_file(ev.buf) then return end
    vim.schedule(function()
      if vim.api.nvim_get_current_buf() == ev.buf and normal_code_file(ev.buf) then
        vim.api.nvim_exec_autocmds('User', { pattern = 'NormalFile', modeline = false })
      end
    end)
  end,
})

vim.api.nvim_create_user_command('LargeFileInfo', function()
  print(M.is_large() and ('大文件模式：' .. vim.b.large_file_reason) or '普通文件模式')
end, {})
return M
