# cdrx4-typesetting

吊牌行业 CorelDRAW X4 排版插件一键打包项目。

**核心方案**：蘭雅 CorelVBA（corelvba）+ vbabox 双开源插件，打包为 CorelDRAW X4 一键安装包，覆盖"设计师稿件 → 排版 → 印刷"全部排版动作（合并/排序/对齐/拼版/角线/居中/微调）。

> 详细需求与验收见 [`../吊牌排版开源方案.md`](../吊牌排版开源方案.md)，开发准则见 [`../开发项目准则.md`](../开发项目准则.md)，**项目计划与当前状态见 [`PLAN.md`](PLAN.md)（唯一事实源）。**

## 当前状态

- **里程碑**：M1（环境安装 + 双插件跑通）进行中
- 2026-09-28：项目初始化，文档体系就绪，等待克隆上游仓库与编写安装器

## 目录结构

```
cdrx4-typesetting/
├── PLAN.md            # 项目计划与状态（唯一事实源，接手先读）
├── README.md          # 本文件
├── CHANGELOG.md       # 变更日志
├── HANDOFF.md         # 交接文档（给其他 agent 接手）
├── docs/              # 方案、上游分析等
├── upstream/          # 上游 clone：corelvba / vbabox
├── installer/         # 一键安装器脚本
└── scripts/           # 辅助脚本（验证、打包等）
```

## 技术要点

- 目标软件：CorelDRAW Graphics Suite X4（32 位；插件兼容至最新版）
- 打包形态：Windows 安装器自动复制 GMS/xslt + 一键导入宏（人工最后一步约 10 秒，CDR VBA 机制限制）
- 上游：
  - corelvba → https://github.com/hongwenjun/corelvba
  - vbabox → https://github.com/hongwenjun/vbabox

## 许可证

本项目文档 MIT（继承父目录 LICENSE © 2026 Ri1035）。**上游插件许可证待 clone 后核对**（corelvba 标注不一，见 PLAN.md 风险清单）。
