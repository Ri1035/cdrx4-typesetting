# 上游仓库分析（upstream-analysis）

> 生成日期：2026-09-28 · 基于 `upstream/` 浅克隆（commit 以克隆时为准）

## 1. LICENSE 结论（重要）

- **corelvba：仓库内无 LICENSE 文件**
- **vbabox：仓库内无 LICENSE 文件**

第三方平台标注不一致：渠成社区标 **Apache**、OSCHINA 标 **GPL**；作者 README 仅声明"永久免费开源开放"。
**法律状态**：无 LICENSE 文件时默认"保留所有权利"，仅作者明确授权可自由使用。**打包分发/商用前必须联系作者确认授权，或仅限内部使用**。此为项目最高优先级合规风险，见 PLAN.md §8。

## 2. corelvba 仓库结构

```
corelvba/
├── InnoSetup/CorelVBA.iss   # 上游 Inno Setup 安装脚本（打包逻辑参考）
├── module/                  # 插件核心 VBA 模块（源码）
│   ├── CorelVBA.bas         # 主入口
│   ├── Arrange.bas          # 排列
│   ├── AutoCutLines.bas     # 自动裁切线
│   ├── CardsTools.bas       # 卡片工具（吊牌相关）
│   ├── CutLines.bas         # 裁切线
│   ├── SmartGroup.bas       # 智能群组
│   ├── ALGO.bas / API.bas / Tools.bas / Launcher.bas / HotKeys.bas ...
├── base/                    # 基础模块
│   ├── Batch_Center.bas     # 批量居中
│   ├── sort.bas             # 排序
│   ├── CorelDRAW_VBA编程手册_学习笔记.bas
│   └── ...
├── UI/                      # 窗体（.frm/.frx）
│   ├── ArrangeForm.frm      # 排列窗体
│   ├── CardsToolsForm.frm   # 卡片工具窗体
│   └── ...
├── LinesTool/               # 仅 README（实现已并入 Lanya_LinesTool.gms）
├── python/  zerobase/  simple/  donate.md  README.md
```

**GMS/xslt 不在源码仓库**（release 产物）。iss 显示安装包内含：`LYVBA.gms`、`Lanya_LinesTool.gms`（即 vbabox 打包形态）、`ZeroBase.gms`、`ColorMark.cdr`、`README-LYVBA.md`、`lycpg64.cpg`（→ Plugins64）、`LYVBA/` 目录（含 100/125/150/175/200 DPI 皮肤）、`TSP/`。

## 3. 上游安装脚本关键逻辑（CorelVBA.iss）

- 注册表探测安装目录：`HKLM64\SOFTWARE\Corel\Setup\CorelDRAW Graphics Suite {14..2026}` 的 `Destination` 值 → 目标 = `ExtractFilePath(Destination) + Draw\GMS`
  - **Suite 14 = CorelDRAW X4**（本项目目标版本）
- 目标目录：`{app}` = `...\Draw\GMS`
- 附加组件：`lycpg64.cpg` → `Draw\Plugins64\`；`TSP\` → `C:\TSP\`
- 默认回退目录：`C:\Program Files\Corel\CorelDRAW Graphics Suite 2020\Draw\GMS`
- **局限**：仅查 HKLM64 视图；32 位 X4 可能写在 32 位视图（`WOW6432Node`），需本项目安装器补齐

## 4. vbabox 仓库结构

```
vbabox/
├── Form/  img/
├── ALGO.bas                # 算法
├── API.bas                 # API 封装
├── AverageDistance.bas     # 自动中心间距
├── Box.bas                 # 包装盒
├── lines.bas
├── LinesForm.frm / .frx
├── MirrorParalleHorizon.bas # 镜像/水平
├── RotateMoveDuplicate.bas  # 批量旋转移动复制
├── ThisMacroStorage.cls
├── Tools.bas
└── README.md               # 含教学代码
```

打包形态 = `Lanya_LinesTool.gms`（已含于 corelvba 安装体系，无需单独打包）。

## 5. 素材获取策略（GMS/xslt 产物）

- GitHub 无 release 资产（仅 tag v1.0）→ GMS 需从作者渠道获取：
  - 作者站 lyvba.com（博客，无直接下载链接）
  - 论坛 bbs.lyvba.com / 华印 52cnp.com（作者发布帖）
- 本项目安装器采用**素材就绪模式**：素材放入 `installer/assets/`，缺失时安装器列出缺失清单与获取指引，不静默失败
- 必需素材清单（对应 X4）：
  - `LYVBA.gms`
  - `Lanya_LinesTool.gms`
  - `ZeroBase.gms`
  - `ColorMark.cdr`（可选）
  - `蘭雅sRGB工具_导入CorelDRAW_X4.xslt`（X4 工具栏导入文件）
  - `LYVBA/` 目录（含多 DPI 皮肤）
  - `lycpg64.cpg`（64 位插件，X4 32 位可不装，可选）

## 6. 素材已获取（2026-09-28 实测）

- 作者蓝奏云官方分享（华印 thread-29658 发布帖）：`https://wwapl.lanzout.com/iK1lo3qi880j`（密码 bf73）
- 包：`Lanya_CorelVBA_2026_0528.zip`（2.4MB，2026-05-27 发布），已下载并归档至 `installer/assets/`（见 `assets/SOURCE.md`）
- 官方安装器 `Lanya_CorelVBA.exe`（Inno Setup 产物，无数字签名）用 `/VERYSILENT /DIR=<临时>` 解包提取 GMS
- **解包实际清单**：LYVBA.gms、Lanya_LinesTool.gms、ColorMark.cdr、README-LYVBA.md、LYVBA/（含 100/125/150/175/200 皮肤）✅；ZeroBase.gms 在包内 optional/ ✅；**xslt 不在 2026 包内**

## 7. 安装方式变更（重要，2026 版）

- **donate.md 确认**：2026 版无需导入 xslt——安装 GMS 后，宏管理器展开 **LYVBA 工程，运行 `Start` 宏**即打开主工具栏（CorelVBA.bas: `Toolbar.Show 0`）；其余功能双击对应模块（如 `Start_Dimension`）
- README 中 X4 导入 `蘭雅sRGB工具_导入CorelDRAW_X4.xslt` 为**旧版流程**（README 未同步更新）
- **X4 宏目录**：corelvba.com 官方指引 = 用户目录 `%APPDATA%\Corel\CorelDRAW Graphics Suite X4\User Draw\GMS`（安装器 2a 探测已实现并实测命中）

## 8. 本机真实部署结果（2026-09-28）

- 开发机真实装有 **CorelDRAW X4（32 位）**：注册表 `HKLM:\SOFTWARE\WOW6432Node\Corel\Setup\CorelDRAW Graphics Suite 14` → `C:\Program Files (x86)\CorelDRAW X4\`
- 安装器实测：命中 X4 用户宏目录，复制 6 项（LYVBA.gms、Lanya_LinesTool.gms、ColorMark.cdr、ZeroBase.gms、README-LYVBA.md、LYVBA\）✅ 退出码 0
- 用户宏目录既有文件 `CDRX4Toolkit.gms` 未受影响（属用户已有插件）
- 作者官方安装器解包时向 `C:\TSP\` 写入运行时（lyreg.exe/lyvba.dll 等，疑为 GMS 部分功能依赖），已记录未删除
