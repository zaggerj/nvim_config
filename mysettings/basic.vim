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
set smartindent
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

if exists('g:goneovim')
    " ginit 中设置无效
    let &guifont = "FantasqueSansMono NFM:h14,FantasqueSansM_Nerd_Font:h12"
endif

" let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
" let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';'
" let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
" let &shellpipe  = '2>&1 | %%{ "$_" } | Tee-Object %s; exit $LastExitCode'
" set shellquote= shellxquote=
