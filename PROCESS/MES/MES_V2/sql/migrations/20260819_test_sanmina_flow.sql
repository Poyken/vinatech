-- =========================================================================================
-- End-to-End Verification Test for Sanmina Shipment Plan & Backward Compatibility
-- =========================================================================================

SET NOCOUNT ON;

PRINT '=== TEST 1: CHẾ ĐỘ THIẾT LẬP PLAN (POKA-YOKE AUTO MODE) ===';
DECLARE @NewPlanID INT;
DECLARE @NewPlanCode VARCHAR(30);
DECLARE @InsertResult TABLE (NewPlanID INT, NewPlanCode VARCHAR(30));

INSERT INTO @InsertResult
EXEC usp_SanminaShipmentPlan_iud 
    @pAction = 'INSERT', 
    @pPONumber = 'PO-SANMINA-TEST-DYNAMIC-01', 
    @pPartNumber = 'CUSTOM-PART-999', -- Test Dynamic Part Number (Không fix cứng)
    @pTotalBox = 2, 
    @pQtyPerBox = 200, 
    @pProcessUserID = 'TEST_LEADER';

SELECT TOP 1 @NewPlanID = NewPlanID, @NewPlanCode = NewPlanCode FROM @InsertResult;
PRINT '1.1 Đã tạo PlanID: ' + CAST(@NewPlanID AS VARCHAR) + ' - PlanCode: ' + @NewPlanCode;

-- Kích hoạt Plan
EXEC usp_SanminaShipmentPlan_iud 
    @pAction = 'ACTIVATE', 
    @pPlanID = @NewPlanID, 
    @pProcessUserID = 'TEST_LEADER';

SELECT PlanID, PlanCode, PONumber, PartNumber, TotalBox, PrintedBoxCount, Status
FROM STB_SanminaShipmentPlan WITH(NOLOCK)
WHERE PlanID = @NewPlanID;

-- Tìm 1 Lot thành phẩm để test
DECLARE @TestLotNo VARCHAR(50);
SELECT TOP 1 @TestLotNo = SI.Barcode
FROM STB_SetInfo SI WITH(NOLOCK)
JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = SI.MaterialCode
WHERE SI.IsProdFinish = 1 AND MM.MaterialName LIKE '%VEC3R0727QG%';

PRINT '1.2 Lot test: ' + ISNULL(@TestLotNo, 'NONE');

IF @TestLotNo IS NOT NULL
BEGIN
    PRINT '1.3 Gọi usp_SanminaLabelPrint_get_Vietnam ở chế độ Auto (Không truyền PO, PartNo, TotalBox):';
    EXEC usp_SanminaLabelPrint_get_Vietnam @pLotNo = @TestLotNo;

    PRINT '1.4 Giả lập in Thùng 1:';
    EXEC usp_SanminaIndiaLabelPrintHist_iud 
        @pProcessUserID = 'TEST_OP',
        @pSupplierName = 'Vinatech Vina',
        @pSanminaPartNumber = 'CUSTOM-PART-999',
        @pPONumber = 'PO-SANMINA-TEST-DYNAMIC-01',
        @pLotNo = @TestLotNo,
        @pCartonBoxNo = '01/02',
        @pBoxSerialNo = 'VINATEST00001, VINATEST00002';

    SELECT PlanID, PlanCode, PrintedBoxCount, (TotalBox - PrintedBoxCount) AS RemainingBox, Status 
    FROM STB_SanminaShipmentPlan WITH(NOLOCK) 
    WHERE PlanID = @NewPlanID;

    PRINT '1.5 Gọi tiếp Thùng 2 (Tự nhảy Box 02/02):';
    EXEC usp_SanminaLabelPrint_get_Vietnam @pLotNo = @TestLotNo;

    PRINT '1.6 Giả lập in Thùng 2 (Hoàn tất Lô xuất):';
    EXEC usp_SanminaIndiaLabelPrintHist_iud 
        @pProcessUserID = 'TEST_OP',
        @pSupplierName = 'Vinatech Vina',
        @pSanminaPartNumber = 'CUSTOM-PART-999',
        @pPONumber = 'PO-SANMINA-TEST-DYNAMIC-01',
        @pLotNo = @TestLotNo,
        @pCartonBoxNo = '02/02',
        @pBoxSerialNo = 'VINATEST00003, VINATEST00004';

    SELECT PlanID, PlanCode, PrintedBoxCount, (TotalBox - PrintedBoxCount) AS RemainingBox, Status, FinishDateTime 
    FROM STB_SanminaShipmentPlan WITH(NOLOCK) 
    WHERE PlanID = @NewPlanID;
END

PRINT '=== TEST 2: CHẾ ĐỘ CŨ (BACKWARD COMPATIBILITY / MANUAL INPUT KHÔNG DÙNG PLAN) ===';
-- Lúc này Plan test đã COMPLETED (không còn plan active nào), test nhập tay đầy đủ:
IF @TestLotNo IS NOT NULL
BEGIN
    PRINT '2.1 Test gọi logic cũ với PartNumber bất kỳ do user nhập tay:';
    EXEC usp_SanminaLabelPrint_get_Vietnam 
        @pLotNo = @TestLotNo,
        @pPONumber = 'PO-MANUAL-USER-INPUT-888',
        @pPartNumber = 'ANY-PART-USER-ENTERED-123',
        @pTotalBox = 3,
        @pQuantity = '200';
END

PRINT '=== BƯỚC DỌN DẸP DỮ LIỆU TEST ===';
DELETE FROM STB_SanminaIndiaLabelPrintHist WHERE PONumber IN ('PO-SANMINA-TEST-DYNAMIC-01', 'PO-MANUAL-USER-INPUT-888');
DELETE FROM STB_SanminaShipmentPlanLot WHERE PlanID = @NewPlanID;
DELETE FROM STB_SanminaShipmentPlan WHERE PlanID = @NewPlanID;
PRINT 'Dọn dẹp dữ liệu test hoàn tất!';
GO
