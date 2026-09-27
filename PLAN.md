# PLAN.md — 吊牌排版插件一键打包项目（cdrx4-typesetting）

> 本文件是项目的**唯一事实源（source of truth）**。上下文压缩或会话切换后，接手者先读本文件恢复全部计划与状态。
> 最后更新：2026-09-28（M1 启动）

---

## 1. 项目身份

| 项 | 值 |
|---|---|
| 项目名 | cdrx4-typesetting |
| 行业 | 吊牌（服装/鞋包挂牌）排版 |
| 工作流 | 设计师稿件（CDR 多页/多文件）→ 直接排版 → 印刷（**无可变数据环节**） |
| 目标 | 将 corelvba + vbabox 打包为 CorelDRAW X4 一键安装包 |
| 项目位置 | `C:\Users\Administrator\Desktop\Vibe\cdrx4-typesetting` |
| 父目录 | `C:\Users\Administrator\Desktop\Vibe`（含无关的既有项目 text-rope-effect，**不得改动**） |

## 2. 关键决策记录（ADR 摘要）

1. **选型**：蘭雅 CorelVBA（corelvba）+ vbabox 双插件，X4 内开源方案。
   - corelvba：拼版印前主力（物件排列拼版、批量排序、多页合并、拼版角线、安全辅助线、批量多页居中）
   - vbabox：排列微调（顶/左对齐+间距、批量旋转/移动/镜像、自动中心间距、转平）
2. **不做可变数据**：用户行业明确为"设计师出稿直接排版"，排除 Excel 绑定生成、条码批量（如需条码另配 Zint）。
3. **打包形态**：Windows 批处理/PowerShell 安装器（自动检测 X4 路径 → 复制 GMS → 复制 xslt）+ 一键导入宏（人工最后一步约 10 秒）。
   - **边界**：CorelDRAW VBA 宏必须由 CDR 进程运行才能注入，无官方 CLI 装宏接口 → 无法 100% 无人值守，最后一步人工是机制限制，不是开发缺口。
4. **仓库隔离**：吊牌项目独立子目录 + 独立 Git 仓库，避免污染 Vibe 根目录既有项目（text-rope-effect 的 README/LICENSE）。
5. **开发周期**：纯打包 1-2 天；打包+增强 1-1.5 周；产品化全套 2-3 周。

## 3. 里程碑与状态

| 里程碑 | 内容 | 状态 |
|---|---|---|
| M1 | 环境安装 + 双插件跑通（安装器 + X4 实测） | **进行中（本次会话）** |
| M2 | 真实稿件完整流程验证（≥3 SKU 真实订单 PDF 交印刷端确认） | 未开始 |
| M3 | 二次开发增强（按需：精确行列拼版、自动出血、角线组） | 未开始 |
| M4 | 方案固化（封装团队可复用 skill） | 未开始 |

## 4. M1 任务清单与进度

- [x] 方案文档（`../吊牌排版开源方案.md`，完整需求/流程/验收）
- [x] 项目目录骨架 + 文档体系（PLAN/README/CHANGELOG/HANDOFF/.gitignore）
- [ ] clone corelvba、vbabox 到 `upstream/`
- [ ] 核对两仓库 LICENSE（corelvba 标注不一：渠成=Apache、OSCHINA=GPL，**必须看仓库 LICENSE 文件定论**）
- [ ] 结构分析：GMS 文件清单、xslt/cdws 文件名、vbabox .bas 模块清单 → 写入 `docs/upstream-analysis.md`
- [ ] 编写一键安装器 `installer/install.bat`（或 .ps1）：注册表检测 X4 路径 → 复制 GMS/xslt → 生成安装报告
- [ ] 编写/验证"一键导入工具栏"宏说明
- [ ] 自验证：脚本语法/逻辑检查 + 安装报告输出正确
- [ ] Git 小步提交（Conventional Commits）

## 5. 环境与关键事实（接手必读）

- 主机：Windows，**shell 一律用 PowerShell 工具**（Bash 不可用，已验证报错）
- 目标软件：CorelDRAW Graphics Suite X4（32 位；corelvba 支持 X4–最新版）
- X4 GMS 目录示例：`C:\Program Files\Corel\CorelDRAW Graphics Suite X4\Draw\GMS\`（实际以注册表检测为准，不同版本路径不同）
- 上游地址：
  - corelvba：https://github.com/hongwenjun/corelvba （Gitee 镜像 https://gitee.com/mirrors/CorelVBA）
  - vbabox：https://github.com/hongwenjun/vbabox
- corelvba X4 工具栏导入文件：`蘭雅sRGB工具_导入CorelDRAW_X4.xslt`（README 确认；高版本为 .cdws）
- vbabox 模块清单（README 确认）：ALGO.bas / API.bas / AverageDistance.bas / Box.bas / MirrorParalleHorizon.bas / RotateMoveDuplicate.bas / ThisMacroStorage.cls / Tools.bas / lines.bas / Form/ / img/ / LinesForm.frm(.frx)
- 商业对标（非开源，功能参考）：CDR插件技术网"批量顺序拼版"、超平面"批量排版拼版"、魔镜插件"所有页重新排版"

## 6. 开发规范（引用父目录 `开发项目准则.md`，要点）

- Conventional Commits；小步提交；main 永远可部署；禁止直接推 main（走分支/PR）
- 密钥/token 一律环境变量，仓库零密钥
- 去除一切 AI 水印/作者署名残留
- 完成后自验证并报告（构建/检查/测试结果 + 覆盖范围 + 缺口）
- 提交身份：name=`Ri1035`，email=`koka2996978242@outlook.com`（对应 GH token 的环境变量注入）
- 不覆盖/删除/重命名用户已有文件（Vibe 根目录的 text-rope 项目、准则、方案文档）

## 7. 下一步动作（接手者按序执行）

1. `git clone https://github.com/hongwenjun/corelvba upstream/corelvba`
2. `git clone https://github.com/hongwenjun/vbabox upstream/vbabox`
3. 读取两仓库 LICENSE 文件 → 记录到 `docs/upstream-analysis.md` 并更新本文件 ADR
4. 列出 GMS/xslt/.bas 清单 → 写 `docs/upstream-analysis.md`
5. 编写 `installer/install.bat`（检测注册表 `HKCU/HKLM\Software\...\Corel\CorelDRAW Graphics Suite X4\` 或已知安装路径；找不到则提示手动指定）
6. 自验证 → 更新 CHANGELOG/HANDOFF → 提交

## 8. 风险清单

| 风险 | 影响 | 应对 |
|---|---|---|
| corelvba 许可证标注不一 | 商用合规 | clone 后核对 LICENSE；如 GPL 商用受限，内部使用或换方案 |
| X4 安装路径检测失败 | 安装器不可用 | 注册表多键探测 + 手动指定路径回退 |
| 安装包内含字体依赖 | 吊牌模板字体缺失 | 安装器附字体说明（参照条幅插件的方正大黑简体先例） |
| 上游仓库中断维护 | 长期维护风险 | fork 保留，内部维护 |
