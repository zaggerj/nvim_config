"mysettings/plugins.vim
"mysettings/functions.vim
"mysettings/basic.vim
"mysettings/ui.vim
"mysettings/maps.vim
"mysettings/autocmds.vim
"mysettings/firenvim.vim
" ----------------gf 快速跳转通道----------------

let s:module_dir = "mysettings"

" ui 必须在 plugins 后，原因：colo 需要 theme 先加载
" firenvim 必须在最后，覆盖所有的设置
let s:modules = [ "plugins", "functions", "basic", "ui", "maps", "autocmds", "firenvim"]
" load choosed modules
for module in s:modules
    exec "runtime ".s:module_dir."/".module.".vim"
endfor
