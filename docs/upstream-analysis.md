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
