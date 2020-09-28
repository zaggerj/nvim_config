"With ginit.vim
" |>Installed plugins<|
call plug#begin('~\\vimfiles\\plugged')
    " Git
    Plug 'tpope/vim-fugitive'
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    " Editor enhancement
    Plug 'Yggdroot/indentLine'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'luochen1990/rainbow'
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-surround'
    Plug 'vimwiki/vimwiki'
    " Themes
    Plug 'sainnhe/forest-night'
    "Plug 'kristijanhusak/vim-hybrid-material'
    "Plug 'morhetz/gruvbox' 
    "Plug 'crusoexia/vim-monokai' 
    "Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline-themes'
    " Syntax
    Plug 'pangloss/vim-javascript'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'uiiaoo/java-syntax.vim'
    "Plug 'MaxMEllon/vim-jsx-pretty'
call plug#end()
"
" |>my maps<|
" native replacing maps
let mapleader = " "
inoremap fj <Esc> 
inoremap <C-v> <C-R>+
nnoremap \ :
nnoremap / /\v
nnoremap ? ?\v
" terminal control
tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>
" window jump
noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l
noremap <silent> <A-S-h> <C-w>H
noremap <silent> <A-S-j> <C-w>J
noremap <silent> <A-S-k> <C-w>K
noremap <silent> <A-S-l> <C-w>L
" buffer jump & tab jump
noremap <silent> <C-Left> :bp<cr>
noremap <silent> <C-Right> :bn<cr>
noremap <silent> <C-S-Left> :tabp<cr>
noremap <silent> <C-S-Right> :tabn<cr>
noremap <silent> <leader><left> :bdelete<cr>
" my functions
" or <C-R>=
inoremap <silent><expr> <tab> CTab()
noremap <silent> <Leader>fc :call Compiler()<cr>
noremap <silent> <Leader>fr :call Runner()<cr>
nnoremap <silent> <Leader>fs :call Set_it()<cr>
nnoremap <silent> <Leader>ft :call Open_terminal()<cr>
" single plugin maps
nnoremap <silent> <Leader>pv :Vista coc<cr>
nnoremap <silent> <Leader>pd :NERDTree<cr>
" (fugitive)
nnoremap <silent> <Leader>gs :G<cr>
nnoremap <silent> <Leader>gps :Gpush<cr>
nnoremap <silent> <Leader>gpl :Gpull<cr>
nnoremap <silent> <Leader>gl :Gclog<cr>
" (vim-plug)
nnoremap <silent> <Leader>pi :PlugInstall<cr>
nnoremap <silent> <Leader>pu :PlugUpdate<cr>
nnoremap <silent> <Leader>pc :PlugClean<cr>
" (coc)
nnoremap <silent> gh :call CocActionAsync('doHover')<cr>
nmap <Leader>ci :CocInstall 
nmap <Leader>cu :CocUninstall 
nmap <silent> <Leader>cl :CocList<cr>
nnoremap <silent> <Leader>cc :CocConfig<cr>
nmap <silent> <Leader>ca <Plug>(coc-codeaction)
nmap <silent> <Leader>cd <Plug>(coc-definition)
nmap <silent> <Leader>cf <Plug>(coc-format)
nmap <silent> <Leader>cr <Plug>(coc-rename)
nmap <silent> <C-Up> <Plug>(coc-diagnostic-prev-error)
nmap <silent> <C-Down> <Plug>(coc-diagnostic-next-error)
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
"
" |>autocmd<|
autocmd TermOpen * startinsert
autocmd FileType javascript,html set tabstop=2 | set shiftwidth=2
autocmd FileType css,html,jsx,javascript,typescript imap <silent> <S-Tab> <plug>(emmet-expand-abbr)
autocmd FileType vimwiki set mouse=iv
" (coc)
autocmd BufWrite *.go :call CocActionAsync('organizeImport')
"
" |>options(native & plugin)<|
" `:options` for all available options.
filetype plugin indent on
syntax enable
set title
set grepprg=rg\ --vimgrep
set mouse=nv
set fileencodings=utf-8,gb2312
set cursorline
" set showmatch
set number
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set timeoutlen=1500
set splitbelow
set ignorecase
"
" |>theme<|
set termguicolors
let g:forest_night_disable_italic_comment = 0
let g:forest_night_enable_italic = 0
colo forest-night
set background=dark
set pumblend=10
set winblend=30
"
" (airline)
set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme = 'forest_night'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1
"
" (vista)
let g:vista_cursor_delay = 60
let g:vista_sidebar_position = "vertical topleft"
let g:vista_default_executive = "coc"
"
" (coc)
set cmdheight=1
set updatetime=500
set shortmess+=c
set signcolumn=yes
"
" |>highlights<|
" (cpp)
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1
" (python)
let g:python_highlight_all = 1
"
" (rainbow)
let g:rainbow_active = 1
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}
"
" (vim-plug)
let g:plug_timeout = 180
let g:plug_retries = 5
"
" (vimwiki)
"let g:vimwiki_list = [{'path': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\sources', 'path_html': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\html'}]
" 
" |>functions<|
"
" Caclulator, you can also use winheight() and winwidth()
let g:Sp_height = {x -> float2nr(nvim_win_get_height(0) * x)}
let g:Vsp_width = {x -> float2nr(nvim_win_get_width(0) * x)}
"
" Tab to complete
function! CTab()
    " 优先考虑有弹出菜单的情况，否则<tab>将不会进行菜单选择。.
    if pumvisible()
        return "\<C-N>"
    else
        " 获取光标前四个字符, 相比于整行正则匹配效率更高.
        let matchL = strpart(getline('.'), col('.') - 5, 4) 
        " 匹配路径
        let isPath = match(matchL, '/\|\\') 
        " 匹配是否有字符
        let isNormal = match(matchL, '\w') 
        " -1代表无匹配, 没有字符就TAB
        if isNormal == -1
            return "\<tab>"
        " 有字符则按照以下顺序尝试： filepath -> omnifunc.
        " 文件路径补全
        elseif isPath != -1
            return "\<C-X>\<C-F>"
        " 尝试omni补全
        elseif isNormal != -1 
            " 如果没有设置 omnifunc 函数，则尝试关键字补全
            if &omnifunc == "" 
                return "\<C-X>\<C-N>"
            else
                return "\<C-X>\<C-O>"
            endif
        endif
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
    " [N]sp/vsp
    exe l:temp.a:action
endfunction

function! Compiler()
    exe "wa"
    call PercentSplit(0.4, "sp")
    if &filetype=='c'
        exe "te clang -o %:r.exe %"
    elseif &filetype=='cpp'
        exe "te g++ -o %:r.exe %"
    elseif &filetype=='java'
        exe "te javac -encoding utf-8 %"
    elseif &filetype=='go'
        exe "go build"
    else 
        echo 'Do not support this type of file!'
        exe "q"
    endif
endfunc

function! Runner()
    if &filetype == 'html'
        write
        exe "!%"
    else
        write
        call PercentSplit(0.4, "sp")
        if &filetype=='cpp'|| &filetype=='c'
            exe "te %:r.exe"
        elseif &filetype == 'javascript'
            exe "te node %"
        elseif &filetype == 'java'
            exe "te java %:r"
        elseif &filetype == 'typescript'
            exe "te node %<.js"
        elseif &filetype == 'python'
            exe "te python %"
        elseif &filetype == 'ps1'
            exe "te powershell -c \"./%\""
        elseif &filetype == 'go'
            exe "te go run %"
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
