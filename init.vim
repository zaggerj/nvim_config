call plug#begin('~\\vimfiles\\plugged')
    Plug 'scrooloose/nerdtree'
    Plug 'yianwillis/vimcdoc'
    Plug 'vim-airline/vim-airline'
    "Plug 'itchyny/lightline.vim'
    Plug 'vim-airline/vim-airline-themes'
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
"|--------------my maps------------------|
inoremap fj <Esc> 
"inoremap ' ''<Esc>i    "Now have coc-pair plugin
"inoremap " ""<Esc>i
"inoremap ( ()<Esc>i
"inoremap ) <Esc>la
"inoremap { {}<Esc>i<cr><Esc>O
"inoremap [ []<Esc>i
"inoremap ] <Esc>la
nmap <silent> <F2> :call Set_it()<cr>
nnoremap <silent> <F5> :call Complier()<cr>
noremap <silent> <F6> :Vista coc<cr>
noremap <silent> <F8> :NERDTreeFind<cr>	            "NERDTree %:h<cr>
noremap <silent> <C-F1> :AirlineTheme random<cr>
noremap <silent> <C-F2> :!git status -s<cr>
noremap <silent> <C-F3> :!git add %<cr>
noremap <C-F4> :!git commit -m "
nnoremap <silent> <C-F5> :call Runner()<cr>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
"|--------------my maps------------------|
"
"|--------------my hooks------------------|
autocmd TermOpen * startinsert
"|--------------my hooks------------------|
"
"|--------------regular------------------|
syntax enable
colo gruvbox
let &encoding="utf-8"
let &fileencodings="utf-8,gb2312"
"set clipboard+=unnamedplus "总是启用系统剪贴板(Always use system clipboard),Maybe lower speed
let &cursorline=1
let &showmatch = 0 "just like lisp repl's bracket highlight
let g:rainbow_active = 1
let &guifont="FiraCode Nerd Font:h15" "Suggest to use *.otf fonts
let &number=1
let &background="dark"
"set smartindent
let &autoindent=1
"let &lisp = 1 " lisp's indent
let &termguicolors=1 "Just for neovim
"let &cmdheight=1 " 见帮助(doc)，默认为1。
let &softtabstop=4
let &expandtab = 1 "Don't use TABs
let &shiftwidth=4
"let &autochroot=1 "auto change path to current path.
"set shell=pwsh
"set shellpipe=\| shellredir=> shellxquote=\(	 	 "Not '\' or '(' !!! Must setting the xquote not quote!!!
"set shellcmdflag=/c					 "Not /s/c or /s\ /c or /s\ /c\ ! Can be -c or -Command
"|--------------regular------------------|
"
"|--------------my funcs------------------|
let &splitbelow=1
function! Complier()
    exe "w"
    exe "10sp" 
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
    else 
	echo 'Do not support this type of file!'
    endif
endfunc

function! Runner()
    exe "13sp"
    if &filetype=='cpp'
        exe "te %:p.exe"
    elseif &filetype == 'c'
        exe "te %:p.exe"
    endif
endfunc

function! Set_it()
    exe "sp ~/AppData/Local/nvim/init.vim"
    exe "cd %:h"
endfunc
"|--------------my funcs------------------|
"
"|--------------airline------------------|
let &laststatus = 2
let &showtabline = 0   " Always display if 2
let &showmode = 0	    " no default line
let g:airline_section_b = '%{FugitiveStatusline()}'
"let g:airline#extensions#ale#enabled = 1
let g:airline_theme='gruvbox' "Must after colo
let g:airline#extensions#tabline#enabled = 0

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
"|--------------airline------------------|
"
"|--------------Vista------------------|
let g:vista_cursor_delay = 70
"|--------------Vista------------------|
"
"|--------------Coc-nvim-----------------|
let g:coc_enable_locationlist = 0
"|--------------Coc-nvim------------------|

"|--------------ale------------------|
"let g:ale_disable_lsp = 0
"let g:ale_completion_enabled = 1
"let &omnifunc="ale#completion#OmniFunc"
"|--------------ale------------------|
"|--------------highlight------------------|
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1

let g:python_highlight_all = 1
"|--------------highlight------------------|
"|--------------tex------------------|

"|--------------tex------------------|
