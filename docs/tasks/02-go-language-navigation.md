# 02：恢复Go语言导航并保留构建测试

**What to build（交付行为）：** 在真实Go module中通过同一语言服务完成定义、引用、重命名和文档查看，并继续明确执行Go构建、测试与格式化。

**Blocked by（阻塞依赖）：** [01 查清并修复Go回归超时与进程遗留](01-go-process-lifecycle.md)。

**Status：** done（Windows真实跨包服务、保存格式化、构建/测试成功与失败路径通过；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R01、R05 / ID02；验收 AC02、AC03。

## 验收标准

- [x] 补齐Coc负责的Go服务与gopls依赖，记录工具发现、版本及显式安装方式。
- [x] gd、gD、Ctrl+]、K及函数文本对象的职责明确，局部键不再进入被关闭的gopls路径；gr和重命名与之保持一致。
- [x] 真实module覆盖跨包定义、引用、重命名、悬浮和保存格式化，明确哪些动作由服务或vim-go负责。
- [x] GoBuild、测试和失败诊断可用，服务不重复启动；大文件不启动该服务。
- [x] 复跑01所恢复的Go启动及退出回归；同步Go教程、部署说明和故障台账。

## 范围与交付记录

近期沿用Coc，不迁移原生LSP或替换vim-go。

依赖说明：01提供本任务必须复用的可靠启动/退出回归。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 实施与证据

初始 Go 导航没有 Coc 服务，vim-go 的局部映射仍可能进入被关闭的 gopls；保存时还缺少默认 imports_autosave 所调用的 goimports。现由 coc-go 1.3.35 + gopls 0.23.0 统一导航与诊断，vim-go 只保留构建、测试、保存格式化与导入整理。关闭其 def/doc/textobj 局部映射，gd、gD、Ctrl+]、K、gr、F2、if/af 统一遵循公共 Coc 映射。

`python tests/language_services_smoke.py --language go` 已真实通过跨包定义、引用、重命名、hover、成员补全和格式编辑；保存输出与 gofmt 一致；GoBuild、GoTest成功；注入类型错误后Coc诊断和GoBuild错误列表有效，修复后构建成功；最后外部 go build/test 通过。`tests/go_startup_smoke.py` 复验不调用关闭的 vim-go LSP且正常退出。gopls/goimports显式部署到stdpath(data)，不隐式升Go工具链。详细版本、路径、恢复和工具缺失诊断见[语言服务](../language-services.md)，教程由[统一教程](../tutorial.md)收纳。Windows最终矩阵由主验收记录关联，未把macOS当作已验证。

[返回任务索引](README.md)
