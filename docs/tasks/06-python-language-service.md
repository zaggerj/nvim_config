# 06：补齐Python解释器与语言服务

**What to build（交付行为）：** Python项目使用正确解释器完成补全、定义和诊断，并在缺依赖时显示可操作提示。

**Blocked by（阻塞依赖）：** 无（可开始）。

**Status：** done（Python真实功能与未激活项目.venv通过；macOS归21待验）

**归属：** A；[治理SPEC](../spec.md) R05 / ID02；验收 AC03。

## 验收标准

- [x] 选择维护中的Coc Python服务并记录固定版本与显式部署方式，编辑启动不隐式安装。
- [x] 临时项目覆盖系统解释器与项目虚拟环境的选择，导入和诊断结果符合解释器。
- [x] 真实Python示例验证补全、定义、引用、重命名及错误诊断，区分高亮与服务就绪。
- [x] 服务缺失可定位，普通文件切回恢复，大文件不附加该服务。
- [x] 更新部署、Python教程和语言服务缺口台账。

## 范围与交付记录

保留Coc，不引入整套原生LSP迁移。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 实施与证据

真实项目最初无Python definition provider；固定部署 coc-pyright 1.1.414 后，系统环境场景实际验证导入定义、引用、重命名、补全和参数类型错误诊断。额外创建未激活的项目.venv，仅在该环境site-packages提供模块，定义解析正确进入该环境。使用现有项目发现，不额外注入机器解释器路径。`python tests/language_services_smoke.py --language python`、`--language python-venv`通过。

扩展由:CocProvision显式安装，普通启动不下载；缺失检查入口:CocList extensions/:CocInfo，项目解释器配置和部署步骤见[语言服务](../language-services.md)。共享bigfile入口阻止Coc附加并保持其他普通缓冲区服务；阈值/恢复回归由05覆盖。恢复以固定扩展清单重新部署，不清空用户Coc状态。详细教程关联[统一教程](../tutorial.md)。

[返回任务索引](README.md)
