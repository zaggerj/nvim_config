# 原生注释与 Comment.nvim 对照

2026-10-22，Windows、Neovim 0.12.6。执行 `python tests/comment_evaluation.py`；完整插件 revision 和实际输出见 [comment-comparison.json](comment-comparison.json)。隔离 `--clean` 进程使用同一组已安装 parser/query，分别加载 Comment 和原生默认映射。先完整解析注入语言，再执行真实 `gcc`、`gcj` 和 `Vjgc`，验证第一次确实修改、第二次恢复原文。

| 场景 | Comment + 上下文 | 原生 gc |
| --- | --- | --- |
| Lua | `--`，通过 | `--`，通过 |
| JSX / TSX 元素内部 | `{/* ... */}`，通过 | `// <span>...`，不是有效 JSX 注释 |
| Vue 模板 | HTML 注释，通过 | HTML 注释，通过 |
| Vue script | `//`，通过 | `//`，通过 |
| Vue style | `/* ... */`，通过 | `/* ... */`，通过 |
| Lua 操作符、可视选择 | 通过 | 通过 |

结论：保留 Comment.nvim 与 nvim-ts-context-commentstring。当前原生版本配合相同 query 不能保持 React 嵌套上下文行为，不能直接替换。此结论不以插件数量判断速度；本次未做注释耗时对比。

原生有 `gc`、`gcc` 和操作符组合；Comment 还提供块注释 `gb`、`gbc`、追加注释 `gcA`、上下插入 `gcO/gco`。这些键有现有用户语义，未来迁移必须逐项选择保留映射或明确变更。隔离评估不改变日常映射。跨嵌套语言的单个选区不能由单一 commentstring 表达，本次只验证单语言选区，未宣称跨区域混合注释正确。macOS 未实机验证。

测试建设中发现两个测量陷阱并已修正：只调用 Comment setup 而未 source `plugin/Comment.lua` 时 `<Plug>` 不存在，会出现无修改的假通过；仅 `parse()` 未完整解析 Vue 注入会误判 script/style。现在显式 source、`parse(true)` 并断言第一次结果，避免把测试装配错误报告为插件缺陷。
