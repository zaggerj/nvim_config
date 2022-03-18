autocmd TermOpen * startinsert
autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
" autocmd FileType javascript,html,vue,javascriptreact set tabstop=2 | set shiftwidth=2
autocmd FileType css,html,jsx,javascript,typescript,vue imap <S-Tab> <plug>(emmet-expand-abbr)
" (vimwiki)
" 自动更新日记索引
autocmd BufWinEnter diary.md execute "VimwikiDiaryGenerateLinks" | w
autocmd FileType vimwiki,markdown set wrap
