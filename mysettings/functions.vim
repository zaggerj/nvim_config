" Caclulator, you can also use winheight() and winwidth()
let g:Sp_height = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vsp_width = {x -> float2nr(nvim_win_get_width(0) * x)}

" Tab to complete
function! Check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" function! CTab()
"     " 优先考虑有弹出菜单的情况，否则<tab>将不会进行菜单选择。.
"     if pumvisible()
"         return "\<C-N>"
"     else
"         " 获取光标前四个字符, 相比于整行正则匹配效率更高.
"         let matchL = strpart(getline('.'), col('.') - 5, 4) 
"         " 匹配路径
"         let isPath = match(matchL, '/\|\\') 
"         " 匹配是否有字符
"         let isNormal = match(matchL, '\w') 
"         " -1代表无匹配, 没有字符就TAB
"         if isNormal == -1
"             return "\<tab>"
"             " 有字符则按照以下顺序尝试： filepath -> omnifunc.
"             " 文件路径补全
"         elseif isPath != -1
"             return "\<C-X>\<C-F>"
"             " 尝试omni补全
"         elseif isNormal != -1 
"             " 如果没有设置 omnifunc 函数，则尝试关键字补全
"             if &omnifunc == "" 
"                 return "\<C-X>\<C-N>"
"             else
"                 return "\<C-X>\<C-O>"
"             endif
"         endif
"     endif
" endf

" Function to get current absolute file path, also see fnamemodify()
function! Get_current_path(...)
    if a:0 == 0
        return expand("%:p")
    elseif a:0 > 1
        echom "Wrong argument"
    else
        return expand("%".a:1)
    endif
endf

" Split window in percent.
function! PercentSplit(percent, action)
    if a:action == "sp"
        let l:temp = g:Sp_height(a:percent)
    else
        let l:temp = g:Vsp_width(a:percent)
    endif
    " [N]sp/vsp
    exe l:temp.a:action
endf

" 保留原函数接口，命令发现、路径和 argv 由跨平台模块统一处理。
function! Compiler()
    lua require('platform').compile_current()
endfunction

function! Runner()
    lua require('platform').run_current()
endfunction

" Neovim 专属
function! Set_it()
    exe g:Sp_height(0.8)."sp ".fnameescape(stdpath("config")."/init.vim")
    " lcd %:h"：这是要执行的命令字符串。在这个命令中，lcd 是 Vim 的内置命令，用于改变当前目录（working directory）。% 表示当前文件的路径，而 :h 是一个修饰符，表示获取当前文件所在目录的路径。
    exe "lcd ".fnameescape(expand('%:p:h'))
endf

function! Go_plugin()
    lua require('nvim-tree.api').tree.open({path = vim.fn.stdpath('data') .. '/lazy'})
endf

function! Open_terminal()
    lua require('platform').open_terminal()
endfunction

" 打开 quickfix 或者 locallist
function! Open_fix()
    if len(getqflist())
        copen
    elseif len(getloclist(0)) 
        lopen
    else
        echo 'Neither quickfix or locallist has any sources!'
    endif
endfunction
