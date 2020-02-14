"With ginit.vim
" |>pluggings<|
call plug#begin('~\\vimfiles\\plugged')
    Plug 'Yggdroot/indentLine'
    Plug 'scrooloose/nerdtree'
    "Plug 'yianwillis/vimcdoc'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'PProvost/vim-ps1'
    "Plug 'itchyny/lightline.vim'
    Plug 'reasonml-editor/vim-reason-plus'
    "Plug 'HerringtonDarkholme/yats.vim'
    Plug 'guns/xterm-color-table.vim'
    Plug 'tpope/vim-fugitive'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Plug 'dense-analysis/ale'
    Plug 'liuchengxu/vista.vim'
    Plug 'icymind/NeoSolarized' "Theme
    Plug 'morhetz/gruvbox' 
    Plug 'joshdick/onedark.vim'
    Plug 'luochen1990/rainbow'
    Plug 'pangloss/vim-javascript'
call plug#end()
"
"
" |>my maps<|
let mapleader = " "
inoremap fj <Esc> 
tnoremap fj <C-\><C-n>
inoremap <expr><tab> g:CTab()
noremap <silent> <C-h> <C-w><C-h>
noremap <silent> <C-j> <C-w><C-j>
noremap <silent> <C-k> <C-w><C-k>
noremap <silent> <C-l> <C-w><C-l>
nnoremap <silent> <leader>s :call Set_it()<cr>
nnoremap <silent> <leader>c :call Complier()<cr>
nnoremap <silent> <leader>r :call Runner()<cr>
nnoremap <silent> <leader>v :Vista coc<cr>
nnoremap <silent> <leader>d :NERDTreeFind<cr>	            "NERDTree %:h<cr>
nnoremap <silent> <leader><F1> :AirlineTheme random<cr>
nnoremap <silent> <leader><F2> :!git status -s<cr>
nnoremap <silent> <leader><F3> :!git add %<cr>
nnoremap <silent> <leader><F4> :!git commit -m "
nnoremap <silent> <leader>t :call Open_terminal()<cr>
nnoremap <silent> <leader>I :PlugInstall<cr>
nnoremap <silent> <leader>U :PlugUpdate<cr>
nnoremap <silent> <M-s> :execute "help ".expand("<cword>")<cr>
noremap <silent> gd <Plug>(coc-definition)
noremap <silent> gp <Plug>(coc-diagnostic-prev)
"
" |>my hooks<|
autocmd TermOpen * startinsert
"
" |>regular<|
colo gruvbox
set background=dark
syntax enable
set fileencodings=utf-8,gb2312
set clipboard+=unnamedplus
set cursorline
" Bracket jump like lisp
set showmatch
let g:rainbow_active = 1
set number
"set smartindent
set autoindent
set termguicolors
"set cmdheight=1
set softtabstop=4
set expandtab
set shiftwidth=4
set timeoutlen=1500
"Open window below
set splitbelow
"
" |>PopupMenu<| 
" !After the colo option
" If you use gruvbox, do not set other airline theme!
set pumblend=10
set winblend=30
hi Pmenu guifg=#dfaf00 "Normal popup menu's color
hi PmenuSel guifg=#00afff guibg=#dfffaf blend=0  "Selected item's color
hi PmenuSbar guibg=#3a3a3a "Scroll bar's color
hi PmenuThumb guibg=#ffffff "Scroll button's color.
"
" |>my funcs<|
" Tab to complete
let g:CTab = {-> pumvisible() ? "\<C-n>" : "\<tab>"}
" Caclulator, you can also use winheight() and winwidth()
let g:Spheight = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vspwidth = {x -> float2nr(nvim_win_get_width(0) * x)}

" Function to get current file path
function! Get_current_path(...)
    if a:0 == 0
        return expand("%")
    else
        return expand("%:".a:1)
    endif
endfunction

function! PercentSplit(percent, action)
    if a:action == "sp"
        let l:temp = g:Spheight(a:percent)
    else
        let l:temp = g:Vspwidth(a:percent)
    endif
    exe l:temp.a:action
endfunction

function! Complier()
    exe "w"
    call PercentSplit(0.4, "sp")
    exe "cd %:h"    
    if &filetype=='c'
	exe "te clang -o %:r.exe %"
    elseif &filetype=='cpp'
	exe "te g++ -o %:r.exe %"
    elseif &filetype == 'java'
        exe "te javac %"
    elseif &filetype == 'scheme'
        exe "te racket % -p sicp"
    elseif &filetype == 'python'
	exe "te python %"
    elseif &filetype == 'ps1'
	exe "te powershell -c \"./%\""
    elseif &filetype == 'scala'
	exe "te scalac %"
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
    elseif &filetype == 'scala'
        exe "te scala %:r"
    else
        exe "q"
    endif
endfunc

function! Set_it()
    exe g:Spheight(0.8)."sp ~/AppData/Local/nvim/init.vim"
    exe "cd %:h"
endfunc

function! Open_terminal()
    exe "cd %:h"
    call PercentSplit(0.4, "sp")
    exe "te pwsh"
endfunction
"
" |>airline<|
let &laststatus = 2
let &showmode = 0
let g:airline_section_b = '%{FugitiveStatusline()}'
"let g:airline#extensions#ale#enabled = 1
"Must after colo
let g:airline_theme='gruvbox'
" Always display if 2, turn off GuiTabline in ginit when using nvim-qt
let &showtabline = 1
let g:airline#extensions#tabline#enabled = 1

let g:airline_powerline_fonts=1
"基本主题，需要修改的话取消注释掉底下对应项目以覆盖
"if !exists('g:airline_symbols')	
"  let g:airline_symbols={}
"endif
"let g:airline_left_sep = "\ue0bc"
"let g:airline_left_alt_sep = "\ue0b8"
"let g:airline_right_sep = "\ue0ba"
"let g:airline_right_alt_sep = "\ue0cf"
"let g:airline_symbols.branch = "\ue0a0"
"let g:airline_symbols.readonly = "\ue0a2"
"let g:airline_symbols.linenr = "\ue0a3"
"let g:airline_symbols.maxlinenr = "\ue0a1"
"let g:airline_symbols.dirty='⚡'
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
let g:rainbow_conf = {'guifgs': ['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Purple']}
