if exists("g:todo_loaded")
    finish
endif


let g:todo_symbols= {"todo":"\u25a1", "doing": "\u23F1", "done": "\u2714", "cancel": "\u2717"}
let g:todo_loaded = v:true

call todo#init()

