# assets/ — 安装素材目录

将以下文件放入本目录后，运行 `..\install.ps1` 即可自动部署到 CorelDRAW X4。

## 必需素材

| 文件 | 说明 |
|---|---|
| `LYVBA.gms` | corelvba 主插件（GMS 宏容器） |
| `Lanya_LinesTool.gms` | vbabox（批量排列/对齐/间距/镜像）打包形态 |
| `ZeroBase.gms` | 兰雅基础宏 |
| `蘭雅sRGB工具_导入CorelDRAW_X4.xslt` | X4 工具栏导入文件 |

## 可选素材

| 文件 | 说明 |
|---|---|
| `ColorMark.cdr` | 色彩标记模板 |
| `lycpg64.cpg` | 64 位 CPG 插件（X4 32 位可忽略） |
| `README-LYVBA.md` | 作者说明 |
| `LYVBA/` | 多 DPI 皮肤目录（100/125/150/175/200） |

## 素材获取

GMS/xslt 是作者发布的产物，**源码仓库（GitHub）不含**。获取渠道：

- 作者网站：https://lyvba.com/
- 作者论坛：https://bbs.lyvba.com/（发布帖内含 GMS 压缩包，如"蘭雅CorelVBA工具 X.X 版"）
- 华印论坛：https://www.52cnp.com/（蘭雅CorelDRAW插件发布帖）

获取后解压，将上述文件放入本目录即可。缺失时安装器会列出缺失清单并中止，不会静默装错。
