let mapleader = " "
inoremap fj <Esc> 
inoremap <C-v> <C-R>+
nnoremap \ :
nnoremap / /\v
nnoremap ? ?\v
nmap <silent> <leader>n :noh<cr>
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
noremap <silent> <C-Left> :bp<cr>
noremap <silent> <C-Right> :bn<cr>
noremap <silent> <C-S-Left> :tabp<cr>
noremap <silent> <C-S-Right> :tabn<cr>
noremap <silent> <leader><left> :bdelete<cr>
" (my)
" or <C-R>=
inoremap <silent><expr> <tab> CTab()
inoremap <silent><expr> _tm strftime("%c")
nnoremap <silent> <Leader>fo :call Open_fix()<cr>
noremap <silent> <Leader>fc :call Compiler()<cr>
noremap <silent> <Leader>fr :call Runner()<cr>
nnoremap <silent> <Leader>fs :call Set_it()<cr>
nnoremap <silent> <Leader>fd :exe "e expand('<sfile>:p:h')".'\pack\my\start\myplugin\plugin\one.vim'<cr>
nnoremap <silent> <Leader>ft :call Open_terminal()<cr>
nnoremap <silent> <Leader>fh :cd %:h<cr>
" (single plugin maps)
nnoremap <silent> <Leader>pv :Vista coc<cr>
nnoremap <silent> <Leader>pd :NERDTree .<cr>
" (fugitive)
nnoremap <silent> <Leader>gs :G<cr>
nnoremap <silent> <Leader>gps :Git push<cr>
nnoremap <silent> <Leader>gpl :Git pull<cr>
nnoremap <silent> <Leader>gl :Gclog<cr>
" (vim-plug)
nnoremap <silent> <Leader>pi :PlugInstall<cr>
nnoremap <silent> <Leader>pu :PlugUpdate<cr>
nnoremap <silent> <Leader>pc :PlugClean<cr>
" (coc)
nnoremap <silent> gh :call CocActionAsync('doHover')<cr>
nmap <Leader>ci :CocInstall 
nmap <Leader>cu :CocUninstall 
nmap <silent> <Leader>cl :CocList<cr>
nnoremap <silent> <Leader>cc :CocConfig<cr>
nmap <silent> <Leader>ca <Plug>(coc-codeaction)
nmap <silent> <Leader>cd <Plug>(coc-definition)
nmap <silent> <Leader>cf <Plug>(coc-format)
nmap <silent> <Leader>cr <Plug>(coc-rename)
nmap <silent> <C-Up> <Plug>(coc-diagnostic-prev-error)
nmap <silent> <C-Down> <Plug>(coc-diagnostic-next-error)
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
nnoremap <nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
