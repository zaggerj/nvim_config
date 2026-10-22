" 保留旧函数入口，项目身份、路径与切换事件由同一模块管理。
function! TrySwitchTheme()
    lua require('project_theme').apply()
endfunction
lua require('project_theme').setup()
