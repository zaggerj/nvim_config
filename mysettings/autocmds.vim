autocmd TermOpen * startinsert
autocmd FileType javascript,html,vue,javascriptreact set tabstop=2 | set shiftwidth=2
autocmd FileType css,html,jsx,javascript,typescript,vue imap <S-Tab> <plug>(emmet-expand-abbr)
