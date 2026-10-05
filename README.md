# cdrx4-typesetting · 吊牌排版插件一键打包

> 面向吊牌行业的 CorelDRAW X4 排版插件打包项目：把双开源插件与自研增强宏打成一键安装包，覆盖「稿件 → 排版 → 印刷」的常用排版动作。

## 项目简介

本项目基于蘭雅 CorelVBA（corelvba）与 vbabox 两个开源插件，打包为 CorelDRAW X4 一键安装包，覆盖合并 / 排序 / 对齐 / 拼版 / 角线 / 居中 / 微调等排版动作，并附带自研的吊牌增强宏。安装器自动复制 GMS / xslt 并引导导入宏，开箱即用。

## 主要功能

- 整合 corelvba + vbabox 双开源插件，统一一键安装
- 混拼：不同规格吊牌混合排版（TagMixPacking）
- 自动出血：背景外扩 + 描边加圈双模式，自动加 3mm 出血（TagAddBleed）
- 套准角线：四角四边套准十字 + 裁切角线（TagCornerMarks）
- 删除角线：一键清除套准角线（TagRemoveCornerMarks）

## 快速开始

运行 `installer/` 目录下的安装脚本，按提示完成 GMS / xslt 复制与宏导入（最后一步手动导入约 10 秒，为 CorelDRAW VBA 机制限制）。项目计划与状态见仓库内 [PLAN.md](PLAN.md)，变更记录见 [CHANGELOG.md](CHANGELOG.md)。

## 技术栈

- CorelDRAW Graphics Suite X4（32 位；插件兼容至更新版本）
- VBA 宏（GMS / xslt）· Windows 安装器脚本
- 上游开源插件：corelvba、vbabox
- 许可证：MIT

## 修改记录

> 说明：修改记录仅记录文档维护变更，不计入版本更新。

| 日期 | 修改内容 |
| --- | --- |
| 2026-10-05 | README 精简为项目介绍，补充 topics 标签 |
