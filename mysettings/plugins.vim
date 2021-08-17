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
" 使用 coc 补全
let g:go_code_completion_enabled = 0
let g:go_imports_autosave = 1
let g:go_metalinter_autosave = 0

" (rust)
let g:rustfmt_autosave = 1

" (indentLine)
" 排除一些不能正常工作的文件
let g:indentLine_fileTypeExclude = ['go', 'coc-explorer']
" 避免和 vimwiki 的高亮冲突
let g:indentLine_concealcursor = ''

" (vimwiki)
let g:vimwiki_list = [{'syntax': 'markdown', 'ext': '.md'}]
"let g:vimwiki_list = [{'path': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\sources', 'path_html': 'C:\Personal\\GIT\NoteBooks\\vimwiki\\html'}]

" (leaderF)
let g:Lf_WindowPosition = 'bottom'
let g:Lf_WindowHeight = 0.3
let g:Lf_ShortcutF = '<Leader>lf'
let g:Lf_ShortcutB = '<Leader>lb'
let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg'],
            \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
            \}
let g:Lf_RgConfig = [
            \ "--type-add web:*.{html,css,js}*",
            \ "--glob=!git/*",
            \ "--hidden"
            \ ]
"let g:Lf_DisableStl = 1
let g:Lf_StlSeparator = { 'left': '', 'right': '' }
let g:Lf_ExternalCommand = 'fd "%s" --type f'
