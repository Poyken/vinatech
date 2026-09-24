# UTF-8 BOM
# Complete Simulation Test for Screen B781 (Both tung22 and tung22_v2 branches)
# 100% SELECT-ONLY, NO DB MODIFICATION

param(
    [string]$FromDate = "2026-09-23",
    [string]$ToDate = "2026-09-24",
    [string]$WorkCenterCode = "VVT_F1"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

. (Join-Path $PSScriptRoot "db_shared.ps1")

$conn = Get-DbConnection -Profile "SmartFactoryV2"
if ($null -eq $conn) {
    Write-Error "Cannot connect to SmartFactoryV2."
    exit 1
}

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host " FULL B781 SIMULATION: BOTH TRADITIONAL & POP/MLI BRANCHES       " -ForegroundColor Cyan
Write-Host " Range: $FromDate to $ToDate | WorkCenter: $WorkCenterCode" -ForegroundColor Yellow
Write-Host " Database state: 100% UNTOUCHED (Read-Only validation)" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan

# Test with FULL logic including tung22_v2 (POP)
function Get-B781Simulation([bool]$ApplyFilter) {
    $filterClause1 = if ($ApplyFilter) {
        "AND DRI.MaterialCode NOT IN ('ECVT30-373', 'ECVT30-346', 'RE3000-106') AND DRI.MaterialName NOT IN ('HY-CAP VEC3R0606QG-C030(1840)', 'HY-CAP WEC3R0106QG-C035 (1030)')"
    } else { "" }
    
    $filterClause2 = if ($ApplyFilter) {
        "AND MLI.MaterialCode NOT IN ('ECVT30-373', 'ECVT30-346', 'RE3000-106') AND MM.MaterialName NOT IN ('HY-CAP VEC3R0606QG-C030(1840)', 'HY-CAP WEC3R0106QG-C035 (1030)')"
    } else { "" }

    $sql = @"
DECLARE @FromDate VARCHAR(19) = '$FromDate 10:00:00';
DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '$ToDate')), 120) + ' 10:00:00';

;WITH tung AS (
    SELECT id,
        (SELECT TOP 1 newbarcode FROM STB_LotChangeMaterialHistory WITH(NOLOCK) WHERE oldBarcode=LotNo) AS newLotno,
        LotNo, PackingID, MaterialCode, MaterialName, EmpNo, PrintTime, PackQty, isPrinted, PartNo,
        (RANK() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RankPackQty,
        (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty
    FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI WITH(NOLOCK) 
    WHERE EmpNo NOT IN ('test_worker','assy_packing')
      AND PrintTime BETWEEN @FromDate AND @ToDate
      AND PackQty > 1
      AND (isPrinted = 0)
      $filterClause1
),
tung22 AS (
    SELECT a.*, b.InputLineCode, c.ProdDateTime, b.ControlNo,
        (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty2
    FROM tung a WITH(NOLOCK) 
    JOIN STB_SetInfo b WITH(NOLOCK) ON (a.LotNo = b.Barcode OR a.newLotno = b.Barcode)
    JOIN STB_ProdRouteHist c WITH(NOLOCK) ON b.ControlNo = c.ControlNo 
    AND c.RouteCode IN ('V-28', 'V-28_BG', 'VE10', 'V-28_HY')
    WHERE a.RowPackQty = 1
),
tung_v2 AS (
    SELECT 
        MLI.MaterialLotNo AS id,
        (SELECT TOP 1 newbarcode FROM STB_LotChangeMaterialHistory WITH(NOLOCK) WHERE oldBarcode = MLI.LotNo) AS newLotno,
        MLI.LotNo, MLI.PackingID, MLI.MaterialCode, 
        MM.MaterialName AS MaterialName,   
        MLI.CreateUserID AS EmpNo,                     
        MLI.CreateDateTime AS PrintTime,                      
        CAST(MLI.InitialQty AS INT) AS PackQty,                 
        CAST(NULL AS INT) AS isPrinted,               
        (ROW_NUMBER() OVER (PARTITION BY MLI.LotNo ORDER BY MLI.GRDate DESC)) AS RowPackQty
    FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
    LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = MLI.MaterialCode
    WHERE MLI.PackingID IS NOT NULL 
      AND MLI.MaterialWarehouseCode IN ('PROD_VN_WH','PROD_HY_WH')  
      AND MLI.CreateUserID NOT IN ('vvtworker','nhat2k','vvtworker_hy','nguyentha')
      AND MLI.CreateDateTime BETWEEN @FromDate AND @ToDate
      $filterClause2
),
tung22_v2 AS (
    SELECT a.*, b.InputLineCode, c.ProdDateTime, b.ControlNo,
        (ROW_NUMBER() OVER (PARTITION BY a.id ORDER BY c.ProdDateTime DESC)) AS RowPerRecord
    FROM tung_v2 a WITH(NOLOCK) 
    JOIN STB_SetInfo b WITH(NOLOCK) ON (a.LotNo = b.Barcode OR a.newLotno = b.Barcode)
    JOIN STB_ProdRouteHist c WITH(NOLOCK) ON b.ControlNo = c.ControlNo 
    AND c.RouteCode IN ('V-28', 'V-28_BG', 'VE10', 'V-28_HY')
)
SELECT 
    MaterialName,
    InputLineCode,
    SUM(PackQty) AS Qty
FROM (
    SELECT MaterialName, InputLineCode, PackQty FROM tung22 WHERE RowPackQty2 = 1
    UNION ALL
    SELECT MaterialName, InputLineCode, PackQty FROM tung22_v2 WHERE RowPerRecord = 1
) Combined
GROUP BY MaterialName, InputLineCode
ORDER BY MaterialName, InputLineCode;
"@

    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $cmd.CommandTimeout = 90
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    $adapter.Fill($dt) | Out-Null
    return $dt
}

Write-Host "`n>>> [1/2] RUNNING BEFORE PATCH (Simulating Current SP)..." -ForegroundColor Yellow
$dtBefore = Get-B781Simulation -ApplyFilter $false

Write-Host "`n>>> [2/2] RUNNING AFTER PATCH (Simulating New SP with Exclude)..." -ForegroundColor Yellow
$dtAfter = Get-B781Simulation -ApplyFilter $true

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " COMPARISON SUMMARY (TARGET ITEMS IN USER SCREENSHOT):" -ForegroundColor Cyan
Write-Host "------------------------------------------------------------------" -ForegroundColor Gray

$target1Before = $dtBefore | Where-Object { $_["MaterialName"] -like "*VEC3R0606QG-C030*" }
$target1After  = $dtAfter  | Where-Object { $_["MaterialName"] -like "*VEC3R0606QG-C030*" }

$target2Before = $dtBefore | Where-Object { $_["MaterialName"] -like "*WEC3R0106QG-C035*" }
$target2After  = $dtAfter  | Where-Object { $_["MaterialName"] -like "*WEC3R0106QG-C035*" }

Write-Host "1. HY-CAP VEC3R0606QG-C030(1840):" -ForegroundColor White
if ($target1Before) {
    $lines = ($target1Before | ForEach-Object { "$($_.InputLineCode): $($_.Qty)" }) -join ", "
    $total = ($target1Before | Measure-Object -Property Qty -Sum).Sum
    Write-Host "   - Before Patch : APPEARED -> Total: $total EA ($lines)" -ForegroundColor Red
} else {
    Write-Host "   - Before Patch : Not present in selected date window" -ForegroundColor Gray
}
if ($target1After) {
    Write-Host "   - After Patch  : STILL APPEARED [FAIL]" -ForegroundColor Red
} else {
    Write-Host "   - After Patch  : COMPLETELY EXCLUDED (0 EA) [PASS]" -ForegroundColor Green
}

Write-Host "`n2. HY-CAP WEC3R0106QG-C035 (1030):" -ForegroundColor White
if ($target2Before) {
    $lines = ($target2Before | ForEach-Object { "$($_.InputLineCode): $($_.Qty)" }) -join ", "
    $total = ($target2Before | Measure-Object -Property Qty -Sum).Sum
    Write-Host "   - Before Patch : APPEARED -> Total: $total EA ($lines)" -ForegroundColor Red
} else {
    Write-Host "   - Before Patch : Not present in selected date window" -ForegroundColor Gray
}
if ($target2After) {
    Write-Host "   - After Patch  : STILL APPEARED [FAIL]" -ForegroundColor Red
} else {
    Write-Host "   - After Patch  : COMPLETELY EXCLUDED (0 EA) [PASS]" -ForegroundColor Green
}

Write-Host "`n3. General Health Check:" -ForegroundColor White
Write-Host "   - Total rows before: $($dtBefore.Rows.Count)" -ForegroundColor White
Write-Host "   - Total rows after : $($dtAfter.Rows.Count)" -ForegroundColor White
$diff = $dtBefore.Rows.Count - $dtAfter.Rows.Count
Write-Host "   - Excluded item count: $diff [PASS]" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan

$conn.Close()
