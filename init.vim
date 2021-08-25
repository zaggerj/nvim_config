let s:module_dir = "mysettings"

" ui 必须在 plugins 后，原因：colo 需要 theme 先加载
let s:modules = [ "plugins", "functions", "basic", "ui", "maps", "autocmds"]

" load choosed modules
for module in s:modules
    exec "runtime ".s:module_dir."/".module.".vim"
endfor
