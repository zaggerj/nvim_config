# 23：评估原生LSP与blink的功能等价性

**What to build（交付行为）：** 基于已修复的Coc基线，验证原生LSP加blink能否保留实际语言工作流，并给出迁移或保留结论。

**Blocked by（阻塞依赖）：** [02 恢复Go语言导航并保留构建测试](02-go-language-navigation.md)；[06 补齐Python解释器与语言服务](06-python-language-service.md)；[07 恢复Lua服务与补全](07-lua-language-service.md)；[08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** ready-for-agent（用户已确认拆分与依赖，未开始实施；执行前须满足Blocked by）

**归属：** 候选评估；[治理SPEC](../spec.md) ID02、ID06；验收 AC03、AC08、AC10。

## 验收标准

- [ ] 盘点当前Coc扩展、诊断、格式化、文本对象、Vista接口、快捷键及项目服务能力。
- [ ] 隔离原型部署对应语言服务器，覆盖Go/Python/Lua/前端兼容矩阵，不把blink当服务器安装器。
- [ ] 真实动作和跨包/跨文件场景对照，记录缺失能力及迁移成本。
- [ ] 同环境比较服务就绪和补全响应，组件宣传的0.5–4ms不能与整机启动相比。
- [ ] 形成选型材料及可恢复的后续迁移票，Coc日常配置在决定前保留。

## 范围与交付记录

只做隔离验证与选型，不实施Coc整套替换。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

[返回任务索引](README.md)
