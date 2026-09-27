# HANDOFF.md — 交接文档（给接手 Agent）

> 本文件让任何接手本项目的 agent 无需依赖此前对话，即可恢复工作。**先读 `PLAN.md`（唯一事实源），再读本文件。**

## 1. 这是什么项目

吊牌行业 CorelDRAW X4 排版插件一键打包：把开源插件 corelvba + vbabox 做成"双击安装 → 1-2 分钟启用"的安装包。工作流 = 设计师稿件直接排版（**无**可变数据环节）。

## 2. 当前状态（2026-09-28）

- **M1 进行中**：文档体系 ✅、上游 vendor 化 ✅、LICENSE 核对 ✅（两仓库均无 LICENSE）、安装器 ✅（自验证通过：语法/缺失分支/模拟成功路径）
- 提交历史：`157f261` 文档初始化 → `2f661f4` 上游引入 → `29a6a88` 分析文档 → `2944bfb` 安装器
- 已完成：`../吊牌排版开源方案.md`（完整方案）、`docs/upstream-analysis.md`、`installer/install.ps1`、`installer/assets/README.md`

## 3. 下一步（严格按序）

1. **获取素材**：从作者渠道（lyvba.com / bbs.lyvba.com / 52cnp.com）下载 GMS 压缩包，解压后放入 `installer/assets/`：
   `LYVBA.gms`、`Lanya_LinesTool.gms`、`ZeroBase.gms`、`蘭雅sRGB工具_导入CorelDRAW_X4.xslt`（可选 ColorMark.cdr/lycpg64.cpg/LYVBA 皮肤目录）
2. **真实 X4 实测**：在装有 CorelDRAW X4 的机器运行
   `powershell -ExecutionPolicy Bypass -File installer\install.ps1`
   （本机开发环境无 CorelDRAW，路径探测与复制逻辑已用模拟目录验证）
3. 打开 CDR → 运行导入宏 → 导入 xslt 工具栏 → 验证「蘭」图标与 vbabox 宏
4. M2 真实稿件验证（≥3 SKU 订单 → 排版 PDF 交印刷端确认）
5. 更新 CHANGELOG/HANDOFF/PLAN → 提交

## 4. 环境硬约束

- **Windows 主机，shell 必须用 PowerShell 工具**（Bash 不可用，已验证；不要尝试 Bash）。
- 工作目录：`C:\Users\Administrator\Desktop\Vibe\cdrx4-typesetting`
- 提交身份：name=`Ri1035`，email=`koka2996978242@outlook.com`；GH token 走环境变量（不在代码/提交里写）。
- **禁止改动 Vibe 根目录既有文件**：`README.md`（文字绳子项目）、`LICENSE`、`开发项目准则.md`、`text-rope-demo.html`。
- 提交规范：Conventional Commits，小步提交，一个提交一个逻辑变更；不直接推 main（走分支/PR）。

## 5. 关键事实速查

| 事实 | 值 |
|---|---|
| corelvba X4 工具栏导入文件 | `蘭雅sRGB工具_导入CorelDRAW_X4.xslt` |
| vbabox 模块 | ALGO/API/AverageDistance/Box/MirrorParalleHorizon/RotateMoveDuplicate/Tools/lines .bas + ThisMacroStorage.cls + Form/ |
| GMS 目录示例 | `C:\Program Files\Corel\CorelDRAW Graphics Suite X4\Draw\GMS\` |
| 安装流程（打包后） | 双击 install.bat（自动）→ 打开 CDR 运行一次"一键导入工具栏"宏（人工 10 秒） |
| 无法无人值守的原因 | CDR VBA 宏必须由 CDR 进程运行注入，无官方 CLI 装宏接口 |

## 6. 验证方式

- 安装器：在 X4 环境实测（或至少 dry-run 检查路径探测逻辑与报告输出）
- 插件：安装后 X4 打开无报错、工具栏出现"蘭"图标、vbabox 宏可运行
- 提交前：`git diff --stat` 核对改动范围、`git status` 无临时文件、搜索无密钥泄漏

## 7. 常见坑

- corelvba GMS 可能包含多版本目录，复制时注意 X4 用哪个（README 以 X6 举例，X4 单独有 xslt）
- 32 位 X4 注册表路径与高版本不同（可能在 `HKLM\SOFTWARE\WOW6432Node\Corel\...` 或 `SOFTWARE\Corel\...`，需多键探测）
- 安装器若检测不到路径，必须提供手动指定目录的回退，不能静默失败

## 8. 已完成交付物索引

- `../吊牌排版开源方案.md` — 完整方案（需求/选型/流程/验收/风险）
- `PLAN.md` — 项目计划与状态（唯一事实源）
- 本文件 — 交接说明
