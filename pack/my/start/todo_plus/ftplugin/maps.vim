inoremap <nowait><buffer> <C-CR> <esc>^i<C-R>=g:todo_symbols["todo"]<cr> 
nnoremap <nowait><silent><buffer> <leader>d <cmd>call todo#done()<cr>
