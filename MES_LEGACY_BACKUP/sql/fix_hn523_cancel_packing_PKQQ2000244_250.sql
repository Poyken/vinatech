-- ==============================================================================
-- FIX SCRIPT: HỦY 2 BOX ĐÓNG GÓI TẠI MÀN HÌNH HN523 (PKQQ2000244 & PKQQ2000250)
-- LOT NO: VE260813-004 | CONTROL_NO: 20260813000295 | PO NO: 260813000005
-- SỐ LƯỢNG HỦY: 376 + 342 = 718 CON (TRẢ LẠI SẢN LƯỢNG CHƯA ĐÓNG GÓI)
-- DATABASE: SmartFactoryV2
-- FILE: sql/fix_hn523_cancel_packing_PKQQ2000244_250.sql
-- ==============================================================================
USE SmartFactoryV2;
GO

-- ------------------------------------------------------------------------------
-- PHẦN 1: TẠO BẢNG BACKUP DỮ LIỆU ĐẦY ĐỦ TRƯỚC KHI XỬ LÝ
-- ------------------------------------------------------------------------------
IF OBJECT_ID('dbo.STB_MaterialLotInfo_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_MaterialLotInfo_BK_20260822_HN523 
    FROM dbo.STB_MaterialLotInfo WITH(NOLOCK) 
    WHERE MaterialLotNo IN ('20260820000403', '20260820000409')
       OR PackingID IN ('PKQQ2000244', 'PKQQ2000250');

IF OBJECT_ID('dbo.STB_MaterialDocInfo_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_MaterialDocInfo_BK_20260822_HN523 
    FROM dbo.STB_MaterialDocInfo WITH(NOLOCK) 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

IF OBJECT_ID('dbo.STB_MaterialDocDetail_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_MaterialDocDetail_BK_20260822_HN523 
    FROM dbo.STB_MaterialDocDetail WITH(NOLOCK) 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

IF OBJECT_ID('dbo.STB_MaterialDocLotInfo_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_MaterialDocLotInfo_BK_20260822_HN523 
    FROM dbo.STB_MaterialDocLotInfo WITH(NOLOCK) 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

IF OBJECT_ID('dbo.STB_ProdRouteHist_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_ProdRouteHist_BK_20260822_HN523 
    FROM dbo.STB_ProdRouteHist WITH(NOLOCK) 
    WHERE ControlNo = '20260813000295' AND RouteCode = 'VE10';

IF OBJECT_ID('dbo.STB_ProdRouteSummary_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_ProdRouteSummary_BK_20260822_HN523 
    FROM dbo.STB_ProdRouteSummary WITH(NOLOCK) 
    WHERE ProductSummaryID = '20260820000301';

IF OBJECT_ID('dbo.STB_ProductionOrderInfo_BK_20260822_HN523', 'U') IS NULL
    SELECT * INTO dbo.STB_ProductionOrderInfo_BK_20260822_HN523 
    FROM dbo.STB_ProductionOrderInfo WITH(NOLOCK) 
    WHERE PONo = '260813000005';
GO

-- ------------------------------------------------------------------------------
-- PHẦN 2: THỰC THI SỬA ĐỔI TRONG TRANSACTION VÀ COMMIT
-- ------------------------------------------------------------------------------
BEGIN TRANSACTION;
BEGIN TRY

    -- 1. Xóa 2 bản ghi sub-lot đóng gói trong STB_MaterialLotInfo
    DELETE FROM dbo.STB_MaterialLotInfo
    WHERE MaterialLotNo IN ('20260820000403', '20260820000409')
      AND PackingID IN ('PKQQ2000244', 'PKQQ2000250')
      AND LotNo = 'VE260813-004';

    -- 2. Hủy 2 chứng từ xuất nhập đóng gói trong MaterialDoc
    UPDATE dbo.STB_MaterialDocInfo 
    SET DocStatus = 'CREATE', IsCancel = 0 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

    SET CONTEXT_INFO 0x999997;
    DELETE FROM dbo.STB_MaterialDocLotInfo 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');
    SET CONTEXT_INFO 0;

    DELETE FROM dbo.STB_MaterialDocDetail 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

    UPDATE dbo.STB_MaterialDocInfo 
    SET IsCancel = 1, CancelDateTime = GETDATE(), CancelUserID = 'vanduc' 
    WHERE MaterialDocNo IN ('260820000261', '260820000267');

    -- 3. Giảm trừ sản lượng công đoạn đóng gói VE10 (-718 con, từ 5,718 -> 5,000)
    UPDATE dbo.STB_ProdRouteHist
    SET ProdQty = ProdQty - 718
    WHERE ControlNo = '20260813000295' AND RouteCode = 'VE10';

    -- 4. Giảm trừ bảng tổng hợp sản lượng ngày & lệnh sản xuất PO (-718 con, từ 31,242 -> 30,524)
    UPDATE dbo.STB_ProdRouteSummary
    SET OutputQty = OutputQty - 718
    WHERE ProductSummaryID = '20260820000301';

    UPDATE dbo.STB_ProductionOrderInfo
    SET ProdFinishQty = ProdFinishQty - 718
    WHERE PONo = '260813000005';

    COMMIT TRANSACTION;
    PRINT N'SUCCESS: Đã hủy thành công 2 packing PKQQ2000244 & PKQQ2000250!';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'LỖI: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
