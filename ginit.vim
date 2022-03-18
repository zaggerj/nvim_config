" 注意：只有最新版的 nvim-qt 支持已被注释掉的选项
if exists('g:GuiLoaded')
    " 用 w57 指定粗细为 retina，retina 和 medium 其实没有区别
    GuiFont! FiraCode NF:h16:w57
    " GuiRenderLigatures 1
    GuiPopupmenu 0
    GuiTabline 0
    " GuiWindowOpacity 0.95
endif
