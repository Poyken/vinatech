# ==============================================================================
# pop_readiness.ps1 — KIỂM TOÁN MỨC ĐỘ SẴN SÀNG CHUYỂN ĐỔI 100% POP WEB
# ==============================================================================
# Phân tích theo Checklist 8 bước tại POP_KB_06_MIGRATION_SPEC.md:
# 1. Chế độ nạp nhóm (VINA_ASSEMBLY_GROUP_MODE)
# 2. Định mức Slot nạp NVL (VINA_GROUP_INPUT_ROUTE)
# 3. Chế độ chốt sản lượng Line (VINA_LINE_PROD_MODE: SUBTRACT vs ADD)
# 4. Kiểm tra thiết bị kẹt khóa mồ côi (VINA_EQUIPMENT_MAPPING ACTIVE)
# 5. Kiểm tra nghẽn pipeline đồng bộ (MongoToMesPerformance IsTransferred=0)
# ==============================================================================

param(
    [string]$Line = '',
    [switch]$Detail
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$scriptDir = $PSScriptRoot
. (Join-Path $scriptDir 'db_shared.ps1')

Write-Host ''
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host '     VINATECH MES ➔ POP FULL CUTOVER READINESS AUDIT' -ForegroundColor Yellow
Write-Host '     Kiem Toan Muc Do San Sang Cat WinForm & Chay 100% POP Web' -ForegroundColor White
Write-Host '======================================================================' -ForegroundColor Cyan
Write-Host ''

$connPop = Get-DbConnection -Profile 'POP' -Silent
$connMes = Get-DbConnection -Profile 'SmartFactoryV2' -Silent

if ($connPop -eq $null -or $connMes -eq $null) {
    Write-Host '[ERROR] Khong the ket noi CSDL VINATECH_POP hoac SmartFactoryV2.' -ForegroundColor Red
    exit 1
}

# 1. Quét tổng quan các Line hoặc 1 Line cụ thể
$lineFilter = ""
if ($Line) {
    $lineUpper = $Line.ToUpper()
    $lineFilter = "WHERE g.LINE_CODE = '$lineUpper'"
    Write-Host "(*) Dang phan tich chuyen sau cho Line: $lineUpper..." -ForegroundColor Cyan
} else {
    Write-Host '(*) Dang quet toan bo 31 day chuyen san xuat Cell & Module...' -ForegroundColor Cyan
}

$queryOverview = @"
SELECT 
    g.LINE_CODE,
    ISNULL(g.INPUT_MODE, 'CHUA_CAU_HINH') AS INPUT_MODE,
    ISNULL(p.PROD_MODE, 'THIEU') AS PROD_MODE,
    COUNT(r.SLOT_CODE) AS TotalSlots,
    SUM(CASE WHEN r.ROUTE_CODE LIKE 'V-22%' THEN 1 ELSE 0 END) AS WindingSlots,
    SUM(CASE WHEN r.ROUTE_CODE LIKE 'V-24%' THEN 1 ELSE 0 END) AS AssemblySlots,
    SUM(CASE WHEN r.ROUTE_CODE LIKE 'V-25%' THEN 1 ELSE 0 END) AS SleevingSlots
FROM VINATECH_POP.dbo.VINA_ASSEMBLY_GROUP_MODE g WITH(NOLOCK)
LEFT JOIN VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE r WITH(NOLOCK) ON r.LINE_CODE = g.LINE_CODE
LEFT JOIN (
    SELECT DISTINCT LINE_CODE, PROD_MODE 
    FROM VINATECH_POP.dbo.VINA_LINE_PROD_MODE WITH(NOLOCK)
) p ON p.LINE_CODE = g.LINE_CODE
$lineFilter
GROUP BY g.LINE_CODE, g.INPUT_MODE, p.PROD_MODE
ORDER BY g.LINE_CODE
"@

$cmd = $connPop.CreateCommand()
$cmd.CommandText = $queryOverview
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$adapter.Fill($dt) | Out-Null

# 2. Lấy danh sách máy kẹt ACTIVE theo Line
$qOrphan = "SELECT LINE_CODE, COUNT(*) AS OrphanCount FROM VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING WITH(NOLOCK) WHERE MAPPING_STATUS IN ('ACTIVE', 'AUTO_MAPPED') GROUP BY LINE_CODE"
$cmdOrphan = $connPop.CreateCommand()
$cmdOrphan.CommandText = $qOrphan
$dtOrphan = New-Object System.Data.DataTable
(New-Object System.Data.SqlClient.SqlDataAdapter($cmdOrphan)).Fill($dtOrphan) | Out-Null
$orphanHash = @{}
foreach ($row in $dtOrphan.Rows) { $orphanHash[$row["LINE_CODE"]] = [int]$row["OrphanCount"] }

# 3. Lấy danh sách nghẽn sync (IsTransferred = 0)
$qPending = "SELECT LineCode, COUNT(*) AS PendingCount FROM MongoToMesPerformance WITH(NOLOCK) WHERE IsDone = 1 AND IsTransferred = 0 GROUP BY LineCode"
$cmdPending = $connMes.CreateCommand()
$cmdPending.CommandText = $qPending
$dtPending = New-Object System.Data.DataTable
(New-Object System.Data.SqlClient.SqlDataAdapter($cmdPending)).Fill($dtPending) | Out-Null
$pendingHash = @{}
foreach ($row in $dtPending.Rows) { $pendingHash[$row["LineCode"]] = [int]$row["PendingCount"] }

# 4. Hiển thị bảng đánh giá mức độ sẵn sàng
Write-Host ''
$format = "{0,-10} | {1,-10} | {2,-9} | {3,-5} (W:{4} A:{5} S:{6}) | {7,-7} | {8,-7} | {9,-15}"
Write-Host ([string]::Format($format, "Line Code", "Input Mode", "Prod Mode", "Slots", "22", "24", "25", "May Ket", "Sync Ket", "Trang Thai POP")) -ForegroundColor Yellow
Write-Host ('-' * 88) -ForegroundColor Gray

$passCount = 0
$warnCount = 0
$failCount = 0

foreach ($row in $dt.Rows) {
    $lCode = $row["LINE_CODE"]
    $inMode = $row["INPUT_MODE"]
    $prMode = $row["PROD_MODE"]
    $totSlots = [int]$row["TotalSlots"]
    $wSlots = [int]$row["WindingSlots"]
    $aSlots = [int]$row["AssemblySlots"]
    $sSlots = [int]$row["SleevingSlots"]

    $orphans = if ($orphanHash.ContainsKey($lCode)) { $orphanHash[$lCode] } else { 0 }
    $pendings = if ($pendingHash.ContainsKey($lCode)) { $pendingHash[$lCode] } else { 0 }

    # Đánh giá Readiness
    $status = "PASS (Ready)"
    $color = "Green"

    if ($inMode -ne 'GROUP' -or $prMode -eq 'THIEU' -or $totSlots -lt 9 -or $pendings -gt 5) {
        $status = "FAIL (Blocker)"
        $color = "Red"
        $failCount++
    }
    elseif ($totSlots -ne 10 -or $orphans -gt 0 -or $pendings -gt 0) {
        $status = "WARN (Needs Fix)"
        $color = "Yellow"
        $warnCount++
    }
    else {
        $passCount++
    }

    $lineOut = [string]::Format($format, $lCode, $inMode, $prMode, $totSlots, $wSlots, $aSlots, $sSlots, $orphans, $pendings, $status)
    Write-Host $lineOut -ForegroundColor $color
}

Write-Host ('-' * 88) -ForegroundColor Gray
Write-Host ''
Write-Host "TONG KET MUC DO SAN SANG (TOTAL READINESS):" -ForegroundColor Cyan
Write-Host "  - PASS (San sang cat WinForm 100%): $passCount line" -ForegroundColor Green
Write-Host "  - WARN (Can tinh chinh slots/giai phong may): $warnCount line" -ForegroundColor Yellow
Write-Host "  - FAIL (Thieu PROD_MODE hoac kẹt sync nghiem trong): $failCount line" -ForegroundColor Red

# 5. Nếu xem chi tiết 1 Line cụ thể
if ($Line -and $dt.Rows.Count -gt 0) {
    Write-Host ''
    Write-Host "CHI TIET 10 SLOT NAP NVL CUA LINE ${lineUpper}:" -ForegroundColor Cyan
    $qSlots = "SELECT SLOT_CODE, SLOT_NAME, ROUTE_CODE, MASTER_GROUP_CODES, IS_REQUIRED, DISPLAY_ORDER FROM VINATECH_POP.dbo.VINA_GROUP_INPUT_ROUTE WITH(NOLOCK) WHERE LINE_CODE = '$lineUpper' ORDER BY DISPLAY_ORDER"
    Execute-SqlQuery -Connection $connPop -Query $qSlots
}

$connPop.Close()
$connMes.Close()

Write-Host ''
Write-Host '-> Hoan thanh kiem toan POP Readiness.' -ForegroundColor Green
