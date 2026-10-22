"lua/plugins.lua
"mysettings/functions.vim
"mysettings/basic.vim
"mysettings/ui.vim
"mysettings/maps.vim
"mysettings/autocmds.vim
"mysettings/firenvim.vim
"mysettings/ngconsole.vim
" ----------------gf 快速跳转通道----------------

let g:nvim_config_root = fnamemodify(expand('<sfile>:p'), ':h')
execute 'set runtimepath^=' . fnameescape(g:nvim_config_root)
if !isdirectory(stdpath('data') . '/lazy/lazy.nvim')
  echohl WarningMsg
  echom '尚未部署 lazy.nvim。请运行 scripts/deploy.py --data <stdpath(data)> --bootstrap-lazy --apply'
  echohl None
  finish
endif
lua << EOF
require('bootstrap').init(vim.g.nvim_config_root)
require('large_file')
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

" 扩展安装属于部署步骤，不在编辑启动时自动访问 npm 或旧 TabNine 域名。
let g:coc_global_extensions = []
lua require('coc_setup').register()
