# ============================================================
#  cdrx4-typesetting 一键安装器
#  吊牌行业 CorelDRAW X4 排版插件（corelvba + vbabox）自动部署
#
#  用法:
#    powershell -ExecutionPolicy Bypass -File install.ps1
#    powershell -ExecutionPolicy Bypass -File install.ps1 -X4Root "D:\Corel\CorelDRAW Graphics Suite X4"
#    powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun
#
#  参数:
#    -AssetsDir 素材目录（默认脚本同目录下 assets\）
#    -X4Root    手动指定 CorelDRAW 安装根目录（跳过注册表探测）
#    -DryRun    仅检测与报告，不执行复制
#
#  退出码: 0=成功  1=素材缺失  2=未找到 X4  3=复制失败
# ============================================================
param(
    [string]$AssetsDir = "",
    [string]$X4Root = "",
    [switch]$DryRun
)
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $AssetsDir) { $AssetsDir = Join-Path $here "assets" }
$reportLines = New-Object System.Collections.Generic.List[string]
function Log($msg) { $reportLines.Add($msg); Write-Host $msg }

Log "=============================================="
Log " cdrx4-typesetting 一键安装器"
Log " 吊牌排版插件: corelvba + vbabox -> CorelDRAW X4"
Log "=============================================="

# ---------- 1. 素材校验 ----------
$requiredAssets = @(
    "LYVBA.gms",
    "Lanya_LinesTool.gms",
    "ZeroBase.gms",
    "蘭雅sRGB工具_导入CorelDRAW_X4.xslt"
)
$optionalAssets = @("ColorMark.cdr", "lycpg64.cpg", "README-LYVBA.md")
$missing = @()
foreach ($f in $requiredAssets) {
    if (-not (Test-Path (Join-Path $AssetsDir $f))) { $missing += $f }
}
if ($missing.Count -gt 0) {
    Log "[错误] 素材缺失，安装中止："
    foreach ($f in $missing) { Log "  - 缺少: $f" }
    Log ""
    Log "获取指引：GMS/xslt 为作者发布产物，源码仓库不含。请从以下渠道获取后解压放入：$AssetsDir"
    Log "  - 作者网站: https://lyvba.com/"
    Log "  - 论坛: https://bbs.lyvba.com/  （作者发布帖内含 GMS 压缩包）"
    Log "  - 华印论坛: https://www.52cnp.com/  （蘭雅CorelVBA发布帖）"
    Log "需要的文件：LYVBA.gms / Lanya_LinesTool.gms / ZeroBase.gms / 蘭雅sRGB工具_导入CorelDRAW_X4.xslt"
    $reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
    exit 1
}
Log "[OK] 必需素材齐备（$($requiredAssets.Count) 个）"
foreach ($f in $optionalAssets) {
    if (Test-Path (Join-Path $AssetsDir $f)) { Log "  - 可选素材存在: $f" }
}

# ---------- 2. 定位 CorelDRAW 安装目录 ----------
function Find-GmsDirFromRoot {
    param([string]$root)
    $current = $root
    for ($i = 0; $i -lt 4; $i++) {
        if (-not $current -or -not (Test-Path $current)) { break }
        $cand = Join-Path $current "Draw\GMS"
        if (Test-Path $cand) { return $cand }
        $current = Split-Path $current -Parent
    }
    return $null
}

$gmsDir = $null
if ($X4Root) {
    Log "[信息] 使用手动指定目录: $X4Root"
    $gmsDir = Find-GmsDirFromRoot $X4Root
    if (-not $gmsDir) { Log "[警告] 指定目录下未找到 Draw\GMS" }
}

if (-not $gmsDir) {
    $views = @("HKLM:\SOFTWARE\Corel\Setup", "HKLM:\SOFTWARE\WOW6432Node\Corel\Setup")
    $suiteNames = @(
        "CorelDRAW Graphics Suite 14",   # X4
        "CorelDRAW Graphics Suite 15",   # X5
        "CorelDRAW Graphics Suite 16",   # X6
        "CorelDRAW Graphics Suite 17",   # X7
        "CorelDRAW Graphics Suite 2018",
        "CorelDRAW Graphics Suite 2019",
        "CorelDRAW Graphics Suite 2020",
        "CorelDRAW Graphics Suite 2021",
        "CorelDRAW Graphics Suite 2022",
        "CorelDRAW Graphics Suite 2023",
        "CorelDRAW Graphics Suite 2024",
        "CorelDRAW Graphics Suite 2025",
        "CorelDRAW Graphics Suite 2026"
    )
    foreach ($view in $views) {
        foreach ($n in $suiteNames) {
            $key = Join-Path $view $n
            if (-not (Test-Path $key)) { continue }
            $dest = $null
            try { $dest = (Get-ItemProperty -Path $key -Name "Destination" -ErrorAction Stop).Destination } catch {}
            if ($dest) {
                Log "[探测] $view\$n -> $dest"
                $cand = Find-GmsDirFromRoot $dest
                if ($cand) { $gmsDir = $cand; break }
            }
        }
        if ($gmsDir) { break }
    }
}

if (-not $gmsDir) {
    Log "[错误] 未定位到 CorelDRAW 安装目录。请用 -X4Root 手动指定，例如："
    Log '  powershell -ExecutionPolicy Bypass -File install.ps1 -X4Root "C:\Program Files\Corel\CorelDRAW Graphics Suite X4"'
    $reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
    exit 2
}
Log "[OK] 目标 GMS 目录: $gmsDir"

# ---------- 3. 执行复制（DryRun 跳过） ----------
if ($DryRun) {
    Log "[DryRun] 检测完成，未执行复制。"
} else {
    if (-not (Test-Path $gmsDir)) { New-Item -ItemType Directory -Path $gmsDir -Force | Out-Null }
    $copied = @()
    try {
        foreach ($f in $requiredAssets) {
            Copy-Item -Path (Join-Path $AssetsDir $f) -Destination $gmsDir -Force
            $copied += $f
        }
        foreach ($f in $optionalAssets) {
            if (Test-Path (Join-Path $AssetsDir $f)) {
                Copy-Item -Path (Join-Path $AssetsDir $f) -Destination $gmsDir -Force
                $copied += $f
            }
        }
        if (Test-Path (Join-Path $AssetsDir "LYVBA")) {
            Copy-Item -Path (Join-Path $AssetsDir "LYVBA") -Destination $gmsDir -Recurse -Force
            $copied += "LYVBA\（目录）"
        }
    } catch {
        Log "[错误] 复制失败: $($_.Exception.Message)"
        $reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
        exit 3
    }
    Log "[OK] 已复制 $($copied.Count) 项："
    foreach ($c in $copied) { Log "  - $c" }
}

# ---------- 4. 下一步人工动作 ----------
Log ""
Log "=============================================="
Log " 下一步（人工，约 10 秒，CDR 机制限制）:"
Log "  1. 打开 CorelDRAW X4"
Log "  2. 菜单: 工具 -> 宏 -> 宏管理器，运行「蘭雅」导入宏"
Log "  3. 导入工具栏文件: 蘭雅sRGB工具_导入CorelDRAW_X4.xslt"
Log "  4. 右键工具栏区域，打开「蘭」工具栏，点击图标启动"
Log "=============================================="

$reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
Log "[完成] 报告已写入: $(Join-Path $here 'install-report.txt')"
exit 0
