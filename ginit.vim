if exists('g:GuiLoaded')
    " 注意：只有最新版的 nvim-qt 支持已被注释掉的选项
    " 用 w57 指定粗细为 retina，retina 和 medium 其实没有区别
    GuiFont! FantasqueSansMono NF:h14,思源黑体:h14

    GuiPopupmenu 0
    GuiTabline 0
    " GuiRenderLigatures 1
    GuiWindowOpacity 0.95
elseif exists('g:fvim_loaded')
    " Fvim nvim-tree 无法正确显示
    let &guifont = "FiraCode NF:h18"
    " 启用抗锯齿，和 hint
    FVimFontAntialias v:true
    FVimFontSubpixel v:true
    FVimFontAutohint v:true
    FVimFontHintLevel 'full'
    FVimFontLigature v:true

    FVimFontNoBuiltinSymbols v:true
    FVimCursorSmoothMove v:true

    FVimCustomTitleBar v:true
elseif exists('g:neovide')
    " neovide 中文输入法输入框位置不正确
    set guifont=FiraCode\ NF:h14
    let g:neovide_remember_window_position = v:true
    let g:neovide_remember_window_size = v:true
    " 更短的拖尾
    let g:neovide_cursor_trail_length=0.1
    let g:neovide_cursor_animation_length=0
    " 存在内存泄漏，关闭
    " let g:neovide_cursor_vfx_mode = "railgun"
    " 更显眼的粒子
    " let g:neovide_cursor_vfx_particle_lifetime=1.4
    " let g:neovide_cursor_vfx_particle_density=9.0
endif
