"With ginit.vim
" |>pluggings<|
call plug#begin('~\\vimfiles\\plugged')
    Plug 'Yggdroot/indentLine'
    Plug 'scrooloose/nerdtree'
    Plug 'yianwillis/vimcdoc'
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
call plug#end()
"
" |>my maps<|
let mapleader = " "
"inoremap ' ''<Esc>i    "Now have coc-pair plugin
"inoremap " ""<Esc>i
"inoremap ( ()<Esc>i
"inoremap ) <Esc>la
"inoremap { {}<Esc>i<cr><Esc>O
"inoremap [ []<Esc>i
"inoremap ] <Esc>la
inoremap fj <Esc> 
inoremap <expr><tab> CTab()
tnoremap <Esc> <C-\><C-n>
nmap <silent> <leader>s :call Set_it()<cr>
nnoremap <silent> <leader>c :call Complier()<cr>
nnoremap <silent> <leader>r :call Runner()<cr>
noremap <silent> <leader>v :Vista coc<cr>
noremap <silent> <leader>d :NERDTreeFind<cr>	            "NERDTree %:h<cr>
noremap <silent> <leader><F1> :AirlineTheme random<cr>
noremap <silent> <leader><F2> :!git status -s<cr>
noremap <silent> <leader><F3> :!git add %<cr>
noremap <silent> <leader><F4> :!git commit -m "
noremap <silent> <leader>t :call Open_terminal()<cr>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
"
" |>my hooks<|
autocmd TermOpen * startinsert
"autocmd BufRead,BufNewFile *.rkt if &ft == 'scheme' | set ft=racket | endif
autocmd BufRead,BufNewFile *.elm set ft=elm
"
" |>regular<|
colo gruvbox
let &background="dark"
syntax enable
let &encoding="utf-8"
let &fileencodings="utf-8,gb2312"
"set clipboard+=unnamedplus "总是启用系统剪贴板(Always use system clipboard),Maybe lower speed
let &cursorline=1
let &showmatch = 1 "Just like lisp repl's bracket highlight
let g:rainbow_active = 1
"let &guifont="FiraCode Nerd Font:h15" "In nvim-qt, you can make a file
"'ginit.vim' and modify this option in it.
let &number=1
"set smartindent
let &autoindent=1
let &lisp = 0 " lisp's indent
let &termguicolors=1 
"let &t_Co=256
"let &cmdheight=1 " 见帮助(doc)，默认为1。
let &softtabstop=4
let &expandtab = 1 "Don't use TABs
let &shiftwidth=4
let &timeoutlen = 1500
"let &autochroot=1 "auto change path to current path.
"set shell=pwsh
"set shellpipe=\| shellredir=> shellxquote=\(	 	 "Not '\' or '(' !!! Must setting the xquote not quote!!!
"set shellcmdflag=/c					 "Not /s/c or /s\ /c or /s\ /c\ ! Can be -c or -Command
"
" |>PopupMenu<| After the colo option
"If you use gruvbox, do not set Pmenu guibg option
hi Pmenu guifg=#dfaf00 "Normal popup menu's color
hi PmenuSel guifg=#00afff guibg=#dfffaf "Selected item's color
hi PmenuSbar guibg=#3a3a3a "Scroll bar's color
hi PmenuThumb guibg=#ffffff "Scroll button's color.
"
" |>my funcs<|
let &splitbelow=1 "Open window below
function! Complier()
    exe "w"
    exe "10sp" 
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
    exe "13sp"
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
    exe "25sp ~/AppData/Local/nvim/init.vim"
    exe "cd %:h"
endfunc

function! Open_terminal()
    exe "cd %:h"
    exe "20sp"
    exe "te"
endfunction

let CTab = {-> pumvisible() ? "\<C-n>" : "\<tab>"}
"
" |>airline<|
let &laststatus = 2
let &showmode = 0	    " no default line
let g:airline_section_b = '%{FugitiveStatusline()}'
"let g:airline#extensions#ale#enabled = 1
let g:airline_theme='gruvbox' "Must after colo
let &showtabline = 1   " Always display if 2, turn off GuiTabline in ginit when using nvim-qt
let g:airline#extensions#tabline#enabled = 1

let g:airline_powerline_fonts=1 "基本主题，需要修改的话取消注释掉底下对应项目以覆盖
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

" |>ale<|
"let g:ale_disable_lsp = 0
"let g:ale_completion_enabled = 1
"let &omnifunc="ale#completion#OmniFunc"
"
" |>highlight<|
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1

let g:python_highlight_all = 1
"
" |>rainbow<|
let g:rainbow_conf = {'guifgs': ['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Blue', 'Purple']}
