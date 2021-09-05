if exists("b:current_syntax")
    finish
endif

" 英文和汉字范围 [a-z\u4E00-\u9FA5]

syntax case ignore

" 如果有状态统计的话是带括号的
syntax match todoProject "\v^.+\)?:$"

syntax cluster todoStates contains=todoToday,todoTag,todoHigh,todoLow,todoCritical,todoTime
syntax match todoDone /\v[\u2714]\s.+$/ contains=@todoStates
syntax match todoDoing /\v[\u23F1]\s.+$/ contains=@todoStates
syntax match todoCanc /\v[\u2717]\s.+$/ contains=@todoStates

highlight def link todoProject Identifier 
highlight def todoCanc guifg=#DC4341 ctermfg=12
highlight def todoDone guifg=#B1E325 ctermfg=10

syntax match todoTag /\v\@[a-z\u4E00-\u9FA5]{-1,}>/
syntax match todoCritical /\v\@critical>/
syntax match todoHigh /\v\@high>/
syntax match todoLow /\v\@low>/
syntax match todoToday /\v\@today>/

highlight def link todoTag Tag
highlight def todoCritical guifg=#000000 guibg=#DC4341 ctermbg=12 gui=bold
highlight def todoHigh guifg=#000000 guibg=#DF9E3B ctermbg=6
highlight def todoLow guifg=#000000 guibg=#E2D035 ctermbg=14
highlight def todoToday guifg=#000000 guibg=#C0A3FE ctermbg=13

syntax match todoTime /\v\d{4}-\d-\d\s\d{2}:\d{2}:\d{2}/
syntax match todoTime /\v\d{1,2}h\s\d{1,2}m\s\d{1,2}s/

highlight def link todoTime Constant
let b:current_syntax = "todo"
