let mapleader = " "
inoremap fj <Esc> 
inoremap <C-v> <C-R>+
noremap \ :
nnoremap / /\v
nnoremap ? ?\v
nnoremap <silent> <leader>n <Cmd>noh<CR>
" (terminal control)
tnoremap fj <C-\><C-n>
tnoremap <Esc> exit<cr>
" (window jump)
noremap <silent> <A-h> <C-w>h
noremap <silent> <A-j> <C-w>j
noremap <silent> <A-k> <C-w>k
noremap <silent> <A-l> <C-w>l
noremap <silent> <A-S-h> <C-w>H
noremap <silent> <A-S-j> <C-w>J
noremap <silent> <A-S-k> <C-w>K
noremap <silent> <A-S-l> <C-w>L
" (buffer jump & tab jump)
noremap <silent> <C-Left> <Cmd>bp<cr>
noremap <silent> <C-Right> <Cmd>bn<cr>
noremap <silent> <C-S-Up> <Cmd>tabnew<cr>
noremap <silent> <C-S-Down> <Cmd>tabclose<cr>
noremap <silent> <C-S-Left> <Cmd>tabp<cr>
noremap <silent> <C-S-Right> <Cmd>tabn<cr>
noremap <silent> <leader><left> <Cmd>bdelete<cr>
" (my)
" or <C-R>=
inoremap <silent><expr> <tab> CTab()
inoremap <silent><expr> _tm strftime("%Y-%m-%d")
nnoremap <silent> <Leader>fo <Cmd>call Open_fix()<cr>
noremap <silent> <Leader>fc <Cmd>call Compiler()<cr>
noremap <silent> <Leader>fr <Cmd>call Runner()<cr>
nnoremap <silent> <Leader>fs <Cmd>call Set_it()<cr>
nnoremap <silent> <Leader>fd <Cmd>exe "e expand('<sfile>:p:h')"."\pack\my\start\myplugin\plugin\one.vim"<cr>
nnoremap <silent> <Leader>ft <Cmd>call Open_terminal()<cr>
nnoremap <silent> <Leader>fh <Cmd>tcd %:h<cr>
" (single plugin maps)
nnoremap <silent> <Leader>pv <Cmd>Vista coc<cr>
" (tree)
nnoremap <silent> <Leader>pd <Cmd>NvimTreeFindFileToggle<cr>
" (fugitive)
nnoremap <silent> <Leader>gs <Cmd>G<cr>
nnoremap <silent> <Leader>gps <Cmd>Git push<cr>
nnoremap <silent> <Leader>gpl <Cmd>Git pull<cr>
nnoremap <silent> <Leader>gl <Cmd>Gclog<cr>
" (vim-plug)
nnoremap <silent> <Leader>pi <Cmd>PlugInstall<cr>
nnoremap <silent> <Leader>pu <Cmd>PlugUpdate<cr>
nnoremap <silent> <Leader>pc <Cmd>PlugClean<cr>
" (coc) 不遵循通用命名规则，和 vscodevim 保持一致
nnoremap <silent> gh <Cmd>call CocActionAsync('doHover')<cr>
noremap <Leader>ci <Cmd>call CocActionAsync('organizeImport')<CR> 
noremap <silent> <Leader>cl <Cmd>CocList<cr>
nnoremap <silent> <Leader>cc <Cmd>CocConfig<cr>
nmap <silent> <leader>. <Plug>(coc-codeaction)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <Leader>cf <Plug>(coc-format)
nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <C-Up> <Plug>(coc-diagnostic-prev-error)
nmap <silent> <C-Down> <Plug>(coc-diagnostic-next-error)
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" (finder)
let g:Lf_ShortcutF = "<Leader>lf"
let g:Lf_ShortcutB = "<Leader>lb"
" noremap <silent> <Leader>lf <Cmd>Leaderf file<CR>
" noremap <silent> <Leader>lb <Cmd>Leaderf buffer<CR>
noremap <silent><Leader>lg <Cmd>Leaderf rg<CR>
noremap <silent> <Leader>lr <Cmd>Leaderf mru<CR>
noremap <silent> <Leader>l: <Cmd>Leaderf command<CR>
noremap <silent> <Leader>l/ <Cmd>Leaderf line<CR>
