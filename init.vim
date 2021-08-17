"With ginit.vim
" 必须要放在开头，否则插件不会在配置前加载
call plug#begin('~\vimfiles\plugged')
    " Toolset
    Plug 'tpope/vim-fugitive'
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    Plug 'fatih/vim-go'
    " Editor enhancement
    "Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    "Plug 'junegunn/fzf.vim'
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
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

" 自定义函数被配置依赖，需要优先加载
runtime mysettings/functions.vim
runtime mysettings/ui.vim
runtime mysettings/maps.vim
runtime mysettings/autocmds.vim
runtime mysettings/basic.vim
runtime mysettings/plugins.vim
