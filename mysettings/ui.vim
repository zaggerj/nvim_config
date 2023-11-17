" 配置 colorscheme 和 syntax highlight
" 务必确保 highlight 在 colorscheme 之后进行设置，否则会导致高亮不正确

" (theme)
" 根据时间自动调整主题，每 5 分钟更新一次
"function TrySwitchTheme(timer)
"    let s:now = str2nr(strftime("%H"))
"    if s:now > 8 && s:now < 18
"        " let g:onedark_config['style'] = "light"
"        colo catppuccin-latte
"    else
"        " let g:onedark_config['style'] = "cool"
"        colo catppuccin-macchiato
"    endif
"endfunction
"
"call TrySwitchTheme(0)

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
" let g:rainbow_active = 1
" let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}

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

" 由于一部分字体设置在 ginit 中死都不生效，所以挪到这里来
if exists('g:goneovim')
    " goneovim 它现在不支持任何字体回退，gfw 会导致字体图标失效
    let &guifont = "FantasqueSansMono NFM:h14,FantasqueSansM_Nerd_Font:h12"
elseif exists('g:neovide')
    " neovide 的字体回退都在 guifont，gfw 不支持
    let &guifont = "FantasqueSansMono NFM,霞鹜文楷等宽,思源黑体,微软雅黑:h14"

    let g:neovide_remember_window_position = v:true
    let g:neovide_remember_window_size = v:true
    let g:neovide_scroll_animation_length = 0.3
    " 输入时动画
    let g:neovide_cursor_animate_in_insert_mode = v:true
    " 跳转到 cmd 时是否使用动画
    let g:neovide_cursor_animate_command_line = v:false
    " 更长的拖尾
    " let g:neovide_cursor_trail_length=0.1
    " 更慢的动画
    " let g:neovide_cursor_animation_length=0.08

    " 存在内存泄漏，关闭
    " let g:neovide_cursor_vfx_mode = "railgun"
    "" 更显眼的粒子
    " let g:neovide_cursor_vfx_particle_lifetime=1.4
    " let g:neovide_cursor_vfx_particle_density=9.0
else
    " 借助 gfw 实现 cjk 字符显示，gvim，nvim-qt 通用，
    " 但 nvim-qt 不支持回退列表，分别只能指定一个
    let &guifont = "FantasqueSansMono NFM:h14"
    let &guifontwide = "霞鹜文楷"
endif

