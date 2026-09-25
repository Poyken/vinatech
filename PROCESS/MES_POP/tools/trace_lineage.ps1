<#
.SYNOPSIS
    trace_lineage.ps1 — Truy vet huyet mach du lieu lien he thong (PO/GW -> ERP/Kho -> MES -> POP KIOSK)
.DESCRIPTION
    Khao sat toan bo vong doi san xuat tu PO -> NVL -> Tien do cong doan MES -> Kiosk POP
    Tu dong chi ra nut that nghen dong chay du lieu trong 1 luot truy van duy nhat.
#>

param (
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Target
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$toolsDir = $PSScriptRoot
. (Join-Path $toolsDir "db_shared.ps1")

$t = $Target.Trim()
if ([string]::IsNullOrWhiteSpace($t)) {
    Write-Host "Loi: Vui long nhap ma Lot, ma PO hoac ma Barcode can truy vet huyet mach!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   HUYET MACH 3 TRU COT VINATECH: PO/GW -> KHO/NVL -> MES -> POP KIOSK" -ForegroundColor Yellow
Write-Host "   Ma doi tuong: $t" -ForegroundColor White
Write-Host "======================================================================" -ForegroundColor Cyan

$conn = Get-DbConnection -Profile "SmartFactoryV2" -Silent
if ($null -eq $conn) {
    Write-Host "Loi: Khong the ket noi toi CSDL SmartFactoryV2!" -ForegroundColor Red
    exit 1
}

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$cmd = $conn.CreateCommand()
$ds = New-Object System.Data.DataSet

$cmd.CommandText = @"
SET NOCOUNT ON;
DECLARE @Input VARCHAR(50) = '$t';
DECLARE @Ctrl VARCHAR(30) = NULL;
DECLARE @Bar VARCHAR(50) = NULL;
DECLARE @PO VARCHAR(50) = NULL;

-- 0. RESOLVE IDENTITY
IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Input)
BEGIN
    SELECT TOP 1 @Bar = Barcode, @Ctrl = ControlNo, @PO = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Input;
END
ELSE IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @Input)
BEGIN
    SELECT TOP 1 @Bar = Barcode, @Ctrl = ControlNo, @PO = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @Input;
END
ELSE IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) WHERE PONo = @Input)
BEGIN
    SET @PO = @Input;
    SELECT TOP 1 @Bar = Barcode, @Ctrl = ControlNo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE PONo = @Input ORDER BY CreateDateTime DESC;
END
ELSE
BEGIN
    SET @Bar = @Input;
    SET @Ctrl = @Input;
END

-- 1. KHAU PO / MASTER DATA (STB_ProductionOrderInfo)
SELECT TOP 1 PONo, MaterialCode, PlanQty, ProdFinishQty, IsFinish, BasicRoutingCode 
FROM SmartFactoryV2.dbo.STB_ProductionOrderInfo WITH(NOLOCK) 
WHERE PONo = @PO OR PONo = (SELECT TOP 1 PONo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Bar);

-- 2.1 KHAU KHO NVL BOM & TON KHO KHO CHUYEN (ROUTE_VN_WH)
SELECT 
    B.RouteCode, 
    B.ChildMaterialCode, 
    ISNULL(MM.MaterialName, '') AS MaterialName, 
    B.UsedQty, 
    ISNULL(MM.DelegateMaterialCode, '-') AS AltCode1
INTO #BOM
FROM SmartFactoryV2.dbo.STB_ProductionOrderBom B WITH(NOLOCK)
LEFT JOIN SmartFactoryV2.dbo.STB_MaterialMaster MM WITH(NOLOCK) ON B.ChildMaterialCode = MM.MaterialCode
WHERE B.PONo = @PO OR B.PONo = (SELECT TOP 1 PONo FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Bar);

SELECT MaterialCode, SUM(CurrentQty) AS StockQty
INTO #STOCK
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE MaterialWarehouseCode = 'ROUTE_VN_WH' 
  AND MaterialCode IN (SELECT ChildMaterialCode FROM #BOM)
  AND CurrentQty > 0
GROUP BY MaterialCode;

SELECT b.RouteCode, b.ChildMaterialCode, b.MaterialName, b.UsedQty, b.AltCode1, ISNULL(s.StockQty, 0) AS WhStockQty
FROM #BOM b
LEFT JOIN #STOCK s ON b.ChildMaterialCode = s.MaterialCode
ORDER BY b.RouteCode, b.ChildMaterialCode;

-- 2.2 LICH SU NVL DA NAP TREN KIOSK POP (STB_RawMaterialInputHist)
SELECT TOP 10 RawMaterialBarcode, MaterialCode, Qty, RouteCode, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_RawMaterialInputHist WITH(NOLOCK) 
WHERE Barcode = @Bar
ORDER BY CreateDateTime DESC;

-- 3. KHAU TIEN DO SAN XUAT MES (STB_SetInfo & STB_ProdRouteHist)
SELECT TOP 1 ControlNo, PONo, Barcode, MaterialCode, IsLineInput, IsProdFinish, DefectQty, CreateDateTime 
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
WHERE ControlNo = @Ctrl OR Barcode = @Bar;

SELECT TOP 10 ProdRouteHistNo, RouteCode, WorkCenterCode, ProdQty, JobDate, ProdDateTime, CompleteRoute 
FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) 
WHERE ControlNo = @Ctrl 
ORDER BY ProdRouteHistNo;

-- 4. KHAU DONG BO POP KIOSK (MongoToMesPerformance & Action Log)
SELECT TOP 5 DayPlanNo, Barcode, RouteCode, LineCode, TotalProdQty, TotalDefectQty, IsDone, IsTransferred, InsertDateTime 
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK) 
WHERE Barcode = @Bar 
ORDER BY InsertDateTime DESC;
"@

$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
$adapter.Fill($ds) | Out-Null
$conn.Close()
$sw.Stop()

# HIEN THI KET QUA HUYET MACH
function Out-Block($title, $table, $color="White") {
    Write-Host ""
    Write-Host ">>> $title ($($table.Rows.Count) ban ghi):" -ForegroundColor $color
    if ($table.Rows.Count -gt 0) {
        $table | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Host $_.TrimEnd() -ForegroundColor $color }
    } else {
        Write-Host "    (Khong co du lieu)" -ForegroundColor DarkGray
    }
}

Out-Block "1. LENH SAN XUAT / PO MASTER DATA" $ds.Tables[0] "Yellow"
Out-Block "2.1 DINH MUC BOM & TON KHO KHO CHUYEN (ROUTE_VN_WH)" $ds.Tables[1] "Cyan"
Out-Block "2.2 LICH SU NVL DA NAP TREN KIOSK POP (STB_RawMaterialInputHist)" $ds.Tables[2] "Cyan"
Out-Block "3.1 KHOI TAO TUYEN MES (STB_SetInfo)" $ds.Tables[3] "Green"
Out-Block "3.2 CAC CONG DOAN DA CHOT TREN MES" $ds.Tables[4] "Green"
Out-Block "4. DONG BO KIOSK POP (MongoToMesPerformance)" $ds.Tables[5] "Magenta"

# PHAN TICH TU DONG NUT THAT DONG CHAY
Write-Host ""
Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "[!] CHAN DOAN NUT THAT HUYET MACH (AUTOMATED BOTTLENECK ANALYSIS):" -ForegroundColor Yellow

$poTable = $ds.Tables[0]
$bomTable = $ds.Tables[1]
$rawHistTable = $ds.Tables[2]
$setTable = $ds.Tables[3]
$routeTable = $ds.Tables[4]
$popTable = $ds.Tables[5]

# 1. Kiem tra thieu hang kho trung chuyen xuong
if ($bomTable -ne $null -and $bomTable.Rows.Count -gt 0) {
    $outOfStock = @($bomTable.Rows | Where-Object { [double]$_["WhStockQty"] -eq 0 })
    if ($outOfStock.Count -gt 0) {
        $codes = ($outOfStock | ForEach-Object { $_["ChildMaterialCode"] }) -join ', '
        Write-Host "[-] CANH BAO KHO CHUYEN XUONG: Co $($outOfStock.Count) vat tu BOM het ton kho tai ROUTE_VN_WH: $codes" -ForegroundColor Red
        Write-Host "    -> Khac phuc: Thu kho can xuat chuyen kho F430 tu MAIN_VN_WH sang ROUTE_VN_WH hoac dung ma AltCode." -ForegroundColor Gray
    }
}

if ($rawHistTable -ne $null -and $rawHistTable.Rows.Count -gt 0) {
    Write-Host "[+] KIOSK POP: Da nap thanh cong $($rawHistTable.Rows.Count) vat tu tai xuyen suot ca truc." -ForegroundColor Green
}

if ($setTable -eq $null -or $setTable.Rows.Count -eq 0) {
    Write-Host "[-] DUT GAY TAI DAU VAO: Ma $t chua tung duoc dua vao tuyen MES (STB_SetInfo trong)." -ForegroundColor Red
} elseif ($setTable.Rows[0]["IsLineInput"] -eq $false) {
    Write-Host "[-] DUT GAY TAI CONG DOAN DAU: Lot da tao nhung chua scan vao tuyen (IsLineInput = 0)." -ForegroundColor Yellow
    Write-Host "    -> Khac phuc: Quet cong doan dau hoac IT kich hoat IsLineInput=1." -ForegroundColor Gray
} elseif ($popTable -ne $null -and $popTable.Rows.Count -gt 0 -and $popTable.Rows[0]["IsDone"] -eq $true -and $popTable.Rows[0]["IsTransferred"] -eq $false) {
    Write-Host "[-] NGHEN TAI DONG BO POP <-> MES: Chuyen POP da chot hoan thanh nhung chua chuyen giao sang MES (IsTransferred = 0)." -ForegroundColor Yellow
    Write-Host "    -> Khac phuc: Cho worker sync hoac kiem tra dich vu POP Sync Scheduler." -ForegroundColor Gray
} elseif ($routeTable -ne $null -and $routeTable.Rows.Count -gt 0 -and ($routeTable.Rows | Select-Object -Last 1)["CompleteRoute"] -eq [DBNull]::Value) {
    $lastRoute = ($routeTable.Rows | Select-Object -Last 1)["RouteCode"]
    Write-Host "[*] LOT DANG DO DANG TAI CONG DOAN: $lastRoute (Chua hoan thanh luot chot CompleteRoute)." -ForegroundColor Green
} else {
    Write-Host "[OK] DONG CHAY BINH THUONG: Du lieu thong suot giua PO, MES va Kiosk POP." -ForegroundColor Green
}

Write-Host "----------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "-> Thoi gian truy vet huyet mach: $($sw.ElapsedMilliseconds) ms" -ForegroundColor Gray
Write-Host "======================================================================" -ForegroundColor Cyan
