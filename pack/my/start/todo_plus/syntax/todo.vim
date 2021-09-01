if exists("b:current_syntax")
    finish
endif

syntax case ignore

syntax match todoProject "\v^.+:$"

syntax match todoCritical "\v\@critical"
syntax match todoHigh "\v\@high"
syntax match todoLow "\v\@low"
syntax match todoToday "\v\@today"
syntax match todoTag "\v\@\w{-1,}>"

syntax region todoDone start=/✔ / end=/$/
syntax region todoCanc start=/✘ / end=/$/
syntax region todoTodo  start=/☐/ end=/\s/

highlight todoCritical ctermfg=0 ctermbg=12
highlight todoHigh ctermfg=0 ctermbg=6
highlight todoLow ctermfg=0 ctermbg=14
highlight todoToday ctermfg=0 ctermbg=13

highlight def link todoProject Identifier 
highlight def link todoTag Tag
highlight def link todoCanc Error
highlight def link todoDone comment
highlight def link todoTodo Error

let b:current_syntax = "todo"
" ✔ ✘ ☐
