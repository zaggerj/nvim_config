call plug#begin('~\vimfiles\plugged')
    " Toolset
    Plug 'tpope/vim-fugitive'
    Plug 'vimwiki/vimwiki'
    Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
    " IDE support
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    Plug 'liuchengxu/vista.vim'
    Plug 'mattn/emmet-vim'
    Plug 'fatih/vim-go'
    " Editor enhancement
    "Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
    "Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'Yggdroot/indentLine'
    " Plug 'scrooloose/nerdtree' 不再维护
    Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
    Plug 'vim-airline/vim-airline'
    Plug 'luochen1990/rainbow'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    " Themes
    Plug 'ryanoasis/vim-devicons'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'sainnhe/forest-night'
    "Plug 'kristijanhusak/vim-hybrid-material'
    "Plug 'morhetz/gruvbox'
    Plug 'crusoexia/vim-monokai' 
    "Plug 'joshdick/onedark.vim'
    Plug 'vim-airline/vim-airline-themes'
    " Syntax
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'pangloss/vim-javascript'
    Plug 'posva/vim-vue'
    Plug 'HerringtonDarkholme/yats.vim'
    Plug 'octol/vim-cpp-enhanced-highlight'
    Plug 'vim-python/python-syntax'
    Plug 'uiiaoo/java-syntax.vim'
    Plug 'rust-lang/rust.vim'
    "Plug 'MaxMEllon/vim-jsx-pretty'
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
" 使用 coc 补全
let g:go_code_completion_enabled = 0
let g:go_imports_autosave = 1
let g:go_metalinter_autosave = 0

" (nerdtree)
let NERDTreeDirArrowExpandable="▸"
let NERDTreeDirArrowCollapsible="▾"

" (rust)
let g:rustfmt_autosave = 1

" (indentLine)
" 排除一些不能正常工作的文件
let g:indentLine_fileTypeExclude = ['go', 'coc-explorer']
" 避免和 vimwiki 的高亮冲突
let g:indentLine_concealcursor = ''

" (vimwiki)
let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md', 'auto_tags': 1}]
let g:mkdp_auto_start = 0

" (finder)
lua << E
require("telescope").setup {
    defaults = {
        layout_config = {
            horizontal = {
                preview_cutoff = 100
            }
        }
    }
}
E

" (treesitter)
lua << E
require'nvim-treesitter.configs'.setup {
    highlight = { enable = true, },
    indent = { enable = { "jsdoc" }, },
}
E

" (chadtree)
let g:chadtree_settings = {
        \"view.width": 30,
        \"theme.text_colour_set": "nord"
      \ }
