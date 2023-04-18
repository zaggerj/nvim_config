" 官方文档推荐
autocmd TermOpen * startinsert
autocmd TextYankPost * lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
" 调整窗口自动对齐布局
autocmd VimResized * wincmd =
" rest.nvim 无法在 win 上使用，此处改用 coc-restclient
autocmd FileType http noremap <buffer>go <Plug>RestNvim
autocmd FileType javascript,vue,scss,less,typescriptreact,javascriptreact,org setl tabstop=2 | setl shiftwidth=2
autocmd FileType css,html,javascriptreact,typescriptreact,javascript,typescript,vue imap <S-Tab> <plug>(emmet-expand-abbr)
" (vimwiki)
" 自动更新日记索引
autocmd BufWinEnter diary.md execute "VimwikiDiaryGenerateLinks" | w
autocmd FileType vimwiki,markdown,text,tex set wrap

" 因为包括了 FocusGained，所以需要判断 mode（）
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | setl rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | setl nornu | endif
:augroup END
