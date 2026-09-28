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
#
#  素材版本: Lanya_CorelVBA_2026_0528（2026-05-27 发布，作者蓝奏云官方分享）
#  安装方式: 新版无需导入 xslt —— 装 GMS 后在宏管理器运行 LYVBA 工程 "Start"
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
$requiredAssets = @("LYVBA.gms", "Lanya_LinesTool.gms")
$requiredDirs = @("LYVBA")
$optionalAssets = @("ColorMark.cdr", "ZeroBase.gms", "README-LYVBA.md", "蘭雅sRGB工具_导入CorelDRAW_X4.xslt")
$missing = @()
foreach ($f in $requiredAssets) {
    if (-not (Test-Path (Join-Path $AssetsDir $f))) { $missing += $f }
}
foreach ($d in $requiredDirs) {
    if (-not (Test-Path (Join-Path $AssetsDir $d))) { $missing += "$d\（目录）" }
}
if ($missing.Count -gt 0) {
    Log "[错误] 素材缺失，安装中止："
    foreach ($f in $missing) { Log "  - 缺少: $f" }
    Log ""
    Log "获取指引：请从作者官方渠道下载 Lanya_CorelVBA 压缩包，解压后放入：$AssetsDir"
    Log "  - 作者论坛: https://bbs.lyvba.com/ （蘭雅CorelVBA发布帖，内含蓝奏云链接）"
    Log "  - 作者网站: https://lyvba.com/ / 华印: https://www.52cnp.com/"
    Log "需要的文件：LYVBA.gms / Lanya_LinesTool.gms / LYVBA\ 目录"
    $reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
    exit 1
}
Log "[OK] 必需素材齐备（$($requiredAssets.Count) 文件 + $($requiredDirs.Count) 目录）"
foreach ($f in $optionalAssets) {
    if (Test-Path (Join-Path $AssetsDir $f)) { Log "  - 可选素材存在: $f" }
}

# ---------- 2. 定位 CorelDRAW 宏目录 ----------
function Find-GmsDirFromRoot {
    param([string]$root)
    $current = $root
    for ($i = 0; $i -lt 4; $i++) {
        if (-not $current -or -not (Test-Path $current)) { break }
        $cand = Join-Path $current "Draw\GMS"
        if (Test-Path $cand) { return $cand }
        $cand2 = Join-Path $current "User Draw\GMS"
        if (Test-Path $cand2) { return $cand2 }
        $current = Split-Path $current -Parent
    }
    return $null
}

$gmsDir = $null

# 2a. X4 用户宏目录（官方推荐：AppData\Roaming\Corel\CorelDRAW Graphics Suite X4\User Draw\GMS）
$userGms = Join-Path $env:APPDATA "Corel\CorelDRAW Graphics Suite X4\User Draw\GMS"
if (Test-Path $userGms) {
    Log "[OK] 发现 X4 用户宏目录: $userGms"
    $gmsDir = $userGms
}

# 2b. 手动指定
if (-not $gmsDir -and $X4Root) {
    Log "[信息] 使用手动指定目录: $X4Root"
    $gmsDir = Find-GmsDirFromRoot $X4Root
    if (-not $gmsDir) { Log "[警告] 指定目录下未找到 Draw\GMS 或 User Draw\GMS" }
}

# 2c. 注册表探测（HKLM64 + 32 位视图）
if (-not $gmsDir) {
    $views = @("HKLM:\SOFTWARE\Corel\Setup", "HKLM:\SOFTWARE\WOW6432Node\Corel\Setup")
    $suiteNames = @(
        "CorelDRAW Graphics Suite 14", "CorelDRAW Graphics Suite 15",
        "CorelDRAW Graphics Suite 16", "CorelDRAW Graphics Suite 17",
        "CorelDRAW Graphics Suite 2018", "CorelDRAW Graphics Suite 2019",
        "CorelDRAW Graphics Suite 2020", "CorelDRAW Graphics Suite 2021",
        "CorelDRAW Graphics Suite 2022", "CorelDRAW Graphics Suite 2023",
        "CorelDRAW Graphics Suite 2024", "CorelDRAW Graphics Suite 2025",
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
        foreach ($d in $requiredDirs) {
            if (Test-Path (Join-Path $AssetsDir $d)) {
                Copy-Item -Path (Join-Path $AssetsDir $d) -Destination $gmsDir -Recurse -Force
                $copied += "$d\（目录）"
            }
        }
    } catch {
        Log "[错误] 复制失败: $($_.Exception.Message)"
        $reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
        exit 3
    }
    Log "[OK] 已复制 $($copied.Count) 项："
    foreach ($c in $copied) { Log "  - $c" }
}

# ---------- 4. 下一步人工动作（新版流程，无需 xslt；X4 无"宏管理器"菜单，用"运行宏"） ----------
Log ""
Log "=============================================="
Log " 下一步（人工，约 10 秒）:"
Log "  1. 打开 CorelDRAW X4"
Log "  2. 菜单: 工具 -> 宏 -> 运行宏"
Log "  3. 宏列表选 LYVBA 工程 -> Start，点运行（打开主工具栏；X4 无'宏管理器'入口，此为等价操作）"
Log "  4. 其余功能：工具 -> 宏 -> 运行宏，选对应宏（如 Tools.尺寸标注 / LinesTool / 增强宏 ZeroBase.TagMixPacking 等）"
Log "  （若使用旧版包且含 xslt，另需: 工具->宏->运行宏导入 蘭雅sRGB工具_导入CorelDRAW_X4.xslt）"
Log "=============================================="

$reportLines | Set-Content -Path (Join-Path $here "install-report.txt") -Encoding UTF8
Log "[完成] 报告已写入: $(Join-Path $here 'install-report.txt')"
exit 0
