" `:options` for all available options.
filetype plugin indent on
syntax enable
set nowrap
set title
set grepprg=rg\ --vimgrep
"set mouse=i
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,gb18030,gbk,gb2312
set cursorline
" set showmatch
set matchpairs+=<:>
set number
set relativenumber
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set timeoutlen=1500
set splitbelow
set ignorecase
set hidden
set cmdheight=1
set nobackup
set nowritebackup
set foldopen-=search

"let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
"let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
"let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
"let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
"set shellquote= shellxquote=
