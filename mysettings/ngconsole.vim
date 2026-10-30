" 保留旧函数入口，项目身份、路径与切换事件由同一模块管理。
" 按项目根名称匹配，Windows/macOS无需写不同的绝对路径。
lua << EOF
vim.g.nvim_project_themes = {
  { root = 'aipaas', theme = 'tokyonight-night', background = 'dark' },
  { root = 'zagger_obsidian_gc', theme = 'catppuccin-latte', background = 'light' },
}
EOF

function! TrySwitchTheme()
    lua require('project_theme').apply()
endfunction
lua require('project_theme').setup()
