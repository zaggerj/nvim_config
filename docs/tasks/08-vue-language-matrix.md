# 08：建立Vue与React语言能力兼容矩阵

**What to build（交付行为）：** JS/TS/React以及Vue2.6、2.7、3项目按兼容版本获得语言导航、补全和诊断。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Vue2.6/2.7/3及JS/TS/JSX/TSX真实动作通过；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R05 / ID02；验收 AC03。

## 验收标准

- [x] 核实服务、TypeScript和各Vue代际的官方支持范围，记录实际选用的Coc扩展准确名称与固定版本。
- [x] Vue2.6、2.7、3分别用最小真实项目验证模板与脚本之间的补全、定义及诊断；不把最新Volar默认适用于所有代际。
- [x] JS、TS、JSX和TSX分别验证现有tsserver能力，确认Vue服务不重复抢占。
- [x] 服务选择由项目依赖决定，工具缺失可诊断；高亮和语言服务分别验收。
- [x] 大文件保护继续生效；更新兼容矩阵、部署、前端教程与台账。

## 范围与交付记录

不升级用户业务项目的Vue/TypeScript依赖来绕过兼容性。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 实施与证据

部署准确包名 @yaegassy/coc-volar 0.37.4，固定内部language-core/server/TS-plugin2.2.8，配合coc-tsserver2.4.1；禁用并移除额外coc-vetur服务，避免双服务。核实固定源码的Vue版本推断及2.6/2.7包装分支，没有假定最新版自动兼容全部Vue。保留Volar hybrid职责，不把直接向vue客户端请求TS表达式返回空误判为补全失效。

真实固定fixture为Vue2.6.14、2.7.16、3.5.13+项目TS5.7.3：均实际验证模板绑定定义、经tsserver的模板表达式补全、Coc引用/实际重命名及未知模板绑定诊断；JS/TS/JSX/TSX四组也完成跨文件定义、补全、引用、实际重命名和诊断。命令:python tests/language_services_smoke.py --language <vue26|vue27|vue3|javascript|typescript|javascriptreact|typescriptreact>，首次加--prepare显式安装fixture依赖。最终11语言矩阵由主agent顺序复验全部通过。业务项目依赖未改。

共享bigfile保护在服务之前生效，高亮由独立Treesitter矩阵验证。官方支持依据、项目target配置、部署和恢复见[语言服务](../language-services.md)，实际操作关联[教程](../tutorial.md)。新版本扩展须重新跑矩阵；macOS仍待真实宿主验收。

[返回任务索引](README.md)
