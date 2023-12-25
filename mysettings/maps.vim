" 见 plugins.lua let mapleader = " "
inoremap fj <Esc> 

" 方便粘贴
inoremap <C-v> <C-o>"+p

noremap \ :
nnoremap / /\v
nnoremap ? ?\v
nnoremap <silent> <leader>n <Cmd>noh<CR>
" (cmd mode)
cnoremap <A-b> <C-Left>
cnoremap <A-f> <C-Right>
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
noremap <silent> <leader><left> <Cmd>bdelete<cr>
" (diff)
noremap <silent> <Leader>dt <Cmd>diffthis<cr>
noremap <silent> <Leader>do <Cmd>diffoff<cr>
" (my)
" or <C-R>=
" 根据最新的 coc 配置，不再使用此项
" inoremap <silent><expr> <tab> CTab()
inoremap <silent><expr> _tm strftime("%Y-%m-%d")
" 改用 Telescope 吧
"nnoremap <silent> <Leader>fo <Cmd>call Open_fix()<cr>
noremap <silent> <Leader>fc <Cmd>call Compiler()<cr>
noremap <silent> <Leader>fr <Cmd>call Runner()<cr>
" 打开init.vim 配置文件
nnoremap <silent> <Leader>fs <Cmd>call Set_it()<cr>
" 目前好像没啥用 <sfile>：表示当前正在编辑的文件名 :p：表示展开为绝对路径 :h：表示展开为所在目录路径 当前正在编辑的文件所在的目录的绝对路径
" nnoremap <silent> <Leader>fd <Cmd>exe "e expand('<sfile>:p:h')"."\pack\my\start\myplugin\plugin\one.vim"<cr>
nnoremap <silent> <Leader>ft <Cmd>call Open_terminal()<cr>
" 将nvimtree目录更新到文件所在目录, tcd 是 Vim 的内置命令，用于在新的标签页中改变当前目录。% 表示当前文件的路径，而 :h 是一个修饰符，表示获取当前文件所在目录的路径。
nnoremap <silent> <Leader>fh <Cmd>tcd %:h<cr>
" (single plugin maps) 使用coc生成vsita 大纲
nnoremap <silent> <Leader>pv <Cmd>Vista coc<cr>
" (tree)
nnoremap <silent> <Leader>pd <Cmd>NvimTreeFindFileToggle<cr>
" (fugitive) https://github.com/tpope/vim-fugitive/wiki/Basic-fugitive-commands
nnoremap <silent> <Leader>gs <Cmd>G<cr>
nnoremap <silent> <Leader>gps <Cmd>Git push<cr>
nnoremap <silent> <Leader>gpl <Cmd>Git pull<cr>
nnoremap <silent> <Leader>gla <Cmd>Gclog<cr>
nnoremap <silent> <Leader>gll <Cmd>exec "Git log -L ".line('.').",".line('.').":% --no-merges --oneline"<cr>
nnoremap <silent> <Leader>gls :Git log -p --no-merges -S"<cword>" %<cr>
" (gitsigns)
nnoremap <silent> ]g <Cmd>Gitsigns next_hunk<cr>
nnoremap <silent> [g <Cmd>Gitsigns prev_hunk<cr>
" unstaged file
nnoremap <silent> [d <Cmd>Gitsigns diffthis<cr>
" staged file
nnoremap <silent> [f <Cmd>Gitsigns diffthis ~<cr>
" stage current file
nnoremap <silent> [c <Cmd>Gitsigns stage_buffer<cr>
" clear stage changes
nnoremap <silent> ]c <Cmd>Gitsigns reset_buffer<cr>
" (vim-plug)
nnoremap <silent> <Leader>pi <Cmd>Lazy install<cr>
nnoremap <silent> <Leader>pu <Cmd>Lazy update<cr>
nnoremap <silent> <Leader>pc <Cmd>Lazy clean<cr>
" (coc) 不遵循通用命名规则，{rhs} 和 vscodevim 保持一致
nnoremap <silent> <Leader>cr <Cmd>CocRestart<cr>
nnoremap <silent> gh <Cmd>call CocActionAsync('doHover')<cr>
" 用系统默认程序打开当前文件所在目录 目前默认使用了cmd打开
nnoremap gx <Cmd>exec "!start ".expand('<cfile>')<cr>
noremap <Leader>ci <Cmd>call CocActionAsync('organizeImport')<CR> 
noremap <silent> <Leader>cl <Cmd>CocList<cr>
" 打开coc-settings.json
nnoremap <silent> <Leader>cc <Cmd>CocConfig<cr>
nmap <silent> <leader>. <Plug>(coc-codeaction)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
" 弄一下文本对象的跳转，omap 就不用 silent 了
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
nmap <silent> <Leader>cf <Plug>(coc-format)
xmap <silent> <Leader>cf <Plug>(coc-format-selected)
xmap <silent> <Leader>cv <Plug>(coc-convert-snippet)
nmap <silent> <F2> <Plug>(coc-rename)
nmap <silent> <Up> <Plug>(coc-diagnostic-prev)
nmap <silent> <Down> <Plug>(coc-diagnostic-next)
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" 0.0.82 版适配
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Insert <tab> when previous text is space, refresh completion if not.
inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1):
            \ Check_back_space() ? "\<Tab>" :
            \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Telescope (finder) https://github.com/nvim-telescope/telescope.nvim#pickers
" Lists files in your current working directory, respects .gitignore
noremap <silent> <Leader>lf <Cmd>Telescope find_files<CR>
" Search for a string in your current working directory and get results live as you type, respects .gitignore.
noremap <silent><Leader>lg <Cmd>Telescope live_grep<CR>
" Searches for the string under your cursor or selection in your current working directory
noremap <silent><Leader>ls <Cmd>Telescope grep_string<CR>
" Lists open buffers in current neovim instance
noremap <silent> <Leader>lb <Cmd>Telescope buffers<CR>
" Lists previously open files
noremap <silent> <Leader>lr <Cmd>Telescope oldfiles<CR>

" Lists vim options, allows you to edit the current value on <cr>
noremap <silent> <Leader>lv <Cmd>Telescope vim_options<CR>
" Lists items from the current window's location list
noremap <silent> <Leader>lt <Cmd>Telescope registers<CR>
noremap <silent> <Leader>lm <Cmd>Telescope marks<CR>
" Lists available help tags and opens a new window with the relevant help info on <cr>
noremap <silent> <Leader>lh <Cmd>Telescope help_tags<CR>

" git
noremap <silent> <Leader>lj <Cmd>Telescope git_status<CR>
noremap <silent> <Leader>lk <Cmd>Telescope git_stash<CR>
noremap <silent> <Leader>ll <Cmd>Telescope git_branches<CR>

" noremap <silent> <Leader>l/ <Cmd><CR>
" noremap <silent> <Leader>l: <Cmd><CR>
" 2-character Sneak (default)
nmap ' <Plug>Sneak_s
nmap <BS> <Plug>Sneak_S
xmap ' <Plug>Sneak_s
xmap <BS> <Plug>Sneak_S
omap ' <Plug>Sneak_s
omap <BS> <Plug>Sneak_S
