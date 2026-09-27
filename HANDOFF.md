# HANDOFF.md — 交接文档（给接手 Agent）

> 本文件让任何接手本项目的 agent 无需依赖此前对话，即可恢复工作。**先读 `PLAN.md`（唯一事实源），再读本文件。**

## 1. 这是什么项目

吊牌行业 CorelDRAW X4 排版插件一键打包：把开源插件 corelvba + vbabox 做成"双击安装 → 1-2 分钟启用"的安装包。工作流 = 设计师稿件直接排版（**无**可变数据环节）。

## 2. 当前状态（2026-09-28）

- **M1 进行中**：文档体系已完成，尚未 clone 上游仓库、未写安装器。
- 已完成：`../吊牌排版开源方案.md`（完整方案）、PLAN/README/CHANGELOG/HANDOFF/.gitignore、目录骨架。

## 3. 下一步（严格按序）

1. clone 两仓库到 `upstream/`：
   - `git clone https://github.com/hongwenjun/corelvba upstream/corelvba`
   - `git clone https://github.com/hongwenjun/vbabox upstream/vbabox`
2. **核对 LICENSE**：corelvba 标注不一（渠成=Apache、OSCHINA=GPL），以仓库 LICENSE 文件为准，结果写入 `docs/upstream-analysis.md`。
3. 结构分析：列 GMS 文件、xslt/cdws 文件名、vbabox .bas 模块 → `docs/upstream-analysis.md`。
4. 编写 `installer/install.bat`：
   - 注册表探测 X4 安装路径（多键候选 + 手动回退）
   - 复制 GMS 文件到 `Draw\GMS\`
   - 复制 xslt 到对应目录
   - 输出安装报告（装到哪、下一步人工动作）
5. 自验证 → 更新 CHANGELOG/HANDOFF → Git 小步提交。

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
