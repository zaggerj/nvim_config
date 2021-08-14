"With ginit.vim
" |>Installed plugins<|
call plug#begin('~\\vimfiles\\plugged')
    " Toolset
    Plug 'tpope/vim-fugitive'
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    Plug 'fatih/vim-go'
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
    Plug 'kristijanhusak/vim-hybrid-material'
    "Plug 'morhetz/gruvbox' 
    "Plug 'crusoexia/vim-monokai' 
    "Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline-themes'
    " Syntax
    Plug 'pangloss/vim-javascript'
    Plug 'posva/vim-vue'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'uiiaoo/java-syntax.vim'
    Plug 'rust-lang/rust.vim'
    "Plug 'MaxMEllon/vim-jsx-pretty'
call plug#end()

" |>options(native & plugin)<|
" `:options` for all available options.
filetype plugin indent on
syntax enable
set nowrap
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
set hidden

runtime! settings/**/*.vim
