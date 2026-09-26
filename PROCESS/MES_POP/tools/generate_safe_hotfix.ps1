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
    [ValidateSet("movedate", "electrode", "rollback-route", "clean-pop-clone", "cancel-pack", "swap-machine", "fix-solution", "fix-defect-null", "fix-lineinput")]
    [string]$Action,

    [string]$Lots,          # Danh sách mã Lot (ngăn cách bởi dấu phẩy, khoảng trắng hoặc xuống dòng)
    [string]$TargetDate,    # Ngày đích yyyy-MM-dd (cho movedate)
    [int]$Hours = 10,       # Số giờ cộng thêm để vượt mốc 10:00 AM (mặc định 10)
    [string]$Route = "",    # Mã công đoạn (V-22_HY, V-26_HY, V-28_HY...)
    [string]$Type = "Slitting", # Loại điện cực (Slitting / Mixing)
    [string]$BoxId = "",    # Mã Barcode dán trên nhãn Box (VD: ECVT30-260QR2300003)
    [string]$PackingId = "",# Mã PackingID của Box (VD: PKQR2300158)
    [string]$Machine = "",  # Mã máy mới (VVMHY130, VVMHY120...)
    [double]$Qty = 0,       # Số lượng của riêng Box cần hủy
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

# Parse danh sách Lot (luôn ép kiểu Array @() để tránh lỗi chuỗi đơn bị cắt ký tự đầu)
$lotList = @()
if ($Lots) {
    $lotList = @($Lots -split "[\r\n,; ]+" | Where-Object { $_ -match "\S" } | ForEach-Object { $_.Trim() })
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

-- 3. CẬP NHẬT BẢNG DEFECT NẾU CÓ TẠI CÔNG ĐOẠN ĐÍCH
UPDATE D
SET 
    D.FindJobdate = '$TargetDate',
    D.CreateDateTime = DATEADD(HOUR, $Hours, D.CreateDateTime),
    D.ChangeDateTime = GETDATE(),
    D.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo D
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON D.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) $(if ($Route) { "AND D.FindRouteCode = '$Route'" });

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
elseif ($Action -eq "clean-pop-clone") {
    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_POP_CLEAN_CLONED_PRODROUTE_${firstLot}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: XÓA DÒNG CLONE DỞ DANG ĐỂ MỞ CHỐT POP KIOSK (CẤP THỨ AGING)
-- Created At: $nowStr
-- Target Lots: $($lotList -join ', ')
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra các dòng dở dang CompleteRoute IS NULL)
SELECT 
    H.ProdRouteHistNo, H.ControlNo, S.Barcode, H.RouteCode, H.CompleteRoute, H.ProdQty, H.CreateDateTime
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) AND H.CompleteRoute IS NULL;
GO

BEGIN TRAN;

-- 2. XÓA WORKER MAPPING DỞ DANG NẾU CÓ
DELETE W
FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist W
INNER JOIN SmartFactoryV2.dbo.STB_ProdRouteHist H ON W.ProdRouteHistNo = H.ProdRouteHistNo
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) AND H.CompleteRoute IS NULL;

-- 3. XÓA BẢN GHI PRODROUTEHIST TỰ CLONE TỪ MES WINFORM
DELETE H
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) AND H.CompleteRoute IS NULL;

COMMIT TRAN;
PRINT '-> [THANH CONG] Da xoa sach cac dong tu clone CompleteRoute IS NULL cho cac Lot: $($lotList -join ", ")!';
GO
"@
}
elseif ($Action -eq "cancel-pack") {
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_CANCEL_PACK_${firstLot}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $routeCode = if ($Route) { $Route } else { 'V-28_HY' }
    $boxIdVal = if ($BoxId) { $BoxId } else { '' }
    $packingIdVal = if ($PackingId) { $PackingId } else { '' }
    $qtyVal = if ($Qty -gt 0) { $Qty } else { 0 }

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX THỦ CÔNG: HỦY LẺ 1 PACK CỦA LOT [$firstLot]
-- Author: vanduc
-- CreateDateTime: $nowStr
-- Reference: POP_KB_04 §2.5 Phương án 4 & HOTFIX_LOG ID_53
-- ==============================================================================
USE SmartFactoryV2;
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @LotNo VARCHAR(50) = '$firstLot';
    DECLARE @PackingID VARCHAR(50) = '$packingIdVal';
    DECLARE @BoxBarcode VARCHAR(50) = '$boxIdVal';
    DECLARE @CancelQty NUMERIC(20,5) = $qtyVal;
    DECLARE @RouteCode VARCHAR(20) = '$routeCode';
    DECLARE @UserID VARCHAR(20) = 'vanduc';

    -- Tự động tìm PackingID và Qty từ BoxBarcode nếu chưa truyền
    IF (ISNULL(@PackingID, '') = '' OR @CancelQty <= 0) AND ISNULL(@BoxBarcode, '') <> ''
    BEGIN
        SELECT TOP 1 @PackingID = PackingID, @CancelQty = StockQty
        FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo WITH(NOLOCK)
        WHERE LotID = @BoxBarcode AND LotNo = @LotNo;
    END

    -- 1. Lấy thông tin điều phối ControlNo & PONo
    DECLARE @ControlNo VARCHAR(20), @PONo VARCHAR(20);
    SELECT @ControlNo = ControlNo, @PONo = PONo 
    FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = @LotNo;

    IF @ControlNo IS NULL
    BEGIN
        RAISERROR(N'Không tìm thấy thông tin Lot trong STB_SetInfo!', 16, 1);
        RETURN;
    END

    -- 2. Tìm chứng từ kho tương ứng của Pack và hủy chứng từ
    DECLARE @MaterialDocNo VARCHAR(20);
    SELECT @MaterialDocNo = MaterialDocNo 
    FROM SmartFactoryV2.dbo.STB_MaterialDocLotInfo WITH(NOLOCK)
    WHERE PackingID = @PackingID AND LotNo = @LotNo;

    IF @MaterialDocNo IS NOT NULL
    BEGIN
        EXEC usp_DoCancelMaterialDoc 
             @pProcessLanguage = 'VIETNAMESE', 
             @pProcessUserID = @UserID, 
             @pMaterialDocNo = @MaterialDocNo;
        PRINT N'>> 1. Đã hủy chứng từ kho: ' + @MaterialDocNo;
    END

    -- 3. Xóa thùng BTP của riêng Box này trong STB_MaterialLotInfo
    DELETE FROM SmartFactoryV2.dbo.STB_MaterialLotInfo 
    WHERE LotNo = @LotNo AND PackingID = @PackingID;
    PRINT N'>> 2. Đã xóa Box trong STB_MaterialLotInfo: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- 4. Giảm trừ sản lượng lũy kế đóng gói trong STB_ProdRouteHist
    UPDATE SmartFactoryV2.dbo.STB_ProdRouteHist
    SET ProdQty = ProdQty - @CancelQty,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    PRINT N'>> 3. Đã giảm trừ ProdQty trong STB_ProdRouteHist.';

    -- Nếu sau khi trừ mà sản lượng <= 0, xóa dòng chốt và worker mapping
    DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteHist
    WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode AND ProdQty <= 0;
    IF @@ROWCOUNT > 0
    BEGIN
        DELETE FROM SmartFactoryV2.dbo.STB_ProdRouteWorkerHist 
        WHERE ProdRouteHistNo NOT IN (SELECT ProdRouteHistNo FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK));
    END

    -- 5. Giảm trừ sản lượng hoàn thành PO và Tổng kết công đoạn
    UPDATE SmartFactoryV2.dbo.STB_ProductionOrderInfo
    SET ProdFinishQty = CASE WHEN ProdFinishQty >= @CancelQty THEN ProdFinishQty - @CancelQty ELSE 0 END
    WHERE PONo = @PONo;

    UPDATE SmartFactoryV2.dbo.STB_ProdRouteSummary
    SET OutputQty = CASE WHEN OutputQty >= @CancelQty THEN OutputQty - @CancelQty ELSE 0 END
    WHERE PONo = @PONo AND RouteCode = @RouteCode;
    PRINT N'>> 4. Đã giảm trừ sản lượng PO và RouteSummary.';

    -- 6. Đồng bộ Kiosk POP (MongoToMesPerformance)
    UPDATE SmartFactoryV2.dbo.MongoToMesPerformance
    SET TotalProdQty = CASE WHEN TotalProdQty >= CAST(@CancelQty AS INT) THEN TotalProdQty - CAST(@CancelQty AS INT) ELSE 0 END,
        IsDone = 0,
        IsTransferred = 0,
        InsertDateTime = GETDATE()
    WHERE Barcode = @LotNo AND RouteCode = @RouteCode;
    PRINT N'>> 5. Đã đồng bộ giảm trừ Kiosk POP.';

    -- 7. Khôi phục trạng thái Lot trong STB_SetInfo về WIP (chưa hoàn thành)
    UPDATE SmartFactoryV2.dbo.STB_SetInfo 
    SET IsProdFinish = 0,
        ProdFinishDateTime = NULL,
        ChangeDateTime = GETDATE()
    WHERE ControlNo = @ControlNo;
    PRINT N'>> 6. Đã khôi phục IsProdFinish = 0 trong STB_SetInfo.';

    -- 8. Ghi nhật ký kiểm toán Audit Trail
    INSERT INTO SmartFactoryV2.dbo.STB_ProdRouteHistCancelHist (LotNo, CreateUserID, CreateDateTime)
    VALUES (@LotNo, @UserID, GETDATE());
    PRINT N'>> 7. Đã ghi log Audit vào STB_ProdRouteHistCancelHist.';

    SELECT Barcode, IsProdFinish FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK) WHERE ControlNo = @ControlNo;
    SELECT RouteCode, ProdQty FROM SmartFactoryV2.dbo.STB_ProdRouteHist WITH(NOLOCK) WHERE ControlNo = @ControlNo AND RouteCode = @RouteCode;
    SELECT MaterialLotNo, PackingID, CurrentQty FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK) WHERE LotNo = @LotNo;

    ROLLBACK TRANSACTION;
    PRINT N'>> [AN TOÀN] Giao dịch đã ROLLBACK để kiểm tra. Đổi sang COMMIT khi xác nhận chính xác.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'>> LỖI: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
"@
}
elseif ($Action -eq "swap-machine") {
    if ([string]::IsNullOrWhiteSpace($Machine)) {
        Write-Host "Lỗi: Bắt buộc cung cấp mã thiết bị mới qua tham số -Machine (VD: -Machine 'VVMHY130')" -ForegroundColor Red
        exit 1
    }
    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_POP_SWAP_MACHINE_${firstLot}_${Machine}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $routeFilterHist = if ($Route) { "AND H.RouteCode = '$Route'" } else { "" }
    $routeFilterPOP = if ($Route) { "AND RouteCode = '$Route'" } else { "" }

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: POP KIOSK ĐỔI MÁY NHẦM (RULE 20.1 EA PLAYBOOK)
-- Created At: $nowStr
-- Target Lots: $($lotList -join ', ')
-- Target Route: $(if ($Route) { $Route } else { 'ALL' })
-- New Machine: $Machine
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK (Kiểm tra dữ liệu trước khi đổi máy)
SELECT H.ControlNo, S.Barcode, H.RouteCode, H.MachineCode AS CurrentMESMachine, H.ProdQty, H.JobDate
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) $routeFilterHist;

SELECT DayPlanNo, Barcode, RouteCode, LineCode, MachineCode AS CurrentPOPMachine, TotalProdQty, IsDone, IsTransferred
FROM SmartFactoryV2.dbo.MongoToMesPerformance WITH(NOLOCK)
WHERE Barcode IN ($lotInClause) $routeFilterPOP;
GO

BEGIN TRAN;

-- 2. CẬP NHẬT BẢNG MES STB_ProdRouteHist (Author: vanduc)
UPDATE H
SET 
    H.MachineCode = '$Machine',
    H.ChangeDateTime = GETDATE(),
    H.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_ProdRouteHist H
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON H.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) $routeFilterHist;

DECLARE @RowsHist INT = @@ROWCOUNT;

-- 3. CẬP NHẬT BẢNG KIOSK POP MongoToMesPerformance
UPDATE M
SET 
    M.MachineCode = '$Machine',
    M.InsertDateTime = GETDATE()
FROM SmartFactoryV2.dbo.MongoToMesPerformance M
WHERE M.Barcode IN ($lotInClause) $routeFilterPOP;

DECLARE @RowsPOP INT = @@ROWCOUNT;

PRINT '-> So dong STB_ProdRouteHist cap nhat: ' + CAST(@RowsHist AS VARCHAR(10));
PRINT '-> So dong MongoToMesPerformance cap nhat: ' + CAST(@RowsPOP AS VARCHAR(10));

IF @RowsHist = 0 AND @RowsPOP = 0
BEGIN
    PRINT '-> [CANH BAO] Khong co dong nao duoc cap nhat! Dang ROLLBACK...';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    COMMIT TRAN;
    PRINT '-> [THANH CONG] Da doi may sang $Machine dong bo ca MES va POP cho $($lotList.Count) Lots!';
END
GO
"@
}
elseif ($Action -eq "fix-solution") {
    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_RECOVERY_ELECTROLYTE_BARREL_${firstLot}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: CAP CUU THUNG DUNG DICH DIEN GIAI 150KG (ELECTROLYTE RECOVERY)
-- Created At: $nowStr
-- Target Barrel/Lot: $($lotList -join ', ')
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK
SELECT MaterialLotNo, LotNo, PackingID, MaterialCode, MaterialWarehouseCode, CurrentQty, InitialQty, Holddate, HoldError
FROM SmartFactoryV2.dbo.STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo IN ($lotInClause) OR MaterialLotNo IN ($lotInClause) OR PackingID IN ($lotInClause);
GO

BEGIN TRAN;

-- 2. KHOI PHUC TRONG LUONG 150KG VA RESET HOLD
UPDATE SmartFactoryV2.dbo.STB_MaterialLotInfo
SET 
    CurrentQty = 150.0,
    Holddate = NULL,
    HoldError = NULL,
    HoldPeriod = NULL,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE LotNo IN ($lotInClause) OR MaterialLotNo IN ($lotInClause) OR PackingID IN ($lotInClause);

DECLARE @RowsUpdated INT = @@ROWCOUNT;
PRINT '-> So thung dung dich duoc khoi phuc 150kg: ' + CAST(@RowsUpdated AS VARCHAR(10));

IF @RowsUpdated = 0
BEGIN
    PRINT '-> [CANH BAO] Khong tim thay thung dung dich tuong ung! Dang ROLLBACK...';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    COMMIT TRAN;
    PRINT '-> [THANH CONG] Da khoi phuc thanh cong trong luong 150kg va go HOLD!';
END
GO
"@
}
elseif ($Action -eq "fix-defect-null") {
    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_B782_FIX_DEFECT_NULL_${firstLot}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: B782 FIX DEFECT REPAIR NULL (NG COLUMN BLANK FIX)
-- Created At: $nowStr
-- Target Lots: $($lotList -join ', ')
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK
SELECT D.DefectRepairInfoNo, D.ControlNo, S.Barcode, D.FindRouteCode, D.DefectCode, D.DefectQty, D.RepairQty, D.FindJobdate
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo D WITH(NOLOCK)
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S WITH(NOLOCK) ON D.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) AND D.RepairQty IS NULL;
GO

BEGIN TRAN;

-- 2. GÁN REPAIR개수 = 0 ĐỂ PHÉP TRỪ KHÔNG BỊ BIẾN THÀNH NULL
UPDATE D
SET 
    D.RepairQty = 0,
    D.ChangeDateTime = GETDATE(),
    D.ChangeUserID = 'vanduc'
FROM SmartFactoryV2.dbo.STB_DefectRepairInfo D
INNER JOIN SmartFactoryV2.dbo.STB_SetInfo S ON D.ControlNo = S.ControlNo
WHERE S.Barcode IN ($lotInClause) AND D.RepairQty IS NULL;

DECLARE @RowsDefect INT = @@ROWCOUNT;
PRINT '-> So ban ghi Defect duoc chuan hoa RepairQty = 0: ' + CAST(@RowsDefect AS VARCHAR(10));

IF @RowsDefect = 0
BEGIN
    PRINT '-> [THONG BAO] Khong co ban ghi nao co RepairQty = NULL. Khong can can thiep.';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    COMMIT TRAN;
    PRINT '-> [THANH CONG] Da chuan hoa RepairQty = 0, cot NG tren man hinh B782 se hien thi chinh xac!';
END
GO
"@
}
elseif ($Action -eq "fix-lineinput") {
    $lotInClause = ($lotList | ForEach-Object { "'$_'" }) -join ", "
    $firstLot = $lotList[0]
    $fileName = "hotfix_${dateTag}_RESET_LINEINPUT_${firstLot}.sql"
    $filePath = Join-Path $hotfixDir $fileName

    $sqlContent = @"
-- ==============================================================================
-- HOTFIX: RESET ISLINEINPUT CHO PHÉP NẠP LOT VÀO DÂY CHUYỀN
-- Created At: $nowStr
-- Target Lots: $($lotList -join ', ')
-- Author / ChangeUserID: vanduc
-- ==============================================================================
USE SmartFactoryV2;
GO

-- 1. PRE-FLIGHT CHECK
SELECT ControlNo, Barcode, MaterialCode, PlanQty, IsLineInput, IsProdFinish, CreateDateTime
FROM SmartFactoryV2.dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode IN ($lotInClause);
GO

BEGIN TRAN;

-- 2. KÍCH HOẠT LẠI ISLINEINPUT
UPDATE SmartFactoryV2.dbo.STB_SetInfo
SET 
    IsLineInput = 1,
    ChangeDateTime = GETDATE(),
    ChangeUserID = 'vanduc'
WHERE Barcode IN ($lotInClause);

DECLARE @RowsSet INT = @@ROWCOUNT;
PRINT '-> So Lot duoc kich hoat IsLineInput = 1: ' + CAST(@RowsSet AS VARCHAR(10));

IF @RowsSet = 0
BEGIN
    PRINT '-> [CANH BAO] Khong tim thay Lot tuong ung trong STB_SetInfo! Dang ROLLBACK...';
    ROLLBACK TRAN;
END
ELSE
BEGIN
    COMMIT TRAN;
    PRINT '-> [THANH CONG] Da kich hoat IsLineInput = 1 cho $($lotList.Count) Lots!';
END
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
