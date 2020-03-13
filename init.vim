"With ginit.vim
" |>Installed plugins<|
call plug#begin('~\\vimfiles\\plugged')
    Plug 'Yggdroot/indentLine'
    Plug 'luochen1990/rainbow'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-fugitive'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    "themes
    Plug 'morhetz/gruvbox' 
    Plug 'crusoexia/vim-monokai' 
    Plug 'joshdick/onedark.vim'
    "syntax
    Plug 'pangloss/vim-javascript'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'mattn/emmet-vim'
    "clojure
    Plug 'guns/vim-clojure-static'
    Plug 'tpope/vim-fireplace'
call plug#end()
"
" |>my maps<|
let mapleader = " "
inoremap fj <Esc> 
inoremap <silent><tab> <C-R>=CTab()<cr>

tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>

noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l
noremap <silent> <A-H> <C-w>H
noremap <silent> <A-J> <C-w>J
noremap <silent> <A-K> <C-w>K
noremap <silent> <A-L> <C-w>L

noremap <silent> <leader>c :call Compiler()<cr>
noremap <silent> <leader>r :call Runner()<cr>
nnoremap <silent> <leader>s :call Set_it()<cr>
nnoremap <silent> <leader>v :Vista coc<cr>
nnoremap <silent> <leader>d :NERDTreeFind<cr>
nnoremap <silent> <leader>gs :!git status -s<cr>
nnoremap <silent> <leader>ga :!git add %<cr>
nnoremap <silent> <leader>gp :!git push<cr>
nnoremap <leader>gc :!git commit -a -m ""<left>
nnoremap <silent> <leader>t :call Open_terminal()<cr>
nnoremap <silent> <leader>I :PlugInstall<cr>
nnoremap <silent> <leader>U :PlugUpdate<cr>
nnoremap <silent> <C-s> :execute "help ".expand("<cword>")<cr>
noremap <silent> gd <Plug>(coc-definition)
"Plug's maps
let g:user_emmet_leader_key = '<M-m>'
"
" |>my autocmd<|
autocmd TermOpen * startinsert
autocmd BufNewFile,BufRead *.js,*.html set tabstop=2 | set shiftwidth=2 
"
" |>options(universal)<|
" `:options` for all available options.
syntax enable
set incsearch
set fileencodings=utf-8,gb2312
set cursorline
" set showmatch
set number
set smartindent
set autoindent
"set cmdheight=1
set expandtab
set tabstop=4
set shiftwidth=4
set timeoutlen=1500
set splitbelow
"
" |>theme<| 
set termguicolors
colo monokai
set background=dark
set pumblend=10
set winblend=30
"
" |>my funcs<|
" Caclulator, you can also use winheight() and winwidth()
let g:Sp_height = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vsp_width = {x -> float2nr(nvim_win_get_width(0) * x)}
"
" Tab to complete
function! CTab()
    "有弹出菜单则进入选择模式.
    if pumvisible()
        return "\<C-N>"
    " 如果光标所在处的前两个字符组成的字符串中包含word, 则尝试omni补全,
    " 相比于整行匹配效率更高.
    elseif match(strpart(getline('.'), col('.') - 3, 2), '\w') != -1 && &omnifunc != ""
        return "\<C-X>\<C-O>"
    else
        return "\<tab>"
    endif
endfunction

" Function to get current absolute file path, also see fnamemodify()
function! Get_current_path(...)
    if a:0 == 0
        return expand("%:p")
    elseif a:0 > 1
        echom "Wrong argument"
    else
        return expand("%".a:1)
    endif
endfunction

" Split window in percent.
function! PercentSplit(percent, action)
    if a:action == "sp"
        let l:temp = g:Sp_height(a:percent)
    else
        let l:temp = g:Vsp_width(a:percent)
    endif
    " Nsp/vsp
    exe l:temp.a:action
endfunction

function! Compiler()
    exe "wa"
    call PercentSplit(0.4, "sp")
    if &filetype=='c'
        exe "te clang -o %:r.exe %"
    elseif &filetype=='cpp'
        exe "te g++ -o %:r.exe %"
    elseif &filetype == 'java'
        exe "te javac %"
    else 
        echo 'Do not support this type of file!'
        exe "q"
    endif
endfunc

function! Runner()
    if &filetype == 'clojure'
        exe "Eval"
    elseif &filetype == 'html'
        write
        exe "!%"
    else
        write
        call PercentSplit(0.4, "sp")
        if &filetype=='cpp'|| &filetype=='c'
            exe "te %:r.exe"
        elseif &filetype == 'java'
            exe "te java %:r"
        elseif &filetype == 'javascript'
            exe "te node %"
        elseif &filetype == 'python'
            exe "te python %"
        elseif &filetype == 'ps1'
            exe "te powershell -c \"./%\""
        else
            quit
        endif
    endif
endfunc

function! Set_it()
    exe g:Sp_height(0.8)."sp ~/AppData/Local/nvim/init.vim"
    exe "cd %:h"
endfunc

function! Open_terminal()
    call PercentSplit(0.4, "sp")
    exe "te powershell"
endfunction
"
"
"||>plugs<||
"
" |>airline<|
set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme='monokai'
let g:airline_powerline_fonts = 0
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1
"
" |>vista<|
let g:vista_cursor_delay = 70
let g:vista_sidebar_position = "vertical topleft"
"
" |>coc-nvim<|
let g:coc_enable_locationlist = 0

" |>highlight<|
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1

let g:python_highlight_all = 1
"
" |>rainbow<|
let g:rainbow_active = 1
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}
"
" |>vim-plug<|
let g:plug_timeout = 120
let g:plug_retries = 3
