# assets/ — 安装素材目录

> **状态：素材已就绪（2026-09-28）**。已从作者官方渠道下载 `Lanya_CorelVBA_2026_0528.zip` 并提取归档（详见 `SOURCE.md`）。直接运行 `..\install.ps1` 即可自动部署。

## 必需素材

| 文件/目录 | 说明 |
|---|---|
| `LYVBA.gms` | corelvba 主插件（GMS 宏容器，含 LYVBA 工程） |
| `Lanya_LinesTool.gms` | vbabox（批量排列/对齐/间距/镜像）打包形态 |
| `LYVBA/` | 工具栏皮肤目录（100/125/150/175/200 DPI + python 工具 + 图标） |

## 可选素材

| 文件 | 说明 |
|---|---|
| `ColorMark.cdr` | 色彩标记模板 |
| `ZeroBase.gms` | 兰雅基础宏（包内 optional/ 提供） |
| `README-LYVBA.md` | 作者说明 |
| `蘭雅sRGB工具_导入CorelDRAW_X4.xslt` | **兼容参考**：2026 版**不再需要**（装 GMS 后宏管理器运行 LYVBA 工程 Start 即可打开工具栏）；xslt 仅旧版流程使用，当前包内未含 |

## 素材获取（仅当需要重新获取/更新版本时）

GMS/xslt 是作者发布的产物，**源码仓库（GitHub）不含**。获取渠道：

- 作者蓝奏云官方分享（华印 thread-29658 发布帖）：`https://wwapl.lanzout.com/iK1lo3qi880j`（密码 bf73）
- 作者论坛：https://bbs.lyvba.com/
- 作者网站：https://lyvba.com/

下载后解压，将必需文件放入本目录即可。缺失时安装器会列出缺失清单并中止，不会静默装错。
