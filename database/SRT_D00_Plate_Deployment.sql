-- ============================================================
-- DEPLOYMENT: BẢNG + SP CHO SHEET PLATE (TÁCH RIÊNG)
-- Database: SmartFactoryV2
-- Phiên bản: Sửa lỗi map nhầm tên cột (mapping đúng theo file Excel Plate)
-- Ngày tạo: 2026-04-24
-- ============================================================

USE SmartFactoryV2;
GO

-- ============================================================
-- BƯỚC 1: TẠO BẢNG STB_VVT_SortingErrorData_Plate
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_VVT_SortingErrorData_Plate')
    DROP TABLE STB_VVT_SortingErrorData_Plate;
GO

CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate] (
    -- === KEY (IDENTITY 1,1) ===
    [SortingErrorNo]    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_STB_VVT_SortingErrorData_Plate PRIMARY KEY,

    -- === THÔNG TIN CHUNG ===
    [SortingDate]       DATE            NOT NULL,
    [Shift]             VARCHAR(5)      NULL,           -- A / B / C
    [PersonName]        NVARCHAR(100)   NULL,           -- Tên người sorting
    [VendorCode]        VARCHAR(50)     NULL,           -- Nhà cung cấp
    [FactoryName]       NVARCHAR(100)   NULL,           -- Bắc Ninh / Bắc Giang
    [MaterialCode]      VARCHAR(50)     NULL,           -- Mã vật liệu (VD: 3505, 685)
    [LotNo]             VARCHAR(100)    NULL,           -- Số lô
    [QtyCheck]          INT             NULL DEFAULT 0, -- Tổng SL kiểm tra
    [QtyOK]             INT             NULL DEFAULT 0, -- SL đạt
    [Remark]            NVARCHAR(200)   NULL,           -- Ghi chú

    -- ============================================================
    -- CÁC CỘT LỖI DÀNH CHO PLATE (Dựa theo Sheet 2)
    -- ============================================================
    [PLBurr]            INT             NULL DEFAULT 0, -- Burr
    [PLMoDent]          INT             NULL DEFAULT 0, -- Mố Dent
    [PLMepDeform]       INT             NULL DEFAULT 0, -- Mép Deform
    [PLXuocScratch]     INT             NULL DEFAULT 0, -- Xước Scratch
    [PLBongMaNG]        INT             NULL DEFAULT 0, -- Bóng mạ NG Plating
    [PLSanRoughFace]    INT             NULL DEFAULT 0, -- Sần Rough Face
    [PLBanDirty]        INT             NULL DEFAULT 0, -- Bẩn Dirty
    [PLLomDayDentBottom]INT             NULL DEFAULT 0, -- Lõm đáy Dent Bottom
    [PLBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc Discolor
    [PLOther]           INT             NULL DEFAULT 0, -- Lỗi khác Other

    -- === AUDIT ===
    [CreateDateTime]    DATETIME        NOT NULL DEFAULT GETDATE(),
    [CreateUserID]      VARCHAR(20)     NULL,
    [ChangeDateTime]    DATETIME        NULL,
    [ChangeUserID]      VARCHAR(20)     NULL
);

-- Index để search nhanh theo ngày
CREATE INDEX IX_VVT_SortingErrorData_Plate_Date 
    ON STB_VVT_SortingErrorData_Plate (SortingDate);

PRINT N'Tạo bảng STB_VVT_SortingErrorData_Plate thành công!';
GO

-- ============================================================
-- BƯỚC 2A: TẠO SP SEARCH - usp_VVT_SortingErrorData_Plate_get
-- ============================================================
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_Plate_get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_Plate_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @pProcessUserID     VARCHAR(20)    = NULL,
    @pProcessLanguage   VARCHAR(20)    = NULL,
    @pProcessViewName   VARCHAR(50)    = NULL,
    @pSortingDateFrom   DATE           = NULL,
    @pSortingDateTo     DATE           = NULL,
    @pFactoryName       NVARCHAR(100)  = NULL,
    @pMaterialCode      VARCHAR(50)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SED.SortingErrorNo,
        CONVERT(VARCHAR(10), SED.SortingDate, 23) AS SortingDate, -- Format YYYY-MM-DD
        SED.Shift,
        SED.PersonName,
        SED.VendorCode,
        SED.FactoryName,
        SED.MaterialCode,
        SED.LotNo,
        SED.QtyCheck,
        SED.QtyOK,
        SED.Remark,

        -- Lỗi Plate
        SED.PLBurr, SED.PLMoDent, SED.PLMepDeform, SED.PLXuocScratch, SED.PLBongMaNG,
        SED.PLSanRoughFace, SED.PLBanDirty, SED.PLLomDayDentBottom, SED.PLBienSacDiscolor, SED.PLOther,

        -- Tổng lỗi
        ISNULL(SED.PLBurr,0) + ISNULL(SED.PLMoDent,0) + ISNULL(SED.PLMepDeform,0)
        + ISNULL(SED.PLXuocScratch,0) + ISNULL(SED.PLBongMaNG,0) + ISNULL(SED.PLSanRoughFace,0)
        + ISNULL(SED.PLBanDirty,0) + ISNULL(SED.PLLomDayDentBottom,0) + ISNULL(SED.PLBienSacDiscolor,0)
        + ISNULL(SED.PLOther,0) AS TotalDefect,

        SED.CreateDateTime, SED.CreateUserID, SED.ChangeDateTime, SED.ChangeUserID
    FROM STB_VVT_SortingErrorData_Plate SED WITH(NOLOCK)
    WHERE
        (@pSortingDateFrom IS NULL OR SED.SortingDate >= @pSortingDateFrom)
        AND (@pSortingDateTo IS NULL OR SED.SortingDate <= @pSortingDateTo)
        AND (@pFactoryName IS NULL OR SED.FactoryName LIKE '%' + @pFactoryName + '%')
        AND (@pMaterialCode IS NULL OR SED.MaterialCode LIKE '%' + @pMaterialCode + '%')
    ORDER BY SED.SortingDate DESC, SED.SortingErrorNo DESC;
END
GO

PRINT N'Tạo SP usp_VVT_SortingErrorData_Plate_get thành công!';
GO

-- ============================================================
-- BƯỚC 2B: TẠO SP INSERT/UPDATE/DELETE - usp_VVT_SortingErrorData_Plate_iud
-- ============================================================
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_Plate_iud', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_Plate_iud;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @pProcessUserID     VARCHAR(20)   = NULL,
    @pProcessLanguage   VARCHAR(20)   = NULL,
    @pProcessViewName   VARCHAR(50)   = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
    DECLARE @iDoc INT;
    DECLARE @ErrorMsg NVARCHAR(MAX);

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- DELETE
        DELETE T FROM STB_VVT_SortingErrorData_Plate T
        JOIN OPENXML(@iDoc, @DeleteTableName, 2) WITH (SortingErrorNo INT) X
        ON T.SortingErrorNo = X.SortingErrorNo;

        -- INSERT
        INSERT INTO STB_VVT_SortingErrorData_Plate (
            SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
            PLBurr, PLMoDent, PLMepDeform, PLXuocScratch, PLBongMaNG, PLSanRoughFace, PLBanDirty, PLLomDayDentBottom, PLBienSacDiscolor, PLOther,
            CreateUserID, CreateDateTime
        )
        SELECT 
            SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
            PLBurr, PLMoDent, PLMepDeform, PLXuocScratch, PLBongMaNG, PLSanRoughFace, PLBanDirty, PLLomDayDentBottom, PLBienSacDiscolor, PLOther,
            @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            PLBurr INT, PLMoDent INT, PLMepDeform INT, PLXuocScratch INT, PLBongMaNG INT, PLSanRoughFace INT, PLBanDirty INT, PLLomDayDentBottom INT, PLBienSacDiscolor INT, PLOther INT
        );

        -- UPDATE
        UPDATE T SET
            SortingDate = X.SortingDate, Shift = X.Shift, PersonName = X.PersonName, VendorCode = X.VendorCode, FactoryName = X.FactoryName,
            MaterialCode = X.MaterialCode, LotNo = X.LotNo, QtyCheck = X.QtyCheck, QtyOK = X.QtyOK, Remark = X.Remark,
            PLBurr = X.PLBurr, PLMoDent = X.PLMoDent, PLMepDeform = X.PLMepDeform, PLXuocScratch = X.PLXuocScratch,
            PLBongMaNG = X.PLBongMaNG, PLSanRoughFace = X.PLSanRoughFace, PLBanDirty = X.PLBanDirty, PLLomDayDentBottom = X.PLLomDayDentBottom, PLBienSacDiscolor = X.PLBienSacDiscolor, PLOther = X.PLOther,
            ChangeUserID = @pProcessUserID, ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_Plate T
        JOIN OPENXML(@iDoc, @UpdateTableName, 2) WITH (
            SortingErrorNo INT, SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            PLBurr INT, PLMoDent INT, PLMepDeform INT, PLXuocScratch INT, PLBongMaNG INT, PLSanRoughFace INT, PLBanDirty INT, PLLomDayDentBottom INT, PLBienSacDiscolor INT, PLOther INT
        ) X ON T.SortingErrorNo = X.SortingErrorNo;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ErrorMsg = ERROR_MESSAGE();
        RAISERROR(@ErrorMsg, 16, 1);
    END CATCH

    EXEC sp_xml_removedocument @iDoc;
END
GO

PRINT N'Tạo SP usp_VVT_SortingErrorData_Plate_iud thành công!';
GO
