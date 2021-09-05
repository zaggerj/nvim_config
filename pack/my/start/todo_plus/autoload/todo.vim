" 不要放到函数中，否则会得到错误的路径
let s:sdir = expand("<sfile>:p:h")
function! todo#init()
    exec "py3file ".s:sdir."/Item.py"
endfunction

function! todo#generate() abort
    py3 Item().toTodo()
endfunction

function todo#done() abort
    py3 Item().toggleDone()
endfunction

function! todo#archive() abort
" 处理没有 archive project 的情况
python3 << EOF
import vim

noarchive = True
buffer = vim.current.buffer
for line in buffer:
    if "Archive:" in line:
        noarchive = False

if noarchive:
    buffer.append("")
    buffer.append("Archive:")
EOF
    g/[✔✗]/m$
    normal ={j<<
endfunction

function todo#cancel() abort
    py3 Item().toggleCancel()
endfunction

function todo#start() abort
    py3 Item().toggleStart()
endfunction
