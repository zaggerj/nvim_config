command! Reload :call <SID>Reload()<cr>
function! <SID>Reload()
    wa
    syn clear
    syn on
endfunction

py3file runtime/main.py

function todo#done() abort
endfunction

runtime autoload/maps.vim
