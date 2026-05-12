-- =============================================
-- MES DEBUG SCRIPTS - DÙNG NHANH CHO CÁC LỖI THƯỜNG GẶP
-- Author: Antigravity AI Assistant
-- Date: 2026-05-12
-- =============================================

-- =============================================
-- 1. KIỂM TRA BARCODE INFO
-- =============================================
PRINT '=== KIỂM TRA BARCODE INFO ===';
DECLARE @Barcode VARCHAR(50) = 'VE260506-001'; -- Thay barcode cần kiểm tra

SELECT 
    'SETINFO' AS TableType,
    s.SetInfoNo,
    s.ControlNo,
    s.PONo,
    s.MaterialCode,
    s.PlanQty,
    s.IsLineInput,
    s.IsProdFinish,
    s.CreateDateTime
FROM STB_SetInfo s 
WHERE s.ControlNo = @Barcode OR s.Barcode = @Barcode;

SELECT 
    'PROD_ROUTE_HIST' AS TableType,
    COUNT(*) AS TotalRecords,
    MIN(RouteCode) AS FirstRoute,
    MAX(RouteCode) AS LastRoute,
    SUM(ProdQty) AS TotalQty
FROM STB_ProdRouteHist 
WHERE ControlNo IN (
    SELECT SetInfoNo FROM STB_SetInfo 
    WHERE ControlNo = @Barcode OR Barcode = @Barcode
);

-- =============================================
-- 2. KIỂM TRA ROUTING STATUS
-- =============================================
PRINT '=== KIỂM TRA ROUTING STATUS ===';
DECLARE @SetInfoNo VARCHAR(50);
SELECT @SetInfoNo = SetInfoNo FROM STB_SetInfo WHERE ControlNo = @Barcode OR Barcode = @Barcode;

SELECT 
    r.RouteCode,
    r.ProdQty,
    r.WorkerCode,
    r.MachineCode,
    r.ProdDateTime,
    r.CreateDateTime,
    CASE 
        WHEN r.RouteCode IS NOT NULL THEN '✅ COMPLETED'
        ELSE '❌ PENDING'
    END AS Status
FROM STB_ProductionOrderRouting por
LEFT JOIN STB_ProdRouteHist r ON por.PONo = r.PONo 
    AND por.RouteCode = r.RouteCode 
    AND r.ControlNo = @SetInfoNo
WHERE por.PONo = (SELECT PONo FROM STB_SetInfo WHERE SetInfoNo = @SetInfoNo)
ORDER BY por.RouteIndex;

-- =============================================
-- 3. KIỂM TRA LỖI GẦN ĐÂY
-- =============================================
PRINT '=== KIỂM TRA LỖI GẦN ĐÂY ===';
SELECT TOP 10 
    PL.ProcedureName,
    PL.VariableName,
    PL.VariableValue,
    PL.CreateDateTime,
    PL.CreateUserID
FROM STB_ProcedureLog PL
WHERE PL.CreateDateTime >= DATEADD(HOUR, -24, GETDATE())
    AND (PL.VariableValue LIKE '%' + @Barcode + '%' OR PL.VariableName LIKE '%Error%')
ORDER BY PL.CreateDateTime DESC;

-- =============================================
-- 4. KIỂM TRA PRODUCTION ORDER INFO
-- =============================================
PRINT '=== KIỂM TRA PRODUCTION ORDER INFO ===';
DECLARE @PONo VARCHAR(50);
SELECT @PONo = PONo FROM STB_SetInfo WHERE ControlNo = @Barcode OR Barcode = @Barcode;

SELECT 
    PO.PONo,
    PO.MaterialCode,
    PO.PlanQty,
    PO.ProdFinishQty,
    PO.IsFix,
    PO.IsFinish,
    PO.CreateDateTime,
    CASE 
        WHEN PO.IsFinish = 1 THEN '✅ FINISHED'
        WHEN PO.IsFix = 1 THEN '🔄 IN PROGRESS'
        ELSE '⏸️ PENDING'
    END AS POStatus
FROM STB_ProductionOrderInfo PO
WHERE PO.PONo = @PONo;

-- =============================================
-- 5. KIỂM TRA DEFECT INFO
-- =============================================
PRINT '=== KIỂM TRA DEFECT INFO ===';
-- Note: Cần kiểm tra tên cột chính xác trong STB_DefectInfo
-- SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'STB_DefectInfo'

-- SELECT TOP 5
--     DI.DefectCode,
--     DI.DefectQty,
--     DI.CreateDateTime,
--     DI.WorkerCode
-- FROM STB_DefectInfo DI
-- WHERE DI.ControlNo = @SetInfoNo
-- ORDER BY DI.CreateDateTime DESC;

PRINT '=== DEBUG SCRIPT HOÀN THÀNH ===';
PRINT 'Barcode kiểm tra: ' + @Barcode;
PRINT 'SetInfoNo: ' + ISNULL(@SetInfoNo, 'NOT FOUND');
PRINT 'PONo: ' + ISNULL(@PONo, 'NOT FOUND');
