-- ==============================================================================
-- GOLDEN QUERIES: 360° Traceability Query Templates for Vinatech MES
-- Database: SmartFactoryV2
-- ==============================================================================

-- 1. Truy vết theo Barcode / LotNo sản xuất (Cell / Module)
DECLARE @Barcode NVARCHAR(50) = 'VVQL033R07279S';

-- A. Thông tin sản xuất & Kế hoạch ngày
SELECT TOP 5 Barcode, MaterialCode, PONo, DayPlanNo, InputLineCode, CurrentRouteCode, IsDefect, DefectQty, LotDecisionResult, CreateDateTime
FROM STB_SetInfo WITH(NOLOCK)
WHERE Barcode = @Barcode OR ControlNo = @Barcode;

-- B. Quản lý kho & Đóng gói
SELECT TOP 5 LotID, MaterialCode, LotNo, MaterialLotNo, MaterialWarehouseCode, CurrentQty, PackingID, LotAttr10, CreateDateTime
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE LotNo = @Barcode OR MaterialLotNo = @Barcode OR PackingID = @Barcode;

-- C. Toàn bộ tiến trình công đoạn sản xuất (Routing History)
SELECT TOP 30 ControlNo, RouteCode, FindRouteCode, ProdQty, DefectQty, CompleteRoute, ProcessUserID, JobDate, CreateDateTime
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN (SELECT ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Barcode)
ORDER BY CreateDateTime ASC;
