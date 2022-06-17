call plug#begin('~\vimfiles\plugged')
    " Toolset
    Plug 'tpope/vim-fugitive'
    Plug 'vimwiki/vimwiki'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'NTBBloodbath/rest.nvim'
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    Plug 'fatih/vim-go'
    " Editor enhancement
    Plug 'liuchengxu/vim-clap', { 'do': { -> clap#installer#force_download() } }
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
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'joshdick/onedark.vim'
    " Syntax
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
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
let g:clap_enable_icon = v:true
let g:clap_provider_grep_opts = '-H --no-heading --vimgrep --smart-case --hidden -g "!.git/"'
let g:clap_search_box_border_symbols = { 'triangle': [ "\ue0ba", "\ue0b8" ] }
let g:clap_search_box_border_style = 'triangle'
let g:clap_popup_border = "double"
let g:clap_layout = { 'relative': 'editor' }
let g:clap_forerunner_status_sign = { 'running': '', 'done': '', 'using_cache': '' }
let g:clap_prompt_format = ' %spinner% %provider_id% %forerunner_status% > '

" lua 插件也需要在 plugins 后
lua require('plugins')
