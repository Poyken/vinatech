-- =================================================================================
-- Author: Antigravity
-- Date: 2026-06-15
-- Description: PHẦN 1: TẠO BACKUP DATA TRƯỚC KHI CAN THIỆP
--              Chạy phần này trước khi tiến hành chạy script hủy gộp box.
-- =================================================================================

USE SmartFactoryV2;
GO

-- Bắt đầu sao lưu dữ liệu (Idempotent: Tự động xóa bảng BAK cũ nếu đã tồn tại)

PRINT 'Preparing backup tables...';

IF OBJECT_ID('STB_VN_FINISHGOODS_HN_New_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_VN_FINISHGOODS_HN_New_BAK_VE260506');

IF OBJECT_ID('STB_MaterialLotInfo_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_MaterialLotInfo_BAK_VE260506');

IF OBJECT_ID('STB_MaterialDocInfo_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_MaterialDocInfo_BAK_VE260506');

IF OBJECT_ID('STB_MaterialDocLotInfo_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_MaterialDocLotInfo_BAK_VE260506');

IF OBJECT_ID('STB_ProdRouteHist_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_ProdRouteHist_BAK_VE260506');

IF OBJECT_ID('STB_ProdRouteSummary_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_ProdRouteSummary_BAK_VE260506');

IF OBJECT_ID('STB_ProductionOrderInfo_BAK_VE260506', 'U') IS NOT NULL
    EXEC('DROP' + ' TABLE STB_ProductionOrderInfo_BAK_VE260506');

PRINT 'Backing up data...';

-- 1. Backup kho thành phẩm
SELECT * INTO STB_VN_FINISHGOODS_HN_New_BAK_VE260506
FROM STB_VN_FINISHGOODS_HN_New WITH(NOLOCK)
WHERE PackingID IN ('pkqn2500089', 'pkqn2500091') AND LotNo = 'VE260506-003';

-- 2. Backup bảng quản lý Lot
SELECT * INTO STB_MaterialLotInfo_BAK_VE260506
FROM STB_MaterialLotInfo WITH(NOLOCK)
WHERE PackingID IN ('PKQN2500089', 'PKQN2500091') AND LotNo = 'VE260506-003';

-- 3. Backup bảng chứng từ kho chính
SELECT * INTO STB_MaterialDocInfo_BAK_VE260506
FROM STB_MaterialDocInfo WITH(NOLOCK)
WHERE MaterialDocNo IN ('260525000095', '260525000097');

-- 4. Backup bảng chứng từ kho chi tiết
SELECT * INTO STB_MaterialDocLotInfo_BAK_VE260506
FROM STB_MaterialDocLotInfo WITH(NOLOCK)
WHERE PackingID IN ('PKQN2500089', 'PKQN2500091') OR LotNo = 'VE260506-003';

-- 5. Backup lịch sử chốt công đoạn
SELECT * INTO STB_ProdRouteHist_BAK_VE260506
FROM STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo = '20260428000416' AND RouteCode = 'VE10';

-- 6. Backup tổng hợp sản lượng chốt ngày
SELECT * INTO STB_ProdRouteSummary_BAK_VE260506
FROM STB_ProdRouteSummary WITH(NOLOCK)
WHERE ProductSummaryID = '20260525000326';

-- 7. Backup sản lượng PO
SELECT * INTO STB_ProductionOrderInfo_BAK_VE260506
FROM STB_ProductionOrderInfo WITH(NOLOCK)
WHERE PONo = '260428000013';

PRINT 'Backup completed successfully!';
GO


-- =================================================================================
-- PHẦN 2: KHÔI PHỤC (ROLLBACK/RESTORE) DỮ LIỆU GỐC NẾU CÓ SAI SÓT
--              Chỉ chạy phần này khi đã COMMIT script hủy và phát hiện lỗi cần khôi phục lại.
-- =================================================================================

/*
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;
BEGIN TRY
    PRINT 'Restoring data from backup tables...';

    -- 1. Khôi phục kho thành phẩm Hà Nam (Sử dụng IDENTITY_INSERT)
    DELETE FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID IN ('pkqn2500089', 'pkqn2500091') AND LotNo = 'VE260506-003';
    SET IDENTITY_INSERT STB_VN_FINISHGOODS_HN_New ON;
    INSERT INTO STB_VN_FINISHGOODS_HN_New (ID, IDCODE, PackingID, LotNo, PackQty, PackQtyOutPut, PublicCode, MethodAction, SoPhieuNhapKho, Locations, TypeInput, WorkCenterCode, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, StatusImport, PackingNilonToBoxSmallID, CommentType, Note)
    SELECT ID, IDCODE, PackingID, LotNo, PackQty, PackQtyOutPut, PublicCode, MethodAction, SoPhieuNhapKho, Locations, TypeInput, WorkCenterCode, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, StatusImport, PackingNilonToBoxSmallID, CommentType, Note 
    FROM STB_VN_FINISHGOODS_HN_New_BAK_VE260506;
    SET IDENTITY_INSERT STB_VN_FINISHGOODS_HN_New OFF;

    -- 2. Khôi phục bảng quản lý Lot
    DELETE FROM STB_MaterialLotInfo WHERE PackingID IN ('PKQN2500089', 'PKQN2500091') AND LotNo = 'VE260506-003';
    INSERT INTO STB_MaterialLotInfo (MaterialLotNo, LotID, CompanyCode, WorkCenterCode, MaterialWarehouseCode, MaterialLocationCode, MaterialCode, MaterialStockAttribute, StockAttrib1, StockAttrib2, StockAttrib3, PackingID, GRDate, MaterialDeliveryNo, MaterialDeliveryDetailNo, InitialQty, CurrentQty, PickingQty, VendorLotNo, LifeBasicDate, ProductionDate, EndOfLifeDate, LotNo, IsSplitLot, BefMaterialLotNo, LotAttr01, LotAttr02, LotAttr03, LotAttr04, LotAttr05, LotAttr06, LotAttr07, LotAttr08, LotAttr09, LotAttr10, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, DateConfirmEx, HoldError, Holddate, HoldPeriod, PackingIdParent, IsSlitting, CheckTime, CheckUserID, IsCheck, LengthSlitting, IsParrent, IsConfirmInput, MergeParentId, CreateDateSlittingTime, InitialQtyBefMerge, CurrentQtyBefMerge, MarkingCode, MergeNilonToSmallBox, LotNoWithQty, LevelJIANGHAI, MergePackingId)
    SELECT MaterialLotNo, LotID, CompanyCode, WorkCenterCode, MaterialWarehouseCode, MaterialLocationCode, MaterialCode, MaterialStockAttribute, StockAttrib1, StockAttrib2, StockAttrib3, PackingID, GRDate, MaterialDeliveryNo, MaterialDeliveryDetailNo, InitialQty, CurrentQty, PickingQty, VendorLotNo, LifeBasicDate, ProductionDate, EndOfLifeDate, LotNo, IsSplitLot, BefMaterialLotNo, LotAttr01, LotAttr02, LotAttr03, LotAttr04, LotAttr05, LotAttr06, LotAttr07, LotAttr08, LotAttr09, LotAttr10, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, DateConfirmEx, HoldError, Holddate, HoldPeriod, PackingIdParent, IsSlitting, CheckTime, CheckUserID, IsCheck, LengthSlitting, IsParrent, IsConfirmInput, MergeParentId, CreateDateSlittingTime, InitialQtyBefMerge, CurrentQtyBefMerge, MarkingCode, MergeNilonToSmallBox, LotNoWithQty, LevelJIANGHAI, MergePackingId 
    FROM STB_MaterialLotInfo_BAK_VE260506
    WHERE PackingID IN ('PKQN2500089', 'PKQN2500091');

    -- 3. Khôi phục bảng chứng từ kho chính
    UPDATE MDI
    SET MDI.IsCancel = BAK.IsCancel,
        MDI.CancelDateTime = BAK.CancelDateTime,
        MDI.CancelUserID = BAK.CancelUserID
    FROM STB_MaterialDocInfo MDI
    INNER JOIN STB_MaterialDocInfo_BAK_VE260506 BAK ON MDI.MaterialDocNo = BAK.MaterialDocNo;

    -- 4. Khôi phục bảng chứng từ kho chi tiết
    DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo IN ('260525000095', '260525000097');
    INSERT INTO STB_MaterialDocLotInfo (MaterialDocDetailNo, MDLISeqNo, MaterialLotNo, LotID, MaterialCode, MaterialStockAttribute, StockAttrib1, StockAttrib2, StockAttrib3, StockQty, IsChecked, MaterialLocationCode, MaterialDocNo, PackingID, LotNo, VendorLotNo, LotAttr01, LotAttr02, LotAttr03, LotAttr04, LotAttr05, LotAttr06, LotAttr07, LotAttr08, LotAttr09, LotAttr10, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, SAMPArrived, IsIQCSampleLot, Isused, ISPRINTER, IsSlpitLot, MarkingCode, LevelJIANGHAI, PackDate)
    SELECT MaterialDocDetailNo, MDLISeqNo, MaterialLotNo, LotID, MaterialCode, MaterialStockAttribute, StockAttrib1, StockAttrib2, StockAttrib3, StockQty, IsChecked, MaterialLocationCode, MaterialDocNo, PackingID, LotNo, VendorLotNo, LotAttr01, LotAttr02, LotAttr03, LotAttr04, LotAttr05, LotAttr06, LotAttr07, LotAttr08, LotAttr09, LotAttr10, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, SAMPArrived, IsIQCSampleLot, Isused, ISPRINTER, IsSlpitLot, MarkingCode, LevelJIANGHAI, PackDate 
    FROM STB_MaterialDocLotInfo_BAK_VE260506
    WHERE MaterialDocNo IN ('260525000095', '260525000097');

    -- 5. Khôi phục lịch sử chốt công đoạn
    UPDATE PRH
    SET PRH.ProdQty = BAK.ProdQty
    FROM STB_ProdRouteHist PRH
    INNER JOIN STB_ProdRouteHist_BAK_VE260506 BAK ON PRH.ControlNo = BAK.ControlNo AND PRH.RouteCode = BAK.RouteCode;

    -- 6. Khôi phục tổng hợp sản lượng chốt ngày
    UPDATE PRS
    SET PRS.OutputQty = BAK.OutputQty
    FROM STB_ProdRouteSummary PRS
    INNER JOIN STB_ProdRouteSummary_BAK_VE260506 BAK ON PRS.ProductSummaryID = BAK.ProductSummaryID;

    -- 7. Khôi phục sản lượng PO
    UPDATE PO
    SET PO.ProdFinishQty = BAK.ProdFinishQty
    FROM STB_ProductionOrderInfo PO
    INNER JOIN STB_ProductionOrderInfo_BAK_VE260506 BAK ON PO.PONo = BAK.PONo;

    -- Bảng backup sẽ được giữ lại trong DB để đối chiếu, anh có thể xóa bảng (drop) thủ công sau.

    COMMIT TRANSACTION;
    PRINT 'Rollback completed and data restored successfully!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Error occurred during rollback: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
*/
