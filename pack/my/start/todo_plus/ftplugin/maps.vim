inoremap <nowait><buffer><silent> <C-CR> <esc>^i<C-R>=g:todo_symbols["todo"]<cr> 
nnoremap <nowait><silent><buffer> <leader>d <cmd>call todo#done()<cr>
nnoremap <nowait><silent><buffer> <leader>c <cmd>call todo#cancel()<cr>
nnoremap <nowait><silent><buffer> <leader>s <cmd>call todo#start()<cr>
