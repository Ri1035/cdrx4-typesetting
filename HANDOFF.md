# HANDOFF.md — 交接文档（给接手 Agent）

> 本文件让任何接手本项目的 agent 无需依赖此前对话，即可恢复工作。**先读 `PLAN.md`（唯一事实源），再读本文件。**

## 1. 这是什么项目

吊牌行业 CorelDRAW X4 排版插件一键打包：把开源插件 corelvba + vbabox 做成"双击安装 → 1-2 分钟启用"的安装包。工作流 = 设计师稿件直接排版（**无**可变数据环节）。

## 2. 当前状态（2026-09-28）

- **M1 完成 ✅**：文档体系 ✅、上游 vendor 化 ✅、LICENSE 核对 ✅（两仓库均无 LICENSE）、素材获取 ✅、安装器 v2 + 真实部署 ✅（复制 6 项、exit 0）、GUI 加载验证 ✅、**双插件运行验证通过 ✅**
- **M3 完成 ✅**：增强宏开发（`src/LanyaTagPack.bas` 4 宏）→ X4 实测四宏正常（用户确认）→ **持久化保存进 ZeroBase.gms**（VBE 导入 + Ctrl+S；文件 373,778→**396,306** 字节；重启不丢；已归档 assets/）
- **运行验证结果**：
  - corelvba（ZeroBase.gms 方案 B 修复后）：`Tools.尺寸标注` 有反应、结果正确 ✅
  - vbabox（Lanya_LinesTool.gms）：`LinesForm by Lanya` 主面板弹出 ✅
  - `LYVBA.Start`：编译通过但无可见反应 → **已知限制**（Start 为皮肤入口空壳；作者声明 X4 不支持 lyvba32.dll 排序；功能宏不受影响）
  - M3 增强宏：TagMixPacking / TagAddBleed / TagCornerMarks / TagRemoveCornerMarks 全部正常 ✅
- 提交历史：`157f261` → `2f661f4` → `29a6a88` → `2944bfb` → `d78b629` → `8bd888d` → `c18d6de` → `679a6e0`（方案 B 修复）→ `f8bef0d`（M1 完成）→ `3db4cc7`（GitHub 托管）→ `9c8ee08`（M2 推迟）→ `c02fe65`（M3 定案）→ `a634bb5`（M3 源码）→ `6dd7fea`（M3 实测通过）
- 已完成交付物：`../吊牌排版开源方案.md`、`docs/upstream-analysis.md`、`docs/m3-enhancement-plan.md`、`installer/install.ps1`（v2）、`installer/assets/`（素材 + SOURCE.md + README.md + 含 M3 增强的 ZeroBase.gms）

## 3. 下一步（严格按序）

1. **（当前）并入安装器素材清单**：`installer/install.ps1` 素材校验中 ZeroBase.gms 已更新为含 LanyaTagPack 的持久化版（396,306 字节，SHA256 `CD93CBDBE05CFA341DE198B7DEB21A645FE39D691634089F5D5DF5CCFD444A28`）——重跑 dry-run + 真机验证
2. **M2 验收（推迟至此）**：≥3 SKU 真实稿件验证增强后完整流程 → PDF 交印刷端
3. 可选：install.bat 一键入口
4. M4 方案固化；同步文档后提交

## 4. 环境硬约束

- **Windows 主机，shell 必须用 PowerShell 工具**（Bash 不可用，已验证；不要尝试 Bash）。
- 工作目录：`C:\Users\Administrator\Desktop\Vibe\cdrx4-typesetting`
- 提交身份：name=`Ri1035`，email=`koka2996978242@outlook.com`；GH token 走环境变量（不在代码/提交里写）。
- **禁止改动 Vibe 根目录既有文件**：`README.md`（文字绳子项目）、`LICENSE`、`开发项目准则.md`、`text-rope-demo.html`。
- 提交规范：Conventional Commits，小步提交，一个提交一个逻辑变更；不直接推 main（走分支/PR）。

## 5. 关键事实速查

| 事实 | 值 |
|---|---|
| **X4 用户宏目录（官方推荐）** | `%APPDATA%\Corel\CorelDRAW Graphics Suite X4\User Draw\GMS`（安装器 2a 优先探测，本机已实测命中） |
| **新版安装方式（2026.05.28+）** | 装 GMS 后：宏管理器 → LYVBA 工程 → 运行 `Start` 宏即打开主工具栏；**不再需要 xslt** |
| xslt（旧版流程） | `蘭雅sRGB工具_导入CorelDRAW_X4.xslt`：仅旧版/兼容场景需要，2026 包内未含 |
| 本机 X4 | 32 位，注册表 `HKLM\SOFTWARE\WOW6432Node\Corel\Setup\CorelDRAW Graphics Suite 14` → `C:\Program Files (x86)\CorelDRAW X4\` |
| vbabox 模块 | ALGO/API/AverageDistance/Box/MirrorParalleHorizon/RotateMoveDuplicate/Tools/lines .bas + ThisMacroStorage.cls + Form/；打包形态 `Lanya_LinesTool.gms` |
| 安装流程（打包后） | 双击 install.bat（自动部署 GMS）→ 打开 CDR 运行 Start 宏（人工约 10 秒） |
| 无法无人值守的原因 | CDR VBA 宏必须由 CDR 进程运行注入，无官方 CLI 装宏接口 |
| 素材源 | 蓝奏云 `https://wwapl.lanzout.com/iK1lo3qi880j`（密码 bf73）；官方安装器无数字签名，来源为作者官方渠道 |
| C:\TSP | 作者官方安装器写入（lyreg.exe/lyvba.dll 等），疑为部分功能运行时依赖，未删除 |

## 6. 验证方式

- 安装器：在 X4 环境实测（或至少 dry-run 检查路径探测逻辑与报告输出）
- 插件：安装后 X4 打开无报错、工具栏出现"蘭"图标、vbabox 宏可运行
- 提交前：`git diff --stat` 核对改动范围、`git status` 无临时文件、搜索无密钥泄漏

## 7. 常见坑

- **xslt 已不需要**：2026 版（2026.05.28）装 GMS 后运行 LYVBA 工程 `Start` 宏即可，别再按旧 README 找 xslt（README 未同步更新）
- **X4 宏目录在用户目录**：`%APPDATA%\Corel\CorelDRAW Graphics Suite X4\User Draw\GMS`，不是安装根目录 `Draw\GMS`（安装器 v2 已优先探测用户目录，同时保留根目录探测兼容旧安装方式）
- **32 位 X4 注册表**：在 `HKLM\SOFTWARE\WOW6432Node\Corel\Setup\CorelDRAW Graphics Suite 14`（64 位视图可能查不到），安装器已双视图探测
- 安装器若检测不到路径，必须提供手动指定目录的回退，不能静默失败（`-X4Root` 参数）
- **VBE 工程树导航坑（M3 持久化实测）**：① X4 宏菜单**无"宏管理器"入口**（X4 不支持 GUI 新建 GMS）；② 工程树坐标随窗口漂移（每次布局变化需新截图定位）；③ 带锁工程 **VersionConversion102 紧邻 ZeroBase 上方**，双击/回车误触即弹密码框（Esc 取消，无副作用）；④ 键盘 End 只能跳选、**Enter 不激活工程**，激活必须双击工程节点；⑤ 导入文件对话框用 **Alt+N** 聚焦文件名框再输路径（点击输入框不稳）；⑥ 模块导入后 **Ctrl+S** 保存即写入 GMS（二进制复合文档，不可文本拼接/脚本注入）

## 8. 已完成交付物索引

- `../吊牌排版开源方案.md` — 完整方案（需求/选型/流程/验收/风险）
- `PLAN.md` — 项目计划与状态（唯一事实源）
- 本文件 — 交接说明
