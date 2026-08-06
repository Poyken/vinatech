-- ======================================================
-- SCRIPT XÓA CÔNG ĐOẠN VE08 & VE09 CHO BARCODE VE260710-002
-- (Đúng chính xác các bước theo chỉ đạo của User)
-- 1. Xóa trong STB_DefectRepairInfo (FindRouteCode IN VE08, VE09)
-- 2. Xóa trong STB_ProdRouteHist (RouteCode IN VE08, VE09)
-- 3. Update công đoạn trước đó: CompleteRoute = NULL
-- ======================================================
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Barcode NVARCHAR(50) = 'VE260710-002';
    DECLARE @ControlNo NVARCHAR(50);

    -- Lấy ControlNo của Barcode
    SELECT TOP 1 @ControlNo = ControlNo FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = @Barcode;

    -- 1. Xóa bản ghi phế NG tại VE08 và VE09 trong STB_DefectRepairInfo
    DELETE FROM STB_DefectRepairInfo 
    WHERE ControlNo = @ControlNo 
      AND FindRouteCode IN ('VE08', 'VE09', 'Ve08', 'Ve09');

    -- 2. Xóa lịch sử routing VE08 và VE09 trong STB_ProdRouteHist
    DELETE FROM STB_ProdRouteHist 
    WHERE ControlNo = @ControlNo 
      AND RouteCode IN ('VE08', 'VE09', 'Ve08', 'Ve09');

    -- 3. Update công đoạn trước đó: CompleteRoute = NULL
    UPDATE STB_ProdRouteHist
    SET CompleteRoute = NULL
    WHERE ControlNo = @ControlNo 
      AND RouteCode IN ('VE07', 'Ve07');

    -- Tra cứu đối soát kết quả
    SELECT Barcode, ControlNo, DefectQty, IsDefect 
    FROM STB_SetInfo WITH(NOLOCK) 
    WHERE Barcode = @Barcode;

    SELECT RouteCode, ProdQty, CompleteRoute, CreateDateTime 
    FROM STB_ProdRouteHist WITH(NOLOCK)
    WHERE ControlNo = @ControlNo
    ORDER BY CreateDateTime ASC;

    -- Đổi 'ROLLBACK' thành 'COMMIT' khi muốn lưu chính thức trên SSMS
    ROLLBACK TRANSACTION;
    PRINT 'Thực thi thử nghiệm thành công (Rollback).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Lỗi: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
