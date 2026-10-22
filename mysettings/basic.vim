" `:options` for all available options.
filetype plugin indent on
syntax enable
set title
set grepprg=rg\ --vimgrep
"set mouse=i
"set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312
set cursorline
" set showmatch
set matchpairs+=<:>
set number
set relativenumber
"set autoindent
"set smartindent
set expandtab
set softtabstop=2
set shiftwidth=2
set timeoutlen=1500
set splitbelow
set ignorecase
"set hidden
set cmdheight=1
set nobackup
"set nowritebackup
set foldopen-=search
" set nowrap
set showbreak=\|>\ 
set wildoptions+=fuzzy
set diffopt+=vertical,linematch:60,algorithm:histogram

" Terminal settings
" ct 在当前窗口打开终端，cs 分屏；cc 保留给 CocConfig。
:tnoremap <ESC> <C-\><C-n>
if has("win32")
  set shell=cmd.exe
endif
nnoremap <silent> <Leader>ct <Cmd>lua require('platform').open_terminal({split = false})<CR>
nnoremap <silent> <Leader>cs <Cmd>lua require('platform').open_terminal()<CR>
nnoremap <silent> <Leader>cd <Cmd>lua require('platform').open_terminal({split = false, system_shell = true})<CR>
nnoremap <silent> <Leader>csd <Cmd>lua require('platform').open_terminal({system_shell = true})<CR>

augroup TerminalMappings
  autocmd!
  autocmd TermOpen * nnoremap <buffer> <C-E> <Cmd>lua require('platform').close_terminal()<CR>
  autocmd TermOpen * tnoremap <buffer> <C-E> <C-\><C-n><Cmd>lua require('platform').close_terminal()<CR>
augroup END

" Make the split bigger
nnoremap <Leader>b 8<C-W>+<CR>
nnoremap <Leader>B 50<C-W>+<CR>
" Make the split wider
nnoremap <Leader>w 8<C-W>><CR>
nnoremap <Leader>W 56<C-W>><CR>
