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
set softtabstop=4
set shiftwidth=4
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
" cc for commandline, cs for split first, ce to exit
:tnoremap <ESC> <C-\><C-n>
if has("win32")
  " Note, you need to empty the file Git\etc\motd
  " to get rid of the 'Welcome to Git' message
  set shell=cmd.exe
  nnoremap <Leader>cc :term<CR>adoskey.cmd<CR>cmd.exe /c "D:\\GlobalScoopApps\\apps\\git\\current\\bin\\bash.exe --login -i"<CR>clear<CR>
  nnoremap <Leader>cs :sp<CR>:wincmd j<CR>:term<CR>adoskey.cmd<CR>cls<CR>cmd.exe /c "D:\\GlobalScoopApps\\apps\\git\\current\\bin\\bash.exe --login -i"<CR>clear<CR>
  nnoremap <Leader>cd :term<CR>adoskey.cmd<CR>cls<CR>
  nnoremap <Leader>csd :sp<CR>:wincmd j<CR>:term<CR>adoskey.cmd<CR>cls<CR>
else
  nnoremap <Leader>cc :term<CR>A
  nnoremap <Leader>cs :sp<CR>:wincmd j<CR>:term<CR>A
endif

augroup TerminalMappings
  autocmd!
  if has("win32")
    autocmd TermOpen * nnoremap <buffer> <C-E> aexit<CR>exit<CR>
    autocmd TermOpen * tnoremap <buffer> <C-E> exit<CR>exit<CR>
  else
    autocmd TermOpen * nnoremap <buffer> <C-E> aexit<CR>
    autocmd TermOpen * tnoremap <buffer> <C-E> exit<CR>
  endif
augroup END

" Make the split bigger
nnoremap <Leader>b 8<C-W>+<CR>
nnoremap <Leader>B 50<C-W>+<CR>
" Make the split wider
nnoremap <Leader>w 8<C-W>><CR>
nnoremap <Leader>W 56<C-W>><CR>
