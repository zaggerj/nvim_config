if exists('g:started_by_firenvim')
    let &guifont = "Iosevka Curly Slab Medium:h12"
    " 这里得禁用掉状态栏和顶栏，提供不了什么信息
    set laststatus=1
    set showtabline=1
    " 没有底部栏，得找个办法显示模式
    set showmode
    "----------"

    au BufEnter 172.21.17.174* set complete+=k | set dictionary+=D:\Working\iScriptDict.txt 
    function SetDict() abort 
        set complete+=k
        set dictionary+=D:\Working\iScriptDict.txt
    endfunction
    noremap <leader>id <cmd>call SetDict()<cr>
endif

