" 不要放到函数中，否则会得到错误的路径
let s:sdir = expand("<sfile>:p:h")
function! todo#init()
    exec "py3file ".s:sdir."/Item.py"
endfunction

function todo#done() abort
    py3 Item().toggleDone()
endfunction

function todo#cancel() abort
    py3 Item().toggleCancel()
endfunction

function todo#start() abort
    py3 Item().toggleStart()
endfunction
