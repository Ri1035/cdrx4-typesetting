# CHANGELOG

本项目变更日志。版本语义化（SemVer），重要变更记录于此。

## [Unreleased]

### 2026-09-28 — M1 项目初始化

- 建立项目目录骨架（docs/upstream/installer/scripts）
- 写入文档体系：PLAN.md（唯一事实源）、README.md、CHANGELOG.md、HANDOFF.md、.gitignore
- 确认关键事实：corelvba X4 导入文件为 `蘭雅sRGB工具_导入CorelDRAW_X4.xslt`；vbabox 模块清单；环境为 Windows + PowerShell
- 待办：clone 上游仓库 → 核对 LICENSE → 结构分析 → 编写安装器 → 自验证

### 2026-09-28 — M1 开发推进（提交 157f261..2944bfb）

- 安装 Git for Windows 2.55.0.3（winget，机器原本无 git）并初始化仓库（提交身份 Ri1035 / koka2996978242@outlook.com）
- vendor 化引入上游：`upstream/corelvba`（含 InnoSetup/CorelVBA.iss、module/base/UI/python 等 128 文件）、`upstream/vbabox`
- **许可证结论**：两仓库均无 LICENSE 文件；第三方标注 Apache/GPL 不一致 → 默认保留所有权利，分发/商用前须联系作者确认（PLAN 风险清单）
- 关键发现：上游 iss 注册表探测 `HKLM64\SOFTWARE\Corel\Setup\CorelDRAW Graphics Suite {14..2026}`；Suite 14 = X4；安装包内含 LYVBA.gms / Lanya_LinesTool.gms / ZeroBase.gms / LYVBA 皮肤目录
- 关键约束：GMS/xslt 为作者发布产物，GitHub 无 release 资产（仅 tag v1.0）→ 安装器采用"素材就绪"模式
- 编写 `installer/install.ps1`：素材校验（缺失即中止+指引）→ 注册表双视图探测（含 32 位 WOW6432Node）+ 手动 `-X4Root` 回退 → 复制 GMS/xslt/LYVBA → 生成 install-report.txt → 退出码 0/1/2/3
- 自验证：语法检查通过（PS Parser）；dry-run 素材缺失分支退出码 1 且指引完整；模拟 X4 环境成功路径退出码 0、复制 5 项、报告生成
- 待办（下一步）：获取 GMS/xslt 素材放入 `installer/assets/` → 真实 X4 机器实测 → M2 真实稿件验证

### 2026-09-28 — M1 素材获取 + 安装器 v2 + 真实部署（提交中）

- **素材已获取**：作者蓝奏云官方分享（华印 thread-29658，密码 bf73）下载 `Lanya_CorelVBA_2026_0528.zip`（2.4MB）→ Inno 静默解包官方安装器提取 → 归档 `installer/assets/`（LYVBA.gms / Lanya_LinesTool.gms / LYVBA 皮肤目录 / ColorMark.cdr / ZeroBase.gms / README-LYVBA.md，另写 `SOURCE.md` 来源与校验记录）
- **安装方式认知修正**（donate.md 实测确认）：2026 版**无需导入 xslt**——宏管理器运行 LYVBA 工程 `Start` 即打开主工具栏；xslt 为旧版流程（README 未同步）
- **X4 宏目录修正**：官方指引为**用户目录** `%APPDATA%\Corel\CorelDRAW Graphics Suite X4\User Draw\GMS`（非安装根目录 Draw\GMS）；安装器重写为：用户宏目录优先 → 手动 -X4Root → 注册表双视图，并支持 `User Draw\GMS` 子目录探测
- **本机真实部署成功**：开发机装有 32 位 CorelDRAW X4（注册表 WOW6432Node\Corel\Setup\CorelDRAW Graphics Suite 14）；安装器实测命中用户宏目录、复制 6 项、退出码 0；用户既有 `CDRX4Toolkit.gms` 未受影响
- 作者官方安装器向 `C:\TSP\` 写入运行时（lyreg.exe/lyvba.dll 等，疑为部分功能依赖），已记录未删除
- 待办：打开 X4 GUI 验证宏加载（LYVBA 工程 Start）→ M2 真实稿件验证 → 更新 CHANGELOG/HANDOFF/PLAN 并提交
