"mysettings/plugins.vim
"mysettings/functions.vim
"mysettings/basic.vim
"mysettings/ui.vim
"mysettings/maps.vim
"mysettings/autocmds.vim
" ----------------gf 快速跳转通道----------------

let s:module_dir = "mysettings"

" ui 必须在 plugins 后，原因：colo 需要 theme 先加载
let s:modules = [ "plugins", "functions", "basic", "ui", "maps", "autocmds"]

" load choosed modules
for module in s:modules
    exec "runtime ".s:module_dir."/".module.".vim"
endfor

