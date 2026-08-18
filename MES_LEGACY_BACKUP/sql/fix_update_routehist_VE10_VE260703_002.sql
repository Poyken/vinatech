-- ==============================================================================
-- FIX SCRIPT: UPDATE STB_ProdRouteHist FOR B523 / HN523 PACKING RECOVERY
-- LOT NO: VE260703-002 (ControlNo = 20260629000126)
-- ROUTE CODE: VE10 (Đóng gói)
-- PURPOSE: Reduce ProdQty of VE10 by 705 (from 9,234 down to 8,529) to reflect un-packed 705 Qty into "Slg còn lại"
-- REFERENCE SoT: KB_04_02_SCREEN_BUGS.md § 4.1 (Bước 3 - Cập nhật giảm sản lượng chốt công đoạn VE10)
-- ==============================================================================
USE [SmartFactoryV2];
GO

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. Kiểm tra sản lượng công đoạn VE10 trước khi sửa
    SELECT ControlNo, RouteCode, ProdQty 
    FROM dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = '20260629000126' AND RouteCode = 'VE10';

    -- 2. Cập nhật giảm 705 SP trên công đoạn VE10 (từ 9234 về 8529)
    UPDATE dbo.STB_ProdRouteHist
    SET ProdQty = 8529.00000
    WHERE ControlNo = '20260629000126' AND RouteCode = 'VE10';

    -- 3. Kiểm tra lại sản lượng công đoạn VE10 sau khi sửa
    SELECT ControlNo, RouteCode, ProdQty AS NewProdQtyVE10
    FROM dbo.STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = '20260629000126' AND RouteCode = 'VE10';

    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Đã cập nhật sản lượng công đoạn VE10 về 8529 thành công!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
