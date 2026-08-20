-- =====================================================================================
-- ROLLBACK SCRIPT: KHÔI PHỤC 4 LOT HƯNG YÊN TỪ BẢNG BACKUP VỀ TRẠNG THÁI GỐC (19/08/2026)
-- Date: 2026-08-19
-- Author: Antigravity (Pair Programming with vanduc)
-- Scope: STB_SetInfo & STB_ProdRouteHist khôi phục từ BAK tables
-- =====================================================================================

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Khôi phục STB_SetInfo từ bảng Backup
    UPDATE SI
    SET 
        SI.InputJobDate   = BAK.InputJobDate,
        SI.DayPlanNo      = BAK.DayPlanNo,
        SI.CreateDateTime = BAK.CreateDateTime,
        SI.ChangeDateTime = BAK.ChangeDateTime,
        SI.ChangeUserID   = BAK.ChangeUserID
    FROM dbo.STB_SetInfo SI
    INNER JOIN dbo.BAK_STB_SetInfo_4Lots_20260819 BAK ON SI.Barcode = BAK.Barcode;

    -- 2. Khôi phục STB_ProdRouteHist từ bảng Backup
    UPDATE PRH
    SET 
        PRH.ProdDateTime   = BAK.ProdDateTime,
        PRH.CreateDateTime = BAK.CreateDateTime,
        PRH.ChangeDateTime = BAK.ChangeDateTime,
        PRH.ChangeUserID   = BAK.ChangeUserID
    FROM dbo.STB_ProdRouteHist PRH
    INNER JOIN dbo.BAK_STB_ProdRouteHist_4Lots_20260819 BAK ON PRH.ControlNo = BAK.ControlNo AND PRH.RouteCode = BAK.RouteCode;

    COMMIT TRANSACTION;
    PRINT '[ROLLBACK SUCCESS] Đã khôi phục hoàn toàn 4 Lot về trạng thái gốc ngày 19/08/2026!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '[ROLLBACK FAILED] Có lỗi xảy ra trong quá trình khôi phục:';
    PRINT ERROR_MESSAGE();
END CATCH;

-- Truy vấn kiểm tra sau khi khôi phục
SELECT Barcode, ControlNo, InputJobDate, DayPlanNo, CreateDateTime 
FROM dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode IN ('VVQQ163R072734', 'VVQQ163R072735', 'VVQQ163R072736', 'VVQQ163R072737');

SELECT ControlNo, RouteCode, ProdDateTime, CreateDateTime 
FROM dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN ('20260819000315', '20260819000316', '20260819000317', '20260819000318')
ORDER BY ControlNo, RouteCode;
