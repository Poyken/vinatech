-- =====================================================
-- VINATECH MES - SQL DEBUG QUERIES TEMPLATE
-- =====================================================
-- Server: dbserver.hycap.co.kr,5398
-- Database: SmartFactoryV2
-- Cách chạy: sqlcmd -S "dbserver.hycap.co.kr,5398" -U vinaadmin -P "vina1234%6&8" -d SmartFactoryV2 -C -i debug_queries.sql
-- =====================================================

-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. GOLDEN QUERY - Truy vết toàn bộ hành trình 1 Barcode
-- ═══════════════════════════════════════════════════════════════════════════════

-- Thay [BARCODE] bằng mã cần tra
-- Ví dụ: VVQN1220001E17
SELECT
    PRH.ControlNo AS [Mã vạch SP],
    PRH.PONo AS [Lệnh SX],
    RI.RouteName AS [Công đoạn],
    PRH.RouteCode AS [Mã Route],
    PRH.ProdQty AS [Số lượng],
    PRH.CreateDateTime AS [Giờ quét],
    DP.PackingID AS [Mã Thùng hàng],
    DP.ParentPackingID AS [Mã BigBox]
FROM STB_ProdRouteHist PRH WITH(NOLOCK)
LEFT JOIN STB_RouteInfo RI WITH(NOLOCK)
    ON PRH.RouteCode = RI.RouteCode
LEFT JOIN STB_DividePackaging DP WITH(NOLOCK)
    ON PRH.ControlNo = DP.LotNo
WHERE PRH.ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VVQN1220001E17')
ORDER BY PRH.CreateDateTime ASC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 2. KIỂM TRA TRẠNG THÁI BARCODE (SetInfo)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Thay [BARCODE]
SELECT
    Barcode,
    ControlNo,
    MaterialCode,
    ProdQty,
    InputLineCode,
    IsLineInput,
    IsProdFinish,
    LotDecisionResult,
    IsDefect,
    DefectQty,
    InputDateTime,
    ProdFinishDateTime,
    CreateDateTime
FROM STB_SetInfo
WHERE Barcode = 'VVQN1220001E17'


-- ═══════════════════════════════════════════════════════════════════════════════
-- 3. KIỂM TRA HOLDING - Lot có bị HOLD không?
-- ═══════════════════════════════════════════════════════════════════════════════

-- Cách 1: Check kho HOLDING (MaterialWarehouseCode = 'HOLDING')
SELECT
    LotID,
    MaterialCode,
    CurrentQty,
    MaterialWarehouseCode,
    MaterialLocationCode,
    CreateDateTime
FROM STB_MaterialLotInfo
WHERE LotID = 'ML20260501000001'
    AND MaterialWarehouseCode LIKE '%HOLDING%'

-- Cách 2: Check Expiry Date (LotAttr10 + ShelfLife)
SELECT
    MLI.LotID,
    MLI.MaterialCode,
    MLI.LotAttr10 AS [Ngày SX],
    MM.MaterialName,
    MM.MMExtInt01 AS [Hạn tháng],
    DATEADD(MONTH, ISNULL(MM.MMExtInt01, 3), TRY_CAST(MLI.LotAttr10 AS DATE)) AS [Ngày Hết Hạn],
    CASE
        WHEN DATEADD(MONTH, ISNULL(MM.MMExtInt01, 3), TRY_CAST(MLI.LotAttr10 AS DATE)) < GETDATE()
        THEN 'EXPIRED'
        WHEN DATEADD(DAY, 30, GETDATE()) > DATEADD(MONTH, ISNULL(MM.MMExtInt01, 3), TRY_CAST(MLI.LotAttr10 AS DATE))
        THEN 'WARNING'
        ELSE 'OK'
    END AS [Status]
FROM STB_MaterialLotInfo MLI
JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
WHERE MLI.LotID = 'ML20260501000001'


-- ═══════════════════════════════════════════════════════════════════════════════
-- 4. KIỂM TRA FIFO - Lot nào đang chặn?
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm Lot cũ nhất chưa xuất (dùng để biết hệ thống yêu cầu quét cái nào)
DECLARE @MaterialCode NVARCHAR(50) = 'GBAKAC-004'  -- Thay bằng mã cần check
SELECT TOP 5
    LotID,
    MaterialCode,
    CurrentQty,
    MaterialLocationCode,
    CreateDateTime AS [Ngày nhập]
FROM STB_MaterialLotInfo
WHERE MaterialCode = @MaterialCode
    AND CurrentQty > 0
    AND MaterialWarehouseCode NOT LIKE '%HOLDING%'
ORDER BY CreateDateTime ASC  -- Lot cũ nhất lên đầu


-- ═══════════════════════════════════════════════════════════════════════════════
-- 5. KIỂM TRA NVL ĐÃ SCAN TẠI V-23/V-24 (B530 Gate)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem NVL đã scan cho 1 Barcode tại V-23 hoặc V-24
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'  -- Thay bằng barcode cần check
SELECT
    RMI.ProdLotQty AS [Barcode SP],
    RMI.MaterialCode AS [Mã NVL],
    RMI.RouteCode AS [Công đoạn scan],
    RMI.LotNo AS [Lot NVL],
    RMI.CreateDateTime AS [Ngày scan]
FROM STB_RawMaterialInputHist RMI
WHERE RMI.ProdLotQty = @Barcode
    AND RMI.RouteCode IN ('V-23', 'V-24', 'V-23_BG', 'V-24_BG')
ORDER BY RMI.CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 6. KIỂM TRA QC (B597/C443/C512) - CommInspDocHistory
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm CommInspDoc theo Barcode
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    CIDH.CommInspDocNo,
    CIDH.CommInspTypeCode,
    CIDH.ProdNo,
    CIDH.CommInspResult,
    CIDH.CreateDateTime,
    CIDH.FinishDateTime
FROM STB_CommInspDocHistory CIDH
WHERE CIDH.ProdNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
ORDER BY CIDH.CreateDateTime DESC

-- Xem chi tiết hạng mục kiểm tra
DECLARE @CommInspDocNo NVARCHAR(50) = '20260512000001'  -- Thay bằng số thực
SELECT
    CIDI.CommInspItemCode,
    CIDI.CommInspItemName,
    CIDI.CommInspUpperLimit,
    CIDI.CommInspLowerLimit,
    CIME.MeasureValue,
    CIME.CommInspResult
FROM STB_CommInspDocItem CIDI
LEFT JOIN STB_CommInspMeasureHist CIME ON CIDI.CommInspDocItemNo = CIME.CommInspDocItemNo
WHERE CIDI.CommInspDocNo = @CommInspDocNo


-- ═══════════════════════════════════════════════════════════════════════════════
-- 7. KIỂM TRA ĐIỆN CỰC (B552/B597) - ElectrodeLotNumber
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm Electrode Lot cho 1 Barcode SP
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    RMI.ProdLotQty AS [Barcode SP],
    RMI.LotNo AS [ElectrodeLotNumber],
    RMI.MaterialCode AS [Mã điện cực]
FROM STB_RawMaterialInputHist RMI
WHERE RMI.ProdLotQty = @Barcode
    AND RMI.RouteCode = 'V-22'
ORDER BY RMI.CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 8. KIỂM TRA LỊCH SỬ ĐỔI BARCODE (B351)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem chain đổi barcode (lên đến 6 cấp)
SELECT
    OldBarcode,
    NewBarcode,
    ChangeDateTime,
    ChangeUserID
FROM STB_LotChangeMaterialHistory
WHERE OldBarcode = 'VVQN1220001E17'
   OR NewBarcode = 'VVQN1220001E17'
ORDER BY ChangeDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 9. KIỂM TRA MATERIAL DOC (F330/F312) - Chứng từ kho
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm MaterialDocNo theo LotID
DECLARE @LotID NVARCHAR(50) = 'ML20260501000001'
SELECT
    MDI.MaterialDocNo,
    MDI.DocType,
    MDI.DocStatus,
    MDI.CreateDateTime,
    MDI.SourceMaterialWarehouseCode,
    MDI.TargetMaterialWarehouseCode
FROM STB_MaterialDocInfo MDI
JOIN STB_MaterialDocLotInfo MDLI ON MDI.MaterialDocNo = MDLI.MaterialDocNo
WHERE MDLI.LotID = @LotID

-- Xem chi tiết trong MaterialDocDetail
DECLARE @MaterialDocNo NVARCHAR(50) = '250605000001'  -- Thay bằng số thực
SELECT
    MaterialCode,
    MaterialName,
    RequestQty,
    AllowQty,
    PickingAssignQty
FROM STB_MaterialDocDetail
WHERE MaterialDocNo = @MaterialDocNo


-- ═══════════════════════════════════════════════════════════════════════════════
-- 10. KIỂM TRA DEFECT (B530/B791)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem defect theo Barcode
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    DRI.ControlNo,
    DRI.FindRouteCode,
    DRI.FindLineCode,
    DRI.BasicDefectGroupName,
    DRI.DefectName,
    DRI.DefectQty,
    DRI.CreateDateTime
FROM STB_DefectRepairInfo DRI
WHERE DRI.ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
ORDER BY DRI.CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 11. KIỂM TRA PACKING (B523/B525)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm PackingID theo Barcode
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    DP.LotNo AS [Barcode],
    DP.PackingID,
    DP.PackQty,
    DP.ParentPackingID AS [BigBoxID],
    DP.CreateDateTime
FROM STB_DividePackaging DP
WHERE DP.LotNo = @Barcode

-- Xem BigBox chứa Barcode này
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    M.LotNo AS [Barcode trong Box],
    M.PackingID,
    M.CurrentQty,
    M.MaterialCode
FROM STB_MaterialLotInfo M
WHERE M.PackingID IN (
    SELECT DP.ParentPackingID
    FROM STB_DividePackaging DP
    WHERE DP.LotNo = @Barcode
)


-- ═══════════════════════════════════════════════════════════════════════════════
-- 12. KIỂM TRA PRODUCTION ORDER (B310)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem PO theo Barcode
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    POI.PONo,
    POI.MaterialCode,
    POI.PlannedQty,
    POI.ProdFinishQty,
    POI.POType,
    POI.CompanyCode,
    POI.WorkCenterCode,
    POI.CreateDateTime
FROM STB_ProductionOrderInfo POI
WHERE POI.PONo = (SELECT PONo FROM STB_SetInfo WHERE Barcode = @Barcode)

-- Xem ROUTING của PO
DECLARE @PONo NVARCHAR(50) = '260505000026'  -- Thay bằng số thực
SELECT
    RouteCode,
    RouteIndex,
    IsInputRoute,
    IsOutputRoute
FROM STB_ProductionOrderRouting
WHERE PONo = @PONo
ORDER BY RouteIndex


-- ═══════════════════════════════════════════════════════════════════════════════
-- 13. KIỂM TRA BOM CỦA PO
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @PONo NVARCHAR(50) = '260505000026'
SELECT
    MaterialCode,
    Qty,
    UnitCode,
    RouteCode
FROM STB_ProductionOrderBom
WHERE PONo = @PONo


-- ═══════════════════════════════════════════════════════════════════════════════
-- 14. KIỂM TRA LOG (STB_ProcedureLog)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Tìm log theo Barcode/Lot
DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT TOP 20
    ProcedureName,
    VariableName,
    VariableValue,
    CreateDateTime
FROM STB_ProcedureLog
WHERE VariableValue LIKE '%' + @Barcode + '%'
ORDER BY CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 15. KIỂM TRA TỒN KHO (F721)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem tồn kho theo MaterialCode
DECLARE @MaterialCode NVARCHAR(50) = 'GBAKAC-004'
SELECT
    LotID,
    MaterialCode,
    CurrentQty,
    MaterialWarehouseCode,
    MaterialLocationCode,
    CreateDateTime
FROM STB_MaterialLotInfo
WHERE MaterialCode = @MaterialCode
    AND CurrentQty > 0
ORDER BY CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 16. KIỂM TRA STB_MaterialStock (Tổng tồn kho)
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @MaterialCode NVARCHAR(50) = 'GBAKAC-004'
SELECT
    MaterialCode,
    StockQty,
    AllocQty,
    AvailableQty,
    CompanyCode,
    MaterialWarehouseCode
FROM STB_MaterialStock
WHERE MaterialCode = @MaterialCode


-- ═══════════════════════════════════════════════════════════════════════════════
-- 17. AUDIT HOẠT ĐỘNG USER TRONG NGÀY
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @User NVARCHAR(50) = 'vinaadmin'  -- Thay bằng user cần kiểm tra
DECLARE @Date NVARCHAR(10) = CONVERT(VARCHAR, GETDATE(), 120)

SELECT TOP 20
    ProcedureName,
    VariableName,
    VariableValue,
    CreateDateTime
FROM STB_ProcedureLog
WHERE CreateDateTime LIKE @Date + '%'
    AND (VariableValue LIKE '%' + @User + '%' OR VariableName LIKE '%UserID%')
ORDER BY CreateDateTime DESC


-- ═══════════════════════════════════════════════════════════════════════════════
-- 18. KIỂM TRA TRẠNG THÁI ROUTE (IsRawMaterialInputFinish)
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @Barcode NVARCHAR(50) = 'VVQN1220001E17'
SELECT
    PRH.ControlNo,
    PRH.RouteCode,
    RI.RouteName,
    PRH.ProdQty,
    PRH.IsRawMaterialInputFinish,
    PRH.CompleteRoute,
    PRH.CreateDateTime
FROM STB_ProdRouteHist PRH
JOIN STB_RouteInfo RI ON PRH.RouteCode = RI.RouteCode
WHERE PRH.ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)
ORDER BY PRH.CreateDateTime


-- ═══════════════════════════════════════════════════════════════════════════════
-- 19. KIỂM TRA SLITTING CONFIG (B552)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Xem cấu hình Slitting theo PartNo
SELECT
    PartNo,
    SlittingCode,
    SlittingSize,
    Farad,
    Width,
    WarehouseLocation,
    LocationWarehouse,
    RollQty
FROM stb_slittinglocationconfig_vvt
WHERE PartNo = '1025'
ORDER BY SlittingCode


-- ═══════════════════════════════════════════════════════════════════════════════
-- 20. KIỂM TRA BYPASS HẾT HẠN (stb_vvt_OpenExpiredMaterial)
-- ═══════════════════════════════════════════════════════════════════════════════

DECLARE @LotID NVARCHAR(50) = 'ML20260501000001'
SELECT
    LotID,
    MaterialCode,
    OpenExpired,
    CreateDateTime,
    OpenUserID
FROM stb_vvt_OpenExpiredMaterial
WHERE LotID = @LotID
ORDER BY CreateDateTime DESC