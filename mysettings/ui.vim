" 配置 colorscheme 和 syntax highlight
" 务必确保 highlight 在 colorscheme 之后进行设置，否则会导致高亮不正确
set termguicolors
let g:forest_night_disable_italic_comment = 0
let g:forest_night_enable_italic = 1
colo everforest
set background=dark
set pumblend=10
set winblend=30

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
