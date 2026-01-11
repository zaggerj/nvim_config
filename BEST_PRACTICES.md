# Neovim 最佳实践指南

> 基于你当前的配置分析，这是一份完整的工作流程和快捷键速查手册

## 核心理念

你的配置已经非常优秀,遵循了以下原则：

- **Leader 键**: `Space` (空格)
- **插件管理**: Lazy.nvim (懒加载优化)
- **LSP 引擎**: CoC.nvim (强大的补全和诊断)
- **文件搜索**: Telescope (模糊搜索神器)
- **Git 集成**: Fugitive + Gitsigns
- **代码折叠**: nvim-ufo (基于 Treesitter)

---

## 一、Buffer 管理 (文件弹药库)

### 核心快捷键

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl-Left` | 上一个 Buffer | `:bp` |
| `Ctrl-Right` | 下一个 Buffer | `:bn` |
| `<Leader><Left>` | 关闭当前 Buffer | `:bdelete` |
| `<Leader>lb` | Telescope Buffer 列表 | 模糊搜索已打开文件 |
| `<Leader>lr` | 最近打开的文件 | `:Telescope oldfiles` |

### 最佳实践

```vim
" 快速在最近的 2-3 个文件间切换
Ctrl-Left / Ctrl-Right

" 打开了 20+ 文件？用 Telescope 模糊搜索
<Leader>lb  " 输入文件名片段即可跳转
```

**建议**: 不要手动 `:ls` 查看 Buffer 列表，直接用 `<Leader>lb` 进行可视化搜索。

---

## 二、Window 管理 (工作台布局)

### 窗口切换 (Alt + hjkl)

| 快捷键 | 功能 |
|--------|------|
| `Alt-h` | 移动到左边窗口 |
| `Alt-j` | 移动到下边窗口 |
| `Alt-k` | 移动到上边窗口 |
| `Alt-l` | 移动到右边窗口 |

### 窗口移动 (Alt-Shift + hjkl)

| 快捷键 | 功能 |
|--------|------|
| `Alt-Shift-h` | 将当前窗口移到最左 |
| `Alt-Shift-j` | 将当前窗口移到最下 |
| `Alt-Shift-k` | 将当前窗口移到最上 |
| `Alt-Shift-l` | 将当前窗口移到最右 |

### 窗口大小调整

| 快捷键 | 功能 |
|--------|------|
| `<Leader>b` | 增加高度 (+8) |
| `<Leader>B` | 大幅增加高度 (+50) |
| `<Leader>w` | 增加宽度 (+8) |
| `<Leader>W` | 大幅增加宽度 (+56) |

### 终端窗口

| 快捷键 | 功能 |
|--------|------|
| `<Leader>cc` | 打开终端 |
| `<Leader>cs` | 水平分屏打开终端 |
| `Ctrl-E` | 退出终端 (在终端 buffer 中) |
| `fj` | 从终端模式退出到 Normal 模式 |

### 最佳实践

```vim
" 前端开发典型布局：
" 1. 垂直分屏：左边 .tsx，右边 .scss
:vsplit UserList.scss

" 2. 用 Alt-h/l 快速切换左右窗口
Alt-h  " 回到 .tsx
Alt-l  " 跳到 .scss

" 3. 底部开个小终端跑 dev server
<Leader>cs  " 水平分屏终端
npm run dev

" 4. 调整终端高度
<Leader>b  " 增加一点高度
```

---

## 三、Tab 管理 (任务舱)

### Tab 操作

| 快捷键 | 功能 |
|--------|------|
| `Ctrl-Shift-Up` | 新建 Tab |
| `Ctrl-Shift-Down` | 关闭当前 Tab |
| `gt` | 下一个 Tab |
| `gT` | 上一个 Tab |

### 最佳实践

```vim
" Tab 用于任务隔离，不是文件切换！

" Tab 1: 业务开发
UserList.tsx, UserList.scss, user.model.ts

" Tab 2: 配置文件 (紧急修改)
Ctrl-Shift-Up  " 新建 Tab
<Leader>lf     " 搜索 vite.config.ts
修改完毕
Ctrl-Shift-Down  " 关闭 Tab，回到业务开发

" Tab 3: 调试第三方库源码
```

---

## 四、Telescope 文件搜索 (核心工作流)

### 文件与内容搜索

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `<Leader>lf` | 搜索文件名 | 默认排除隐藏/临时文件 (极速) |
| `<Leader>fh` | 搜索文件名 (含隐藏) | 包含 `.env`, `.git` 等隐藏文件 |
| `<Leader>lg` | 全局搜索内容 | `live_grep` (包含隐藏文件内容) |
| `<Leader>ls` | 搜索光标下的词 | `grep_string` |
| `<Leader>lb` | 搜索已打开的 Buffer | 快速切换文件 |
| `<Leader>lr` | 最近打开的文件 | `oldfiles` |

### 📂 文件打开方式 (快捷键)

在搜索结果列表中，您可以使用以下快捷键决定如何打开文件：

| 快捷键 | 结果 | 模式说明 |
| :--- | :--- | :--- |
| **`Enter`** | **当前窗口** | 替换当前 Buffer (最常用) |
| **`Ctrl + v`** | **垂直分屏** | 在左右新建窗口打开 |
| **`Ctrl + x`** | **水平分屏** | 在上下新建窗口打开 |
| **`Ctrl + t`** | **新标签页** | 新建 Tab 标签页打开 |

> [!TIP]
> 如果不确定快捷键，可以在 Telescope 窗口内按 **`?`** 查看实时帮助。


### Git 相关搜索

| 快捷键 | 功能 |
|--------|------|
| `<Leader>lj` | Git 状态 (已修改文件) |
| `<Leader>lk` | Git Stash 列表 |
| `<Leader>ll` | Git 分支列表 |

### 其他实用搜索

| 快捷键 | 功能 |
|--------|------|
| `<Leader>lv` | Vim 选项 |
| `<Leader>lt` | 寄存器内容 |
| `<Leader>lm` | 标记 (Marks) |
| `<Leader>lh` | 帮助文档 |

### 最佳实践

```vim
" 场景 1: 找到某个组件文件
<Leader>lf
输入: UserList  " 模糊匹配，直接回车打开

" 场景 2: 全局搜索某个函数调用
<Leader>lg
输入: fetchUserData  " 实时显示所有匹配

" 场景 3: 查看当前词在哪里被使用
光标移到 handleClick
<Leader>ls  " 自动搜索 handleClick

" 场景 4: 查看 Git 修改了哪些文件
<Leader>lj  " 快速跳转到修改的文件
```

**配置亮点**: 你的 `live_grep` 已经配置了极度精确的 ripgrep 参数：
- **性能飞跃**: 默认在扫描阶段就排除 `.git/`, `node_modules/`, `.quokka/` 等。
- **搜索深度**: 搜索文件数从 24万+ 降至有效源码范围，响应极速。
- **智能过滤**: 自动忽略二进制、媒体文件、缓存及构建产物。
- **防抖延迟**: 100ms 快速响应。

---

## 五、CoC 代码智能 (LSP 核心)

### 代码导航

| 快捷键 | 功能 |
|--------|------|
| `gd` | 跳转到定义 |
| `gr` | 查找所有引用 |
| `gh` | 显示悬浮文档 (Hover) |
| `<Up>` | 上一个诊断错误 |
| `<Down>` | 下一个诊断错误 |

### 代码操作

| 快捷键 | 功能 |
|--------|------|
| `<F2>` | 重命名符号 |
| `<Leader>.` | 代码操作 (Code Action) |
| `<Leader>cf` | 格式化代码 |
| `<Leader>ci` | 组织导入 (Organize Imports) |

### 补全与代码片段

| 快捷键 | 功能 |
|--------|------|
| `Tab` | 选择下一个补全项 |
| `Shift-Tab` | 选择上一个补全项 |
| `Enter` | 确认补全 |
| `<Leader>cv` | 转换为代码片段 (Visual 模式) |

### CoC 管理

| 快捷键 | 功能 |
|--------|------|
| `<Leader>cr` | 重启 CoC |
| `<Leader>cc` | 打开 CoC 配置 |
| `<Leader>cl` | 打开 CoC List |

### 最佳实践

```vim
" 场景 1: 快速查看函数定义
光标移到 fetchUserData
gd  " 跳转到定义
Ctrl-o  " 跳回原位置

" 场景 2: 查看所有调用点
光标移到 UserList
gr  " 显示所有引用位置

" 场景 3: 修复 ESLint 错误
<Down>  " 跳到错误行
<Leader>.  " 打开 Code Action
选择 "Fix all auto-fixable problems"

" 场景 4: 重命名变量
光标移到 userName
<F2>
输入新名字: userFullName
回车  " 自动重命名所有引用
```

**配置亮点**:
- 自动保存时格式化 (JS/TS/Lua)
- ESLint 自动修复
- TypeScript Inlay Hints (显示类型提示)
- 智能导入建议

---

## 六、Git 工作流

### Fugitive (Git 命令)

| 快捷键 | 功能 |
|--------|------|
| `<Leader>gs` | Git Status (`:G`) |
| `<Leader>gps` | Git Push |
| `<Leader>gpl` | Git Pull |
| `<Leader>gla` | Git Log (所有提交) |
| `<Leader>gll` | 当前行的 Git Log |
| `<Leader>gls` | 搜索光标下词的历史 |

### Gitsigns (行级 Git 操作)

| 快捷键 | 功能 |
|--------|------|
| `]g` | 下一个 Git Hunk |
| `[g` | 上一个 Git Hunk |
| `[d` | Diff 当前文件 (未暂存) |
| `[f` | Diff 当前文件 (已暂存) |
| `[c` | Stage 当前文件 |
| `]c` | 重置当前文件的修改 |

### 最佳实践

```vim
" 场景 1: 查看修改了什么
<Leader>gs  " 打开 Git Status
j/k 移动到文件
=  " 查看 diff

" 场景 2: 快速浏览代码修改
]g  " 跳到下一个修改块
[d  " 查看详细 diff

" 场景 3: 查看某行代码的历史
光标移到某行
<Leader>gll  " 显示这一行的所有修改历史

" 场景 4: 提交代码
<Leader>gs
s  " Stage 文件 (在 Fugitive 窗口中)
cc  " 提交
输入 commit message
:wq
<Leader>gps  " Push
```

**配置亮点**:
- Gitsigns 显示当前行的 Blame 信息 (延迟 1 秒)
- 实时显示修改标记 (signcolumn)

---

## 七、代码折叠 (nvim-ufo)

| 快捷键 | 功能 |
|--------|------|
| `zR` | 展开所有折叠 |
| `zM` | 折叠所有 |
| `za` | 切换当前折叠 |

### 最佳实践

```vim
" 打开一个大文件 (500+ 行)
<Leader>lf
UserList.tsx

" 折叠所有函数
zM

" 只展开需要的部分
移动到 handleSubmit
za  " 展开这个函数

" 全部展开
zR
```

---

## 八、其他实用功能

### 文件树 (nvim-tree)

| 快捷键 | 功能 |
|--------|------|
| `<Leader>pd` | 切换文件树 |
| `<Leader>fh` | 切换到当前文件目录 |

### Vista (代码大纲)

| 快捷键 | 功能 |
|--------|------|
| `<Leader>pv` | 打开 Vista 大纲 |

### Sneak (快速跳转)

| 快捷键 | 功能 |
|--------|------|
| `'` + 两个字符 | 向前跳转 |
| `Backspace` + 两个字符 | 向后跳转 |

### Diff 模式

| 快捷键 | 功能 |
|--------|------|
| `<Leader>dt` | 开启 Diff |
| `<Leader>do` | 关闭 Diff |

### 编辑增强

| 快捷键 | 功能 |
|--------|------|
| `fj` | 退出 Insert 模式 (代替 Esc) |
| `\` | 命令模式 (代替 `:`) |
| `/` | 搜索 (自动开启 Very Magic 模式) |
| `<Leader>n` | 清除搜索高亮 |
| `Ctrl-v` | 粘贴 (Insert 模式) |

---

## 九、新增插件使用指南

### 1. Which-Key (快捷键提示系统)

**功能**: 实时显示可用的快捷键组合,帮助快速学习和记忆 Neovim 快捷键。

#### 工作原理

当你按下 `<Leader>` 键(空格)后稍作停顿(200ms),会自动弹出一个浮动窗口,显示所有可用的快捷键组合及其功能说明。

#### 快捷键分组

| 前缀 | 分组名称 | 说明 |
|------|---------|------|
| `<Leader>f` | 🔍 查找 (Find) | Telescope 文件搜索相关 |
| `<Leader>g` | 🔀 Git 操作 | Git 版本控制命令 |
| `<Leader>h` | 🔧 Git Hunk 操作 | Git 代码块级别操作 |
| `<Leader>t` | 🎯 切换 (Toggle) | 开关类功能 |
| `<Leader>b` | 📦 缓冲区 (Buffer) | Buffer 管理 |
| `<Leader>w` | 🪟 窗口 (Window) | 窗口布局管理 |
| `<Leader>c` | 💻 代码 (Code) | 代码操作和 CoC 相关 |
| `<Leader>d` | 🐛 调试 (Debug) | 调试功能 |
| `<Leader>s` | 🔎 搜索 (Search) | 高级搜索功能 |
| `<Leader>n` | 📝 笔记 (Notes) | Neorg 笔记管理 |
| `<Leader>?` | ❓ 帮助 (Help) | 帮助和教程 |

#### 常用快捷键示例

```vim
" 查找相关
<Leader>ff  " 查找文件
<Leader>fg  " 全局搜索
<Leader>fb  " 查找缓冲区
<Leader>fh  " 查找帮助文档
<Leader>fr  " 最近文件

" 文件树和大纲
<Leader>e   " 文件树
<Leader>v   " 代码大纲

" 帮助系统
<Leader>?t  " 📚 Vim 教程 (中文)
<Leader>?e  " 📚 Vim Tutorial (English)
<Leader>?h  " 📖 搜索帮助文档
<Leader>?k  " ⌨️  查看所有快捷键
<Leader>?c  " 🔧 搜索命令

" 命令面板
<Leader><Leader>  " 🎯 打开 Legendary 命令面板
```

#### 最佳实践

```vim
" 场景 1: 忘记快捷键时
<Leader>  " 按下空格后等待 200ms
" 自动显示所有可用的快捷键分组

" 场景 2: 探索某个分组的功能
<Leader>f  " 按下后等待
" 显示所有 f 开头的快捷键(查找相关)

" 场景 3: 查看所有快捷键
<Leader>?k  " 打开 Telescope 快捷键搜索
" 可以模糊搜索任何快捷键

" 场景 4: 学习 Vim 原生快捷键
z  " 按下 z 后等待
" 显示所有 z 开头的折叠命令

g  " 按下 g 后等待
" 显示所有 g 开头的导航命令
```

#### 配置亮点

- **智能触发**: 200ms 延迟,不影响正常操作
- **圆角边框**: 美观的浮动窗口样式
- **完整预设**: 自动显示 Vim 原生操作符、移动命令、文本对象等帮助
- **拼写建议**: 支持拼写检查和建议(20 条)

---

### 2. Alpha-nvim (启动引导页面)

**功能**: 美观的 Neovim 启动页面,提供快速访问常用功能的入口。

#### 启动页面内容

```
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
```

#### 快捷操作按钮

| 按键 | 功能 | 说明 |
|------|------|------|
| `f` | 🔍 查找文件 | 打开 Telescope 文件搜索 |
| `g` | 🔎 全局搜索 | 打开 Telescope 内容搜索 |
| `r` | 📁 最近文件 | 查看最近打开的文件 |
| `c` | ⚙️  配置文件 | 编辑 init.vim |
| `t` | 📚 启动教程 | 打开中文 Vim 教程 |
| `l` | 💤 插件管理 | 打开 Lazy 插件管理器 |
| `q` | 🚪 退出 | 退出 Neovim |

#### 页脚信息

页脚会实时显示:
- 当前日期和时间
- 已安装的插件数量
- Neovim 版本号

示例: ` 2026-01-11   15:54:00   45 plugins   v0.10.0`

#### 最佳实践

```vim
" 场景 1: 快速启动工作流
nvim  " 打开 Neovim
f     " 按 f 搜索文件
输入文件名并打开

" 场景 2: 查看配置
nvim
c     " 直接打开配置文件

" 场景 3: 学习 Vim
nvim
t     " 启动交互式教程

" 场景 4: 管理插件
nvim
l     " 打开 Lazy 插件管理器
```

#### 配置亮点

- **自动刷新**: 页脚时间会在插件加载完成后自动更新
- **美观设计**: 使用 ASCII 艺术字和 Emoji 图标
- **快速访问**: 一键直达常用功能
- **信息丰富**: 实时显示系统状态

---

### 3. Legendary.nvim (命令面板)

**功能**: 强大的命令面板,提供模糊搜索所有命令、快捷键和自定义操作。

#### 打开命令面板

| 快捷键 | 功能 |
|--------|------|
| `<Leader><Leader>` | 打开命令面板 |

#### 功能特性

1. **智能搜索**: 模糊匹配所有可用命令
2. **使用频率排序**: 基于 SQLite 数据库记录使用历史
3. **集成 Which-Key**: 自动注册所有 Which-Key 快捷键
4. **包含内置命令**: 显示 Vim/Neovim 原生命令

#### 预设命令列表

```vim
:Lazy              " 打开插件管理器
:Lazy sync         " 同步插件
:Lazy update       " 更新插件
:NvimTreeFindFileToggle  " 切换文件树
:Vista!!           " 切换代码大纲
:Tutor zh          " 启动中文教程
:Tutor             " 启动英文教程
```

#### 最佳实践

```vim
" 场景 1: 忘记命令名称时
<Leader><Leader>
输入关键词: tree
" 自动匹配 NvimTreeFindFileToggle

" 场景 2: 快速执行常用命令
<Leader><Leader>
输入: lazy
" 显示所有 Lazy 相关命令

" 场景 3: 查找快捷键
<Leader><Leader>
输入: telescope
" 显示所有 Telescope 相关的快捷键和命令

" 场景 4: 探索功能
<Leader><Leader>
直接浏览列表
" 按使用频率排序,最常用的在最上面
```

#### 配置亮点

- **频率统计**: 自动记录最近 10 次使用时间戳
- **数据持久化**: 使用 SQLite 保存使用历史
- **中文界面**: 搜索提示为 " 命令面板 "
- **自动集成**: 无需手动注册,自动发现所有命令

---

### 4. Vim-Tutor-Mode (交互式教程)

**功能**: Neovim 官方交互式教程,支持多语言,带进度保存功能。

#### 启动教程

| 快捷键 | 功能 |
|--------|------|
| `<Leader>?t` | 启动中文教程 |
| `<Leader>?e` | 启动英文教程 |
| `:Tutor zh` | 命令启动中文教程 |
| `:Tutor` | 命令启动默认语言教程 |

#### 支持的语言

- `zh` - 简体中文
- `en` - English
- `es` - Español
- `fr` - Français
- `de` - Deutsch
- `it` - Italiano
- `ja` - 日本語
- `ko` - 한국어
- `pt` - Português
- `ru` - Русский

#### 教程内容

教程分为多个课程,涵盖:
1. **基础移动**: hjkl, w, b, e 等
2. **编辑操作**: d, c, y, p 等
3. **搜索替换**: /, ?, :s 等
4. **文本对象**: iw, aw, i(, a( 等
5. **高级功能**: 宏录制、寄存器、标记等

#### 进度保存

配置已启用 `g:tutor_save_progress = 1`,你的学习进度会自动保存:
- 完成的练习会被标记
- 下次打开会从上次位置继续
- 进度文件保存在 Neovim 数据目录

#### 最佳实践

```vim
" 场景 1: 新手学习
nvim
<Leader>?t  " 启动中文教程
" 按照教程逐步练习

" 场景 2: 查漏补缺
:Tutor zh
" 跳到特定章节复习

" 场景 3: 学习英文术语
:Tutor  " 启动英文教程
" 了解 Vim 命令的英文原意

" 场景 4: 快速查阅
<Leader>?h  " 搜索帮助文档
输入关键词
" 比教程更快速的参考方式
```

#### 配置亮点

- **默认中文**: 自动使用中文教程
- **进度保存**: 学习进度持久化
- **交互式学习**: 边学边练,即时反馈
- **官方教程**: Neovim 官方维护,内容权威

---

### 新插件快速参考

| 插件 | 核心快捷键 | 主要功能 |
|------|-----------|---------|
| **Which-Key** | `<Leader>` + 等待 | 实时显示可用快捷键 |
| **Alpha-nvim** | 启动时自动显示 | 美观的启动页面 |
| **Legendary** | `<Leader><Leader>` | 命令面板和模糊搜索 |
| **Vim-Tutor** | `<Leader>?t` | 交互式 Vim 教程 |

---

## 十、完整前端开发工作流

### 场景：开发一个用户列表页面

#### 1. 启动项目

```vim
" 打开 Neovim
nvim

" 搜索主文件
<Leader>lf
UserList.tsx

" 开启终端跑 dev server
<Leader>cs
npm run dev
Alt-k  " 回到代码窗口
```

#### 2. 编写代码

```vim
" 查看类型定义
光标移到 User
gd  " 跳到 user.model.ts
Ctrl-o  " 跳回

" 自动导入
输入 useState
Tab  " 自动补全并导入

" 查看文档
光标移到 useEffect
gh  " 显示 Hover 文档
```

#### 3. 样式开发

```vim
" 垂直分屏打开样式文件
:vsplit UserList.module.scss

" 左右切换
Alt-h  " 回到 .tsx
Alt-l  " 跳到 .scss

" 调整窗口宽度
<Leader>W  " 增加右侧宽度
```

#### 4. 调试与修复

```vim
" 查看 ESLint 错误
<Down>  " 跳到错误

" 自动修复
<Leader>.
选择 "Fix..."

" 格式化代码
<Leader>cf
```

#### 5. Git 提交

```vim
" 查看修改
<Leader>gs

" 查看 diff
]g  " 跳到修改块
[d  " 查看详细 diff

" 提交
<Leader>gs
s  " Stage
cc  " Commit
:wq
<Leader>gps  " Push
```

#### 6. 搜索与重构

```vim
" 全局搜索某个函数
<Leader>lg
fetchUserData

" 重命名
光标移到 fetchUserData
<F2>
getUserList
回车

" 查看所有引用
gr
```

---

## 十一、避坑指南 (常见误操作修复)

### 1. 误入命令行窗口 (Command-line Window)

**现象**：下方突然弹出一个显示历史命令的小窗口，标记有 `COMMAND` 或 `:[`。

- **触发原因**：
    - 普通模式误触 **`q:`** (查看命令历史)
    - 输入命令模式下误触 **`Ctrl + f`**
- **解药 (如何退出)**：
    - 按下 **`:q`** 然后回车。
    - 或者连续按两次 **`Ctrl + c`**。

---

## 十二、高级技巧

### 1. 快速切换最近文件

```vim
" 在 A.tsx 和 B.tsx 之间反复横跳
Ctrl-Left / Ctrl-Right
```

### 2. 多文件批量操作

```vim
" 搜索所有包含 TODO 的文件
<Leader>lg
TODO

" 在结果中批量修改
:cdo s/TODO/DONE/g
:cfdo update
```

### 3. 代码片段快速插入

```vim
" Insert 模式
_tm  " 自动插入当前日期 (2026-01-06)
```

### 4. 文本对象操作

```vim
" 选择整个函数
vaf  " Visual select a function

" 删除函数内部
dif  " Delete inner function
```

### 5. 浮动窗口滚动

```vim
" CoC 文档浮动窗口太长？
Ctrl-f  " 向下滚动
Ctrl-b  " 向上滚动
```

---

## 十二、配置文件快速访问

| 快捷键 | 功能 |
|--------|------|
| `<Leader>fs` | 打开 `init.vim` |
| `<Leader>cc` | 打开 `coc-settings.json` |

---

## 十三、总结：核心工作流

### Buffer (文件管理)
- 用 `<Leader>lb` 搜索，不要手动 `:ls`
- 用 `Ctrl-Left/Right` 快速切换最近文件

### Window (布局管理)
- 用 `Alt-hjkl` 切换窗口
- 垂直分屏：左代码右样式
- 水平分屏：上代码下终端

### Tab (任务隔离)
- 一个 Tab = 一个任务上下文
- 不要用 Tab 切换文件

### Telescope (搜索一切)
- `<Leader>lf`: 文件名
- `<Leader>lg`: 内容
- `<Leader>lb`: Buffer
- `<Leader>lj`: Git 状态

### CoC (代码智能)
- `gd`: 定义
- `gr`: 引用
- `<F2>`: 重命名
- `<Leader>.`: 代码操作

### Git (版本控制)
- `<Leader>gs`: 状态
- `]g/[g`: 跳转修改
- `[d`: Diff

---

## 十四、快捷键速查表

### 最常用 (Top 20)

```
<Leader>lf    搜索文件
<Leader>lg    搜索内容
<Leader>lb    搜索 Buffer
Ctrl-Left     上一个文件
Ctrl-Right    下一个文件
Alt-h/j/k/l   切换窗口
gd            跳转定义
gr            查找引用
<F2>          重命名
<Leader>.     代码操作
<Leader>gs    Git Status
]g / [g       Git Hunk 跳转
<Leader>pd    文件树
<Leader>n     清除高亮
fj            退出 Insert
<Down>        下一个错误
<Leader>cf    格式化
<Leader>cr    重启 CoC
zM / zR       折叠/展开
<Leader>fs    打开配置
```

---

## 十五、建议优化

基于你的配置，以下是一些可选的优化建议：

### 1. 添加 Buffer 快速跳转

```lua
-- 在 lua/plugins.lua 中添加
vim.keymap.set('n', 'H', ':bprev<CR>', { desc = '上一个文件' })
vim.keymap.set('n', 'L', ':bnext<CR>', { desc = '下一个文件' })
```

### 2. 增强 Telescope 预览

```lua
-- 在 Telescope opts 中添加
defaults = {
  layout_config = {
    preview_width = 0.6,
  },
}
```

### 3. 快速关闭其他 Buffer

```vim
" 在 maps.vim 中添加
nnoremap <silent> <Leader>bo <Cmd>%bd|e#|bd#<CR>
```

---

**恭喜！你的配置已经非常专业，充分利用了 Neovim 的现代化特性。记住核心原则：**

1. **Buffer 是文件** → 用 Telescope 搜索
2. **Window 是视野** → 用 Alt-hjkl 切换
3. **Tab 是任务** → 用于隔离不同工作上下文

**永远优先使用模糊搜索，而不是手动导航！**

---

## 十六、Termux/Android 平台兼容性

### 问题背景

TabNine 插件不支持 Android 平台,因为官方没有提供对应的二进制文件。在 Termux 环境下加载 TabNine 会导致以下错误:

```
[coc.nvim]: UnhandledRejection: Error: Sorry, the platform 'android' is not supported by TabNine.
```

### 解决方案

本配置已实现**自动检测 Termux 环境并条件禁用 TabNine**,无需手动修改配置文件。

#### 实现原理

在 `init.vim` 中通过检测 `$TERMUX_VERSION` 环境变量判断是否为 Termux 环境:

```vim
" 检测是否为 Termux 环境 (Android 平台)
let s:is_termux = !empty($TERMUX_VERSION)

" 基础插件列表(14个通用插件)
let s:base_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-css',
  \ 'coc-eslint',
  \ 'coc-pairs',
  \ 'coc-omni',
  \ 'coc-marketplace',
  \ 'coc-lists',
  \ 'coc-html',
  \ 'coc-emmet',
  \ 'coc-dictionary',
  \ 'coc-cssmodules',
  \ 'coc-lua',
  \ 'coc-unocss',
  \ ]

" 仅在非 Termux 环境下添加 TabNine
if !s:is_termux
  let s:base_extensions += ['coc-tabnine']
endif

let g:coc_global_extensions = s:base_extensions
```

#### 环境检测逻辑

- **Termux 环境**: `$TERMUX_VERSION` 变量存在 → 不加载 `coc-tabnine`
- **其他平台** (macOS/Linux/Windows): 变量不存在 → 正常加载 `coc-tabnine`

### ⚠️ 重要:手动卸载已安装的扩展

**条件加载代码只能阻止 Coc 自动安装新扩展,但无法卸载已安装的扩展。**

如果您之前在 Termux 中使用过 Neovim,`coc-tabnine` 可能已经被安装,即使配置中不包含它,Coc 仍会尝试加载已存在的扩展。

#### 方法 1: 使用 Coc 命令(推荐)

1. 在 Termux 中打开 Neovim
2. 执行命令:
   ```vim
   :CocUninstall coc-tabnine
   ```
3. 等待卸载完成
4. 重启 Neovim,错误应该消失

#### 方法 2: 手动删除扩展目录

在 Termux 终端执行:

```bash
# 删除 coc-tabnine 扩展目录
rm -rf ~/.config/coc/extensions/node_modules/coc-tabnine

# 编辑 package.json 移除依赖
vim ~/.config/coc/extensions/package.json
# 找到并删除 "coc-tabnine": "..." 这一行

# 重启 Neovim
```

#### 方法 3: 完全重置 Coc 扩展(慎用)

```bash
# 备份配置
cp ~/.config/coc/extensions/package.json ~/.config/coc/extensions/package.json.bak

# 删除所有扩展
rm -rf ~/.config/coc/extensions/node_modules

# 重启 Neovim,Coc 会根据 g:coc_global_extensions 重新安装
```

### 验证修复

在 Neovim 中执行:

```vim
" 查看已安装的扩展列表
:CocList extensions

" Termux 环境应该只看到 14 个扩展,不包含 coc-tabnine
" 其他平台应该看到 15 个扩展,包含 coc-tabnine
```

### 技术说明

#### 为什么选择 `$TERMUX_VERSION`?

- ✅ **可靠性高**: Termux 官方环境变量,所有版本都会设置
- ✅ **性能优越**: 直接读取环境变量,无需执行外部命令
- ✅ **精确判断**: 专门针对 Termux,不会误判其他 Android 环境

#### 其他可选方案

如果需要更通用的 Android 检测,可使用:

```vim
let s:is_android = system('uname -o') =~ 'Android'
```

但这需要执行外部命令,性能开销较大,当前方案已足够精确且高效。

### 常见问题

**Q: 为什么不直接从配置中删除 TabNine?**

A: 因为其他平台(macOS/Linux/Windows)需要使用 TabNine。条件加载可以让同一份配置在不同平台上都能正常工作。

**Q: 卸载 TabNine 后会影响代码补全吗?**

A: 不会。Coc 还有其他 14 个扩展提供补全功能,包括:
- `coc-tsserver`: TypeScript/JavaScript 补全
- `coc-json`: JSON 补全
- `coc-css`: CSS 补全
- `coc-html`: HTML 补全
- `coc-emmet`: Emmet 补全
- 等等

**Q: 如何确认当前环境是否为 Termux?**

A: 在 Neovim 中执行:
```vim
:echo $TERMUX_VERSION
```
- Termux: 显示版本号(如 "0.118")
- 其他平台: 显示空字符串

---

**配置已完全支持跨平台使用,无需手动修改!**
