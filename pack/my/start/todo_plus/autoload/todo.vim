let s:sdir = expand("<sfile>:p:h")

exec "py3file ".s:sdir."/Item.py"

function todo#done() abort
    py3 Item().toggleDone()
endfunction

command! Reload :call <SID>Reload()<cr>
function! <SID>Reload()
    wa
    syn clear
    syn on
endfunction

