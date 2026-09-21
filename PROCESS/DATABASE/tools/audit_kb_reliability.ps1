<#
.SYNOPSIS
    audit_kb_reliability.ps1 — Automated KB Reliability & Schema Drift Auditor
.DESCRIPTION
    Kiem tra do tin cay cua toan bo tai lieu Markdown trong PROCESS\DATABASE so voi CSDL thuc te.
#>

param(
    [switch]$ExportReport = $true
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = (Resolve-Path "$PSScriptRoot\..").Path
. "$PSScriptRoot\db_shared.ps1"

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "  VINATECH DATABASE - AUTOMATED KB RELIABILITY & DRIFT AUDITOR" -ForegroundColor Yellow
Write-Host ("  Thoi gian chay: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")) -ForegroundColor Gray
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. KET NOI & THU THAP SCHEMA TU CAC CO SO DU LIEU LIVE
Write-Host "1. DANG THU THAP SCHEMA THUC TE TU CAC CSDL..." -ForegroundColor Cyan

$dbObjects = @{
    Tables = @{}
    SPs    = @{}
}

$scanProfiles = @('SmartFactoryV2', 'SmartFramework', 'Groupware', 'ERP', 'POP', 'Andon')

foreach ($pName in $scanProfiles) {
    try {
        $dbObj = Get-DBConnection -Profile $pName
        $conn = $dbObj.Connection
        $dbName = $dbObj.Database

        Write-Host ("  [OK] Dang doc metadata tu CSDL: " + $dbName.PadRight(20) + " (Profile: " + $pName + ")") -ForegroundColor Green

        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 25
        $cmd.CommandText = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WITH(NOLOCK) WHERE TABLE_TYPE IN ('BASE TABLE', 'VIEW')"
        $rdr = $cmd.ExecuteReader()
        while ($rdr.Read()) {
            $tName = $rdr.GetString(0).ToUpper()
            if (-not $dbObjects.Tables.ContainsKey($tName)) {
                $dbObjects.Tables[$tName] = @()
            }
            $dbObjects.Tables[$tName] += $dbName
        }
        $rdr.Close()

        $cmd.CommandText = "SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WITH(NOLOCK) WHERE ROUTINE_TYPE = 'PROCEDURE'"
        $rdr = $cmd.ExecuteReader()
        while ($rdr.Read()) {
            $spName = $rdr.GetString(0).ToUpper()
            if (-not $dbObjects.SPs.ContainsKey($spName)) {
                $dbObjects.SPs[$spName] = @()
            }
            $dbObjects.SPs[$spName] += $dbName
        }
        $rdr.Close()
        $conn.Close()
    } catch {
        Write-Host ("  [WARN] Khong the doc metadata tu profile " + $pName + ": " + $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host ("-> Tong so Bieu bang thuc te tim thay: " + $dbObjects.Tables.Count) -ForegroundColor Green
Write-Host ("-> Tong so Stored Procedure thuc te tim thay: " + $dbObjects.SPs.Count) -ForegroundColor Green
Write-Host ""

# 2. QUET TOAN BO TAI LIEU MARKDOWN TRONG SOURCE
Write-Host "2. DANG PHAN TICH & DOI SOAT TAI LIEU TRONG SOURCE..." -ForegroundColor Cyan

$kbDirs = @(
    (Join-Path $rootDir "DATABASE_KNOWLEDGE_BASE"),
    (Join-Path $rootDir "SYSTEM_ARCHITECTURE"),
    (Join-Path $rootDir "AI_AGENT_CONFIG"),
    (Join-Path $rootDir "docs")
)

$kbFiles = @()
foreach ($d in $kbDirs) {
    if (Test-Path $d) {
        $kbFiles += Get-ChildItem -Path $d -Filter "*.md" -Recurse -File
    }
}
$kbFiles += Get-ChildItem -Path $rootDir -Filter "*.md" -File
$kbFiles = $kbFiles | Where-Object { $_.Name -ne "KB_RELIABILITY_REPORT.md" }

$auditResults = @()
$totalEntitiesMentioned = 0
$totalEntitiesVerified = 0

foreach ($file in $kbFiles) {
    $content = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    $fullText = $content -join "`n"

    $relPath = $file.FullName.Replace($rootDir, ".").Replace("\", "/")

    # Extract Tables
    $tables = @()
    $tMatches = [regex]::Matches($fullText, '\b(?:STB|VVT|GW|DZ|POP|Andon|FI|MA|PU|VINA)_[a-zA-Z0-9_]+\b')
    foreach ($m in $tMatches) { $tables += $m.Value }
    $tables = $tables | Select-Object -Unique

    # Extract SPs
    $sps = @()
    $spMatches = [regex]::Matches($fullText, '\b(?:[uU][sS][pP]|[fF][nN])_[a-zA-Z0-9_]+\b')
    foreach ($m in $spMatches) { $sps += $m.Value }
    $sps = $sps | Select-Object -Unique

    $fileEntities = $tables.Count + $sps.Count
    if ($fileEntities -eq 0) { continue }

    $verifiedTables = @()
    $unverifiedTables = @()
    foreach ($t in $tables) {
        $tUpper = $t.ToUpper()
        if ($dbObjects.Tables.ContainsKey($tUpper)) {
            $verifiedTables += @{ Name = $t; DBs = ($dbObjects.Tables[$tUpper] -join ", ") }
        } else {
            $unverifiedTables += $t
        }
    }

    $verifiedSPs = @()
    $unverifiedSPs = @()
    foreach ($sp in $sps) {
        $spUpper = $sp.ToUpper()
        if ($dbObjects.SPs.ContainsKey($spUpper)) {
            $verifiedSPs += @{ Name = $sp; DBs = ($dbObjects.SPs[$spUpper] -join ", ") }
        } else {
            $unverifiedSPs += $sp
        }
    }

    $verifiedCount = $verifiedTables.Count + $verifiedSPs.Count
    $score = [math]::Round(($verifiedCount / $fileEntities) * 100, 1)

    $status = "HIGH"
    if ($score -lt 70) {
        $status = "LOW"
    } elseif ($score -lt 90) {
        $status = "MEDIUM"
    }

    $auditResults += [PSCustomObject]@{
        FilePath         = $relPath
        TotalTables      = $tables.Count
        VerifiedTables   = $verifiedTables.Count
        TotalSPs         = $sps.Count
        VerifiedSPs      = $verifiedSPs.Count
        ReliabilityScore = $score
        Status           = $status
        UnverifiedTables = $unverifiedTables
        UnverifiedSPs    = $unverifiedSPs
    }

    $totalEntitiesMentioned += $fileEntities
    $totalEntitiesVerified += $verifiedCount
}

# 3. HIEN THI KET QUA AUDIT
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host "                    KET QUA AUDIT DO TIN CAY TAI LIEU" -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host ('{0,-52} | {1,-7} | {2,-7} | {3,-10} | {4}' -f 'Ten File Tai Lieu', 'Tables', 'SPs', 'Do Tin Cay', 'Trang Thai') -ForegroundColor Cyan
Write-Host ('-' * 90) -ForegroundColor Gray

foreach ($res in ($auditResults | Sort-Object ReliabilityScore -Descending)) {
    $color = "Green"
    if ($res.Status -eq "LOW") { $color = "Red" }
    elseif ($res.Status -eq "MEDIUM") { $color = "Yellow" }

    $dispPath = if ($res.FilePath.Length -gt 50) { "..." + $res.FilePath.Substring($res.FilePath.Length - 47) } else { $res.FilePath }
    $tStat = "$($res.VerifiedTables)/$($res.TotalTables)"
    $spStat = "$($res.VerifiedSPs)/$($res.TotalSPs)"
    $scoreStr = "$($res.ReliabilityScore)%"

    Write-Host ('{0,-52} | {1,-7} | {2,-7} | {3,-10} | {4}' -f $dispPath, $tStat, $spStat, $scoreStr, $res.Status) -ForegroundColor $color
}

Write-Host ('-' * 90) -ForegroundColor Gray
$overallScore = if ($totalEntitiesMentioned -gt 0) { [math]::Round(($totalEntitiesVerified / $totalEntitiesMentioned) * 100, 1) } else { 100 }
Write-Host ("TONG QUAN HE THONG: " + $totalEntitiesVerified + " / " + $totalEntitiesMentioned + " doi tuong khop CSDL Live (" + $overallScore + "% Tin cay)") -ForegroundColor Green
Write-Host "================================================================================" -ForegroundColor Yellow
Write-Host ""

# 4. XUAT FILE BAO CAO MARKDOWN
if ($ExportReport) {
    $reportPath = Join-Path $rootDir "DATABASE_KNOWLEDGE_BASE\KB_RELIABILITY_REPORT.md"
    
    $lines = @(
        "# BÁO CÁO ĐỘ TIN CẬY TÀI LIỆU & SCHEMA DRIFT AUDIT",
        "",
        ("> **Cập nhật:** " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")),
        ("> **Tổng quan hệ thống:** **" + $overallScore + "%** đối tượng khớp chính xác với Live DB (" + $totalEntitiesVerified + " / " + $totalEntitiesMentioned + " đối tượng)."),
        "> **Mục đích:** Hướng dẫn AI và Kỹ sư xác định chính xác mức độ tin cậy của từng tài liệu trước khi vận hành.",
        "",
        "---",
        "",
        "## 1. Tiêu Chuẩn Phân Loại Độ Tin Cậy",
        "",
        "- **HIGH (>= 90%):** Tài liệu chuẩn xác cao, Bảng & Stored Procedure đã được verify với CSDL thực tế. **Có thể áp dụng ngay logic nghiệp vụ.**",
        "- **MEDIUM (70% - 89%):** Tài liệu có độ chính xác khá, một số SP/Bảng thuộc DB phụ hoặc có typo nhỏ. Cần kiểm tra nhẹ trước khi chạy.",
        "- **LOW (< 70%):** Tài liệu có nhiều giả định hoặc đề cập SP chưa triển khai trên Production. Bắt buộc kiểm tra kỹ CSDL.",
        "",
        "---",
        "",
        "## 2. Bảng Đánh Giá Chi Tiết Từng Tài Liệu",
        "",
        "| File Tài Liệu | Bảng Khớp | SP Khớp | Độ Tin Cậy | Phân Loại |",
        "|:---|:---:|:---:|:---:|:---:|"
    )

    foreach ($res in ($auditResults | Sort-Object ReliabilityScore -Descending)) {
        $icon = "[HIGH]"
        if ($res.Status -eq "LOW") { $icon = "[LOW]" }
        elseif ($res.Status -eq "MEDIUM") { $icon = "[MEDIUM]" }

        $tStat = "$($res.VerifiedTables)/$($res.TotalTables)"
        $spStat = "$($res.VerifiedSPs)/$($res.TotalSPs)"
        $lines += "| [$($res.FilePath)]($($res.FilePath)) | $tStat | $spStat | **$($res.ReliabilityScore)%** | $icon |"
    }

    $lines += @(
        "",
        "---",
        "",
        "## 3. Danh Sách Đối Tượng Cần Lưu Ý (Unverified / Typos / Cross-DB)",
        ""
    )

    $hasNotes = $false
    foreach ($res in $auditResults) {
        if ($res.UnverifiedTables.Count -gt 0 -or $res.UnverifiedSPs.Count -gt 0) {
            $hasNotes = $true
            $lines += "### File: $($res.FilePath)"
            if ($res.UnverifiedTables.Count -gt 0) {
                $lines += "- **Bảng chưa tìm thấy trong Live DB:** " + ($res.UnverifiedTables -join ", ")
            }
            if ($res.UnverifiedSPs.Count -gt 0) {
                $lines += "- **SP chưa tìm thấy trong Live DB:** " + ($res.UnverifiedSPs -join ", ")
            }
            $lines += ""
        }
    }

    if (-not $hasNotes) {
        $lines += "*Tất cả các đối tượng trong tài liệu đều khớp hoàn toàn với CSDL.*"
    }

    $lines += @(
        "---",
        "*Báo cáo được tạo tự động bởi công cụ audit_kb_reliability.ps1.*"
    )

    $reportContent = $lines -join [Environment]::NewLine
    $utf8WithBom = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($reportPath, $reportContent, $utf8WithBom)

    Write-Host ("-> Da xuat bao cao chi tiet tai: " + $reportPath) -ForegroundColor Green
}
