"With ginit.vim
" |>Installed plugins<|
call plug#begin('~\\vimfiles\\plugged')
    " Git
    Plug 'tpope/vim-fugitive'
    " Language support
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
    " Themes
    Plug 'morhetz/gruvbox' 
    Plug 'crusoexia/vim-monokai' 
    Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline-themes'
    " Syntax
    Plug 'pangloss/vim-javascript'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
call plug#end()
"
" |>my maps<|
" first-class maps
let mapleader = " "
inoremap fj <Esc> 
inoremap <silent><tab> <C-R>=CTab()<cr>
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
" my functions
noremap <silent> <Leader>fc :call Compiler()<cr>
noremap <silent> <Leader>fr :call Runner()<cr>
nnoremap <silent> <Leader>fs :call Set_it()<cr>
nnoremap <silent> <Leader>ft :call Open_terminal()<cr>
" single map plugins 
nnoremap <silent> <Leader>pv :Vista coc<cr>
nnoremap <silent> <Leader>pd :NERDTreeFind<cr>
" fugitive
nnoremap <silent> <Leader>gs :G<cr>
nnoremap <silent> <Leader>gps :Gpush<cr>
nnoremap <silent> <Leader>gpl :Gpull<cr>
nnoremap <silent> <Leader>gl :Gclog<cr>
" vim-plug
nnoremap <silent> <Leader>pi :PlugInstall<cr>
nnoremap <silent> <Leader>pu :PlugUpdate<cr>
" coc maps
nmap <silent> <Leader>ca <Plug>(coc-codeaction)
nmap <silent> <Leader>cd <Plug>(coc-definition)
nmap <silent> <Leader>cf <Plug>(coc-format)
nmap <silent> <Leader>cl :CocList<cr>
nmap <silent> <C-Left> <Plug>(coc-diagnostic-next-error)
nmap <silent> <C-Right> <Plug>(coc-diagnostic-prev-error)
nnoremap <silent> <Leader>cc :CocConfig<cr>
" emmet
let g:user_emmet_leader_key = '<M-m>'
"
" |>autocmd<|
autocmd TermOpen * startinsert
autocmd BufNewFile,BufRead *.js,*.html set tabstop=2 | set shiftwidth=2 
"
" |>options(universal)<|
" `:options` for all available options.
filetype plugin indent on
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
colo onedark
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
    " 优先考虑有弹出菜单的情况，否则<tab>将不会进行菜单选择。.
    if pumvisible()
        return "\<C-N>"
    else
        " 获取光标前四个字符, 相比于整行正则匹配效率更高.
        let matchL = strpart(getline('.'), col('.') - 5, 4) 
        " 匹配路径
        let isPath = match(matchL, '\/\|\') 
        " 匹配是否有字符
        let isNormal = match(matchL, '\w') 
        " -1代表无匹配, 没有字符就TAB
        if isNormal == -1
            return "\<tab>"
        elseif isPath != -1
            return "\<C-X>\<C-F>"
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
    elseif &filetype=='java'
        exe "javac %:r"
    elseif &filetype == 'typescript'
        exe "te tsc %"
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
        elseif &filetype == 'cs'
            exe "te dotnet run"
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
" |>airline<|
set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme='onedark'
let g:airline_powerline_fonts = 0
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1
"
" |>vista<|
let g:vista_cursor_delay = 60
let g:vista_sidebar_position = "vertical topleft"
"
" |>coc-nvim<|
let g:coc_enable_locationlist = 1

" |>highlight<|
" cpp
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1
" python
let g:python_highlight_all = 1
"
" |>rainbow<|
let g:rainbow_active = 1
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}
"
" |>vim-plug<|
let g:plug_timeout = 180
let g:plug_retries = 5
