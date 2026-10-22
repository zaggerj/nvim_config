# Treesitter main 隔离迁移试验

2026-10-22，Windows、Neovim 0.12.6，候选 `nvim-treesitter` main 固定 `29212d826054bb2948fa9d3a99eca9bf6a050eb2`。执行 `python tests/treesitter_evaluation.py`，原始输出见 [treesitter-comparison.json](treesitter-comparison.json)。候选源码、CLI和parser都位于 `stdpath(data)/tools/evaluations`，不加入日常 runtimepath，不改变 lazy-lock。

采用官方 API `require('nvim-treesitter').setup({install_dir=...})`，`install(langs):wait(180000)`，`vim.treesitter.start()` 与新 `indentexpr()`。实际构建 javascript/typescript/tsx/vue/go/python/lua/http/html/css。Windows 官方 tree-sitter-cli 0.27.1 默认尝试 cl.exe；本机未安装MSVC，首次构建失败。为隔离进程设置 `CC=vim.fn.exepath('gcc')` 后构建成功，未更改全局环境。日常部署若迁移需固定CLI版本并使用平台工具发现，不能沿用旧版的编译器配置接口。

JS、TS、JSX、TSX、Vue2、Vue3、Go、Python、Lua、HTTP样例均真实解析且无ERROR节点，高亮器活动，执行缩进成功。新配置显式注册 javascriptreact→javascript、typescriptreact→tsx，否则 get_parser 返回nil。context、autotag的setup成功；JSX实际键入 `>` 得到 `<div></div>`；新HTTP parser配合原rest rocks向本地HTTP服务器发GET，返回200且正文断言通过。大行编辑增长会关闭新架构高亮并切为bigfile。记录的 ready_ms 包含当前进程首次query装载，不是与master公平对照的启动收益。

结论：本轮保持master架构。main具备迁移基础，但不是改分支即可升级：旧 `nvim-treesitter.configs` 不存在，`highlight/indent/ensure_installed/auto_install` 配置需要改写。官方README明确要求非懒加载、CLI≥0.26.1，并在插件升级时更新匹配parser。parser二进制必须按Windows/macOS和架构分别构建，不能复制另一平台产物。

main下嵌套注释实测见 [comment-main-comparison.json](comment-main-comparison.json)，Comment在JSX/TSX/Vue三区域正确，原生仍在React区域不等价。context实际行为未通过：Lua函数72行，游标60行、窗口topline60，context查询无内容且未生成浮窗；setup成功不能代替这个结果。当前票保留master的迁移阻塞就是context行为及完整读入/增长矩阵尚未对齐，macOS构建未实机验证。后续迁移必须补齐这些项目及同数据集性能对照，单独替换生命周期和构建链路，不与Coc/Go服务切换混在同一批。

重跑前需用官方源将候选与CLI放到上述隔离目录；脚本自己不下载可执行文件，也不修改日常插件。删除隔离评估目录即可回收运行产物，仓库证据仍保留。
