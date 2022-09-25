if exists('g:started_by_firenvim')
    let &guifont = "Iosevka Curly Slab Medium:h12"
    " 这里得禁用掉状态栏和顶栏，提供不了什么信息
    set laststatus=1
    set showtabline=1
    " 没有底部栏，得找个办法显示模式
    set showmode

    function! InitDicts() abort
        let l:dicts = split(&dictionary, ",")
        for item in glob("D:/Working/iScriptDicts/*", v:false, v:true) 
            call insert(l:dicts, fnameescape(item))
        endfor
        let &dictionary = join(l:dicts, ",")
    endfunction

    au! BufEnter 172.21.17.174* set ft=javascript | set complete+=k | call InitDicts()

    function! AppendDict() abort
        let word = expand("<cword>")
        call writefile([word], "D:/Working/iScriptDicts/Custom.txt", "a")
    endfunction
    noremap <leader>ia <cmd>call AppendDict()<cr>

    function! Surround() abort
        " s/\v^(\s*)(.+)$/\1"\2 " +/
        '<,'>s/\v$/ \\/
        noh
    endfunction
    " noremap 不能正确获取到范围！
    vnoremap <leader>is <cmd>call Surround()<cr>
    "
    " 注释和取消注释所有的 println
    nnoremap <leader>ic <cmd>g/\v^\s*println/normal gcc<cr>
    nnoremap <leader>iC <cmd>g/\v\/\/.?println/normal gcc<cr>
endif
