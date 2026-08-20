-- =====================================================================================
-- MIGRATION SCRIPT: CHUYỂN 4 LOT HƯNG YÊN TỪ NGÀY 19/08/2026 VỀ NGÀY 18/08/2026
-- Date: 2026-08-19
-- Author: Antigravity (Pair Programming with vanduc)
-- Scope: STB_SetInfo (4 lots) & STB_ProdRouteHist (20 route steps)
-- Safety: Tự động tạo bảng BACKUP trước khi UPDATE, bọc TRY...CATCH Transaction an toàn
-- =====================================================================================

-- BƯỚC 1: TẠO BẢNG BACKUP DỮ LIỆU GỐC
IF OBJECT_ID('dbo.BAK_STB_SetInfo_4Lots_20260819') IS NOT NULL 
    DROP TABLE dbo.BAK_STB_SetInfo_4Lots_20260819;

SELECT * 
INTO dbo.BAK_STB_SetInfo_4Lots_20260819
FROM dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode IN ('VVQQ163R072734', 'VVQQ163R072735', 'VVQQ163R072736', 'VVQQ163R072737');

IF OBJECT_ID('dbo.BAK_STB_ProdRouteHist_4Lots_20260819') IS NOT NULL 
    DROP TABLE dbo.BAK_STB_ProdRouteHist_4Lots_20260819;

SELECT * 
INTO dbo.BAK_STB_ProdRouteHist_4Lots_20260819
FROM dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN ('20260819000315', '20260819000316', '20260819000317', '20260819000318');

PRINT '[BACKUP COMPLETE] Đã lưu bản sao vào BAK_STB_SetInfo_4Lots_20260819 và BAK_STB_ProdRouteHist_4Lots_20260819';


-- BƯỚC 2: THỰC THI UPDATE TRONG GIAO DỊCH AN TOÀN (TRANSACTION)
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @UpdatedSetInfo INT = 0;
    DECLARE @UpdatedRouteHist INT = 0;

    -- 1. Cập nhật STB_SetInfo cho 4 Lot
    UPDATE dbo.STB_SetInfo
    SET 
        InputJobDate   = '2026-08-18',
        DayPlanNo      = '2026081800056',
        CreateDateTime = DATEADD(DAY, -1, CreateDateTime),
        ChangeDateTime = GETDATE(),
        ChangeUserID   = 'vanduc'
    WHERE Barcode IN ('VVQQ163R072734', 'VVQQ163R072735', 'VVQQ163R072736', 'VVQQ163R072737');

    SET @UpdatedSetInfo = @@ROWCOUNT;

    -- 2. Cập nhật STB_ProdRouteHist (Lùi 1 ngày các công đoạn đã chạy V-22_HY -> V-26_HY)
    UPDATE dbo.STB_ProdRouteHist
    SET 
        ProdDateTime   = DATEADD(DAY, -1, ProdDateTime),
        CreateDateTime = DATEADD(DAY, -1, CreateDateTime),
        ChangeDateTime = GETDATE(),
        ChangeUserID   = 'vanduc'
    WHERE ControlNo IN ('20260819000315', '20260819000316', '20260819000317', '20260819000318');

    SET @UpdatedRouteHist = @@ROWCOUNT;

    -- Kiểm tra tính toàn vẹn: đúng 4 lot và đúng 20 công đoạn
    IF @UpdatedSetInfo <> 4 OR @UpdatedRouteHist <> 20
    BEGIN
        RAISERROR('Số lượng bản ghi cập nhật không khớp (SetInfo=%d, RouteHist=%d). Kích hoạt ROLLBACK!', 16, 1, @UpdatedSetInfo, @UpdatedRouteHist);
    END;

    COMMIT TRANSACTION;
    PRINT '[SUCCESS] Đã cập nhật thành công 4 Lot về ngày 18/08/2026!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '[FAILED] Lỗi xảy ra trong quá trình cập nhật. Đã ROLLBACK dữ liệu an toàn!';
    PRINT ERROR_MESSAGE();
END CATCH;

-- BƯỚC 3: TRUY VẤN ĐỐI SOÁT SAU KHI CẬP NHẬT
SELECT Barcode, ControlNo, MaterialCode, PONo, DayPlanNo, InputJobDate, CreateDateTime, ChangeDateTime, ChangeUserID
FROM dbo.STB_SetInfo WITH(NOLOCK)
WHERE Barcode IN ('VVQQ163R072734', 'VVQQ163R072735', 'VVQQ163R072736', 'VVQQ163R072737');

SELECT ControlNo, RouteCode, ProdQty, ProdDateTime, CompleteRoute, CreateDateTime, ChangeDateTime, ChangeUserID
FROM dbo.STB_ProdRouteHist WITH(NOLOCK)
WHERE ControlNo IN ('20260819000315', '20260819000316', '20260819000317', '20260819000318')
ORDER BY ControlNo, RouteCode;
