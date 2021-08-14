" (airline)
" Fix! Do not uncomment this
"set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme = 'everforest'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1

" (vista)
let g:vista_cursor_delay = 60
let g:vista_sidebar_position = "vertical botright"
let g:vista_default_executive = "coc"

" (coc)
set cmdheight=1
set updatetime=500
set shortmess+=c
set signcolumn=yes

" (vim-plug)
let g:plug_timeout = 180
let g:plug_retries = 5

" (vim-go)
let g:go_term_mode = "split"
let g:go_term_enabled = 1
let g:go_code_completion_enabled = 0
let g:go_imports_autosave = 1
let g:go_metalinter_autosave = 1

" (rust)
let g:rustfmt_autosave = 1

" (indentLine)
" 排除一些不能正常工作的文件
let g:indentLine_fileTypeExclude = ['go', 'coc-explorer']

" (vimwiki)
let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]
"let g:vimwiki_list = [{'path': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\sources', 'path_html': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\html'}]

" (neovide)
"let &guifont = "FiraCode NF:h14"

