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
            t1.TRANSPORT,
            T1.ID,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            IDCODE,
            '' + REPLACE(PublicCode, ' ', '') + '' AS PublicCode, 
            Country,
            PackingID,
            LotNo,
            T1.MaterialCode,
            MaterialName,
            ProductionSize,
            PackQty,
            EmpNo,
            CreatDatePacked AS PackedDate,
            RIGHT(CreatDatePacked, 8) AS TimePacked,
            '' + REPLACE(PartNo, ' ', '') + '' AS PartNo,
            TypeProduction,
            StatusSystem,
            Statusout,
            CreateDate AS CreateDateIn,
            RIGHT(CreateDate, 8) AS TimeIn,
            USERID AS PersonIn,
            PersonExport,
            DateExport AS DateExports,
            RIGHT(DateExport, 8) AS TimeOute,
            CreateDateChange AS CreateDateOut,
            RIGHT(CreateDateChange, 8) AS TimeOuts,
            USERIDChange AS PersonOut,
            Descrption,
            Levels,
            LevelsOut,
            INPUTFROM,
            LOCATIONS,
            TYPEEXPORT,

            -- CHỈ CẦN 1 CỘT AgingDays (Số ngày tồn kho từ ngày nhập CreateDate)
            DATEDIFF(DAY, CONVERT(DATE, T1.CreateDate), GETDATE()) AS AgingDays

        FROM STB_VN_FINISHGOODS_BG T1 (NOLOCK)
        LEFT JOIN STB_MaterialMaster m (NOLOCK) ON T1.MaterialCode = m.MaterialCode
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
            t1.TRANSPORT,
            T1.ID,
            T1.SoPhieuNhapKho,
            T1.SoPhieuXuatKho,
            T1.SoInVoice,
            T1.SoToKhaiHaiQuan,
            IDCODE,
            '' + REPLACE(PublicCode, ' ', '') + '' AS PublicCode, 
            Country,
            PackingID,
            LotNo,
            T1.MaterialCode,
            MaterialName,
            ProductionSize,
            PackQty,
            EmpNo,
            CreatDatePacked AS PackedDate,
            RIGHT(CreatDatePacked, 8) AS TimePacked,
            '' + REPLACE(PartNo, ' ', '') + '' AS PartNo,
            TypeProduction,
            StatusSystem,
            Statusout,
            CreateDate AS CreateDateIn,
            RIGHT(CreateDate, 8) AS TimeIn,
            USERID AS PersonIn,
            PersonExport,
            DateExport AS DateExports,
            RIGHT(DateExport, 8) AS TimeOute,
            CreateDateChange AS CreateDateOut,
            RIGHT(CreateDateChange, 8) AS TimeOuts,
            USERIDChange AS PersonOut,
            Descrption,
            Levels,
            LevelsOut,
            INPUTFROM,
            LOCATIONS,
            TYPEEXPORT,

            -- Số ngày tồn kho tính đến khi xuất
            DATEDIFF(DAY, CONVERT(DATE, T1.CreateDate), CONVERT(DATE, T1.DateExport)) AS AgingDays

        FROM STB_VN_FINISHGOODS_BG T1 (NOLOCK)
        LEFT JOIN STB_MaterialMaster m (NOLOCK) ON T1.MaterialCode = m.MaterialCode
        WHERE T1.Statusout = N'Xuất'
          AND (@FromDateExp IS NULL OR CONVERT(DATE, T1.DateExport) >= @FromDateExp)
          AND (@ToDateExp IS NULL OR CONVERT(DATE, T1.DateExport) <= @ToDateExp)
        ORDER BY T1.DateExport DESC
    END
END
GO

PRINT 'Stored Procedure [dbo].[usp_VN_ShowAllFinishGoodMES] updated cleanly with AgingDays only.'
