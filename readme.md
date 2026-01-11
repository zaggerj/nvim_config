# 更新描述

> 2026/01/11 (最新)

**新增插件功能**

本次更新新增了 4 个强大的插件,显著提升 Neovim 的易用性和学习体验:

1. **Which-Key** (`folke/which-key.nvim`)
   - 实时显示可用快捷键提示
   - 按下 `<Leader>` 后等待 200ms 自动弹出提示窗口
   - 支持快捷键分组和 Vim 原生命令帮助
   - 详见 `BEST_PRACTICES.md` 第九章第 1 节

2. **Alpha-nvim** (`goolord/alpha-nvim`)
   - 美观的启动引导页面
   - 提供快速访问入口(查找文件、全局搜索、最近文件等)
   - 实时显示插件数量和系统信息
   - 详见 `BEST_PRACTICES.md` 第九章第 2 节

3. **Legendary** (`mrjones2014/legendary.nvim`)
   - 强大的命令面板,快捷键 `<Leader><Leader>`
   - 模糊搜索所有命令和快捷键
   - 基于 SQLite 的使用频率统计
   - 详见 `BEST_PRACTICES.md` 第九章第 3 节

4. **Vim-Tutor-Mode** (`fmoralesc/vim-tutor-mode`)
   - 交互式 Vim 教程,支持中文
   - 快捷键 `<Leader>?t` 启动中文教程
   - 自动保存学习进度
   - 详见 `BEST_PRACTICES.md` 第九章第 4 节

**快速开始**:
- 按 `<Leader>` 键(空格)查看所有可用快捷键
- 按 `<Leader><Leader>` 打开命令面板
- 按 `<Leader>?t` 启动交互式教程

---

> 2026/01/11

**平台兼容性优化**

1. 新增 Termux/Android 平台自动检测功能
2. TabNine 插件在 Termux 环境下自动禁用(该平台不支持 TabNine 二进制文件)
3. 通过 `$TERMUX_VERSION` 环境变量实现条件加载,保持其他平台正常使用

**重要提示**: 如果在 Termux 中仍看到 TabNine 错误,需要手动卸载已安装的扩展:

```vim
" 方法 1: 使用 Coc 命令(推荐)
:CocUninstall coc-tabnine

" 方法 2: 手动删除扩展目录
" 在 Termux 终端执行:
rm -rf ~/.config/coc/extensions/node_modules/coc-tabnine

" 验证修复
:CocList extensions  " 确认列表中没有 coc-tabnine
```

详细说明请参考 `BEST_PRACTICES.md` 第十五章节。

> 2020/11/19

修复键入`a`进入插入模式缓慢情况。

> 2020/9/28

更好的补全体验（利用悬浮窗口）

1. 现在可以通过`gh`来查函数文档。
2. 现在可以通过`<C-f>/<C-b>`来翻页文档
3. `refactor`更改为`rename`。

> 2020/9/27

整理布局：
主板块：插件列表，映射列表，选项列表，函数列表

> 2020/8/19

1. 重新映射`:`到`\`，以减少击键的次数。
2. 默认将搜索映射到`verymagic`以保持一致性。
3. 适度调整了映射项目的顺序。

> 2020/8/18

添加vimwiki下的鼠标支持。

> 2020/3/1

更新补全搭配方式，采用msys2->Mingw-w64-clang, clang-tools-extra->clangd进行补全。

> 2020/2/16

## 快捷键

- <Esc>以在终端键入`exit`

> 2020/2/14

## 快捷键

1. 快速开启终端。
2. 以与`Insert`模式相同方式退出终端。
3. `Tab`以补全。
5. 快速调用`vim-plug`。
6. 查询光标所在处选项的文档。
7. 便捷地切换窗口。

## 函数

1. 屏幕分割比例计算。
2. 屏幕分割执行。
3. `tab`补全。
4. 当前文件路径获取。

## 属性

1. 延长`leader`键等待时间。
2. 直观化设置。
3. 修改弹出菜单透明度。
