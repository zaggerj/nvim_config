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
    Plug 'liuchengxu/vim-clap', { 'do': { -> clap#installer#force_download() } }
    Plug 'Yggdroot/indentLine'
    " Plug 'scrooloose/nerdtree'
    Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
    Plug 'vim-airline/vim-airline'
    Plug 'luochen1990/rainbow'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-repeat'
    " Themes
    Plug 'ryanoasis/vim-devicons'
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

" ( vim-clap )
let g:clap_provider_grep_opts = '-H --no-heading --vimgrep --smart-case --hidden -g "!.git/"'
let g:clap_enable_background_shadow = v:false
let g:clap_search_box_border_symbols = { 'triangle': [ "", "" ] }
let g:clap_search_box_border_style = "triangle"
let g:clap_forerunner_status_sign = { 'running': '', 'done': '', 'using_cache': '' }
" let g:clap_forerunner_status_sign = { 'running': 'R', 'done': 'D', 'using_cache': 'C' }
let g:clap_prompt_format = ' %spinner% %provider_id% %forerunner_status% > '
let g:clap_popup_border = has('nvim') ? "double" : "sharp"
"let g:clap_open_preview = "never"
let g:clap_preview_direction = "UD"
let g:clap_layout = { 'relative': 'editor' }
" let g:clap_layout = {'width': '47%', 'col':'3%', 'height': '50%', 'row': '25%' }
let g:clap_layout = {'width': '80%', 'col':'10%', 'height': '60%', 'row': '10%' }
" 纵向预览下也和 row 有关，空间不够不显示
let g:clap_preview_size = { '*': 3, 'files': 6 }

" (treesitter)
lua << E
require'nvim-treesitter.configs'.setup {
    highlight = {
    enable = true,
    },
}
E

" (chadtree)
let g:chadtree_settings = {
        \"view.width": 30,
        \"theme.text_colour_set": "nord"
      \ }
