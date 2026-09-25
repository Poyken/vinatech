# ==============================================================================
# inspect_nvl_bom.ps1 — VINATECH MES/POP BOM & STOCK INSPECTOR
# Author: vanduc (EA Team)
# ==============================================================================

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Target
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir 'db_shared.ps1')

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$conn = Get-DbConnection -Profile 'SmartFactoryV2' -Silent
if ($null -eq $conn) {
    Write-Host "LOI: Khong the ket noi CSDL SmartFactoryV2!" -ForegroundColor Red
    exit 1
}

$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SET NOCOUNT ON;
DECLARE @In VARCHAR(50) = '$($Target.Replace("'", "''"))';
DECLARE @PONo VARCHAR(30) = NULL;
DECLARE @RouteCode VARCHAR(20) = NULL;
DECLARE @Model VARCHAR(50) = NULL;

IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @In OR Barcode = @In)
BEGIN
    SELECT TOP 1 @PONo = PONo, @Model = MaterialCode FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @In OR Barcode = @In;
    SELECT TOP 1 @RouteCode = RouteCode FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) WHERE Barcode = @In;
END
ELSE IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = @In)
BEGIN
    SELECT TOP 1 @PONo = PONo, @Model = MaterialCode FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = @In;
END
ELSE
BEGIN
    SET @PONo = @In;
END

SELECT 
    B.RouteCode, 
    B.ChildMaterialCode, 
    ISNULL(MM.MaterialName, '') AS MaterialName, 
    B.UsedQty, 
    ISNULL(MM.DelegateMaterialCode, '-') AS AltCode1, 
    ISNULL(MM.DelegateMaterialCode2, '-') AS AltCode2
INTO #BOM
FROM SmartFactoryV2.dbo.STB_ProductionOrderBom B WITH(NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK) ON B.ChildMaterialCode = MM.MaterialCode
WHERE B.PONo = @PONo AND (@RouteCode IS NULL OR B.RouteCode = @RouteCode OR B.RouteCode = '' OR B.RouteCode IS NULL);

-- 1. Ton kho chuyen ROUTE_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS RouteStockQty
INTO #STOCK_ROUTE
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROUTE_VN_WH' 
  AND MaterialCode IN (SELECT ChildMaterialCode FROM #BOM)
  AND CurrentQty > 0
GROUP BY MaterialCode;

-- 2. Ton kho tong MAIN_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS MainStockQty
INTO #STOCK_MAIN
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'MAIN_VN_WH' 
  AND MaterialCode IN (SELECT ChildMaterialCode FROM #BOM)
  AND CurrentQty > 0
GROUP BY MaterialCode;

-- 3. Ton kho AltCode tai ROUTE_VN_WH
SELECT MaterialCode, SUM(CurrentQty) AS AltStockQty
INTO #STOCK_ALT
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROUTE_VN_WH' 
  AND MaterialCode IN (SELECT AltCode1 FROM #BOM WHERE AltCode1 <> '-' UNION SELECT AltCode2 FROM #BOM WHERE AltCode2 <> '-')
  AND CurrentQty > 0
GROUP BY MaterialCode;

SELECT 
    b.RouteCode, 
    b.ChildMaterialCode, 
    b.MaterialName, 
    b.UsedQty, 
    b.AltCode1, 
    b.AltCode2,
    ISNULL(sr.RouteStockQty, 0) AS RouteStockQty,
    ISNULL(sm.MainStockQty, 0) AS MainStockQty,
    ISNULL(sa.AltStockQty, 0) AS AltStockQty
FROM #BOM b
LEFT JOIN #STOCK_ROUTE sr ON b.ChildMaterialCode = sr.MaterialCode
LEFT JOIN #STOCK_MAIN sm ON b.ChildMaterialCode = sm.MaterialCode
LEFT JOIN #STOCK_ALT sa ON b.AltCode1 = sa.MaterialCode
ORDER BY b.RouteCode, b.ChildMaterialCode;
"@

$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$dt = New-Object System.Data.DataTable
$da.Fill($dt) | Out-Null
$conn.Close()
$sw.Stop()

Write-Host ''
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " [BOM & TON KHO] TRA CUU DINH MUC & KHA DUNG CHO: '$Target'" -ForegroundColor Yellow
Write-Host " Thoi gian truy van: $($sw.ElapsedMilliseconds) ms | So luong NVL: $($dt.Rows.Count)" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan

if ($dt.Rows.Count -eq 0) {
    Write-Host "[-] Khong tim thay ban ghi BOM phu hop cho: $Target" -ForegroundColor Yellow
    exit 0
}

Write-Host ''
Write-Host ">>> DANH MUC NVL BOM & TON KHO KHO CHUYEN (ROUTE_VN_WH):" -ForegroundColor Magenta
foreach ($row in $dt.Rows) {
    $rt = $row['RouteCode']
    $code = $row['ChildMaterialCode']
    $name = $row['MaterialName']
    $qty = $row['UsedQty']
    $alt1 = $row['AltCode1']
    $alt2 = $row['AltCode2']
    $routeStock = [double]$row['RouteStockQty']
    $mainStock = [double]$row['MainStockQty']
    $altStock = [double]$row['AltStockQty']

    $stockStr = if ($routeStock -eq 0) { "[HET HANG (0)]" } else { "$routeStock" }
    $stockColor = if ($routeStock -eq 0) { "Red" } else { "Green" }

    Write-Host "   [$rt] " -NoNewline -ForegroundColor DarkCyan
    Write-Host "$code " -NoNewline -ForegroundColor Yellow
    Write-Host "($name) " -NoNewline -ForegroundColor White
    Write-Host "Dinh muc: $qty " -NoNewline -ForegroundColor Gray
    Write-Host "| Ton ROUTE: " -NoNewline -ForegroundColor Gray
    Write-Host "$stockStr " -NoNewline -ForegroundColor $stockColor

    if ($routeStock -eq 0) {
        if ($mainStock -gt 0) {
            Write-Host "| Kho tong MAIN: $mainStock (Can F430) " -NoNewline -ForegroundColor Cyan
        } else {
            Write-Host "| Kho tong MAIN: 0 " -NoNewline -ForegroundColor DarkGray
        }
    }

    if ($alt1 -ne '-' -or $alt2 -ne '-') {
        Write-Host "| Alt: $alt1" -NoNewline -ForegroundColor DarkYellow
        if ($altStock -gt 0) {
            Write-Host " [Alt ROUTE con: $altStock]" -ForegroundColor Green
        } else {
            Write-Host ""
        }
    } else {
        Write-Host ""
    }

    if ($routeStock -eq 0 -and $altStock -gt 0) {
        Write-Host "      --> [GIAI PHAP OP]: Ma $code het ton kho, nhung ma thay the '$alt1' DANG CO SAN $altStock tai ROUTE_VN_WH. Quet ma '$alt1' de chay tiep!" -ForegroundColor Yellow
    }
}
Write-Host ''
