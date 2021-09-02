let s:sdir = expand("<sfile>:p:h")

exec "py3file ".s:sdir."/Item.py"

function todo#done() abort
    py3 Item().toggleDone()
endfunction
