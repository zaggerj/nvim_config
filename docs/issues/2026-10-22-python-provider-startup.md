# Python provider 同步探测造成打开代码等待

承接任务18的启动工作收敛、任务20的性能证据及任务21的平台验收。起点为 `d1b08f2`，旧回执与37项结果保留，不能覆盖为本次通过。

## 已核实的调用链

Neovim 0.12.6 自带 `runtime/ftplugin/python.vim` 第42行执行 `has('python3')`；随后 `autoload/provider/python3.vim` 调用 `vim.provider.python.detect_by_module('neovim')`。没有显式host时，它依次检查PATH中的Python候选，每个候选通过 `vim.system(...):wait()` 同步检查模块，没有等待上限。某个解释器启动慢或不响应，会直接阻塞文件打开。

两次探索性RPC UI剖析中，仅provider脚本的self时间分别为741.565ms和3231.367ms；对应首屏1450.224ms和4026.439ms。这些是定位证据，未作为收益A/B样本，也不能与上轮632ms直接计算优化比例。

官方依据：当前宿主自带 `:help g:python3_host_prog` 明确要求在首次 `has('python3')` 前设置host，并说明可加快启动、隔离项目venv；[官方provider文档](https://neovim.io/doc/user/provider.html#g:python3_host_prog)。源码与文档均来自本机锁定宿主，未修改Neovim runtime文件。

## TDD边界与红测

沿用已确认的Neovim子进程、临时项目、真实编辑动作及后代进程生命周期边界。新增 `tests/python_provider_smoke.py`，把会记录调用并停滞两秒的本机原生解释器fixture置于子进程PATH，再打开实际Python文件。红测确实创建调用标记，并失败于 `Opening Python synchronously probed an unrelated PATH interpreter`。fixture返回有效Python版本，避免将宿主版本解析错误误判为此缺陷。

## 修复范围

- `bootstrap.init()`在ftplugin之前设置动态 `stdpath(data)/tools/python-provider` 的host路径；Windows使用Scripts/python.exe，macOS使用bin/python。用户预设的host优先，不禁用Python provider。
- `scripts/provision_python.py`显式创建独立venv，按版本清单安装pynvim与依赖，验证C扩展实际导入及pip依赖；不更改全局Python或项目venv。
- 未部署时打开Python给出安装指引，编辑启动不访问PyPI、不运行pip。
- Python3.9使用兼容的greenlet/msgpack固定版本，3.10+使用本机已验证版本；PyPI元数据已核对。macOS运行仍须实机验证。

真实 `py3eval('6 * 7')`得到42。最初两次生命周期检查捕获Windows venv启动的conhost在0.5秒守卫内未退出；后续专用进程树跟踪确认其创建链，跟踪轮中所有后代在Neovim退出时均已结束。保留原守卫、没有针对它忽略进程；同一测试随后默认host/显式host/默认host连续三轮通过。最初两次延迟的具体系统原因未确定，不据后续成功改写它们。

## 双轴审查追加红绿

Standards指出缺失提示依赖cwd、部署文档未同步；Spec另指出不完整venv可能缺pip，以及仅检查解释器会漏掉未安装依赖。分别新增回归后修正：

- `tests/python_provider_installation.py`先创建有解释器、无pip且带管理标记的真实venv，旧脚本红于`No module named pip`。改为标准venv默认clear=False的原地补齐，完整pip依赖/真实C扩展导入检查后转绿，原有sentinel文件保留。此测试会在临时目录显式安装固定包，独立执行，不进入日常不联网的总回归。
- `tests/python_provider_state_smoke.py`在隔离数据目录创建解释器存在、complete=False的真实启动场景，旧逻辑红于没有部署提示；改为读取完成标记，实际`:messages`出现脚本及源码目录后转绿。检查不启动Python解释器，提示明确先进入源码目录，macOS用python3。
- 部署、设计、语言服务和教程同步新步骤，重启后用真实py3eval验收，未把provider与Pyright混用。

首轮完整服务A/B在旧源配置的RPC就绪采样未返回，日志已到首屏，不能归因于provider仍在同步探测。已保存[中断记录](../evaluations/provider-ab-interrupted.json)，只结束本次已核实的Neovim进程。benchmark新增独立worker及45秒外部进程树边界，超时样本保留且最终断言失败，避免Lua定时器无法处理的阻塞。首屏专项模式在两边同样关闭Coc，只用于隔离首屏成本；真实语言能力由完整回归验证，不能混作整配置服务提速。

## 性能与最终整合接续

新provider、标记与恢复路径完成后，独占三轮完整服务A/B：A的运行源码对应97e87e0，B为d1b08f2源配置，两者共用当前插件/服务，RPC UI同样启用ext_messages。内部首屏中位433.397/653.038ms，进程外首次flush482.410/689.641ms，Python定义provider1990.993/2252.818ms；42个必需指标全有效，6个样本正常结束。完整波动、失败采样及边界见[性能记录](../evaluations/performance.md)。不以三个Python样本推断所有语言启动比例。

首次39项整合37项通过，原输出保留provider-integration-first.json：Windows四编辑器频率锁遇EPERM；Go定义请求在Coc默认3000ms超时。Go原测试定点复跑全部行为通过，未扩大超时或改Go配置；原失败仍保留，具体系统调度原因未证实。

并发锁在原有2秒有界等待内补齐Windows EPERM/EACCES处理，永久访问错误仍显示原始异常、不抢锁、不跳过计数。原锁并发测试直接覆盖失败路径，修正后五轮累计400次更新均精确保留。曾尝试用Windows DeleteFile并保留handle构造EPERM，实际路径已移除、未复现同样错误，因此没有把该试验算作根因证明，也没有保留无效测试。当前根因结论限定为实际竞争场景返回码未被锁协议处理；具体底层删除时序只作为解释，未声称全部复现。独立审查核对luvref第三返回值错误码及有界/平台分支后无新问题。

生产修复提交ce2dfb1、97e87e0、02ac5ff；最终完整回归与三Windows入口结果在[平台验收](../platform-acceptance-2026-10-22.md)追加。源码/数据目录不依赖临时目录，本机provider已显式安装且真实导入成功。macOS实机、账号后的AI仍待目标环境。

第二轮39项中，真实Git键位回归遇到index读取Permission denied：Gitsigns异步stage正在更新index，测试观察器在既有就绪等待内立即assert单次读取成功，导致无法继续等待实际stage结果。修正测试的三态观察（已暂存/未暂存/未能读取），仍使用原2秒就绪期限；只有成功读到真实Git结果才判通过，永久失败保留最后stderr并超时报错。取消/重置也明确要求staged()==false，避免nil被当作未暂存。生产Git配置及命令未变，定点真实stage/unstage/取消/确认及diff已通过。
