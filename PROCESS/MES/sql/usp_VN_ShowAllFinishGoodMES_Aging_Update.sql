-- ==============================================================================
-- SCRIPT CẬP NHẬT STORED PROCEDURE: usp_VN_ShowAllFinishGoodMES
-- MÀN HÌNH: [FG01] Thành phẩm Bắc Ninh
-- TÍNH TUỔI HÀNG TỒN KHO: Trả về duy nhất cột AgingDays (Số ngày tồn kho)
-- UI NAIS Grid sẽ dùng cột AgingDays để áp dụng FormatRules đổi màu tự động:
--   1. AgingDays >= 90  AND AgingDays < 180 ➔ Cảnh báo VÀNG (YELLOW)
--   2. AgingDays >= 180 AND AgingDays < 365 ➔ Cảnh báo XÁM (GRAY)
--   3. AgingDays >= 365                    ➔ Cảnh báo CAM (ORANGE)
-- ==============================================================================

USE [SmartFactoryV2]
GO

IF OBJECT_ID('dbo.usp_VN_ShowAllFinishGoodMES', 'P') IS NOT NULL
BEGIN
    PRINT 'Updating Stored Procedure [dbo].[usp_VN_ShowAllFinishGoodMES]...'
END
GO

ALTER PROCEDURE [dbo].[usp_VN_ShowAllFinishGoodMES]
    @pFromdateinput DATE = NULL,
    @pTodateinput DATE = NULL,
    @TypeInput NVARCHAR(50) = NULL,
    @pFromdateExp DATE = NULL,
    @pTodateExp DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FromDate DATE = @pFromdateinput
    DECLARE @ToDate DATE = @pTodateinput
    DECLARE @FromDateExp DATE = @pFromdateExp
    DECLARE @ToDateExp DATE = @pTodateExp
    DECLARE @Input NVARCHAR(50) = @TypeInput

    IF @Input = N'Nhập'
    BEGIN
        SELECT
            T1.CUSTOMERNAME,
            T1.TRANSPORT,
            T1.ID,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            T1.IDCODE,
            '' + REPLACE(T1.PublicCode, ' ', '') + '' AS PublicCode, 
            T1.Country,
            T1.PackingID,
            T1.LotNo,
            T1.MaterialCode,
            T1.MaterialName,
            T1.ProductionSize,
            T1.PackQty,
            T1.EmpNo,
            T1.CreatDatePacked AS PackedDate,
            RIGHT(T1.CreatDatePacked, 8) AS TimePacked,
            '' + REPLACE(T1.PartNo, ' ', '') + '' AS PartNo,
            T1.TypeProduction,
            T1.StatusSystem,
            T1.Statusout,
            T1.CreateDate AS CreateDateIn,
            RIGHT(T1.CreateDate, 8) AS TimeIn,
            T1.USERID AS PersonIn,
            T1.PersonExport,
            T1.DateExport AS DateExports,
            RIGHT(T1.DateExport, 8) AS TimeOute,
            T1.CreateDateChange AS CreateDateOut,
            RIGHT(T1.CreateDateChange, 8) AS TimeOuts,
            T1.USERIDChange AS PersonOut,
            T1.Descrption,
            T1.Levels,
            T1.LevelsOut,
            T1.INPUTFROM,
            T1.LOCATIONS,
            T1.TYPEEXPORT,

            -- CHỈ CẦN 1 CỘT AgingDays (Số ngày tồn kho từ ngày nhập CreateDate)
            DATEDIFF(DAY, CONVERT(DATE, T1.CreateDate), GETDATE()) AS AgingDays

        FROM STB_VN_FINISHGOODS_BG T1 (NOLOCK)
        WHERE T1.StatusSystem = N'Nhập'
          AND (T1.Statusout IS NULL OR T1.Statusout <> N'Xuất')
          AND (@FromDate IS NULL OR CONVERT(DATE, T1.CreateDate) >= @FromDate)
          AND (@ToDate IS NULL OR CONVERT(DATE, T1.CreateDate) <= @ToDate)
        ORDER BY T1.CreateDate DESC
    END
    ELSE IF @Input = N'Xuất'
    BEGIN
        SELECT
            T1.CUSTOMERNAME,
            T1.TRANSPORT,
            T1.ID,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            T1.IDCODE,
            '' + REPLACE(T1.PublicCode, ' ', '') + '' AS PublicCode, 
            T1.Country,
            T1.PackingID,
            T1.LotNo,
            T1.MaterialCode,
            T1.MaterialName,
            T1.ProductionSize,
            T1.PackQty,
            T1.EmpNo,
            T1.CreatDatePacked AS PackedDate,
            RIGHT(T1.CreatDatePacked, 8) AS TimePacked,
            '' + REPLACE(T1.PartNo, ' ', '') + '' AS PartNo,
            T1.TypeProduction,
            T1.StatusSystem,
            T1.Statusout,
            T1.CreateDate AS CreateDateIn,
            RIGHT(T1.CreateDate, 8) AS TimeIn,
            T1.USERID AS PersonIn,
            T1.PersonExport,
            T1.DateExport AS DateExports,
            RIGHT(T1.DateExport, 8) AS TimeOute,
            T1.CreateDateChange AS CreateDateOut,
            RIGHT(T1.CreateDateChange, 8) AS TimeOuts,
            T1.USERIDChange AS PersonOut,
            T1.Descrption,
            T1.Levels,
            T1.LevelsOut,
            T1.INPUTFROM,
            T1.LOCATIONS,
            T1.TYPEEXPORT,

            -- Số ngày tồn kho tính đến khi xuất
            DATEDIFF(DAY, CONVERT(DATE, T1.CreateDate), CONVERT(DATE, T1.DateExport)) AS AgingDays

        FROM STB_VN_FINISHGOODS_BG T1 (NOLOCK)
        WHERE T1.Statusout = N'Xuất'
          AND (@FromDateExp IS NULL OR CONVERT(DATE, T1.DateExport) >= @FromDateExp)
          AND (@ToDateExp IS NULL OR CONVERT(DATE, T1.DateExport) <= @ToDateExp)
        ORDER BY T1.DateExport DESC
    END
END
GO

PRINT 'Stored Procedure [dbo].[usp_VN_ShowAllFinishGoodMES] updated cleanly with AgingDays only.'
