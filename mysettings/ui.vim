" 配置 colorscheme 和 syntax highlight
" 务必确保 highlight 在 colorscheme 之后进行设置，否则会导致高亮不正确
" (theme)
set termguicolors
colo everforest
let g:forest_night_disable_italic_comment = 0
let g:forest_night_enable_italic = 1
set pumblend=10
set winblend=30

" 根据时间自动调整主题
let s:now = str2nr(strftime("%H"))
if s:now > 7 && s:now < 23
    set background=light
else
    set background=dark
endif

" (airline)
" Fix! Do not uncomment this
"set noshowmode
set laststatus=2
set showtabline=2
let g:airline_theme = 'everforest'
let g:airline_powerline_fonts = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tabline#enabled = 1

" (rainbow)
" 确保在 colo 之后
let g:rainbow_active = 1
let g:rainbow_conf = {'guifgs': reverse(['Red', 'Orange', 'Yellow', 'Green', 'Cyan', 'Lightblue', 'Purple'])}

" (vim-go)
let g:go_highlight_extra_types = 1
let g:go_highlight_operators = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_parameters = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1

" (cpp)
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1

" (python)
let g:python_highlight_all = 1
