# 23：评估原生LSP与blink的功能等价性

**What to build（交付行为）：** 基于已修复的Coc基线，验证原生LSP加blink能否保留实际语言工作流，并给出迁移或保留结论。

**Blocked by（阻塞依赖）：** [02 恢复Go语言导航并保留构建测试](02-go-language-navigation.md)；[06 补齐Python解释器与语言服务](06-python-language-service.md)；[07 恢复Lua服务与补全](07-lua-language-service.md)；[08 建立Vue与React语言能力兼容矩阵](08-vue-language-matrix.md)；[20 建立可复用的启动与搜索性能基线](20-performance-baseline.md)。

**Status：** evaluated-retain-current（10语言原型与18个交替请求样本完成；保留Coc，20最终基线由主记录关联）

**归属：** 候选评估；[治理SPEC](../spec.md) ID02、ID06；验收 AC03、AC08、AC10。

## 验收标准

- [x] 盘点当前Coc扩展、诊断、格式化、文本对象、Vista接口、快捷键及项目服务能力。
- [x] 隔离原型部署对应语言服务器，覆盖Go/Python/Lua/前端兼容矩阵，不把blink当服务器安装器。
- [x] 真实动作和跨包/跨文件场景对照，记录缺失能力及迁移成本。
- [x] 同环境比较服务就绪和补全响应，组件宣传的0.5–4ms不能与整机启动相比。
- [x] 形成选型材料及可恢复的后续迁移票，Coc日常配置在决定前保留。

## 范围与交付记录

只做隔离验证与选型，不实施Coc整套替换。

完成时追加复现、改动原因、执行环境/revision、实际结果、未验证边界和恢复方式；同步当前设计、教程、问题状态及决策记录。候选评估票以可复现比较和选型材料完成，不因评估结束自动获得迁移状态。

### 2026-10-22 评估与结论

隔离固定blink.cmp v1.10.2，明确Lua matcher且不隐式下载Rust产物；服务器复用已部署的固定版本，前端补充typescript-language-server6.0.2。-u NONE原型覆盖Python/Lua/Go/Vue2.6/2.7/3/JS/TS/JSX/TSX十种真实项目，定义、引用、rename、completion、诊断与blink菜单回调/候选列表均通过。

另采Python/Lua/Go各3组交替Coc/native样本，在两边完成定义引用rename后测补全：Coc/native中位数分别23.43/51.18ms、12.60/13.66ms、189.30/212.22ms；不把native initialize和Coc provider就绪当同一指标。证据未显示当前迁移收益，保留Coc。迁移还须覆盖Vista、函数文本对象、诊断/列表/代码动作/导入整理、17扩展及大文件/重连接口，不以blink替代服务器部署。完整原型、原始JSON、限制及后续迁移步骤见[评估报告](../evaluations/language-stack.md)，20统一首屏基线见[性能记录](../evaluations/performance.md)。候选未写入日常插件。

[返回任务索引](README.md)
