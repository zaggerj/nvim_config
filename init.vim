"lua/plugins.lua
"mysettings/functions.vim
"mysettings/basic.vim
"mysettings/ui.vim
"mysettings/maps.vim
"mysettings/autocmds.vim
"mysettings/firenvim.vim
"mysettings/ngconsole.vim
" ----------------gf 快速跳转通道----------------

lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('plugins')
EOF

let s:transform = {dir, list -> join(map(list,  { _, module -> dir."/".module.".vim" }), ' ')}

if exists('g:vscode')
    let s:dir = 'vscode'
    let s:modules = [ "plugins", "maps", "vs"]
else
    " ui 必须在 plugins 后，原因：colorscheme 需要 theme 先加载
    " firenvim 必须在最后，覆盖所有的设置
    let s:dir = 'mysettings'
    let s:modules = [ "functions", "basic", "ui", "maps", "autocmds", "ngconsole" ]
endif

" 这里假定加载按照列表顺序，否则应该用链式加载确保顺序
exec "runtime! ".s:transform(s:dir, s:modules)
