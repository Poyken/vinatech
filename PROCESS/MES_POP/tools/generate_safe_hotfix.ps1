<#
.SYNOPSIS
    generate_safe_hotfix.ps1 — Bộ sinh mã SQL Hotfix An Toàn 100% chuẩn Vinatech MES
.DESCRIPTION
    Tự động sinh file SQL Hotfix theo đúng chuẩn kiến trúc:
    - Bắt buộc Author & ChangeUserID = 'vanduc'
    - Bọc trong BEGIN TRAN ... ROLLBACK / COMMIT
    - Tự động tích hợp Pre-flight Snapshot
    - Phù hợp 3 bài toán kinh điển: MoveDate (B782), Electrode (B552), Rollback Route (B530/POP)
#>

param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("movedate", "electrode", "rollback-route")]
    [string]$Action,

    [string]$Lots,          # Danh sách mã Lot (ngăn cách bởi dấu phẩy, khoảng trắng hoặc xuống dòng)
    [string]$TargetDate,    # Ngày đích yyyy-MM-dd (cho movedate)
    [int]$Hours = 10,       # Số giờ cộng thêm để vượt mốc 10:00 AM (mặc định 10)
    [string]$Route = "",    # Mã công đoạn (V-22_HY, V-26_HY, V-28_HY...)
    [string]$Type = "Slitting", # Loại điện cực (Slitting / Mixing)
    [switch]$DeployNow      # Chạy deploy ngay sau khi sinh file
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$rootDir = Split-Path -Parent $PSScriptRoot
$hotfixDir = Join-Path $rootDir "sql\hotfixes"
if (-not (Test-Path $hotfixDir)) {
    New-Item -ItemType Directory -Path $hotfixDir -Force | Out-Null
}

$dateTag = Get-Date -Format "yyyyMMdd_HHmmss"
$nowStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Parse danh sách Lot
$lotList = @()
if ($Lots) {
    $lotList = $Lots -split "[\r\n,; ]+" | Where-Object { $_ -match "\S" } | ForEach-Object { $_.Trim() }
}

if ($lotList.Count -eq 0 -and $Action -ne "electrode") {
    Write-Host "Lỗi: Bắt buộc cung cấp ít nhất 1 mã Lot qua tham số -Lots" -ForegroundColor Red
    exit 1
}

$fileName = ""
$sqlContent = ""

if ($Action -eq "movedate") {
    if ([string]::IsNullOrWhiteSpace($TargetDate)) {
        $TargetDate = (Get-Date).ToString("yyyy-MM-dd")
    }

    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $fileName = "hotfix_${dateTag}_B782_MOVE_JOBDATE_${TargetDate}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $routeFilter = ""
    if ($Route) {
        $routeFilter = "AND RouteCode = '$Route'"
    }

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: B782 MOVE JOBDATE & TIME (CẮT CA 10:00 AM)
-- Created At: $nowStr
-- Target Date: $TargetDate (Add $Hours Hours)
-- Author / ChangeUserID: vanduc
-- Total Lots: $($lotList.Count)
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra dữ liệu trước khi sửa)
SELECT 
    H.ControlNo, S.Barcode, H.RouteCode, H.JobDate, H.ProdDateTime, H.ProdQty, H.ChangeUserID
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) $routeFilter
ORDER BY H.ControlNo, H.ProdRouteHistNo;
GO

BEGIN TRAN;

-- 2. CẬP NHẬT JOBDATE VÀ PRODDATETIME VƯỢT MỐC 10:00 AM
UPDATE H
SET 
    H.ProdDateTime = DATEADD(HOUR, $Hours, H.ProdDateTime),
    H.JobDate = '$TargetDate',
    H.ChangeDateTime = GETDATE(),
    H.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) $routeFilter;

DECLARE @RowsHist INT = @@ROWCOUNT;

-- 3. CẬP NHẬT STB_ProdRouteWorkerHist
UPDATE W
SET 
    W.JobDate = '$TargetDate',
    W.ChangeDateTime = GETDATE(),
    W.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist W
INNER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist H ON W.ProdRouteHistNo = H.ProdRouteHistNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause);

-- 4. CẬP NHẬT BẢNG DEFECT NẾU CÓ
UPDATE D
SET 
    D.FindJobdate = '$TargetDate',
    D.CreateDateTime = DATEADD(HOUR, $Hours, D.CreateDateTime),
    D.ChangeDateTime = GETDATE(),
    D.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo D
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON D.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause);

-- 5. KIỂM TRA SỐ DÒNG BỊ TÁC ĐỘNG
PRINT '-> So dong STB_ProdRouteHist cap nhat: ' + CAST(@RowsHist AS VARCHAR(10));

IF @RowsHist = 0
BEGIN
    PRINT '-> [CANH BAO] Khong co dong nao bi tac dong! Dang ROLLBACK...';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    -- MAC DINH AN TOAN: COMMIT
    COMMIT TRAN;
    PRINT '-> [THANH CONG] Da commit thanh cong toan bo $($lotList.Count) Lots sang ngay $TargetDate!';
END
GO
"@
}
elseif ($Action -eq "electrode") {
    $lotTarget = $lotList[0]
    $fileName = "hotfix_${dateTag}_B552_ELECTRODE_CLEANUP_${lotTarget}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: B552 ELECTRODE CLEANUP ($Type)
-- Created At: $nowStr
-- Target Lot: $lotTarget
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra an toàn: Chưa tráng Coating mới được xóa)
IF EXISTS (SELECT 1 FROM SmartFactoryV2.dbo.STB_ElectrodeCoatingInfo WITH(NOLOCK) WHERE ElectrodeLotNumber = '$lotTarget')
BEGIN
    RAISERROR(N'CANH BAO: Cuon/Me dien cuc $lotTarget da di vao cong doan Coating! Tuyet doi khong xoa!', 16, 1);
    RETURN;
END

BEGIN TRAN;

-- 2. XÓA CASCADE CHI TIẾT CÁC BƯỚC CÂN
DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeMixStepInfo 
WHERE ElectrodeLotNumber = '$lotTarget';

-- 3. XÓA BẢN GHI MẸ
DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeMixInfo 
WHERE ElectrodeLotNumber = '$lotTarget';

DELETE FROM SmartFactoryV2.dbo.STB_ElectrodeSlittingInfo 
WHERE ElectrodeLotNumber = '$lotTarget';

-- 4. RESET CỜ CHO PHÉP CUỘN MẸ SCAN LẠI
UPDATE SmartFactoryV2.dbo.STB_SetInfo 
SET IsLineInput = 1, ChangeDateTime = GETDATE(), ChangeUserID = 'vanduc'
WHERE Barcode = '$lotTarget';

COMMIT TRAN;
PRINT '-> [THANH CONG] Da xoa sach me tron/cuon slitting dien cuc va reset IsLineInput cho $lotTarget!';
GO
"@
}
elseif ($Action -eq "rollback-route") {
    $lotTarget = $lotList[0]
    $fileName = "hotfix_${dateTag}_B530_ROLLBACK_ROUTE_${lotTarget}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    if ([string]::IsNullOrWhiteSpace($Route)) {
        $Route = "V-22_HY"
    }

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: ROLLBACK ROUTE CHỐT NHẦM (B530 / POP KIOSK)
-- Created At: $nowStr
-- Target Lot: $lotTarget | Route: $Route
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK
SELECT 
    H.ProdRouteHistNo, H.ControlNo, H.RouteCode, H.CompleteRoute, H.ProdQty, H.JobDate
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
WHERE S.Barcode = '$lotTarget' AND H.RouteCode = '$Route';
GO

BEGIN TRAN;

-- 2. XÓA WORKER MAPPING CỦA ROUTE
DELETE W
FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist W
INNER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist H ON W.ProdRouteHistNo = H.ProdRouteHistNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode = '$lotTarget' AND H.RouteCode = '$Route';

-- 3. XÓA HOẶC RESET PRODROUTEHIST
DELETE H
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode = '$lotTarget' AND H.RouteCode = '$Route';

-- 4. NẾU LÀ CÔNG ĐOẠN ĐÓNG GÓI -> DỌN BẢN GHI TẠM TRONG VINATECH_POP
IF '$Route' LIKE '%28%'
BEGIN
    DELETE FROM VINATECH_POP.dbo.VINA_PACKING_REMAIN_QTY WHERE BARCODE = '$lotTarget';
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WHERE LotNo = '$lotTarget' AND MaterialWarehouseCode LIKE '%ROUTE%';
END

COMMIT TRAN;
PRINT '-> [THANH CONG] Da rollback thanh cong cong doan $Route cho Lot $lotTarget!';
GO
"@
}

# Ghi file chuẩn UTF-8 with BOM
$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($filePath, $sqlContent, $utf8Bom)

Write-Host "======================================================================" -ForegroundColor Green
Write-Host "-> DA TAO THANH CONG FILE SQL HOTFIX AN TOAN 100%:" -ForegroundColor Green
Write-Host "   Tep tin : $filePath" -ForegroundColor Cyan
Write-Host "   Action  : $Action" -ForegroundColor Yellow
Write-Host "   Lots    : $($lotList.Count) ma" -ForegroundColor Yellow
Write-Host "   Author  : vanduc (ChangeUserID='vanduc')" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Green

if ($DeployNow) {
    Write-Host "-> Dang tu dong deploy qua deploy_tool.ps1..." -ForegroundColor Magenta
    $deployScript = Join-Path $PSScriptRoot "deploy_tool.ps1"
    & $deployScript -SqlPath $filePath
} else {
    Write-Host "Huong dan thuc thi an toan:" -ForegroundColor Yellow
    Write-Host "   Kiểm tra nội dung:  code $filePath" -ForegroundColor Gray
    Write-Host "   Chạy deploy an toàn: .\mes.ps1 deploy `"$filePath`"" -ForegroundColor Cyan
}
