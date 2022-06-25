call plug#begin('~\vimfiles\plugged')
    " Toolset
    Plug 'tpope/vim-fugitive'
    Plug 'vimwiki/vimwiki'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'NTBBloodbath/rest.nvim'
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    "临时使用
    Plug 'yaegassy/coc-volar', {'do': 'yarn install --frozen-lockfile'}
    Plug 'yaegassy/coc-volar-tools', {'do': 'yarn install --frozen-lockfile'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    Plug 'fatih/vim-go'
    " Editor enhancement
    Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'luochen1990/rainbow'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    " Themes
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'sainnhe/forest-night'
    "Plug 'kristijanhusak/vim-hybrid-material'
    "Plug 'morhetz/gruvbox'
	Plug 'tanvirtin/monokai.nvim'
    Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline-themes'
    " Syntax
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'rust-lang/rust.vim'
call plug#end()

" (vista)
let g:vista_cursor_delay = 60
let g:vista_sidebar_position = "vertical botright"
let g:vista_default_executive = "coc"

" (coc)
"set updatetime=500
set shortmess+=c
set signcolumn=number

" (vim-plug)
let g:plug_timeout = 180
let g:plug_retries = 5

" (vim-go)
let g:go_term_mode = "split"
let g:go_term_enabled = 1
" 使用 coc-go 代替
let g:go_code_completion_enabled = v:false
let g:go_gopls_enabled = v:true
let g:go_imports_autosave = v:true
let g:go_metalinter_autosave = v:false

" (rust)
let g:rustfmt_autosave = 1

" (vimwiki)
let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md', 'auto_tags': 1}]
let g:mkdp_auto_start = 0

" (finder)
let g:Lf_WindowPosition = "popup"
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
let g:Lf_PreviewInPopup = 1
let g:Lf_PopupHeight = 0.6
let g:Lf_PopupWidth = 0.8
let g:Lf_RgConfig = [
            \ "--glob=!git/*",
            \ "--hidden",
            \ "--smart-case"
            \ ]
let g:Lf_WildIgnore = {
            \ 'dir': ["node_modules", ".git"],
            \}

" lua 插件也需要在 plugins 后
lua require('plugins')
