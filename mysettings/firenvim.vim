if exists('g:started_by_firenvim')
lua << EOF
    -- 白名单，这里用 lua 写比较方便
    vim.g.firenvim_config = {
        localSettings = {
            [".*"] = {takeover = "never", priority = 0},
            ["http://172.21.17.175:8080/designer"] = {
                takeover = "always",
                selector = "textarea.SourceField,textarea:not(td>textarea,.el-textarea__inner)"
            },
            ["http://172.16.65.50:8080/designer"] = {
                takeover = "always",
                selector = "textarea.SourceField,textarea:not(td>textarea,.el-textarea__inner)"
            },
            ["http://172.16.65.52:8080/designer"] = {
                takeover = "always",
                selector = "textarea.SourceField,textarea:not(td>textarea,.el-textarea__inner)"
            },
        },
    }
EOF

    let &guifont = "Cascadia Code:h11"
    " 这里得禁用掉状态栏和顶栏，提供不了什么信息
    colorscheme everforest
    set laststatus=1
    set showtabline=1
    set cursorcolumn
    set wrap
    set mouse=
    " 没有底部栏，得找个办法显示模式
    set showmode

    function! InitDicts() abort
        let l:dicts = split(&dictionary, ",")
        for item in glob("D:/Working/iScriptDicts/*", v:false, v:true) 
            call insert(l:dicts, fnameescape(item))
        endfor
        let &dictionary = join(l:dicts, ",")
    endfunction

    au! BufEnter 172.* set ft=javascript | set complete+=k | call InitDicts()

    function! AppendDict() abort
        let word = expand("<cword>")
        call writefile([word], "D:/Working/iScriptDicts/Custom.txt", "a")
    endfunction
    noremap <leader>ia <cmd>call AppendDict()<cr>

    " 用 : 切换模式而不是 <cmd>
    vnoremap <leader>is :s/\v$/ \\/<cr>
    " vnoremap <leader>is :s/\v^(\s)*(\w.+)$/\1"\2 " +/g<cr>
    " 注释和取消注释所有的 println
    nnoremap <leader>ic <cmd>g/\v^\s*println/normal gcc<cr>
    nnoremap <leader>iC <cmd>g/\v\/\/.?println/normal gcc<cr>
endif
