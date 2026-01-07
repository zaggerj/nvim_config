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
| `<Leader>lf` | 搜索文件名 | `find_files` |
| `<Leader>lg` | 全局搜索内容 | `live_grep` (ripgrep) |
| `<Leader>ls` | 搜索光标下的词 | `grep_string` |
| `<Leader>lb` | 搜索已打开的 Buffer | 快速切换文件 |
| `<Leader>lr` | 最近打开的文件 | `oldfiles` |

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

**配置亮点**: 你的 `live_grep` 已经配置了智能过滤：
- 排除 `*.bundle.js`, `*.min.css`
- 排除 `node_modules/`, `built/`, `lib/` 等目录
- 防抖 500ms，避免输入卡顿

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

## 九、完整前端开发工作流

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

## 十、高级技巧

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

## 十一、配置文件快速访问

| 快捷键 | 功能 |
|--------|------|
| `<Leader>fs` | 打开 `init.vim` |
| `<Leader>cc` | 打开 `coc-settings.json` |

---

## 十二、总结：核心工作流

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

## 十三、快捷键速查表

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

## 十四、建议优化

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
