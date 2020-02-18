"With ginit.vim
" |>Installed plugins<|
call plug#begin('~\\vimfiles\\plugged')
    Plug 'Yggdroot/indentLine'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'tpope/vim-fugitive'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'morhetz/gruvbox' 
    Plug 'joshdick/onedark.vim'
    Plug 'luochen1990/rainbow'
    Plug 'pangloss/vim-javascript'
call plug#end()
"
" |>my maps<|
let mapleader = " "
inoremap fj <Esc> 
tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>
inoremap <expr><tab> g:CTab()
noremap <silent> <C-h> <C-w><C-h>
noremap <silent> <C-j> <C-w><C-j>
noremap <silent> <C-k> <C-w><C-k>
noremap <silent> <C-l> <C-w><C-l>
nnoremap <silent> <leader>s :call Set_it()<cr>
nnoremap <silent> <leader>c :call Compiler()<cr>
nnoremap <silent> <leader>r :call Runner()<cr>
nnoremap <silent> <leader>v :Vista coc<cr>
nnoremap <silent> <leader>d :NERDTreeFind<cr>	            "NERDTree %:h<cr>
nnoremap <silent> <leader>gs :!git status -s<cr>
nnoremap <silent> <leader>ga :!git add %<cr>
nnoremap <silent> <leader>gp :!git push<cr>
nnoremap <leader>gc :!git commit -a -m ""<left>
nnoremap <silent> <leader>t :call Open_terminal()<cr>
nnoremap <silent> <leader>I :PlugInstall<cr>
nnoremap <silent> <leader>U :PlugUpdate<cr>
nnoremap <silent> <C-s> :execute "help ".expand("<cword>")<cr>
noremap <silent> gd <Plug>(coc-definition)
"
" |>my autocmd<|
autocmd TermOpen * startinsert
"
" |>options(universal)<|
" `:options` for all available options.
syntax enable
set incsearch
set fileencodings=utf-8,gb2312
set clipboard+=unnamedplus
set cursorline
" set showmatch
set number
set smartindent
set autoindent
"set cmdheight=1
set softtabstop=4
set expandtab
set shiftwidth=4
set timeoutlen=1500
set splitbelow
"
" |>theme<| 
set termguicolors
colo gruvbox
set background=dark
set pumblend=10
set winblend=30
"
" |>my funcs<|
" Tab to complete
let g:CTab = {-> pumvisible() ? "\<C-n>" : "\<tab>"}
" Caclulator, you can also use winheight() and winwidth()
let g:Sp_height = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vsp_width = {x -> float2nr(nvim_win_get_width(0) * x)}
"
" Function to get current absolute file path
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
    exe l:temp.a:action
endfunction

function! Compiler()
    exe "w"
    call PercentSplit(0.4, "sp")
    if &filetype=='c'
	exe "te clang -o %:r.exe %"
    elseif &filetype=='cpp'
	exe "te g++ -o %:r.exe %"
    elseif &filetype == 'java'
        exe "te javac %"
    elseif &filetype == 'javascript'
        exe "te node %"
    elseif &filetype == 'python'
	exe "te python %"
    elseif &filetype == 'ps1'
	exe "te powershell -c \"./%\""
    else 
	echo 'Do not support this type of file!'
        exe "q"
    endif
endfunc

function! Runner()
    call PercentSplit(0.4, "sp")
    if &filetype=='cpp'
        exe "te %:r.exe"
    elseif &filetype == 'c'
        exe "te %:r.exe"
    elseif &filetype == 'java'
        exe "te java %:r"
    else
        exe "q"
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
"||>plugs<||
"
" |>airline<|
set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme='gruvbox'
let g:airline_section_b = '%{FugitiveStatusline()}'
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline_powerline_fonts=1
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
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Purple'])}
"
" |>vim-plug<|
let g:plug_timeout = 120
let g:plug_retries = 3
