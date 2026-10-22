# Neovim 插件审查：2026-10-22

后续综合评审见 [性能、插件替换/升级与项目主题](configuration-review-2026-10-22.md)，完整操作见 [教程](tutorial.md)。本页保留39项官方版本和维护状态的逐项证据；Go定义跳转已由后续源码链和运行映射确认为缺陷，详见综合评审R01。

当前宿主已升级到 **0.12.6**。核心组合可以继续使用；优先处理已归档插件和语言服务缺口，再分批更新。此次实施仅包括宿主升级、rest 的必要兼容修复和回归测试，**没有批量升级、删除或替换插件**。

## 证据与解释

核对 lazy 实际规格、39个已安装 Git 插件、锁文件及官方仓库信息。全部 installed SHA 与锁文件一致；2个仓库已归档，23个锁定分支的 head 与锁文件不同。SHA 不同只表示存在差异，尚未逐个核对祖先关系，不直接等同于落后或应更新。未归档也不等于持续维护活跃。

完整提交、仓库规范名称、更新时间与 API 来源保存在 [Git 插件证据](plugin-audit-2026-10-22.json)；[Coc 版本证据](coc-audit-2026-10-22.json)；[替代方案官方 README 证据](plugin-alternatives-2026-10-22.json)。后者保留初次分支 URL 404 和更正后的取证，不能把错误 URL 当成项目消失。

## 39项逐项结论

分支 head 为审查日快照；“相同”不检查其他分支。当前 SHA 取前8位，完整值见证据 JSON。下表均为审查建议，尚未实施更新或替换。

| 插件 / 官方来源 | 锁定分支 / 当前提交 | 与分支 head | 已归档 | 判断与后续动作 |
|---|---|---|---|---|
| [Comment.nvim](https://github.com/numToStr/Comment.nvim) | `master` / `e30b7f20` | 相同 | 否 | 保留；原生 gc 可评估替代，但必须保留 Vue/JSX 嵌套注释行为。 |
| [alpha-nvim](https://github.com/goolord/alpha-nvim) | `main` / `3979b01c` | 不同 | 否 | 保留；首页按 VimEnter 加载，低优先更新。 |
| [catppuccin](https://github.com/catppuccin/nvim) | `main` / `beaf41a3` | 不同 | 否 | 保留主主题；低优先定点更新。 |
| [coc.nvim](https://github.com/neoclide/coc.nvim) | `release` / `889f5e28` | 不同 | 否 | 保留；release 分支定点评估，更新时验扩展、诊断、跳转与重启。 |
| [copilot.vim](https://github.com/github/copilot.vim) | `release` / `a12fd567` | 相同 | 否 | 保留；已按用户选择安装，当前锁定分支无差异；账号由用户完成。 |
| [forest-night](https://github.com/sainnhe/everforest) | `master` / `b90025cc` | 不同 | 否 | 保留；特殊项目目录仍使用，不按主题数量直接删。 |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | `main` / `42d6aed4` | 不同 | 否 | 保留，适合单独评估更新；新上游要求 >=0.11，宿主已满足。 |
| [hererocks](https://github.com/luarocks/hererocks) | `master` / `5d77b0ba` | 相同 | 否 | 保留固定构建工具链，不随意更新。 |
| [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim) | `master` / `005b5600` | 不同 | 否 | 保留；与 Treesitter 相关变更一起验证缩进和大文件保护。 |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | `main` / `85c7ff37` | 不同 | 否 | 保留；先比较提交祖先关系再选择版本，SHA 不同不能直接认定落后。 |
| [legendary.nvim](https://github.com/mrjones2014/legendary.nvim) | `master` / `6de819bc` | 相同 | 是 | 已归档，优先替换候选；用现有 Telescope commands/keymaps 与 which-key 组合，先迁移自定义命令和频率记录行为。 |
| [lua-utils.nvim](https://github.com/nvim-neorg/lua-utils.nvim) | `main` / `e5657494` | 相同 | 否 | Neorg 依赖；随依赖闭包审查，不独立删除。 |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | `master` / `47f91c41` | 不同 | 否 | 保留；定点更新并验证状态栏。 |
| [neorg](https://github.com/nvim-neorg/neorg) | `main` / `a402a63e` | 不同 | 否 | 保留待核实使用情况；与 Obsidian 有重叠，9.0 有破坏性变更。评估启动依赖加载，不能未经确认删笔记工作流。 |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim) | `main` / `10fc3618` | 相同 | 否 | 依赖；随使用者更新和验收。 |
| [nvim-nio](https://github.com/nvim-neotest/nvim-nio) | `master` / `edcc181a` | 相同 | 否 | 依赖；随使用者更新和验收。 |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | `main` / `1098d7b3` | 不同 | 否 | 保留；README 的0.12要求针对 vim.pack 安装示例，不能误当整个插件最低要求。 |
| [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua) | `master` / `a0db8bf7` | 不同 | 否 | 保留；旧组织 URL 可规范到官方 nvim-tree。当前 NvimTreeFindFileToggle 入口实测成功。 |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | `master` / `42fc28ba` | 不同 | 否 | 保留当前 master 锁定；main 是不兼容重写，不能把旧 configs.setup 原样搬过去。迁移单独验 parser/query/缩进与相关插件。 |
| [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) | `master` / `64dd4cf3` | 不同 | 否 | 保留；与 Treesitter 迁移同批验证。 |
| [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | `main` / `c4ca798a` | 不同 | 否 | 保留；当前 standalone setup 已正确。实际检查与 coc-pairs / Vue 服务的标签补齐边界后再决定。 |
| [nvim-ts-context-commentstring](https://github.com/JoosepAlviste/nvim-ts-context-commentstring) | `main` / `1b212c2e` | 不同 | 否 | 保留；支持 Vue/JSX 注释，原生 gc 迁移也需要对应集成。 |
| [nvim-ufo](https://github.com/kevinhwang91/nvim-ufo) | `main` / `72d54c31` | 不同 | 否 | 保留；更新需验证折叠、大文件与切回行为。 |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | `master` / `80335345` | 不同 | 否 | 保留；旧组织 URL 可规范到官方 nvim-tree。 |
| [onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) | `main` / `6b12e00b` | 不同 | 否 | 保留；特殊项目 _oem 分支使用 onelight。 |
| [pathlib.nvim](https://github.com/pysan3/pathlib.nvim) | `main` / `a0d3dbbe` | 相同 | 否 | Neorg 依赖；随依赖闭包审查。 |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | `master` / `b9fd5226` | 不同 | 否 | 共享依赖；先检查使用者再更新。 |
| [promise-async](https://github.com/kevinhwang91/promise-async) | `main` / `119e8961` | 相同 | 否 | 折叠依赖；随 UFO 验收。 |
| [rest.nvim](https://github.com/rest-nvim/rest.nvim) | `main` / `714d5512` | 相同 | 否 | 保留；用户明确要求 Windows 可用，本轮修复0.12兼容。不为依赖复杂擅自替换。 |
| [sqlite.lua](https://github.com/kkharji/sqlite.lua) | `master` / `50092d60` | 相同 | 否 | 暂保留 legendary 频率记录依赖；迁移该行为后再评估移除。未将 DLL 加载计为已验。 |
| [telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim) | `main` / `6fea601b` | 不同 | 否 | 保留；更新后需要真实原生构建和 extension 加载验收，不能靠 pcall 隐藏失败。 |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | `0.1.x` / `a0bbec21` | 相同 | 否 | 保留，评估离开0.1.x；该分支无差异不表示默认分支无更新。当前上游要求 >=0.11.7，宿主已满足。另需统一搜索排除策略。 |
| [tokyonight.nvim](https://github.com/folke/tokyonight.nvim) | `main` / `5da1b76e` | 不同 | 否 | 当前启动未使用；可选精简候选，性能收益有限。 |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | `master` / `61b51c09` | 不同 | 否 | 保留；Git 操作与 Gitsigns 行级信息互补。 |
| [vim-go](https://github.com/fatih/vim-go) | `master` / `dc07b908` | 不同 | 否 | 暂保留 GoBuild/Test 等工作流与 go_compat；梳理其 gd 等 buffer 映射是否覆盖 Coc，专用语言服务需补齐后验收。 |
| [vim-sneak](https://github.com/justinmk/vim-sneak) | `master` / `feea86ad` | 相同 | 否 | 保留；稳定使用无需因提交时间较早就替换。 |
| [vim-tutor-mode](https://github.com/fmoralesc/vim-tutor-mode) | `master` / `8c53ae4b` | 相同 | 是 | 已归档，优先移除候选；先确认自定义进度行为，再用原生 Tutor 替代。 |
| [vista.vim](https://github.com/liuchengxu/vista.vim) | `master` / `1e90efad` | 相同 | 否 | 保留 Coc 大纲；不能直接换只支持原生 LSP 的方案。 |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | `main` / `3aab2147` | 相同 | 否 | 保留；已使用 v3 API，与命令面板有部分重叠但不等价。 |

## Coc 扩展与语言服务缺口

14个版本清单项目均与 npm latest 相同，无须为追新运行全量 CocUpdate。

| 扩展 | 固定版本 | npm latest |
|---|---|---|
| coc-tsserver | 2.4.1 | 2.4.1 |
| coc-json | 1.9.17 | 1.9.17 |
| coc-css | 2.2.4 | 2.2.4 |
| coc-eslint | 3.1.4 | 3.1.4 |
| coc-pairs | 1.5.6 | 1.5.6 |
| coc-omni | 1.2.4 | 1.2.4 |
| coc-marketplace | 1.9.0 | 1.9.0 |
| coc-lists | 1.5.9 | 1.5.9 |
| coc-html | 1.9.2 | 1.9.2 |
| coc-emmet | 1.1.6 | 1.1.6 |
| coc-dictionary | 1.2.3 | 1.2.3 |
| coc-cssmodules | 1.1.1 | 1.1.1 |
| coc-lua | 2.0.6 | 2.0.6 |
| coc-unocss | 0.2.0 | 0.2.0 |

当前无 `coc-go`、`coc-pyright` 或 Vue 专用服务。配置中虽有相关残留设置，并不代表对应服务存在。自定义 Lua server 指向 `lua-lsp`，本机 executable 检查为0；安装了 coc-lua 也不能据此认定该自定义命令可用。`volar/vetur/snippets/rust/powershell` 等残留配置应逐项核实用途。

建议继续沿用 Coc 补齐服务，避免一次重写全部键位、诊断、扩展和 Vista 大纲：

- Go：[josa42/coc-go](https://github.com/josa42/coc-go)，npm 1.3.35；明确部署 gopls 并配置路径，控制自动工具链更新。与 vim-go 构建/格式化职责及 gd 映射一起验收。
- Python：[fannheyward/coc-pyright](https://github.com/fannheyward/coc-pyright)，npm 1.1.414；验收解释器、虚拟环境、诊断和跳转。
- Vue：[yaegassy/coc-volar](https://github.com/yaegassy/coc-volar)，正确安装名为 `@yaegassy/coc-volar`，npm 0.37.4。官方说明 script 区域仍需 coc-tsserver，并与旧 typescript-vue-plugin 不兼容。Vue2.6/2.7 与最新 Volar 的支持边界尚未核验，不能声称同时覆盖所有 Vue2/Vue3 项目。`coc-vetur` 的实际官方源本轮未确认，暂不据此推荐。
- JS/TS/React 已有 coc-tsserver；仍需在实际项目验证 tsconfig、诊断和跳转，不能用8类高亮测试替代。

以上服务本轮未安装，属于后续实施建议。淘汰的 coc-tabnine 不在14项清单中，保留旧状态但禁用，官方服务未恢复；AI 使用用户已选择的 Copilot Free。

## 分批维护与验收顺序

1. 先补齐实际项目的 Go/Python/Vue 服务并修正 Lua 命令、映射冲突，明确部署下载与编辑启动的边界。
2. 迁移已归档 legendary、vim-tutor-mode；保留自定义命令、快捷键发现、教程进度等仍有价值的行为，再清理独占依赖。
3. 定点更新 Gitsigns、文件树、状态栏、主题及共享依赖，逐批审查锁文件，验证 blame/搜索/文件操作/启动。Neorg 先核实实际工作流与启动依赖闭包。
4. Treesitter 新 main 架构单独迁移，与 context、autotag、commentstring、缩进、HTTP parser 和大文件保护一起验收；宿主升级并不意味着可直接切分支。Telescope 离开0.1.x也需真实搜索验证。

每批以明确插件名更新，失败恢复对应锁定提交和平台构建产物；不把 Lazy sync 当成无风险的一键维护。平台产物重新构建，macOS 需实机验证。账号授权和真实 AI 建议继续由用户完成。

相关记录：[问题总台账](issues/README.md)、[宿主升级](issues/2026-10-22-neovim-012-upgrade.md)、[整体设计](design.md)、[持续决策](decisions.md)。

## 同日后续实施补充：UI顺序与主题入口

用户随后授权继续优化Go启动。未改变插件版本，将lualine推迟到最终主题确定后的VimEnter，避免重复setup；alpha文件启动不载入，空启动和:Alpha保留。特殊目录实测发现本表forest-night的“仍使用”只代表配置意图，旧调用实际已失效；锁定插件只提供everforest，现已修正并回归。完整证据见 [性能记录](issues/2026-10-22-startup-performance.md)。前文关于批量更新/替换未实施的边界继续有效。
