-- =========================================================================================
-- Comprehensive Test Script: Sanmina Config Screen & B767 Label Printing
-- =========================================================================================

SET NOCOUNT ON;

PRINT '------------------------------------------------------------';
PRINT 'TEST 1: TẠO CẤU HÌNH TRÊN MÀN HÌNH QUẢN LÝ (CONFIG SCREEN)';
PRINT '------------------------------------------------------------';

DECLARE @TestPO VARCHAR(50) = 'PO-SANMINA-TEST-2026';
DECLARE @TestPart VARCHAR(50) = 'LFIBLM164855';
DECLARE @TestLot VARCHAR(50);
DECLARE @ConfigID INT;

-- Lấy 1 Lot thành phẩm hợp lệ để test
SELECT TOP 1 @TestLot = SI.Barcode
FROM STB_SetInfo SI WITH(NOLOCK)
JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = SI.MaterialCode
WHERE SI.IsProdFinish = 1 AND MM.MaterialName LIKE '%VEC3R0727QG%';

PRINT '-> Lot thành phẩm test: ' + ISNULL(@TestLot, 'N/A');

-- 1. Lưu cấu hình: PO, PartNumber, LotNo, Quantity (200), TotalBox (2 thùng/pallet), IsActive = 1
DECLARE @RetID TABLE (NewPlanID INT);
INSERT INTO @RetID
EXEC usp_SanminaShipmentPlan_iud 
    @pAction = 'SAVE',
    @pPONumber = @TestPO,
    @pPartNumber = @TestPart,
    @pLotNo = @TestLot,
    @pQuantity = 200,
    @pTotalBox = 2,
    @pIsActive = 1,
    @pProcessUserID = 'LEADER_TEST';

SELECT TOP 1 @ConfigID = NewPlanID FROM @RetID;
PRINT '-> Đã lưu cấu hình với ID: ' + CAST(@ConfigID AS VARCHAR);

-- 2. Kiểm tra SP Get cấu hình
PRINT '-> Kiểm tra truy vấn danh sách cấu hình (usp_SanminaShipmentPlan_get):';
EXEC usp_SanminaShipmentPlan_get @pPONumber = @TestPO;

PRINT '------------------------------------------------------------';
PRINT 'TEST 2: KIỂM TRA MÀN B767 TỰ NẠP TỪ CẤU HÌNH (POKA-YOKE)';
PRINT '------------------------------------------------------------';

IF @TestLot IS NOT NULL
BEGIN
    PRINT '-> [Thùng 1] OP chỉ quét mã LotNo (Không truyền PO/PartNo/BoxNo):';
    EXEC usp_SanminaLabelPrint_get_Vietnam @pLotNo = @TestLot;

    PRINT '-> [In Thùng 1] Giả lập bấm in tem thùng 1:';
    EXEC usp_SanminaIndiaLabelPrintHist_iud 
        @pProcessUserID = 'OP_TEST',
        @pSupplierName = 'Vinatech Vina',
        @pSanminaPartNumber = @TestPart,
        @pPONumber = @TestPO,
        @pLotNo = @TestLot,
        @pCartonBoxNo = '01/02',
        @pBoxSerialNo = 'VINATEST00001, VINATEST00002';

    PRINT '-> [Thùng 2] OP quét lại mã LotNo (Hệ thống phải tự nhảy Box 02/02):';
    EXEC usp_SanminaLabelPrint_get_Vietnam @pLotNo = @TestLot;

    PRINT '-> [In Thùng 2] Giả lập bấm in tem thùng 2:';
    EXEC usp_SanminaIndiaLabelPrintHist_iud 
        @pProcessUserID = 'OP_TEST',
        @pSupplierName = 'Vinatech Vina',
        @pSanminaPartNumber = @TestPart,
        @pPONumber = @TestPO,
        @pLotNo = @TestLot,
        @pCartonBoxNo = '02/02',
        @pBoxSerialNo = 'VINATEST00003, VINATEST00004';
END

PRINT '------------------------------------------------------------';
PRINT 'TEST 3: KIỂM TRA CHẾ ĐỘ NHẬP TAY THỦ CÔNG (LOGIC CŨ 100%)';
PRINT '------------------------------------------------------------';

IF @TestLot IS NOT NULL
BEGIN
    PRINT '-> OP nhập tay Part Number & PO tùy ý (Không phụ thuộc cấu hình):';
    EXEC usp_SanminaLabelPrint_get_Vietnam 
        @pLotNo = @TestLot,
        @pPONumber = 'PO-MANUAL-TEST-999',
        @pPartNumber = 'USER-CUSTOM-PART-888',
        @pTotalBox = 2,
        @pQuantity = '200';
END

PRINT '------------------------------------------------------------';
PRINT 'DỌN DẸP DỮ LIỆU TEST SAU KHI KIỂM THỬ';
PRINT '------------------------------------------------------------';
DELETE FROM STB_SanminaIndiaLabelPrintHist WHERE PONumber IN (@TestPO, 'PO-MANUAL-TEST-999');
DELETE FROM STB_SanminaShipmentPlanLot WHERE PlanID = @ConfigID;
DELETE FROM STB_SanminaShipmentPlan WHERE PlanID = @ConfigID;
PRINT '-> Hoàn tất kiểm thử và dọn dẹp sạch sẽ!';
GO
