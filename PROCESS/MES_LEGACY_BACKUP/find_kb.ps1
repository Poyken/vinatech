# ==============================================================================
# find_kb.ps1 — 2-Tier Knowledge Base Finder for Vinatech MES Ecosystem
# Tier 1: L1 Ultra-Fast JSON Cache (<0.001s, ~200 tokens)
# Tier 2: Deep Markdown Archive (78+ files)
# ==============================================================================

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Query,
    [ValidateSet("ALL", "MES", "DB", "GW", "POP", "SYS", "CONFIG")]
    [string]$Category = "ALL",
    [int]$Limit = 15
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 1. TIER 1: KIEM TRA L1 QUICK MATRIX TRUOC
$matrixFile = Join-Path $PSScriptRoot "AI_AGENT_CONFIG\QUICK_MATRIX.json"
$foundInL1 = $false

if (Test-Path $matrixFile) {
    try {
        $matrixJson = Get-Content -Path $matrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
        $qUpper = $Query.ToUpper().Trim()

        if ($matrixJson.screens.$qUpper) {
            $sc = $matrixJson.screens.$qUpper
            Write-Host ""
            Write-Host "======================================================================" -ForegroundColor Green
            Write-Host "  [L1 CACHE HIT] MAN HINH: $qUpper - $($sc.name)" -ForegroundColor Yellow
            Write-Host "======================================================================" -ForegroundColor Green
            Write-Host "  * Module      : $($sc.module)" -ForegroundColor White
            Write-Host "  * SP Search   : $($sc.sp_get)" -ForegroundColor Cyan
            Write-Host "  * SP Process  : $($sc.sp_iud)" -ForegroundColor Cyan
            Write-Host "  * Bang CSDL   : $($sc.tables -join ', ')" -ForegroundColor Yellow
            Write-Host "  * Cac loi thuong gap:" -ForegroundColor White
            foreach ($prop in $sc.common_bugs.PSObject.Properties) {
                Write-Host "    - $($prop.Name) : $($prop.Value)" -ForegroundColor Gray
            }
            if ($sc.fix_template) {
                Write-Host "  * Hotfix Mau  : $($sc.fix_template)" -ForegroundColor Green
            }
            Write-Host "======================================================================" -ForegroundColor Green
            $foundInL1 = $true
        }
    } catch {}
}

# 2. TIER 2: QUET DEEP MARKDOWN ARCHIVE (NEU CHUA CO TRONG L1 HOAC SEARCH CHUNG)
$targetDirs = @()
switch ($Category) {
    "MES"    { $targetDirs += Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE" }
    "DB"     { $targetDirs += Join-Path $PSScriptRoot "DATABASE_KNOWLEDGE_BASE" }
    "GW"     { $targetDirs += Join-Path $PSScriptRoot "GROUPWARE_KNOWLEDGE_BASE" }
    "POP"    { $targetDirs += Join-Path $PSScriptRoot "POP_KNOWLEDGE_BASE" }
    "SYS"    { $targetDirs += Join-Path $PSScriptRoot "SYSTEM_ARCHITECTURE" }
    "CONFIG" { $targetDirs += Join-Path $PSScriptRoot "AI_AGENT_CONFIG" }
    default  {
        $targetDirs += Join-Path $PSScriptRoot "MES_MASTER_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "DATABASE_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "GROUPWARE_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "POP_KNOWLEDGE_BASE"
        $targetDirs += Join-Path $PSScriptRoot "SYSTEM_ARCHITECTURE"
        $targetDirs += Join-Path $PSScriptRoot "AI_AGENT_CONFIG"
    }
}

$files = @()
foreach ($dir in $targetDirs) {
    if (Test-Path $dir) {
        $files += Get-ChildItem -Path $dir -Filter "*.md" -Recurse
    }
}

if ($Category -eq "ALL") {
    $files += Get-ChildItem -Path $PSScriptRoot -Filter "*.md" -File
}

if (-not $foundInL1) {
    Write-Host ""
    Write-Host "(*) DANG TRA CUU TRI THUC CHO TU KHOA: '$Query' (Phan loai: $Category, Tong file quet: $($files.Count))..." -ForegroundColor Cyan
    Write-Host ""
}

$totalMatches = 0
$fileMatchDict = [ordered]@{}

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }

    $relPath = $file.FullName.Replace($PSScriptRoot, ".").Replace("\", "/")
    $lines = @()
    $lineNo = 0
    $currentHeader = ""

    foreach ($line in $content) {
        $lineNo++
        if ($line -match "^#+\s+(.+)") {
            $currentHeader = $matches[1]
        }
        if ($line -match "(?i)$([regex]::Escape($Query))") {
            $lines += [PSCustomObject]@{
                LineNo = $lineNo
                Header = $currentHeader
                Text   = $line.Trim()
            }
        }
    }

    if ($lines.Count -gt 0) {
        $fileMatchDict[$relPath] = $lines
    }
}

$shownCount = 0
foreach ($relPath in $fileMatchDict.Keys) {
    if ($shownCount -ge $Limit) { break }

    Write-Host "File: $relPath" -ForegroundColor Green
    foreach ($m in $fileMatchDict[$relPath]) {
        if ($shownCount -ge $Limit) { break }
        $hdr = if ($m.Header) { " [$($m.Header)]" } else { "" }
        $dispText = if ($m.Text.Length -gt 100) { $m.Text.Substring(0, 97) + "..." } else { $m.Text }
        Write-Host "   Line $($m.LineNo)$hdr" -ForegroundColor Yellow
        Write-Host "   -> $dispText" -ForegroundColor Gray
        $shownCount++
    }
    Write-Host ""
}

$totalMatches = ($fileMatchDict.Values | Measure-Object -Property Count -Sum).Sum
if ($totalMatches -eq 0 -and -not $foundInL1) {
    Write-Host "(-) Khong tim thay ket qua nao phu hop voi '$Query' trong $Category." -ForegroundColor Red
} elseif ($totalMatches -gt 0) {
    Write-Host "----------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Tim thay $totalMatches ket qua phu hop trong Markdown Archive. (Toi da hien thi: $Limit)" -ForegroundColor Cyan
}
