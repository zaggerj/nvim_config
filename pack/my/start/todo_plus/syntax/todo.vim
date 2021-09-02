if exists("b:current_syntax")
    finish
endif

" 英文和汉字范围 [a-z\u4E00-\u9FA5]

syntax case ignore

syntax match todoProject "\v^[a-z\u4E00-\u9FA5]+:$"

syntax match todoDone /\v[\u2714]\s[a-z\u4E00-\u9FA5]+(\s|$)/
syntax match todoDoing /\v[\u23F1]\s[a-z\u4E00-\u9FA5]+(\s|$)/
syntax match todoCanc /\v[\u2717]\s[a-z\u4E00-\u9FA5]+(\s|$)/

highlight def link todoProject Identifier 
highlight def todoCanc guifg=#DC4341 ctermfg=12
highlight def todoDone guifg=#B1E325 ctermfg=10

syntax match todoTag /\v\@[a-z\u4E00-\u9FA5]{-1,}>/
syntax match todoCritical /\v\@critical>/
syntax match todoHigh /\v\@high>/
syntax match todoLow /\v\@low>/
syntax match todoToday /\v\@today>/

highlight def link todoTag Tag
highlight def todoCritical guibg=#DC4341 ctermbg=12 gui=bold
highlight def todoHigh guibg=#DF9E3B ctermbg=6
highlight def todoLow guibg=#E2D035 ctermbg=14
highlight def todoToday guibg=#C0A3FE ctermbg=13

let b:current_syntax = "todo"
