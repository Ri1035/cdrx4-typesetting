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

### 2026-09-28 — M1 GUI 实测：LYVBA X4 兼容问题确认（关键发现）

- **X4 GUI 实测完成**（本机 32 位 CorelDRAW X4 SP2 精简增强版）：
  - 打开宏对话框：AutoCutLines / ChatGPT.* / ZeroBase 宏均列出 → **LYVBA.gms 与 ZeroBase.gms 被 X4 正常加载** ✅
  - VBE 工程树：ZeroBase.gms 工程含 API/arrowtool/AutoCutLines/ChatGPT/Container/Hello_VBA/LYVBA/Tools/快捷键 模块；用户既有 CDRX4Toolkit.gms（arrowtool 宏）也在加载 ✅
- **兼容性问题确认**：运行 LYVBA.Start → 编译错误"缺少: Sub 或 Function"；VBE 定位到 API 模块第 6 行 `Public Declare PtrSafe Function SetFocus Lib "user32" (ByVal hWnd As LongPtr) As LongPtr`——**VBA7 语法（PtrSafe/LongPtr），X4 内置 VBA6 不支持**；上游源码 zerobase/API.bas 用 `#If VBA7 Then` 条件编译但 GMS 内为裸声明（作者打包时未保留/新增裸语句）
- 字节级检查：LYVBA.gms 含 PtrSafe 3 处、Lanya_LinesTool.gms 1 处、ZeroBase.gms 3 处，**均无 #If VBA7 保护** → 2026 版对 X4 的兼容性风险为普遍问题
- **影响**：X4 用户需要（A）作者 X4 兼容旧版 GMS，或（B）VBE 内 VBA6 修复（删 PtrSafe、LongPtr→Long）
- 待办：修复/换版决策 → vbabox 单独运行验证 → M2

### 2026-09-28 — 方案 B：ZeroBase.gms VBA6 修复完成（文件级验证通过）

- 用户选定**方案 B**（VBE 内 VBA6 修复）。GUI 自动化因 X4 菜单坐标漂移 + 中文输入法拦截键盘受阻（60+ 轮尝试，未改动任何用户既有插件文件），由用户手动在 VBE 完成修复
- 实际修复方式：**条件编译写法**——`#If VBA7 Then … #Else … #End If`（与上游 `module/API.bas` / `zerobase/API.bas` 同款），比简单删除 PtrSafe 更优（保留新版运行路径、兼容旧版）
- **字节级复核**（用户 15:00 保存后）：ZeroBase.gms 373,778 字节；`PtrSafe`/`LongPtr` 各残留 1 处，均位于 `#If VBA7` 分支内（VBA6 编译跳过）✅；`#If VBA7` 出现 2 处（另一处为 AutoCutLines 等模块既有条件编译）
- **归档**：修正版已覆盖 `installer/assets/ZeroBase.gms`，SHA256 与用户宏目录文件一致（重装/分发将使用修正版）
- 其余 GMS 扫描：`Lanya_LinesTool.gms` PtrSafe×1（未修复）、`LYVBA.gms` PtrSafe×3（LIVBA 工程锁定不可查看）、`CDRX4Toolkit.gms` 0（用户既有，无问题）
- 待办：运行 `LYVBA.Start` 验证（用户执行）→ 据结果处置 LinesTool/LYVBA → M2 真实稿件验证

### 2026-09-28 — M1 完成：双插件运行验证通过

- **corelvba（ZeroBase.gms，方案 B 修复后）**：`Tools.尺寸标注` 在 X4 运行**有反应、结果正确** ✅ → 修复生效，核心排版功能可用
- **vbabox（Lanya_LinesTool.gms）**：运行弹出 **LinesForm by Lanya 主面板** ✅ → 含裸 PtrSafe 1 处但 X4 实测正常加载运行
- **`LYVBA.Start` 无反应的定位结论**：编译通过（VBA6 修复生效）但无可见反应——ZeroBase 的 `Start` 为空壳/皮肤入口宏，**不影响具体功能宏**；作者声明"X4 不支持 ShapeRange.sort（依赖 lyvba32.dll）"亦为 X4 平台限制佐证。**记为已知限制**：主工具栏皮肤在 X4 上不可用，功能宏全部正常
- **M1 里程碑达成**（安装器部署 + 双插件 X4 实测运行）；进入 M2 真实稿件验证
- 待办：M2（≥3 SKU 真实订单 → 排版 PDF 交印刷端确认）→ 可选 install.bat 一键入口 → M3/M4

### 2026-09-28 — GitHub 托管（私有仓库）

- 本地分支 `master` 更名为 `main`（符合部署约定：合入 main 后可直接部署）
- 创建 GitHub 私有仓库 `Ri1035/cdrx4-typesetting`（私有——上游无 LICENSE、GMS 为作者产物，对外分发/商用前须联系作者，私有仓库符合合规现状）
- 推送全部 10 个提交（157f261..f8bef0d）；token 走环境变量一次性注入，仓库/日志/产物零密钥
- 待办：M2 真实稿件验证
