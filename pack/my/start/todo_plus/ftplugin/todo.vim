" 必须和 filetype 同名
setlocal autoindent
setlocal smartindent
setlocal foldmethod=indent
setlocal foldignore=
setlocal tabstop=2
set expandtab
setlocal shiftwidth=2

let g:todo_symbols= {"todo":"\u25a1", "doing": "\u23F1", "done": "\u2714", "cancel": "\u2717"}

runtime ftplugin/maps.vim
