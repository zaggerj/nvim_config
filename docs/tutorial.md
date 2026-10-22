# 当前配置的 Neovim 完整使用教程

更新：2026-10-22。适用配置：本仓库 `init.vim`、`mysettings/`、`lua/` 和当前 `lazy-lock.json`；Windows 原生 Neovim 0.12.6，启动入口包括 PowerShell、Git Bash 和 MSYS2 zsh。macOS 复用源码和操作方式，工具安装、终端组合键及原生依赖需在目标机器验证。

本文先教日常工作流，再解释每一层，最后列出当前自定义快捷键、插件默认操作与排障入口。这里的完整指当前配置声明的用户快捷键和已安装插件的主要工作方式；Neovim 全部内置命令、插件内部 `<Plug>` 接口与随语言服务器动态出现的动作，以安装版本的 `:help` 和运行时映射为准，不把其他发行版的快捷键当作本配置已有能力。

**先记住：文件用 buffer 管，屏幕布局用 window 管，任务布局用 tab 管。** 最方便的默认做法是一个项目开一个 Neovim 进程，在一个 tab 中保留少量分屏，用文件搜索和 buffer 搜索切文件；确实需要保留另一套布局时再开 tab。

## 目录

1. [先会用：十分钟上手](#1-先会用十分钟上手)
2. [按键记法、模式和帮助](#2-按键记法模式和帮助)
3. [buffer、window、tab 的关系](#3-bufferwindowtab-的关系)
4. [buffer：管理文件与修改](#4-buffer管理文件与修改)
5. [window：管理分屏和焦点](#5-window管理分屏和焦点)
6. [tab：管理任务布局](#6-tab管理任务布局)
7. [推荐的项目工作流](#7-推荐的项目工作流)
8. [搜索、文件树与大纲](#8-搜索文件树与大纲)
9. [移动、文本对象与编辑](#9-移动文本对象与编辑)
10. [补全、诊断与重构](#10-补全诊断与重构)
11. [Git、blame 和差异](#11-gitblame-和差异)
12. [终端、编译、运行与 Go](#12-终端编译运行与-go)
13. [HTTP、AI、折叠与笔记](#13-httpai折叠与笔记)
14. [高级工具：quickfix、寄存器、宏与会话](#14-高级工具quickfix寄存器宏与会话)
15. [不同项目使用不同主题](#15-不同项目使用不同主题)
16. [当前自定义快捷键完整清单](#16-当前自定义快捷键完整清单)
17. [插件窗口与默认快捷键清单](#17-插件窗口与默认快捷键清单)
18. [39 个 Git 插件及 14 个 Coc 扩展怎么用](#18-39-个-git-插件及-14-个-coc-扩展怎么用)
19. [安装、维护、重载与大文件](#19-安装维护重载与大文件)
20. [常见问题与练习路线](#20-常见问题与练习路线)

## 1. 先会用：十分钟上手

### 1.1 从项目根目录启动

在平时使用的终端进入项目根目录后执行：

```sh
nvim
```

空参数启动会出现首页。按 `f` 找文件，按 `g` 搜全文，按 `r` 看最近文件。直接指定文件则跳过首页：

```sh
nvim path/to/main.go
nvim src/App.vue
nvim src/App.tsx src/App.test.tsx
```

多个参数会建立参数列表和多个 buffer，默认不为每个文件建立 tab。路径含空格时用 shell 的引号包住。Git Bash 的 `/c/...` 是 shell 路径表示法，nvim 内显示 `C:/...` 或反斜杠也正常。

### 1.2 用最少的键完成一次修改

| 操作 | 按什么 | 结果 |
|---|---|---|
| 找文件 | `空格 ff`，输入文件名，回车 | 在当前窗口打开文件 |
| 进入输入 | `i` | 开始编辑 |
| 回普通模式 | `Esc` 或本配置的 `fj` | 可以移动和执行编辑命令 |
| 保存 | `:w` 回车 | 写入当前文件 |
| 打开另一个文件 | `空格 ff` | 当前窗口换文件，原文件留在 buffer 列表 |
| 找已打开文件 | `空格 fb` | 从 buffer 列表选择 |
| 回上个文件 | `Ctrl+^`，通常是 `Ctrl+Shift+6` | 切换当前窗口的 alternate buffer；也可 `:b#` |
| 同时看两个文件 | `:vsplit`，再 `空格 ff` | 新窗口中选择第二个文件 |
| 左右切窗口 | `Alt+h` / `Alt+l` | 不改变 buffer 本身 |
| 关闭当前分屏 | `:close` | 文件通常仍留在 buffer 列表 |
| 保存全部 | `:wa` | 保存全部已命名且可写的修改文件 |
| 退出 | `:qa` | 未保存修改会阻止退出；先看提示 |

前三天只练这一组即可。不需要先记住所有插件命令。

### 1.3 推荐的屏幕布局

```text
一个项目 / 一个 nvim 进程
├─ tab 1：日常开发
│  ├─ window 左：实现文件 buffer
│  ├─ window 右：测试 / 接口定义 buffer
│  └─ window 下：需要时才打开终端或 quickfix
└─ tab 2：临时保留的 Git diff / 调试排查布局

buffer 列表：实现、测试、类型、配置等文件，跨所有 tab 共用
```

文件树按需展开后可关闭，不必长期开着占屏。搜索打开文件通常比逐层找目录更快。当前lualine选项虽然写了`globalstatus=true`，配置回调随后又设置`laststatus=2`，运行实测为每个window状态栏；不要把当前画面理解成已经启用跨窗口统一状态栏。

## 2. 按键记法、模式和帮助

### 2.1 如何读本教程的按键

| 记法 | 含义 |
|---|---|
| `空格 ff` | 依次按空格、f、f；空格是本配置的 `<leader>` |
| `Ctrl+w h` | 先同时按 Ctrl+w，松开，再按 h |
| `Alt+h` / `<M-h>` | Alt 与 h；macOS 是 Option，终端需允许发送对应序列 |
| `Alt+Shift+h` | 移动整个窗口，和 `Alt+h` 切焦点不同 |
| `:命令` | 普通模式按冒号、输入命令、回车 |
| `3dd` | 删除3行；前面的数字称 count |
| `N` / `I` / `V` / `O` / `T` / `C` | 普通、插入、可视、操作符等待、终端输入、命令行模式 |

`noremap` 在源码里可能覆盖普通、可视、操作符等待等多种模式；本教程默认在普通模式操作窗口、文件和插件。插件窗口的局部映射优先于全局映射。同一按键在文件树、Telescope、Go 文件和普通 JS 文件中，含义可能不同。

### 2.2 最重要的模式

| 模式 | 进入 | 离开 | 用途 |
|---|---|---|---|
| 普通模式 | 启动后；`Esc` | `i`、`v`、`:` 等 | 移动、删除、复制、跳转 |
| 插入模式 | `i`、`a`、`o` | `Esc` / `fj` | 输入文字 |
| 字符可视 | `v` | `Esc` | 选择连续字符 |
| 行可视 | `V` | `Esc` | 选择完整行 |
| 块可视 | 普通模式 `Ctrl+v` | `Esc` | 选择矩形区域；注意插入模式的 Ctrl+v 被改为系统粘贴 |
| 命令行 | `:`、`/`、`?` | 回车执行，`Esc`取消 | 文件、搜索、Ex 命令 |
| 终端输入 | `:terminal` 或终端快捷键 | **`fj` 或 `Ctrl+\ Ctrl+n`** | 给 shell / 程序发送键盘输入 |

**当前终端输入模式的 `Esc` 会发送 `exit` 并回车。** 它不是单纯返回普通模式：`maps.vim` 后加载的终端映射覆盖了 `basic.vim` 的同键映射。在 shell 中会退出，在其他前台程序里会把这些字符交给程序。要保留终端任务，使用 `fj` 或原生 `Ctrl+\ Ctrl+n`。

### 2.3 忘记快捷键时怎么查

```vim
:help user-manual
:help windows
:help buffers
:help tabpage
:help index
:help <C-W>
:help :bdelete
:verbose nmap gd
:verbose imap <Tab>
:verbose tmap <Esc>
```

`verbose` 的最后几行会显示映射来自哪个文件。`空格 ?k` 可搜索当前映射，`空格 ?c` 搜索命令，`空格 ft` / `空格 ?h` 搜帮助。which-key 会在输入前缀稍等后显示提示；它显示的分组或描述不一定已经有可执行映射，例如目前 `空格 gd` 只有描述。

## 3. buffer、window、tab 的关系

### 3.1 buffer 是正在编辑的数据

打开一个文件时，Neovim 为它建立 buffer。buffer 保存文字、光标相关状态、未写入磁盘的修改。一个文件可以在多个窗口同时显示；这仍然是同一个 buffer，修改会同时出现在这些窗口。

buffer 不一定是磁盘文件：终端、帮助、文件树、插件结果也使用 buffer。`:ls` 主要列出 listed buffers，`:ls!` 还能看到未列出的特殊 buffer。关闭窗口不等于删除 buffer，删除 buffer 也不等于删除磁盘文件。

### 3.2 window 是看 buffer 的视口

窗口决定宽高、滚动位置、折叠视图以及当前显示哪个 buffer。`:vsplit` 默认让新窗口显示同一 buffer，随后再用 `空格 ff` 或 `:buffer` 换成另一个文件。同文件左右分屏适合对照远处两段代码。

### 3.3 tab 是一套窗口布局

tab page 包含一组窗口，不是某个文件本身。tab1 可以左右看实现和测试；tab2 可以上下看历史和当前版本。两者都能显示同一个 buffer；buffer 列表仍由同一进程共享。

| 层次 | 用来回答的问题 | 典型操作 |
|---|---|---|
| buffer | 我要编辑哪个文件？ | `空格 fb`、`:b 文件名` |
| window | 我要同时看哪些内容？ | `:vsplit`、`:split`、`Alt+h/l` |
| tab | 我要保留哪套任务布局？ | `:tabnew`、`gt`、`gT` |
| 独立 nvim 进程 | 我要隔离哪个项目的环境、cwd和主题？ | 另开终端，在另一个项目根目录执行 nvim |

### 3.4 四种容易混淆的关闭操作

| 命令 | 关闭什么 | 是否删除磁盘文件 |
|---|---|---|
| `:close` | 当前窗口；最后一个编辑窗口不能这样关 | 否 |
| `:tabclose` | 当前 tab 的所有窗口；最后一个 tab 不能这样关 | 否 |
| `:bdelete` | 当前 buffer 从常用列表卸下；显示它的窗口可能被关闭或换内容 | 否 |
| `:q` | 当前窗口；最后一个窗口时结束 nvim | 否 |

带 `!` 的变体会绕过相关保护，例如 `:bdelete!` 可丢弃该 buffer 未保存内容，`:qa!` 可丢弃多个 buffer 修改。先 `:ls` 看 `+` 标记和 `:wa`，再决定关闭。文件树的 `d` 才属于删除文件的操作，和 `:bd` 不同。

## 4. buffer：管理文件与修改

### 4.1 日常切换优先使用搜索

1. `空格 ff` 打开新文件。
2. `空格 fb` 在已打开文件中按文件名筛选。
3. 两个文件频繁往返时用 `Ctrl+^` 或 `:b#`。
4. 偶尔按顺序浏览时用 `Ctrl+Left` / `Ctrl+Right`。

不建议把持续按下一 buffer 当成主要导航方式；文件多时它要求记住列表顺序。当前配置没有 `H/L` 切buffer，也没有 `Shift+h/l` 切buffer，不要照搬其他发行版教程。

| 原生命令 | 含义 |
|---|---|
| `:ls` / `:buffers` | 列 buffer；`%`当前、`#`备用、`+`有修改 |
| `:b 7` | 切到编号7；编号取`:ls`，不要假设从1连续 |
| `:b service` | 按名字片段选择buffer；不唯一时继续输入或Tab补全 |
| `:bn` / `:bp` | 下/上一个listed buffer |
| `:bf` / `:bl` | 第一/最后一个listed buffer |
| `:b#` | 当前窗口的备用buffer |
| `:sbuffer 7` / `:vertical sbuffer 7` | 在新窗口显示已有buffer |
| `:bd` / `:bd 7` | 删除当前/指定buffer，不删除文件 |
| `:bwipeout 7` | 更彻底清理buffer及其状态，日常通常用不到 |
| `:edit` | 重新读取或编辑当前文件，未保存时会受保护 |
| `:checktime` | 检查磁盘是否被外部程序改动 |

当前运行时 `hidden` 为true：切到别的buffer通常不会丢失未保存修改。它不表示自动保存，关闭进程仍需处理修改。可通过 `:set hidden?` 核对，不要把源码中注释的 `set hidden` 当成当前关闭了hidden。

### 4.2 不破坏分屏地换文件

在要复用的窗口里按 `空格 fb` 选择另一个buffer，或 `:b 名字`。如果使用 `:bd` 删除当前buffer，Neovim可能调整显示它的窗口布局；当前没有配置专门保持布局的buffer删除插件。保留布局更重要时，先 `:b#` 切走，再 `:bd 编号` 清理旧buffer。

例子：左侧是测试，右侧是实现。右侧需要换成接口文件时，右侧 `空格 ff` 即可；无需关闭右侧分屏再重建。

### 4.3 参数列表不是buffer列表

```vim
:args
:args src/a.ts src/b.ts
:next
:previous
:argdo %s/OldName/NewName/ge | update
```

参数列表是明确的一组操作目标，和“进程里打开过哪些文件”不同。最后一条会修改列表内文件，应先用少量练习文件确认。批量修改前检查`:args`，不要用 `:bufdo` 对帮助、终端和所有遗留buffer盲目操作。

## 5. window：管理分屏和焦点

### 5.1 创建窗口

| 操作 | 原生命令/按键 | 使用场景 |
|---|---|---|
| 上下分屏当前buffer | `:split` 或 `Ctrl+w s` | 比较同文件两段代码 |
| 左右分屏当前buffer | `:vsplit` 或 `Ctrl+w v` | 并排看实现和测试 |
| 分屏打开另一文件 | `:split path` / `:vsplit path` | 已知道目标路径 |
| 上下新空buffer | `:new` | 临时笔记 |
| 左右新空buffer | `:vnew` | 临时对照 |
| 打开已有buffer | `:vertical sbuffer 编号` | 不重复读文件 |

当前设置了 `splitbelow`，上下分屏的新窗口倾向在下方；没有在配置中显式开启 `splitright`，左右分屏的位置以运行时选项和命令修饰符为准。要明确放右侧可用 `:rightbelow vsplit`。

### 5.2 移动焦点与移动窗口

| 动作 | 当前配置 | 原生替代 |
|---|---|---|
| 焦点到左/下/上/右 | `Alt+h/j/k/l` | `Ctrl+w h/j/k/l` |
| 把窗口移到最左/下/上/右 | `Alt+Shift+h/j/k/l` | `Ctrl+w H/J/K/L` |
| 下一个窗口 | 无自定义 | `Ctrl+w w` |
| 回上个窗口 | 无自定义 | `Ctrl+w p` |
| 当前窗口移为新tab | 无自定义 | `Ctrl+w T` |
| 交换窗口 | 无自定义 | `Ctrl+w x` |
| 旋转窗口 | 无自定义 | `Ctrl+w r` / `Ctrl+w R` |

Alt组合键可能被Windows Terminal、macOS终端或系统快捷键截获。若没有效果，先使用原生Ctrl+w组合，不需要为此安装窗口管理插件。

### 5.3 调整尺寸

| 按键/命令 | 作用 |
|---|---|
| `空格 b` | 当前窗口增高8行 |
| `空格 B` | 增高50行，受屏幕空间限制 |
| `空格 w` | 当前窗口增宽8列 |
| `空格 W` | 增宽56列 |
| `Ctrl+w +` / `Ctrl+w -` | 高度增/减1；可加数字，例如`5Ctrl+w +` |
| `Ctrl+w >` / `Ctrl+w <` | 宽度增/减1 |
| `Ctrl+w =` | 均分所有窗口 |
| `Ctrl+w _` / `Ctrl+w \|` | 尽量扩大高度/宽度；后者实际按竖线键 |
| `:resize 20` | 设高度20行 |
| `:vertical resize 100` | 设宽度100列 |
| `:call PercentSplit(0.4, 'sp')` | 当前配置提供的函数，按当前窗口高度比例上下分屏 |
| `:call PercentSplit(0.5, 'vsp')` | 按当前宽度比例左右分屏 |

终端窗口大小变化时，配置会自动执行 `wincmd =` 均分布局，因此之前手动调的尺寸可能被重置。`空格 b` 和 `空格 w` 本身已经是完整映射，虽然which-key也把它们显示为分组，不应随意往这两个前缀追加更多键。

### 5.4 关闭和临时聚焦

- `:close` 关当前分屏，保留文件buffer。
- `:only` 只保留当前窗口；它会改变布局，不会保留一键恢复快照。
- `Ctrl+w o` 等价于`:only`，不是“临时最大化再按一次恢复”。
- 需要长期保留两种布局时用tab；临时最大化可先 `:tab split`，看完`:tabclose`回去。
- 同文件两个窗口想同步滚动可分别 `:setlocal scrollbind`，结束后`:setlocal noscrollbind`。对照差异优先用diff模式。

## 6. tab：管理任务布局

### 6.1 何时开tab

适合：主开发布局之外，保留一组Git diff、一组接口/调用方/测试窗口，或临时阅读另一段代码。

不建议：每打开一个文件就新开tab。当前lualine在顶部显示buffer和tab，两者都可见，但buffer不会自动按tab隔离。

| 动作 | 当前/原生操作 |
|---|---|
| 新建空tab | `Ctrl+Shift+Up` 或 `:tabnew` |
| 当前buffer复制到新tab | `:tab split` |
| 在新tab打开文件 | `:tabedit path` |
| 下一个tab | `gt` 或`:tabnext` |
| 上一个tab | `gT` 或`:tabprevious` |
| 到第3个tab | `3gt` 或`:tabnext 3` |
| 列全部tab及窗口 | `:tabs` |
| 关闭当前tab | `Ctrl+Shift+Down` 或`:tabclose` |
| 只保留当前tab | `:tabonly`，会关闭其他布局，先处理修改 |
| 移动tab | `:tabmove 0`移到最前，`:tabmove`移到最后 |
| 文件树/Telescope在新tab打开 | 各自窗口中`Ctrl+t` |

Ctrl+Shift+方向键在某些终端无法区分；`:tabnew`、`:tabclose`、`gt/gT`更通用。

### 6.2 tab的目录和项目隔离

`:tcd 项目目录` 只为当前tab设置工作目录，`:lcd 目录`只为当前window设置工作目录，`:cd 目录`是全局目录。层次存在继承，不能把它们当成三个完全无关的值；`:pwd`查看当前窗口最终生效的目录。

当前 `空格 wd` 执行`:tcd`到文件所在目录，不是项目根目录。它会影响本tab里后续Telescope、终端等以cwd工作的操作。例如文件在`internal/service/`，按完后全文搜索就可能只搜这个子目录。项目搜索前先`:pwd`；需要回根目录时显式`:tcd 项目根目录`。

多个项目放进不同tab也仍共享全局buffer、部分插件状态、环境变量和colorscheme。希望主题和工具环境清楚隔离时，一项目一进程更直接。

## 7. 推荐的项目工作流

### 7.1 开发一个功能

1. 从项目根目录启动nvim。
2. `空格 ff`打开入口文件；用`空格 fg`搜索接口名或函数名。
3. 阅读结果后回车定位，`Ctrl+o`返回原位置。
4. 需要长期对照测试时`:vsplit`，在新窗口`空格 ff`打开测试。
5. 在两个窗口里各自用`空格 fb`换buffer，不再增加分屏。
6. 修改后`:w`。JS/TS/React等有保存时格式化、ESLint修复配置，保存后查看diff。
7. `空格 cs`开底部终端，运行项目真正使用的测试命令；`fj`退出终端输入模式，再`Alt+k`回代码。
8. `空格 gs`看Git状态，`:Gdiffsplit`检查diff，确认后再暂存/提交。
9. 完成后关闭终端/quickfix等临时窗口，用`:ls`清理不再需要的buffer。

主布局保持2个编辑窗口加1个按需工具窗口，比让文件树、outline、终端、搜索结果一直占屏更容易操作。

### 7.2 看调用链与排查Bug

1. 用`空格 fg`找报错文字、接口路径或符号。
2. 符号服务可用时用`gd`跳定义、`gr`查引用、`gh`看说明。
3. 关键位置用`ma`设置本文件标记，使用反引号加a精确返回；不要用被Sneak覆盖的单引号跳转。
4. `Ctrl+o`沿跳转历史退回，`Ctrl+i`向前。部分终端将Ctrl+i与Tab视为同一键，普通模式两者可能等价。
5. 结果很多时从Telescope送入quickfix，`:cnext/:cprevious`逐项看，避免不断重新搜索。
6. Git问题用`空格 gb`看当前行作者，必要时`:Git blame`或`:Git log -p -- %`看完整历史。

**Go例外：当前Go buffer的`gd`是vim-go的`:GoDef`，会覆盖全局Coc定义跳转。** 本配置关闭了vim-go的gopls，专用Coc Go服务也尚未补齐，不能保证该跳转可用。此时先使用文本搜索；已有相应Coc服务时可明确执行`:call CocActionAsync('jumpDefinition')`核对服务，而不是反复按一个被覆盖的键。

### 7.3 前后端联调

项目工作目录保持根目录，编辑tab里实现与请求文件并排，底部终端运行服务。`.http`文件中光标放到请求，按`go`发起请求；结果窗口用`H/L`换结果页。想保留Git对照布局时再建tab2。

前后端属于不同仓库且需要不同主题时，推荐分别开两个nvim进程。当前没有配置跨tab隔离语言服务和主题的项目管理插件。

## 8. 搜索、文件树与大纲

### 8.1 Telescope：先按目标选入口

| 我要找什么 | 快捷键 | 匹配范围 |
|---|---|---|
| 项目文件名 | `空格 ff` / `空格 lf` | 当前cwd，遵循配置中的rg排除 |
| 已打开文件 | `空格 fb` / `空格 lb` | 当前进程的listed buffers |
| 最近文件 | `空格 fr` / `空格 lr` | 历史记录，不限当前项目 |
| 全文 | `空格 fg` / `空格 lg` | cwd下live_grep |
| 光标词 | `空格 ls` | grep_string |
| 隐藏文件 | `空格 fh` | 显式带`--hidden`，仍受全局忽略模式影响 |
| 帮助 | `空格 ft` / `空格 lh` / `空格 ?h` | 帮助tags |
| 标记 | `空格 lm` | marks |
| 寄存器 | `空格 lt` | registers；旧注释称location list不准确 |
| 可调选项 | `空格 lv` | vim_options |
| Git状态/分支/stash | `空格 lj` / `空格 ll` / `空格 lk` | 当前Git仓库 |

当前`find_files`默认不带`--hidden`，而`live_grep`带`--hidden`及`--no-ignore-vcs`。后者会绕过`.gitignore`，但仍有配置的Lua忽略模式。两者范围不完全相同，不能把找不到文件一律归于插件故障。

全局忽略中还有`vendor/`、`lib/`、构建目录、日志、lock文件、图片和`.env`等。业务代码恰好位于`lib/`时也可能被隐藏。这里的Lua忽略是rg扫描后的结果过滤，不能阻止rg先遍历目录；而且`lib/`等模式要求斜杠，Windows结果若使用反斜杠可能不命中。因此当前目录排除尚未做到所有搜索入口和平台完全一致，参见 [配置综合评审](configuration-review-2026-10-22.md)。`空格 fh`不是完全取消忽略的“找所有文件”。要核实特定文件，直接`:edit 路径`；临时全范围搜索可在终端用自己明确限定目录的`rg`命令，不在编辑器里盲目扫描依赖和巨大日志。

### 8.2 搜索结果在哪里打开

在Telescope选择行后，回车复用当前目标窗口；`Ctrl+v`竖分屏、`Ctrl+x`横分屏、`Ctrl+t`新tab。这让“搜索文件”和“决定布局”可以一次完成。

输入模式`Esc`通常先退到picker普通模式，再按`Esc`关闭；`Ctrl+c`可直接关闭。`Tab`多选，`Shift+Tab`反向多选；`Ctrl+q`把全部当前结果送quickfix，`Alt+q`送所选结果。当前配置禁用了picker插入模式`Ctrl+u`的默认预览上滚，别拿其他教程的这个键当作必然有效。

### 8.3 文件树：看结构与做文件操作

`空格 e`或`空格 pd`使用`NvimTreeFindFileToggle`，可以定位当前文件再切换树。当前lazy只把这个命令注册为加载入口；第一次直接执行其他尚未注册的树命令可能出现`E492`，先用这两个入口加载。

在树里：`Enter/o`打开，`Ctrl+v`右/左分屏打开，`Ctrl+x`上下分屏，`Ctrl+t`新tab，`a`创建、`r`重命名、`d`删除、`x`剪切、`c`复制、`p`粘贴。删除前看确认内容。按`g?`查看本机安装版本的完整映射；[第17节](#17-插件窗口与默认快捷键清单)列出当前默认表。

树的根目录和`:pwd`有关，但它也有自己变更根目录的操作。当前`sync_root_with_cwd=true`、`update_focused_file.enable=true`；不要仅凭树顶端路径就推断当前window的cwd，仍以`:pwd`为准。

### 8.4 Vista：按符号读文件

`空格 v`切换Vista，`空格 pv`明确使用Coc提供者。Vista中`Enter`跳符号、`p`预览、`s`切排序、`q`关闭。`:Vista focus`在侧栏与源文件之间切换。

Vista需要对应语言服务提供符号；Go/Python/Vue专用服务缺失时，看到语法颜色也不保证大纲可用。当前没有配置独立fzf.vim前端，不把`:Vista finder`当成已验收功能；一般搜索用Telescope。

## 9. 移动、文本对象与编辑

### 9.1 原生移动与编辑组合

| 按键 | 作用 |
|---|---|
| `h/j/k/l` | 左/下/上/右 |
| `w/b/e` | 下个词开头/上个词开头/词尾 |
| `W/B/E` | 以空白划分的大词移动 |
| `0/^/$` | 行首/首个非空白/行尾 |
| `gg/G/42G` | 文件首/末/第42行 |
| `Ctrl+d/Ctrl+u` | 半屏下/上 |
| `Ctrl+f/Ctrl+b` | Coc已加载时：无可滚浮窗则整屏下/上，有浮窗时优先滚浮窗 |
| `zz/zt/zb` | 当前行放屏幕中/上/下 |
| `%` | 匹配括号；matchit可能提供额外结构匹配 |
| `f{字符}` / `t{字符}` | 本行找到字符/停在字符前 |
| `F/T` | 向后找；`;`/`,`重复最近字符或Sneak查找 |
| `ciw` | 改当前词，保留周边空白 |
| `di"` / `ci(` / `ya{` | 按引号、括号文本对象删除/修改/复制 |
| `dd/yy/p/P` | 删行/复制行/向后粘贴/向前粘贴 |
| `u` / `Ctrl+r` / `.` | 撤销/重做/重复上次修改 |
| `>>/<<` / `==` | 缩进/反缩进/按当前indent规则重新缩进 |
| `gv` | 恢复最近可视选择 |

`d/c/y`是动作，后面可以接移动或文本对象：例如`d3w`、`ciw`、`yap`。学会组合比背大量独立快捷键更省力。

### 9.2 本配置的搜索正则

普通模式`/`和`?`自动加上`\v`（very magic），因此括号、`+`、`|`等默认按正则操作符解释。例如按`/`后输入`(foo|bar)`即可搜两者。需要原样字符串时，在已经自动出现的`\v`后加`\V`切到very nomagic，再输入文字；或用`:let @/ = '\V' . escape('literal.text', '\')`等明确设置。

`n/N`重复搜索；`空格 n`取消当前高亮。原生`*`/`#`搜索光标单词，不经过`/`映射。配置`ignorecase`使普通搜索默认不区分大小写；需强制时在模式中加`\C`，强制忽略用`\c`。

替换由Ex命令控制，不经过普通模式`/`映射：

```vim
:%s/old/new/gc
:'<,'>s/old/new/gc
:%s/\<oldName\>/newName/gc
```

第一条全文件、第二条可视选中范围、第三条限制词边界；末尾`c`逐项确认。符号重命名优先F2和语言服务器，文本替换无法识别同名不同含义的符号。

### 9.3 Sneak：两字符跳转

本配置把Sneak的正向键改成单引号`'`，反向键改成Backspace：先按`'`，再输入目标两个字符；出现标签时按标签到目标。`;`继续、`,`反向重复。普通、可视和操作符等待模式都有该映射，可组合`d'xy`删除到目标，但先在练习文件确认范围。

单引号已不能直接使用原生`'a`“到标记a所在行”；使用反引号加a仍能精确跳到标记位置。Sneak默认`s/S`是否存在取决于插件检测到的自定义`<Plug>`映射，本文以当前显式`'`和Backspace为标准，不要求你再背`s/S`。

### 9.4 注释与surround

注释使用Comment.nvim：`gcc`切换当前行、`gc`接移动（如`gcap`注释一段）、可视选择后`gc`；`gbc`切换块注释，`gb`用于选择/移动；`gco/gcO/gcA`分别在下方/上方/行尾插入注释。Vue/JSX的注释字符由Treesitter context-commentstring协助判断，位置和parser会影响结果。

surround常用三组：

```text
ysiw"    给当前词加双引号
cs"'     把外围双引号改成单引号
ds"      删除外围双引号
```

`yss)`包住整行，`ysiw(`会添加带空白的括号形式，而`)`通常不加内侧空格。可视选中后`S`再输入包围字符，`gS`使用换行形式。插入模式默认`Ctrl+g s/S`由surround使用，而Copilot配置了独立`Ctrl+g`隐藏建议，二者存在前缀等待关系；感觉停顿时先用普通模式的`ys/cs/ds`路径，查看`:verbose imap <C-g>`和`:verbose imap <C-g>s`。

## 10. 补全、诊断与重构

### 10.1 三种不同能力

| 能力 | 提供者 | 当前边界 |
|---|---|---|
| 语法颜色、结构节点、部分缩进 | Treesitter | 已验证JS/TS/JSX/TSX/Vue2/Vue3/Go/Python高亮 |
| 确定性的补全、诊断、定义、引用、重命名 | Coc及扩展/语言服务器 | JS/TS等有扩展；Go/Python/Vue专用服务尚缺，Lua自定义命令也需修正 |
| AI行内建议 | Copilot | 插件和本地服务已配置，账号由本人授权；不代替语言服务器 |

有颜色不说明F2、gd和诊断已可用。有AI建议也不说明语义跳转或类型检查正确。

### 10.2 Coc插入模式

| 按键 | 当前行为 |
|---|---|
| `Tab` | 菜单可见则下一项；光标前为空白则插入Tab；否则请求刷新补全 |
| `Shift+Tab` | 菜单可见则上一项；否则发送Ctrl+h，即退格行为 |
| `Enter` | 菜单可见则确认；否则正常换行并调用Coc enter处理 |
| `Ctrl+v` | 本配置从系统`+`寄存器粘贴，替代原生插入模式quoted-insert |

当前`suggest.noselect=true`，菜单刚出现不一定预选第一项，先Tab选择再Enter会更明确。AI接受使用Ctrl+j，和Coc Tab分开。

### 10.3 导航与重构

- `gh`悬停，`gd`定义，`gr`引用，F2重命名，`空格 .`代码动作。
- `空格 cf`格式化整个文件，可视模式同键格式化选区。
- `空格 ci`组织import；`空格 cl`打开CocList，可继续输入`diagnostics`、`symbols`、`extensions`等可用来源。
- `Up/Down`在普通模式被改为上/下一个诊断，移动一行改用`k/j`。
- `af/if`在可视与操作符等待模式代表函数对象，例如`vif`选函数内部；Go中被vim-go局部文本对象覆盖。

相关命令：

```vim
:CocInfo
:CocList extensions
:CocList diagnostics
:CocList commands
:CocCommand eslint.executeAutofix
:CocCommand eslint.showOutputChannel
:CocRestart
```

扩展未激活时它的命令可能不在列表中。确认Coc识别了项目根和语言服务后，再判断快捷键是否工作。Go局部映射覆盖见[第16节](#16-当前自定义快捷键完整清单)。

### 10.4 保存时会发生什么

JS/JSX/TS/TSX/Lua列在Coc的formatOnSaveFiletypes中；ESLint有自动修复与save code action配置；TS有formatOnType。项目缺格式化provider时可能不执行，不能理解为所有语言保存都必然格式化。Go另有vim-go保存前格式化/保存后检查事件，会显式调用工具；启动不再探测下载不代表保存和构建不需要工具。

重要修改先看`:Git diff`，必要时`u`撤销当前buffer的自动格式化结果。不要通过停止所有语言服务来替代对某个provider的定位。

## 11. Git、blame 和差异

### 11.1 日常最顺手的一组

1. `空格 gs`打开Fugitive状态面板。
2. 看当前修改，Enter打开文件或diff；`g?`查状态面板局部帮助。
3. `s`暂存光标目标，`u`取消暂存；按`=`展开/收起内联diff。
4. `cc`进入提交；写好消息后按Git提示保存退出提交buffer。
5. 推送前确认分支、remote和差异，再明确执行`:Git push`或本配置`空格 gps`。

推送、拉取会访问远端，拉取还可能合并或变基当前工作区。熟悉配置时不要拿这些键做无意义练习。

### 11.2 Gitsigns与Fugitive分工

Gitsigns显示当前文件行级变化、hunk和行尾blame；Fugitive管理仓库状态、完整历史、提交和diff。二者互补。

| 操作 | 当前键/命令 |
|---|---|
| 下一/上一hunk | `]g` / `[g` |
| 看当前行完整blame | `空格 gb`，只在Gitsigns成功附加的Git buffer出现 |
| 切换行尾blame | `空格 tb`，同上 |
| 和index比较 | `[d`，实际`:Gitsigns diffthis` |
| 与`~`基准比较 | `[f`，实际`:Gitsigns diffthis ~`；不要简单称作只看staged文件 |
| 暂存整个buffer | `[c`，不是上一diff hunk |
| **重置整个buffer修改** | **`]c`，实际`:Gitsigns reset_buffer`，可能丢失未暂存改动** |
| 仅暂存当前hunk | `:Gitsigns stage_hunk` |
| 撤销最近一次hunk暂存 | `:Gitsigns undo_stage_hunk` |
| 预览当前hunk | `:Gitsigns preview_hunk` |
| 完整blame视图 | `:Git blame` |

**这里的`]c`覆盖了diff模式原生“下一个差异”键。** 在不熟悉配置前，不要习惯性用`]c/[c`导航diff；用`:normal! ]c`、`:normal! [c`明确执行原生动作，或使用当前Gitsigns的`]g/[g`。任何reset操作前先看diff和备份。

行尾blame配置延迟1000ms，是停留后显示的延迟，不是启动卡顿。非Git文件、未附加、大文件保护等情况下没有blame属于可解释状态。

### 11.3 原生diff与历史

```vim
:vsplit another-file
:diffthis
```

在另一个窗口也执行`:diffthis`；本配置`空格 dt`同义。结束用`:diffoff!`关闭所有窗口diff，`空格 do`只对当前窗口执行diffoff。`do/dp`是原生diff get/put动作，会修改内容；它们与“空格do”是不同按键序列。

同仓库文件可用`:Gdiffsplit`，提交可用`:Git log --oneline -- %`，变更内容可用`:Git log -p -- %`。本配置`空格 gla`用Gclog把历史送quickfix，大仓库历史可能很大，必要时改为明确限制数量的`:Git log -20 --oneline -- %`。

## 12. 终端、编译、运行与 Go

### 12.1 终端生命周期

| 当前键 | 行为 |
|---|---|
| `空格 ct` | 当前窗口替换为新终端 |
| `空格 cs` | 新建底部终端，约当前窗口高度40% |
| `空格 cd` | 当前窗口打开系统shell；Windows优先COMSPEC/cmd.exe |
| `空格 csd` | 分屏打开系统shell |
| 终端输入`fj` | 回终端普通模式，任务继续运行 |
| `Ctrl+\ Ctrl+n` | 原生回终端普通模式 |
| 终端输入`Esc` | 当前配置发送exit和回车，可能退出shell |
| 终端buffer中`Ctrl+e` | 当前配置调用jobstop终止该终端任务；不只是把窗口隐藏 |

终端用的是`NVIM_TERMINAL`、SHELL以及可发现的zsh/bash/PowerShell等候选，不保证和Neovim执行`:!`时的`shell`一致。Windows配置将`:!`的shell设为cmd.exe，而平台模块创建终端使用argv；不要从其中一个推断另一个。

推荐：任务运行时`fj`离开输入、`Alt+k`回代码；要再输入命令，切回终端window按`i`。若只是临时不用该终端，可换buffer或关闭显示它的窗口，终止任务时明确使用Ctrl+e或程序自己的退出方式。

### 12.2 当前文件编译/运行

`空格 fc`调用Compiler，`空格 rr`调用Runner。**fc不是格式化**，格式化是`空格 cf`。两者会保存文件，编译路径调用`:wall`还会保存其他已修改buffer；执行前留意未准备保存的内容。

| filetype | `空格 fc` | `空格 rr` |
|---|---|---|
| C | clang/gcc/cc编译成同目录可执行文件 | 运行同名可执行文件 |
| C++ | clang++/g++/c++ | 运行同名可执行文件 |
| Go | 在终端cwd执行`go build` | `go run 当前文件` |
| Java | `javac -encoding utf-8 当前文件` | java指定当前文件目录classpath与类名 |
| JavaScript | 未实现编译分支 | node运行当前文件 |
| TypeScript | 未实现编译分支 | node运行同名`.js`，不会自动编译当前TS |
| Rust | 未实现编译分支 | `cargo run` |
| Python | 未实现编译分支 | 发现可用Python3.9+后执行当前文件 |
| PowerShell | 未实现编译分支 | pwsh/powershell `-NoProfile -File` |
| HTML | 未实现编译分支 | 保存并用系统默认程序打开 |
| Vue、TSX、JSX等项目文件 | 没有通用框架构建器 | 使用项目package.json与终端命令，不假设node能直接运行 |

Go的`go run 当前文件`不会自动等同于`go run .`；多文件包、build tags和复杂项目通常应在项目终端执行真正的构建/测试命令。Java包结构、TS转译等也超出这个简单当前文件Runner的范围。

### 12.3 Go专用命令

vim-go按Go filetype加载，启动兼容模块已解除关闭gopls后残留的同步工作区探测，但明确构建、保存格式化仍遵循项目Go工具链，可能需要下载项目要求的Go版本。

常见命令以当前安装`:help vim-go`为准：

```vim
:GoBuild
:GoTest
:GoTestFunc
:GoTestFile
:GoRun
:GoFmt
:GoImports
:GoCoverage
:GoCoverageToggle
```

构建测试命令和gopls语义导航不是一项能力。当前gopls关闭，GoDef/GoDefType/GoDoc等依赖工具/语言服务的功能不能仅凭命令存在认定可用；查看`:CocInfo`、`:CocList extensions`和项目工具，再决定用哪个入口。此教程不自动安装工具或改变项目Go版本。

## 13. HTTP、AI、折叠与笔记

### 13.1 rest.nvim请求文件

新建`requests.http`，可以先对自己启动的本地测试服务练习：

```http
@base = http://127.0.0.1:8080

### health
GET {{base}}/health

### create
POST {{base}}/items
Content-Type: application/json

{"name":"demo"}
```

光标放在某个请求上，普通模式`go`或`:Rest run`发送。请求会真实访问目标服务并执行其业务语义，示例路径需本地服务支持，不要无意对生产写接口测试。

| 命令/按键 | 行为 |
|---|---|
| `.http`中的`go` | 当前请求；这个buffer局部映射覆盖原生go到字节位置 |
| `:Rest run name` | 执行命名请求，语法按插件版本 |
| `:Rest last` | 重发最近请求 |
| `:Rest open` | 打开结果窗口 |
| 结果窗口`H/L` | 前/后结果页 |
| `:Rest logs` | 插件日志 |
| `:Rest env show` | 当前请求文件关联的环境文件 |
| `:Rest env select` | 选择环境文件 |
| `:Rest env set .env.local` | 注册相对于当前cwd的环境文件 |
| `:Rest curl yank` | 实验功能，复制当前请求对应curl命令 |
| `:hor Rest open` / `:tab Rest logs` | 用命令修饰符选择结果/日志布局 |

本配置Windows已构建Lua rocks和HTTP parser，0.12使用rest_compat先显式parse。若换电脑只有Git源码没有平台构建产物，请按安装指南部署，不能仅复制旧DLL给macOS。认证值放本地受保护环境，不提交真实token到教程或仓库。

### 13.2 Copilot AI行内建议

本人完成账号授权：`:Copilot setup`，再`:Copilot status`。插件按首次InsertEnter或`:Copilot`命令加载，使用固定提交内嵌服务，不在启动时运行npx下载服务。Node.js要求22+，账号服务需要可用网络。

| 插入模式按键 | 当前配置 |
|---|---|
| `Ctrl+j` | 接受当前AI建议 |
| `Alt+]` | 下一个建议 |
| `Alt+[` | 上一个建议 |
| `Ctrl+g` | 隐藏建议；与surround的Ctrl+g前缀存在等待关系 |

Copilot默认Tab映射已关闭，默认其他映射也关闭，只保留这里显式设置的键。不要用官方默认Alt+Right或Ctrl+Right等键假设本配置支持逐词接受。Free方案当前每月2000次补全，额度与账号政策可能变化，以GitHub账号页为准。

允许的代码filetype包括JS/JSX/TS/TSX/Vue、Go、Python、Lua、C/C++、Java、Rust、sh/zsh、ps1；普通文本/Markdown默认不启用，大文件禁用。账号后的真实建议尚需本人验收，不能把本地服务初始化成功当作已经收到云端补全。

### 13.3 折叠、缩进线和上下文

UFO使用Treesitter/indent provider，普通文件默认全部展开（foldlevel99）。`zc`收当前折叠、`zo`展开、`za`切换、`zR`全部展开、`zM`全部折叠；后两键由UFO注册。折叠只影响视图，不删除内容。

IBL显示缩进线，Treesitter context显示顶部当前函数/作用域，autotag辅助HTML/Vue/JSX标签补齐，context-commentstring选择注释风格。这些功能没有在本仓库额外定义独立快捷键；没有看到相应UI时先看filetype、parser和大文件状态。

### 13.4 Neorg笔记

Neorg使用`.norg`，不是Markdown。当前配置的workspace名是`notes`，位置`~/Desktop/备忘录`；这仍是既有默认目录，未按每台机器的实际笔记位置验收。需要使用前核对目录，不把Obsidian vault自动视为该workspace。

```vim
:Neorg workspace notes
:Neorg index
:Neorg toc
:Neorg toggle-concealer
```

代码配置启用了core.defaults、concealer、calendar、dirman。Norg语法：`* 标题`、`** 子标题`、`- 列表`、`- ( ) 未完成任务`、`- (x) 已完成任务`，代码块用`@code 语言`到`@end`。

默认预设主要键见第17节。**LocalLeader没有独立设置，通常是反斜杠；但当前全局反斜杠已映射成冒号。** Neorg注册时会检查已有映射并跳过冲突键，不能把默认文档里的所有LocalLeader操作都视为本机已生效。先用命令入口，并在norg buffer里`:verbose nmap \nn`核对。Neorg parser、日历和笔记完整工作流仍未作为当前回归验收项。

## 14. 高级工具：quickfix、寄存器、宏与会话

### 14.1 quickfix和location list

quickfix是一组“文件+行列+消息”的目标，可以由搜索、编译、测试、Git历史产生；location list结构类似，但跟window绑定。不要混同于Telescope本身的搜索窗口。

| quickfix | location list | 行为 |
|---|---|---|
| `:copen` | `:lopen` | 打开列表 |
| `:cclose` | `:lclose` | 关闭列表窗口 |
| `:cnext/:cprevious` | `:lnext/:lprevious` | 下一/上一条 |
| `:cfirst/:clast` | `:lfirst/:llast` | 第一/最后条 |
| `:colder/:cnewer` | `:lolder/:lnewer` | 切换历史列表 |
| `:clist` | `:llist` | 在命令区显示列表 |

可用`:call Open_fix()`先开非空quickfix，否则开当前location list。这个函数存在，但原来的`空格 fo`映射已经注释，当前不能按fo自动打开。

搜索练习：`:grep! --fixed-strings TODO src`使用配置的`rg --vimgrep`，然后`:copen`；或Telescope选结果后Ctrl+q。`grep!`后手动打开列表，`!`在这里防止自动跳转，不表示忽略文件写保护。

批量修复：先检查quickfix内容，再考虑`:cdo s/old/new/ge | update`逐条处理，或`:cfdo %s/old/new/ge | update`逐文件处理。后者每个文件只处理一次，更适合全文件替换。它们都会修改磁盘文件，先在测试分支/练习目录验证目标与正则。

### 14.2 跳转历史与标记

| 按键/命令 | 用法 |
|---|---|
| `Ctrl+o` / `Ctrl+i` | jump list后退/前进 |
| `:jumps` | 看跳转记录 |
| `g;` / `g,` | 在当前buffer修改位置历史中后退/前进 |
| `:changes` | 看修改位置记录 |
| `ma` | 设置本文件标记a |
| `mA` | 设置大写跨文件标记A |
| 反引号加`a/A` | 精确回到标记；避免被Sneak覆盖的单引号 |
| `:marks` / `空格 lm` | 查看/搜索标记 |

跳定义之后返回通常用Ctrl+o，不要误用buffer next/prev；后者只换文件，不能准确恢复调用点位置。

### 14.3 寄存器和系统剪贴板

`"ayy`把当前行复制到a寄存器，`"ap`粘贴a；`"Ayy`追加到a。`"0p`取最近一次yank，能避开被普通删除覆盖的无名寄存器。`"_d`删除到黑洞寄存器，不覆盖要粘贴的内容。

系统剪贴板用`"+y`、`"+p`；本配置插入模式Ctrl+v等价于从`+`粘贴。是否可用取决于平台clipboard provider，可`:checkhealth vim.provider`或`:checkhealth`、`:echo has('clipboard')`及实际粘贴核对。当前没有简单地用`set clipboard=unnamedplus`把全部yank都改成系统复制。

`:registers`或`空格 lt`查看寄存器。插入/命令行模式原生`Ctrl+r a`可插入寄存器a，`Ctrl+r Ctrl+w`可把光标词送进命令行，用于构造搜索/替换。

### 14.4 宏和可重复编辑

1. `qa`开始录制到寄存器a。
2. 做一次稳定操作，例如`I// `、Esc、`j`。
3. 普通模式`q`停止。
4. `@a`重放一次，`10@a`重放10次，`@@`重复最近宏。

宏依赖当前模式、光标和匹配条件；把操作设计成从行首或明确文本对象开始更稳。重复单次修改先用`.`，不必任何小事都录宏。插件弹窗、网络和AI建议不适合作为可确定重放的宏步骤。

### 14.5 手动会话与恢复

当前没有专门的项目会话管理插件。原生支持：

```vim
:mksession! /你选择的目录/project-session.vim
:source /你选择的目录/project-session.vim
```

这会保存window/tab布局及部分编辑状态，具体内容受`:set sessionoptions?`控制；不等同于保存全部未写文本、终端进程、账号和语言服务器状态。先`:wa`，会话文件不一定适合加入项目Git。启动加载会话可`nvim -S 路径`，会话是可执行Vimscript，只加载自己确认来源的文件。

文件崩溃恢复另看`:help recovery`和`:swapname`。当前`nobackup`关闭常规backup，不等于关闭所有swap/undo机制，也不代表所有文件都有持久撤销历史；核对`:set backup? swapfile? undofile?`。

## 15. 不同项目使用不同主题

### 15.1 当前已经有的行为

`mysettings/ngconsole.vim`启动时检查当前cwd字符串：包含`_oem`使用onelight；否则包含`_bug`使用everforest；否则catppuccin-latte。规则是路径子串匹配，不是按Git root的严格项目注册表。两个条件同时命中时_oem优先。

当前DirChanged自动命令是注释状态，因此`:cd/:tcd/:lcd`之后不会自动重算。主题是全局colorscheme，同一进程所有tab/window都受影响；每个tab不可能仅凭`:tcd`拥有独立完整colorscheme。

### 15.2 现在怎么手动切换

```vim
:colorscheme catppuccin-latte
:colorscheme catppuccin-macchiato
:colorscheme onelight
:colorscheme everforest
:colorscheme tokyonight
:call TrySwitchTheme()
```

具体主题名要看已安装插件提供的colors文件；旧forest-night仓库当前主题名是everforest。TrySwitchTheme按当前cwd再执行已有规则。lualine会响应ColorScheme改变，不需要为手动换主题完整重启。

最通用的项目识别方案是不同项目使用独立nvim进程，并从项目根启动。后续若增加明确的项目→主题配置、根目录识别和TabEnter/DirChanged处理，应在正式评审中实施和验收，不把本节的建议当作已安装功能。

## 16. 当前自定义快捷键完整清单

以下以当前源码中未注释的映射为准。N=普通，I=插入，V=可视，O=操作符等待，T=终端输入，C=命令行。标为“N等”表示源代码使用无模式`noremap`，还会影响可视/选择/操作符等待等模式；日常在N使用。插件按需加载前，部分映射暂不存在；buffer局部映射可覆盖全局。

### 16.1 模式、搜索、日期与命令行

| 模式 | 键 | 实际行为 |
|---|---|---|
| I | `fj` | 返回普通模式 |
| I | `Ctrl+v` | 从系统`+`寄存器粘贴 |
| N等 | `\` | 输入冒号进入命令行；影响默认LocalLeader前缀 |
| N | `/` / `?` | 自动加very magic前缀的向前/向后搜索 |
| N | `空格 n` | `noh`清高亮 |
| C | `Alt+b` / `Alt+f` | 发送Ctrl+Left/Right，按词移动命令行光标 |
| I | `_tm` | 插入当前`YYYY-MM-DD`，这是输入映射不是命令 |
| N/V/O | `'` / Backspace | Sneak正向/反向两字符跳转 |

### 16.2 window、buffer、tab、目录

| 模式 | 键 | 实际行为 |
|---|---|---|
| N等 | `Alt+h/j/k/l` | 焦点到左/下/上/右window |
| N等 | `Alt+Shift+h/j/k/l` | 将window移到最左/下/上/右 |
| N等 | `Ctrl+Left` / `Ctrl+Right` | `bp` / `bn`切buffer |
| N等 | `Ctrl+Shift+Up` | `tabnew` |
| N等 | `Ctrl+Shift+Down` | `tabclose` |
| N等 | `空格 Left` | `bdelete`当前buffer |
| N | `空格 b/B` | window增高8/50行 |
| N | `空格 w/W` | window增宽8/56列 |
| N | `空格 wd` | tab cwd改到当前文件目录 |
| N等 | `空格 dt/do` | 当前window启用/关闭diff |
| N | `空格 fs` | 高度约80%的横分屏打开配置init.vim，并将该window lcd到其目录 |
| N | `gx` | 系统默认程序打开光标URL/路径 |

### 16.3 搜索与帮助的两套兼容入口

| 模式 | 键 | 命令/功能 |
|---|---|---|
| N | `空格 ff` | Telescope find_files |
| N | `空格 fg` | Telescope live_grep |
| N | `空格 fb` | Telescope buffers |
| N | `空格 fh` | FindFilesWithHidden |
| N | `空格 fr` | Telescope oldfiles |
| N | `空格 ft` | Telescope help_tags |
| N等 | `空格 lf` | Telescope find_files |
| N等 | `空格 lg` | Telescope live_grep |
| N等 | `空格 ls` | Telescope grep_string |
| N等 | `空格 lb` | Telescope buffers |
| N等 | `空格 lr` | Telescope oldfiles |
| N等 | `空格 lv` | Telescope vim_options |
| N等 | `空格 lt` | Telescope registers |
| N等 | `空格 lm` | Telescope marks |
| N等 | `空格 lh` | Telescope help_tags |
| N等 | `空格 lj` | Telescope git_status |
| N等 | `空格 lk` | Telescope git_stash |
| N等 | `空格 ll` | Telescope git_branches |
| N | `空格 ?t` | Tutor zh |
| N | `空格 ?e` | Tutor |
| N | `空格 ?h` | Telescope help_tags |
| N | `空格 ?k` | Telescope keymaps |
| N | `空格 ?c` | Telescope commands |
| N | `空格 空格` | Legendary命令面板 |

`f*`与`l*`有部分重复，推荐主用f系列，光标词搜索和标记/寄存器等补用l系列。不要把旧`fr/ft/fh`记成运行/终端/目录切换。

### 16.4 文件树、大纲、折叠和插件管理

| 模式 | 键 | 实际行为 |
|---|---|---|
| N | `空格 e` / `空格 pd` | NvimTreeFindFileToggle |
| N | `空格 v` | Vista!!切换大纲 |
| N | `空格 pv` | Vista coc |
| N | `zR` / `zM` | UFO打开/关闭全部折叠，普通文件加载后注册 |
| N | `空格 pi` | Lazy install |
| N | `空格 pu` | **Lazy update，会更新插件与锁文件** |
| N | `空格 pc` | **Lazy clean，清理不在规格中的插件** |

`空格 h/t/d/g/c/...`等which-key组名并不都是可直接执行的动作。尤其`空格 gd`目前只有“Git Diff”描述，没有实际rhs；请用`[d`、`:Gdiffsplit`等已存在入口。

### 16.5 Coc

| 模式 | 键 | 实际行为 |
|---|---|---|
| N | `空格 cr` | CocRestart，仅Coc |
| N | `gh` | Coc doHover |
| N等 | `空格 ci` | Coc organizeImport |
| N等 | `空格 cl` | CocList |
| N | `空格 cc` | CocConfig |
| N | `空格 .` | Coc code action |
| N | `gd` | Coc definition；Go局部覆盖 |
| N | `gr` | Coc references；覆盖原生gr行为并可能影响原生LSP gr系列前缀 |
| V/O | `af` / `if` | Coc函数对象；Go局部覆盖 |
| N | `空格 cf` | Coc format |
| V | `空格 cf` | Coc format-selected |
| V | `空格 cv` | Coc convert-snippet；需要可用扩展/provider |
| N | F2 | Coc rename |
| N | Up / Down | Coc上/下一个诊断 |
| N | `Ctrl+f` / `Ctrl+b` | 先调用Coc判断浮窗，可滚动则滚浮窗，否则原生翻整屏；这条表达式要求Coc函数可用 |
| I | Enter | 菜单可见确认，否则换行+Coc enter |
| I | Tab | 菜单下一项/空白插入Tab/刷新补全 |
| I | Shift+Tab | 菜单上一项，否则退格 |

### 16.6 Git与diff

| 模式 | 键 | 实际行为 |
|---|---|---|
| N | `空格 gs` | G状态 |
| N | `空格 gps` | **Git push，访问远端并发布提交** |
| N | `空格 gpl` | **Git pull，会修改工作区或历史关系** |
| N | `空格 gla` | Gclog，历史入quickfix |
| N | `空格 gll` | Git log -L当前行到当前行，带no-merges/oneline |
| N | `空格 gls` | 映射组装Git log -p -S光标词当前文件；复杂路径/词先核命令 |
| N | `]g` / `[g` | Gitsigns next_hunk / prev_hunk |
| N | `[d` | Gitsigns diffthis |
| N | `[f` | Gitsigns diffthis ~ |
| N | `[c` | Gitsigns stage_buffer，整文件暂存 |
| N | **`]c`** | **Gitsigns reset_buffer，整文件重置** |
| Git buffer N | `空格 gb` | Gitsigns blame_line full |
| Git buffer N | `空格 tb` | 切换行尾blame |

### 16.7 终端、执行与HTTP

| 模式 | 键 | 实际行为 |
|---|---|---|
| N | `空格 ct/cs` | 当前window/横分屏打开首选终端 |
| N | `空格 cd/csd` | 当前window/横分屏打开系统shell |
| T | `fj` | 进入终端普通模式 |
| T | **Esc** | **发送exit与回车**，后加载映射已覆盖早期退出输入模式映射 |
| 终端buffer N/T | **Ctrl+e** | **jobstop当前任务** |
| N等 | `空格 fc` | Compiler，当前类型编译；会wall保存 |
| N等 | `空格 rr` | Runner，当前类型运行；会write保存 |
| HTTP buffer N | `go` | Rest run |

### 16.8 AI显式映射

首次InsertEnter或Copilot命令加载后：I模式Ctrl+j接受，Alt+]下一建议，Alt+[上一建议，Ctrl+g隐藏。默认Tab与其他默认AI映射均关闭。

### 16.9 Go文件的局部覆盖与新增键

以下来自锁定vim-go的ftplugin，普通JS文件没有这些覆盖。运行probe已确认gd/gD/K/Ctrl+]和函数文本对象。

| 模式 | 键 | Go buffer行为 |
|---|---|---|
| N | `gd` / `gD` | GoDef / GoDefType |
| N | `K` | GoDoc |
| N | `Ctrl+]` | GoDef，替代原生tag跳转 |
| N | `Ctrl+LeftMouse` / `g LeftMouse` | 鼠标定位后GoDef，需终端鼠标支持 |
| N | `Ctrl+w Ctrl+]` / `Ctrl+w ]` | 用split形式Go定义跳转 |
| V/O | `af/if` | vim-go函数对象，替代Coc |
| V/O | `ac/ic` | vim-go注释对象 |
| N/V/O | `]]` / `[[` | 下/上一个Go函数 |

源码还按Vim兼容条件选择是否注册Ctrl+t返回Go定义栈；当前Neovim不要把它一律当成GoDefStackPop，原生Ctrl+t用于tag stack。使用`:verbose nmap <C-t>`核对本机。

### 16.10 首页按钮

仅在alpha首页buffer内：`f`文件、`g`全文、`r`最近文件、`c`当前配置、`t`中文Tutor、`l`Lazy、`q`退出。直接打开文件不加载首页，后续可`:Alpha`打开。

## 17. 插件窗口与默认快捷键清单

本节的键只在相应插件/窗口/模式中有效。插件更新可能改变默认值，优先用窗口内帮助与安装版本docs。映射不是全局统一菜单，文件树中的`]c`是下个Git节点，普通代码中的`]c`却是重置buffer。

### 17.1 NvimTree当前58项默认映射

当前没有自定义on_attach覆盖，以下核对自安装版本`lua/nvim-tree/keymap.lua`，树窗口中`g?`也可看。

| 键 | 行为 | 键 | 行为 |
|---|---|---|---|
| Enter / `o` | 打开文件/目录 | `O` | 不经window picker打开 |
| `Ctrl+e` | 用文件替换树所在window | Tab | 预览 |
| `Ctrl+v` | 竖分屏打开 | `Ctrl+x` | 横分屏打开 |
| `Ctrl+t` | 新tab打开 | `Ctrl+k` | 信息浮窗 |
| `Ctrl+]` | 根目录切到节点 | `-` | 根目录上一级 |
| Backspace | 关闭父目录 | `P` | 移到父目录 |
| `>` / `<` | 下/上同级节点 | `J` / `K` | 最后/第一个同级 |
| `a` | 新建文件/目录 | `d` | 删除 |
| `D` | 移入回收站，依赖平台工具 | `r` | 重命名 |
| `e` | 只改basename | `u` | 完整路径重命名 |
| `Ctrl+r` | 重命名时省略文件名 | `x` | 剪切 |
| `c` / `p` | 复制节点/粘贴 | `y` | 复制文件名 |
| `Y` | 复制相对路径 | `gy` | 复制绝对路径 |
| `ge` | 复制basename | `R` | 刷新 |
| `E` / `W` | 展开全部/收起全部 | `L` | 切换空目录分组 |
| `f` / `F` | 开启/清除实时过滤 | `S` | 在树中搜索节点 |
| `H` | 切换隐藏文件过滤 | `I` | 切换gitignore过滤 |
| `U` | 切换自定义过滤 | `C` | 切换Git clean过滤 |
| `B` | 切换无buffer节点过滤 | `M` | 切换无书签节点过滤 |
| `m` | 切换节点书签 | `bd` | 批量删除书签节点 |
| `bt` | 批量回收书签节点 | `bmv` | 批量移动书签节点 |
| `[c` / `]c` | 上/下Git变化节点 | `[e` / `]e` | 上/下诊断节点 |
| `.` | 对节点运行命令 | `s` | 系统程序打开 |
| `q` / `g?` | 关闭树/帮助 | 双击左键/右键 | 打开/切根到节点 |

表中组合如`Enter/o`代表两个独立映射，因此表格行数少于58。平台回收站工具未配置时D/bt可能报缺工具，不把它当成跨平台删除能力已经验收。

### 17.2 Telescope默认picker操作

| 模式 | 键 | 行为 |
|---|---|---|
| I/N | Enter | 打开当前选择 |
| I/N | Ctrl+x / Ctrl+v / Ctrl+t | 横分屏/竖分屏/tab打开 |
| I | Ctrl+n / Ctrl+p；Down/Up | 下一/上一项 |
| N | j/k；Down/Up | 下一/上一项 |
| N | H/M/L，gg/G | 首/中/末位置和首/尾结果 |
| I/N | Tab / Shift+Tab | 切换选中并移动 |
| I/N | Ctrl+q | 当前全部结果送quickfix并打开 |
| I/N | Alt+q | 所选结果送quickfix并打开 |
| I/N | Ctrl+d | 预览向下；Ctrl+u仅N保留默认预览向上 |
| I/N | PageUp/PageDown | 结果列表翻页 |
| I | Ctrl+c | 关闭 |
| N | Esc | 关闭；I中Esc先回N |
| I | Ctrl+/ 或Ctrl+_ | 查看picker键位 |
| I | Ctrl+l | complete_tag |
| I | Ctrl+w | picker提供的删词命令 |
| I | Ctrl+j | 默认nop；不要在picker中把它当作AI接受 |

更多动作和各picker特殊键见`:help telescope.mappings`、`:help telescope.actions`，尤其Git picker可能有checkout等会改变仓库状态的动作，先看帮助。

### 17.3 Comment.nvim、surround与Vista

| 插件 | 默认键 | 作用 |
|---|---|---|
| Comment | gcc/gbc | 当前行line/block注释切换 |
| Comment | gc{motion}/gb{motion}；V选区gc/gb | 对移动范围/选区注释 |
| Comment | gcO/gco/gcA | 上一行/下一行/行尾插入注释 |
| surround | ys{motion}{char}/yss{char} | 添加包围/包整行 |
| surround | yS{motion}{char}/ySS{char} | 换行形式添加包围 |
| surround | ds{char}/cs{old}{new}/cS{old}{new} | 删除/修改/换行修改包围 |
| surround V | S{char}/gS{char} | 给选区加包围/换行包围 |
| surround I | Ctrl+g s / Ctrl+g S | 插入包围/换行包围；受Ctrl+g前缀关系影响 |
| Vista | Enter/双击左键 | 跳符号 |
| Vista | p/s/q | 预览/切排序/关闭 |

### 17.4 Fugitive状态与blame窗口

状态面板`:G`中，`g?`是安装版本完整帮助入口。常用：`s/u/-`暂存/取消暂存/切换目标暂存状态，`=`展开diff，Enter打开目标，`cc`提交。`X`丢弃目标变更，属于危险操作，不要当作关闭面板。

`:Git blame`窗口：`g?`帮助，`A/C/D`调作者/commit/日期列宽，Enter到引入该行的patch，`o/O/p`在split/tab/preview打开patch或blob，`-`在对应提交重新blame，`gq`关闭blame并返回工作树版本。不是所有Git缓冲区都使用同一组键，始终看当前buffer类型。

### 17.5 Neorg默认预设与冲突

以下是锁定版本预设，**不是本机全部已验证生效的快捷键**。模块会跳过冲突，LocalLeader也与本配置反斜杠映射冲突。实际以norg buffer内`:verbose map`和插件帮助为准。

| 模式 | 默认键 | 作用 |
|---|---|---|
| N | LocalLeader nn | 新笔记 |
| N | gO | 目录 |
| N | LocalLeader tu/tp/td/th | undone/pending/done/on-hold |
| N | LocalLeader tc/tr/ti/ta | cancelled/recurring/important/ambiguous |
| N | Ctrl+Space | 循环任务状态，终端可能发送NUL别名 |
| N | Enter / Alt+Enter / Alt+t | 跟随链接/竖分屏/新tab或已有tab |
| N | `>.` / `<,` | 非递归提升/降低结构层级 |
| N | `>>` / `<<` | 递归提升/降低层级 |
| N | LocalLeader lt/li | 切换/反转列表类型 |
| N | LocalLeader id/cm | 插入日期/放大代码块 |
| I | Ctrl+t/Ctrl+d | 提升/降低层级 |
| I | Alt+Enter/Alt+d | 新列表项/插入日期 |
| V | `>` / `<` | 提升/降低所选对象 |

默认预设与具体模块是否载入有关，代码块放大等不能只凭预设存在就认为已配置完整。当前配置未设LocalLeader为空格，不能将`LocalLeader nn`误写成`空格 nn`。

## 18. 39 个 Git 插件及 14 个 Coc 扩展怎么用

### 18.1 用户直接使用的插件与主题

| 插件 | 在这套配置中的入口 | 深入资料/边界 |
|---|---|---|
| lazy.nvim | :Lazy、pi/pu/pc | 安装、锁定、profile、按插件恢复；`:help lazy.nvim` |
| alpha-nvim | 空启动、:Alpha | 首页文件/搜索/最近/配置/教程/Lazy按钮 |
| lualine.nvim | 每window状态栏与顶部buffer/tab | laststatus运行值2；globalstatus选项与后续覆盖有冲突，注意tabline同时显示两种对象 |
| telescope.nvim | f/l搜索系列 | picker多选、分屏、quickfix；`:help telescope` |
| telescope-fzf-native.nvim | Telescope内部排序 | 原生扩展依赖make/C编译；不是独立fzf终端UI |
| nvim-tree.lua | e/pd | 文件树、文件操作、书签、根与过滤；`:help nvim-tree` |
| nvim-web-devicons | 树、首页等图标 | 字体缺字时检查Nerd Font，不需要单独快捷键 |
| coc.nvim | 补全、gd/gr、gh、F2、cf等 | 配合14个扩展；`:help coc-nvim` |
| vista.vim | v/pv | Coc符号大纲；`:help vista` |
| copilot.vim | :Copilot、I Ctrl+j | 账号、云端建议、代码类型白名单；`:help copilot` |
| vim-go | GoBuild/Test等及Go局部键 | gopls关闭、跳转映射仍在；`:help vim-go` |
| vim-fugitive | gs、:Git、:Gdiffsplit | Git状态/历史/diff；`:help fugitive` |
| gitsigns.nvim | ]g/[g、gb/tb | 行级Git信息；`:help gitsigns` |
| nvim-treesitter | 自动高亮/缩进 | 当前旧master configs API；`:help nvim-treesitter` |
| nvim-treesitter-context | 当前函数/作用域顶部提示 | 依赖parser，不是单独outline |
| indent-blankline.nvim | IBL缩进线 | 大文件不附加；`:help ibl` |
| nvim-ts-autotag | 编辑HTML/Vue/JSX标签 | 自动补齐/改名，依赖filetype/parser |
| nvim-ts-context-commentstring | Vue/JSX注释字符选择 | Comment pre_hook使用；没有额外自定义键 |
| Comment.nvim | gcc/gc/gbc等 | 嵌套语言注释；`:help comment.nvim` |
| nvim-surround | ys/ds/cs/S | 包围编辑；`:help nvim-surround` |
| vim-sneak | '/Backspace两字符跳转 | 标签和重复查找；`:help sneak` |
| nvim-ufo | zR/zM、zc/zo/za | Treesitter/indent折叠；`:help ufo.txt` |
| which-key.nvim | 输入前缀稍等 | 帮助发现键位，不等于每个描述都注册动作；`:help which-key` |
| legendary.nvim | 空格空格、:Legendary | 命令/键位面板与频率记录；当前上游已归档，替换待实施 |
| rest.nvim | HTTP go、:Rest | env、请求、结果、日志；`:help rest-nvim` |
| neorg | .norg、:Neorg | norg笔记；默认workspace需核实，完整工作流待验 |
| vim-tutor-mode | :Tutor zh、?t | 交互教程；已归档，不能把“旧插件”直接等同于不能练习 |
| catppuccin | 默认catppuccin-latte | 可手动切其他flavour |
| onedarkpro.nvim | _oem目录onelight | 当前目录主题策略的一个分支 |
| forest-night | _bug目录everforest | 仓库别名与实际colorscheme名字不同 |
| tokyonight.nvim | :colorscheme tokyonight | 已安装可用的可选主题，默认启动不选它 |

### 18.2 依赖型插件：没有必要为它们找快捷键

| 插件 | 作用 |
|---|---|
| plenary.nvim | 共享Lua工具，Telescope等使用 |
| sqlite.lua | legendary频率记录依赖；模块能加载不等于数据库业务读写已验 |
| promise-async | UFO异步依赖 |
| hererocks | 构建隔离Lua/LuaRocks工具链，Windows HTTP部署会使用 |
| lua-utils.nvim | Neorg依赖 |
| nui.nvim | UI构件依赖 |
| nvim-nio | 异步依赖 |
| pathlib.nvim | Neorg路径依赖 |

31个用户可感知插件/主题加8个依赖，共39项。不要因为某依赖没有快捷键，就以为它没有用途；也不要在不检查使用者的情况下独立删除。

### 18.3 Coc版本清单中的14个扩展

| 扩展 | 用途 | 怎么接触它 |
|---|---|---|
| coc-tsserver | JS/TS/React语言服务 | 补全、诊断、F2、gd/gr等；需要项目配置 |
| coc-json | JSON语言服务 | JSON补全、schema和诊断 |
| coc-css | CSS/SCSS/Less服务 | 样式补全和诊断 |
| coc-eslint | ESLint集成 | 保存修复、eslint.executeAutofix与输出日志 |
| coc-pairs | 成对符号 | 输入括号引号等；和autotag/语言服务重叠时实测 |
| coc-omni | 通过omnifunc补全 | 配置只为org启用该source；不等于安装org大插件 |
| coc-marketplace | 扩展市场支持 | CocList与扩展管理入口，按激活来源看命令 |
| coc-lists | 更多CocList来源 | :CocList查看当前可用来源 |
| coc-html | HTML服务 | HTML/配置中的部分模板filetype |
| coc-emmet | Emmet缩写补全 | 通过Coc补全/命令，不把VSCode的Tab习惯直接套进来 |
| coc-dictionary | 词典补全source | 补全源及本地词典配置决定结果 |
| coc-cssmodules | CSS Modules补全 | 对应项目的import/class场景 |
| coc-lua | Lua支持 | 自定义lua-lsp命令当前不可执行，Lua整套服务仍需核实 |
| coc-unocss | UnoCSS补全 | 使用UnoCSS的项目中激活与提示 |

准确版本见仓库`coc-extensions.json`，安装状态看`:CocList extensions`。Coc设置里有volar、vetur、rust、snippets和PowerShell等键，不代表相应扩展已装；当前也没有coc-go/coc-pyright/Vue专用扩展。Tabnine旧状态保留但禁用，不作为现在的AI方案。

## 19. 安装、维护、重载与大文件

### 19.1 新机器部署

按 [WINDOWS-SETUP.md](../WINDOWS-SETUP.md)完整部署，尤其编译器、Node22+、Python3.9+、rg、Git、make、Rust/Cargo及平台rocks/parser。源码和平台产物分开，正式运行不依赖诊断时的临时目录。

首先核对：

```vim
:echo $MYVIMRC
:echo g:nvim_config_root
:echo stdpath('config')
:echo stdpath('data')
:echo g:coc_data_home
:echo exepath('node')
:echo exepath('python')
:echo exepath('rg')
```

Windows默认LOCALAPPDATA入口通过联接指向当前源码；Coc配置和数据已固定，避免Git Bash/zsh各读一份扩展状态。换shell后如果工具不可发现，检查该入口的PATH，不要再装另一份配置来掩盖差异。

### 19.2 插件更新不是编辑启动的一部分

| 命令 | 做什么 | 适合什么时候 |
|---|---|---|
| `:Lazy` | 看状态、日志、profile | 日常检查 |
| `:Lazy install` | 安装缺失插件 | 明确部署 |
| `:Lazy restore` | 恢复锁文件版本 | 重建或回退锁定插件 |
| `:Lazy update 插件名` | 定点更新 | 审查兼容性后按批次做 |
| `:Lazy update` | 全量更新并改锁文件 | 不能当无风险日常操作 |
| `:Lazy clean` | 清理规格外插件 | 确认不再需要后 |
| `:Lazy sync` | 安装+清理+更新组合 | 先理解影响，不用于随手排障 |
| `:CocProvision` | 按仓库清单明确安装Coc扩展 | 部署或修复缺扩展 |

当前Treesitter锁在旧master API；更新Neovim宿主不意味着可以直接切新main。rest依赖、平台构建和关联插件需要配套验收。更新建议见 [插件评审](plugin-review-2026-10-22.md)，不要因为有23项SHA不同就直接判定全部应该升级。

### 19.3 什么修改需要重启

| 变化 | 生效方式 |
|---|---|
| coc-settings.json | :CocRestart或空格cr，只重启Coc |
| colorscheme手动切换 | 当场生效，lualine响应主题事件 |
| Lua模块、plugins.lua、bootstrap、PATH/HOME/XDG | 完整退出nvim再开 |
| parser、rocks、宿主工具升级 | 明确安装/构建后完整重启 |
| Copilot账号 | 本人:Copilot setup后检查status和真实建议 |
| source $MYVIMRC | 只重读入口，不会完整重置require缓存、lazy和自动命令 |

当前没有通用热重载器，不能把source一次当成所有配置已经更新。

### 19.4 大文件保护的准确范围

读取时满足任意条件进入bigfile：总字节数 **>1MiB**、行数 **>20000**、单行 **>20000字节**。不是“大于等于”。检查字节数不是字符数，中文或emoji多字节会更早达到阈值。

进入后关闭Coc、Copilot、Treesitter高亮、IBL、Git附加、折叠等昂贵功能，并关闭wrap、spell、部分行号/光标装饰。`:LargeFileInfo`显示是否启用以及原因；普通文件切回时恢复相应窗口选项。

**当前已发现的边界：**编辑过程中总字节数和行数增长有检查，单行长度增长只在读入时检查。普通文件后来粘贴成很长一行、但总大小和行数仍低于阈值时，可能不进入保护，属于待修事项。不要把“所有增长路径都已覆盖”当成事实。已经标记为bigfile的buffer也不会因删小就自动恢复整套语言服务；保存后重新打开该文件/重启并检查更稳妥。

### 19.5 性能和启动排查

```sh
nvim --startuptime nvim-startup.log path/to/file.go
```

正常退出后看日志中的first screen update，并结合`:Lazy profile`看插件开销。不要只测空buffer替代真实文件，也不要把Coc RPC就绪等同于项目语言服务器全部准备好。

本机最近同环境三组交替对照：首屏中位数约437→350ms，高亮与状态栏约619→512ms；旧1.39秒是历史单次记录，不能拿缓存差异当作同等优化收益。完整证据见 [启动性能记录](issues/2026-10-22-startup-performance.md)。

## 20. 常见问题与练习路线

### 20.1 快速定位问题

| 现象 | 先检查 | 推荐下一步 |
|---|---|---|
| 空格键前缀不对 | :echo mapleader | 本配置是空格，确认读到同一init |
| gd在JS与Go行为不同 | :verbose nmap gd | Go局部vim-go覆盖全局Coc，服务缺口见审查 |
| 有高亮没补全/大纲 | :set filetype?、CocInfo、CocList extensions | 分别查parser与语言服务 |
| 插入Tab只缩进或出现菜单 | 光标前空白、菜单可见性 | 按当前Coc条件分支理解，不是AI接受键 |
| Ctrl+j没有AI | :Copilot status、账号、Node、filetype | 先在允许的普通代码buffer中本人授权验收 |
| 搜不到.env或lib源码 | :pwd、Telescope ignore策略 | 显式edit；fh仍受全局忽略影响 |
| blame没有 | 是否Git文件、Gitsigns附加、LargeFileInfo | 普通Git文件停留1秒；用gb或Git blame核对 |
| 大文件无高亮/补全 | :LargeFileInfo | 保护设计；不要强开全部插件来“修复” |
| Go文件黑屏/要Ctrl+c | 新进程、startuptime、具体buffer目录 | 当前go_compat已解除残留LSP事件；保存/构建下载与首屏区分 |
| 终端Esc把shell退了 | :verbose tmap <Esc> | 当前映射就是exit，保留任务请用fj |
| Ctrl+e后任务没了 | 当前是否终端buffer | 它是jobstop，不是普通隐藏窗口 |
| ]c后改动没了 | :verbose nmap ]c、Git diff | 当前映射为reset_buffer；不要把它当diff导航 |
| nvim树命令E492 | lazy是否已加载树 | 先空格e/pd或NvimTreeFindFileToggle |
| 换tab主题都变了 | 全局colorscheme机制 | 独立进程隔离项目，当前没有tab局部主题 |
| cd后没有自动换主题 | DirChanged被注释 | 手动主题或TrySwitchTheme，待正式项目主题方案 |
| Lua保存服务报错 | lua-lsp是否executable | 自定义服务命令目前存在缺口，别只装插件不查命令 |
| norg键位没注册 | LocalLeader及mapcheck冲突 | 使用Neorg命令，查当前buffer映射 |

### 20.2 三阶段练习

**第一阶段：文件和布局。** 用两个练习文件完成`ff`打开、`fb`切换、`:vsplit`对照、Alt+h/l切焦点、`:close`关窗口、`:bd`清buffer；解释每一步关的是什么。再建一个tab并用gt/gT切，确认两个tab看得到同一buffer列表。

**第二阶段：可重复编辑。** 练`ciw`、`ci"`、`ysiw"`、`cs"'`、`gcc`、`.`、`u/Ctrl+r`；录一个宏批量改5行；从Telescope送quickfix再逐项检查。只在练习文件操作reset和批量替换。

**第三阶段：项目工作。** 在真实项目按“实现+测试+按需终端”布局完成一个小功能：检查cwd、搜索调用、用现有服务跳转、运行测试、查看Git diff和blame，最后保存并清理布局。命令存在而provider缺失的地方记到问题台账，不反复改键位掩盖依赖问题。

### 20.3 文档维护入口

运行事实由源码和当前buffer映射共同决定。更新插件或映射后，至少重核第16节自定义清单、第17节默认映射、语言服务边界和大文件保护，别只修改介绍段落。

- [整体设计](design.md)：模块、启动、平台与责任边界。
- [全部问题台账](issues/README.md)：当前问题、已验证结果和剩余事项。
- [持续决策](decisions.md)：用户决定和追加的取舍。
- [配置综合评审](configuration-review-2026-10-22.md)：本轮性能、升级、替换与项目主题结论。
- [插件评审](plugin-review-2026-10-22.md)：39项版本、替换与升级建议。
- [安装与部署](../WINDOWS-SETUP.md)：新机器/迁移/平台构建。
- [AI方案](ai-completion.md)：账号、服务和免费额度边界。

本次教程核对了当前配置源码、安装版本官方帮助及运行映射probe：普通JS与Go的gd/gr/F2、Go局部覆盖、terminal Esc、which-key描述与实际rhs区别、NvimTree默认58项。没有把Neorg完整笔记工作流、账号后真实AI建议、缺失语言服务器和macOS实机当作已验收功能。
