-- =============================================
-- SCRIPT HOÀN THÀNH CÔNG ĐOẠN VE08 CHO VE260506-001
-- Author: Antigravity AI Assistant
-- Date: 2026-05-11
-- Purpose: Thêm record VE08 vào STB_ProdRouteHist
-- =============================================

-- STEP 1: Kiểm tra data hiện tại
PRINT '=== KIỂM TRA DATA HIỆN TẠI ===';
SELECT 
    'BEFORE_INSERT' AS Status,
    COUNT(*) AS VE08_Count,
    ControlNo,
    RouteCode,
    ProdQty
FROM STB_ProdRouteHist 
WHERE ControlNo = '20260428000408' AND RouteCode = 'VE08'
GROUP BY ControlNo, RouteCode, ProdQty;

-- STEP 2: Lấy thông tin cần thiết
DECLARE @SetInfoNo VARCHAR(50) = '20260428000408';
DECLARE @PONo VARCHAR(50) = '260428000011';
DECLARE @ControlNo VARCHAR(50) = '20260428000408';
DECLARE @MaterialCode VARCHAR(50) = '7R5RL470MB9XXXT101';
DECLARE @BomVersion VARCHAR(20) = '2001';
DECLARE @JobDate DATE = '2026-05-11';
DECLARE @ShiftCode VARCHAR(10) = '1';
DECLARE @TimeCode VARCHAR(10) = '*';
DECLARE @LineCode VARCHAR(20) = 'VELINE-01';
DECLARE @RouteCode VARCHAR(20) = 'VE08';
DECLARE @WorkerCode VARCHAR(20) = 'VES-253';
DECLARE @MachineCode VARCHAR(50) = 'MCTP202012004';

-- Lấy ProdQty từ công đoạn trước (VE07)
DECLARE @PrevQty DECIMAL(18,6) = 0;
SELECT @PrevQty = ProdQty 
FROM STB_ProdRouteHist 
WHERE ControlNo = @ControlNo AND RouteCode = 'VE07';

-- Tính toán số lượng cho VE08
DECLARE @NGQty DECIMAL(18,6) = 6.00; -- Từ màn hình user
DECLARE @ActualQty DECIMAL(18,6) = @PrevQty - @NGQty; -- 5883 - 6 = 5877

PRINT N'Số lượng VE07: ' + CAST(@PrevQty AS VARCHAR(20));
PRINT N'Số lượng NG: ' + CAST(@NGQty AS VARCHAR(20));
PRINT N'Số lượng Actual: ' + CAST(@ActualQty AS VARCHAR(20));

-- STEP 3: INSERT record VE08
PRINT '=== INSERT RECORD VE08 ===';
BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO STB_ProdRouteHist (
        CompanyCode,
        WorkCenterCode,
        PONo,
        DayPlanNo,
        ControlNo,
        MaterialCode,
        BomVersion,
        JobDate,
        ShiftCode,
        TimeCode,
        LineCode,
        RouteCode,
        WorkerCode,
        MachineCode,
        ProdQty,
        ProdDateTime,
        CreateDateTime,
        CreateUserID,
        DelayCode,
        CompleteRoute
    )
    SELECT 
        'VVT',
        'VVT_F3',
        @PONo,
        '2026050900106',
        @ControlNo,
        @MaterialCode,
        @BomVersion,
        @JobDate,
        @ShiftCode,
        @TimeCode,
        @LineCode,
        @RouteCode,
        @WorkerCode,
        @MachineCode,
        @ActualQty, -- Số lượng sau khi trừ NG
        GETDATE(),
        GETDATE(),
        'ducthinh',
        NULL,
        NULL;
    
    COMMIT TRANSACTION;
    PRINT '✅ INSERT VE08 THÀNH CÔNG!';
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '❌ LỖI KHI INSERT VE08:';
    PRINT ERROR_MESSAGE();
END CATCH;

-- STEP 4: Kiểm tra lại sau khi INSERT
PRINT '=== KIỂM TRA SAU KHI INSERT ===';
SELECT 
    'AFTER_INSERT' AS Status,
    COUNT(*) AS VE08_Count,
    ControlNo,
    RouteCode,
    ProdQty,
    CreateDateTime
FROM STB_ProdRouteHist 
WHERE ControlNo = '20260428000408' AND RouteCode = 'VE08'
GROUP BY ControlNo, RouteCode, ProdQty, CreateDateTime;

-- STEP 5: Kiểm tra toàn bộ routing
PRINT '=== TOÀN BỘ ROUTING CỦA BARCODE ===';
SELECT 
    RouteCode,
    ProdQty,
    WorkerCode,
    MachineCode,
    ProdDateTime
FROM STB_ProdRouteHist 
WHERE ControlNo = '20260428000408'
ORDER BY RouteCode;

PRINT '=== HOÀN THÀNH SCRIPT ===';
PRINT 'Barcode VE260506-001 đã hoàn thành công đoạn VE08!';
PRINT 'User có thể tiếp tục công đoạn VE09';
