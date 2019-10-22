call plug#begin('~\\vimfiles\\plugged')
    Plug 'scrooloose/nerdtree'
    "Plug 'icymind/NeoSolarized'
    Plug 'morhetz/gruvbox'
    "Plug 'yianwillis/vimcdoc'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "Plug 'itchyny/lightline.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'liuchengxu/vista.vim'
    Plug 'tpope/vim-fugitive'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    "Plug 'dense-analysis/ale'
    "Plug 'lervag/vimtex'
call plug#end()
"|--------------my maps------------------|
inoremap fj <Esc>
inoremap ' ''<Esc>i
inoremap " ""<Esc>i
inoremap ( ()<Esc>i
inoremap { {}<Esc>i<cr><Esc>O
inoremap [ []<Esc>i
nnoremap <silent> <F5> :call CodeRunner()<cr>
nmap <silent> <F2> :call Set_it()<cr>
noremap <silent> <F8> :NERDTreeFind<cr>	            "NERDTree %:h<cr>
noremap <silent> <C-F1> :AirlineTheme random<cr>
noremap <silent> <C-F2> :!git status -s<cr>
noremap <silent> <C-F3> :!git add %<cr>
noremap <C-F4> :!git commit -m "
noremap <silent> <C-F5> :Vista coc<cr>
noremap <M-C> "+y "Yank to system clipboard("+)
noremap <M-V> "+p "Paste from system clipboard("+)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gp <Plug>(coc-diagnostic-prev)
"|--------------my maps------------------|
"
"|--------------my hooks------------------|
autocmd TermOpen * startinsert
"|--------------my hooks------------------|
"
"|--------------regular------------------|
let &encoding="utf-8"
let &fileencodings="utf-8,gb2312"
"set clipboard+=unnamedplus "总是启用系统剪贴板(Always use system clipboard),Maybe lower speed
let &cursorline=1
let &number=1
syntax enable
let &guifont="DejaVuSansMono NF:h15" "Suggest to use *.otf fonts
let &background="dark"
"colo NeoSolarized "for neovim
colo gruvbox
"set smartindent
let &autoindent=1
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
function! CodeRunner()
    exe "w"
    if &filetype=='c'
	exe "!clang -o %:r.exe %"
	exe "te %:r.exe"
    elseif &filetype=='python'
	exe "te python %"
    elseif &filetype=='cpp'
	exe "!g++ -o %:r.exe %"
	exe "te %:r.exe"
    else 
	echo 'Do not support this type of file!'
    endif
endfunc

function! Set_it()
    exe "e ~/AppData/Local/nvim/init.vim"
endfunc
"|--------------my funcs------------------|
"
"|--------------airline------------------|
let &laststatus = 2
let &showtabline = 0   " Always display if 2
let &showmode = 0	    " no default line
let g:airline_section_b = '%{FugitiveStatusline()}'
"let g:airline#extensions#ale#enabled = 1
let g:airline_theme='gruvbox' "依赖于gruvbox主题
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
