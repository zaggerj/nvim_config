" 配置 colorscheme 和 syntax highlight
" 务必确保 highlight 在 colorscheme 之后进行设置，否则会导致高亮不正确

" (theme)
" 根据时间自动调整主题，每 5 分钟更新一次
function TrySwitchTheme(timer)
    let s:now = str2nr(strftime("%H"))
    if s:now > 8 && s:now < 18
        " let g:onedark_config['style'] = "light"
        colo onelight
    else
        " let g:onedark_config['style'] = "cool"
        colo onedarkpro
    endif
endfunction

call TrySwitchTheme(0)

" if (exists('s:p'))
"     unlet s:p
" endif
" let s:p = timer_start(1000 * 60 * 5, 'TrySwitchTheme')

set termguicolors
set pumblend=10
set winblend=0

" (airline)
" REPLACED BY LUALINE, KEEPING FOR FURTHER USE
" Fix! Do not uncomment this or `a` will laggy
"set noshowmode
" set laststatus=2
" set showtabline=2
" let g:airline_theme = 'molokai'
" let g:airline_powerline_fonts = 1
" let g:airline#extensions#branch#enabled = 1
" let g:airline#extensions#coc#enabled = 1
" let g:airline#extensions#tabline#enabled = 1
" let g:airline_highlighting_cache = 1
" if !exists('g:airline_symbols') 
"     let g:airline_symbols = {}
" endif
" let g:airline_symbols.dirty = ' '
" let g:airline_symbols.readonly = ''
" " let g:airline_symbols.maxlinenr = "  "
" let g:airline_symbols.maxlinenr = " ﭾ "

" (rainbow)
" 确保在 colo 之后
let g:rainbow_active = 1
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}

" (vim-go) Deprecated by treesitter
" let g:go_highlight_extra_types = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_functions = 1
" let g:go_highlight_function_parameters = 1
" let g:go_highlight_function_calls = 1
" let g:go_highlight_types = 1
" let g:go_highlight_fields = 1

" Temp Fix Coc's Popupmenu
hi! link CocMenuSel PmenuSel
