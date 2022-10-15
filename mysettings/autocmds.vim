" 官方文档推荐
autocmd TermOpen * startinsert
autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
" rest.nvim 无法在 win 上使用，此处改用 coc-restclient
autocmd FileType http noremap <buffer>go <Plug>RestNvim
autocmd FileType javascript,vue,typescriptreact,javascriptreact setl tabstop=2 | setl shiftwidth=2
autocmd FileType css,html,javascriptreact,typescriptreact,javascript,typescript,vue imap <S-Tab> <plug>(emmet-expand-abbr)
" (vimwiki)
" 自动更新日记索引
autocmd BufWinEnter diary.md execute "VimwikiDiaryGenerateLinks" | w
autocmd FileType vimwiki,markdown,text,tex set wrap
