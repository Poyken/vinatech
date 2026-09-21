# ==============================================================================
# audit_l1_cache.ps1 — VINATECH MES L1 CACHE & LIVE DB AUDITOR
# ==============================================================================
# Kiểm toán độ tin cậy tuyệt đối giữa L1 Cache (QUICK_MATRIX.json) và Live DB.
# Quét 100% Stored Procedures và Tables để đảm bảo không có SP/Table nào bị "ảo".
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$scriptDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $scriptDir "mes.ps1"))) {
    $scriptDir = $PSScriptRoot
}
$toolsDir = Join-Path $scriptDir "tools"
. (Join-Path $toolsDir "db_shared.ps1")

$matrixFile = Join-Path $scriptDir "AI_AGENT_CONFIG\QUICK_MATRIX.json"
if (-not (Test-Path $matrixFile)) {
    Write-Host "Loi: Khong tim thay file $matrixFile!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "       VINATECH MES L1 CACHE & PRODUCTION DB AUDITOR (v1.0)           " -ForegroundColor Yellow
Write-Host "    Kiem toan 100% Stored Procedures & Tables giua L1 va Live CSDL    " -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan

# 1. Nap L1 Cache
Write-Host "(*) Dang doc L1 Cache Matrix..." -ForegroundColor Cyan
$matrix = Get-Content -Path $matrixFile -Encoding UTF8 -Raw | ConvertFrom-Json
$screens = $matrix.screens

$allSps = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$allTables = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$screenCount = 0

foreach ($prop in $screens.PSObject.Properties) {
    $screenCount++
    $sc = $prop.Value
    if ($sc.sp_get -and $sc.sp_get -ne "N/A" -and $sc.sp_get -ne "") {
        [void]$allSps.Add($sc.sp_get.Trim())
    }
    if ($sc.sp_iud -and $sc.sp_iud -ne "N/A" -and $sc.sp_iud -ne "") {
        [void]$allSps.Add($sc.sp_iud.Trim())
    }
    if ($sc.tables) {
        foreach ($t in $sc.tables) {
            if ($t -and $t -ne "") {
                [void]$allTables.Add($t.Trim())
            }
        }
    }
}

Write-Host "  -> Tong so man hinh trong L1  : $screenCount" -ForegroundColor Green
Write-Host "  -> Tong so Stored Procedures  : $($allSps.Count)" -ForegroundColor Green
Write-Host "  -> Tong so Tables tham chieu  : $($allTables.Count)" -ForegroundColor Green

# 2. Ket noi Live DB lay danh muc Objects thuc te
Write-Host ""
Write-Host "(*) Dang ket noi Live DB (SmartFactoryV2 & SmartFramework) de doi chieu..." -ForegroundColor Cyan

$conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if ($conn -eq $null) {
    Write-Host "Loi: Khong the ket noi toi CSDL Production de kiem toan!" -ForegroundColor Red
    exit 1
}

$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SET NOCOUNT ON;
SELECT DISTINCT name, 'SP' AS ObjType FROM SmartFactoryV2.sys.objects WITH(NOLOCK) WHERE type = 'P'
UNION ALL
SELECT DISTINCT name, 'TABLE' AS ObjType FROM SmartFactoryV2.sys.objects WITH(NOLOCK) WHERE type IN ('U', 'V')
UNION ALL
SELECT DISTINCT name, 'SP' AS ObjType FROM SmartFramework.sys.objects WITH(NOLOCK) WHERE type = 'P'
UNION ALL
SELECT DISTINCT name, 'TABLE' AS ObjType FROM SmartFramework.sys.objects WITH(NOLOCK) WHERE type IN ('U', 'V');
"@

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null
$conn.Close()

$dbSps = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$dbTables = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($row in $dt.Rows) {
    if ($row["ObjType"] -eq "SP") {
        [void]$dbSps.Add([string]$row["name"])
    } else {
        [void]$dbTables.Add([string]$row["name"])
    }
}

Write-Host "  -> Tim thay trong Live DB     : $($dbSps.Count) SPs, $($dbTables.Count) Tables/Views." -ForegroundColor Gray

# 3. Kiem toan SP
$spPass = 0
$spMissing = @()
foreach ($sp in $allSps) {
    if ($dbSps.Contains($sp)) {
        $spPass++
    } else {
        $spMissing += $sp
    }
}

# 4. Kiem toan Tables
$tblPass = 0
$tblMissing = @()
foreach ($tbl in $allTables) {
    if ($dbTables.Contains($tbl)) {
        $tblPass++
    } else {
        $tblMissing += $tbl
    }
}

$spRate = if ($allSps.Count -gt 0) { [math]::Round(($spPass / $allSps.Count) * 100, 1) } else { 100 }
$tblRate = if ($allTables.Count -gt 0) { [math]::Round(($tblPass / $allTables.Count) * 100, 1) } else { 100 }
$overallRate = [math]::Round(($spRate + $tblRate) / 2, 1)

# 5. Xuat ket qua
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                    KET QUA KIEM TOAN DO TIN CAY                     " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "  STORED PROCEDURES : $spPass / $($allSps.Count) HOP LE ($spRate%)" -ForegroundColor $(if ($spRate -ge 95) { 'Green' } else { 'Yellow' })
if ($spMissing.Count -gt 0) {
    Write-Host "  -> Danh sach SP khong tim thay trong CSDL ($($spMissing.Count)):" -ForegroundColor Yellow
    foreach ($m in $spMissing) {
        Write-Host "     - $m" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "  DATABASE TABLES   : $tblPass / $($allTables.Count) HOP LE ($tblRate%)" -ForegroundColor $(if ($tblRate -ge 95) { 'Green' } else { 'Yellow' })
if ($tblMissing.Count -gt 0) {
    Write-Host "  -> Danh sach Tables khong tim thay trong CSDL ($($tblMissing.Count)):" -ForegroundColor Yellow
    foreach ($t in $tblMissing) {
        Write-Host "     - $t" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host "  DO TIN CAY TONG THE (L1 RELIABILITY SCORE): $overallRate%" -ForegroundColor $(if ($overallRate -ge 95) { 'Green' } else { 'Yellow' })
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""
