-- ============================================================
-- DEPLOYMENT: BẢNG + SP CHO SHEET AL CASE (TÁCH RIÊNG)
-- Database: SmartFactoryV2
-- Phiên bản: Cập nhật IDENTITY PK & Date Format & Fix Error Message
-- Ngày tạo: 2026-04-23
-- ============================================================

USE SmartFactoryV2;
GO

-- ============================================================
-- BƯỚC 1: TẠO BẢNG STB_VVT_SortingErrorData_ALCase
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_VVT_SortingErrorData_ALCase')
    DROP TABLE STB_VVT_SortingErrorData_ALCase;
GO

CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase] (
    -- === KEY (IDENTITY 1,1) ===
    [SortingErrorNo]    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_STB_VVT_SortingErrorData_ALCase PRIMARY KEY,

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
    -- CÁC CỘT LỖI DÀNH CHO AL CASE
    -- ============================================================
    [ALBuiDust]         INT             NULL DEFAULT 0, -- Bụi
    [ALMoDent]          INT             NULL DEFAULT 0, -- Mố Dent
    [ALMepDeform]       INT             NULL DEFAULT 0, -- Mép Deform
    [ALXuocScratch]     INT             NULL DEFAULT 0, -- Xước Scratch
    [ALBongNBPlating]   INT             NULL DEFAULT 0, -- Bóng bu NB Plating
    [ALSanRoughFace]    INT             NULL DEFAULT 0, -- Sần Rough Face
    [ALBanDirty]        INT             NULL DEFAULT 0, -- Bẩn Dirty
    [ALBanBoDentGroup]  INT             NULL DEFAULT 0, -- Bẩn/Bọ Dent Group
    [ALBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc Discolor
    [ALLoiKhacOther]    INT             NULL DEFAULT 0, -- Lỗi khác Other

    -- === AUDIT ===
    [CreateDateTime]    DATETIME        NOT NULL DEFAULT GETDATE(),
    [CreateUserID]      VARCHAR(20)     NULL,
    [ChangeDateTime]    DATETIME        NULL,
    [ChangeUserID]      VARCHAR(20)     NULL
);

-- Index để search nhanh theo ngày
CREATE INDEX IX_VVT_SortingErrorData_ALCase_Date 
    ON STB_VVT_SortingErrorData_ALCase (SortingDate);

PRINT N'Tạo bảng STB_VVT_SortingErrorData_ALCase thành công!';
GO

-- ============================================================
-- BƯỚC 2A: TẠO SP SEARCH - usp_VVT_SortingErrorData_ALCase_get
-- ============================================================
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_ALCase_get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_ALCase_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_get]
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

        -- Lỗi AL Case
        SED.ALBuiDust, SED.ALMoDent, SED.ALMepDeform, SED.ALXuocScratch, SED.ALBongNBPlating,
        SED.ALSanRoughFace, SED.ALBanDirty, SED.ALBanBoDentGroup, SED.ALBienSacDiscolor, SED.ALLoiKhacOther,

        -- Tổng lỗi
        ISNULL(SED.ALBuiDust,0) + ISNULL(SED.ALMoDent,0) + ISNULL(SED.ALMepDeform,0)
        + ISNULL(SED.ALXuocScratch,0) + ISNULL(SED.ALBongNBPlating,0) + ISNULL(SED.ALSanRoughFace,0)
        + ISNULL(SED.ALBanDirty,0) + ISNULL(SED.ALBanBoDentGroup,0) + ISNULL(SED.ALBienSacDiscolor,0)
        + ISNULL(SED.ALLoiKhacOther,0) AS TotalDefect,

        SED.CreateDateTime, SED.CreateUserID, SED.ChangeDateTime, SED.ChangeUserID
    FROM STB_VVT_SortingErrorData_ALCase SED WITH(NOLOCK)
    WHERE
        (@pSortingDateFrom IS NULL OR SED.SortingDate >= @pSortingDateFrom)
        AND (@pSortingDateTo IS NULL OR SED.SortingDate <= @pSortingDateTo)
        AND (@pFactoryName IS NULL OR SED.FactoryName LIKE '%' + @pFactoryName + '%')
        AND (@pMaterialCode IS NULL OR SED.MaterialCode LIKE '%' + @pMaterialCode + '%')
    ORDER BY SED.SortingDate DESC, SED.SortingErrorNo DESC;
END
GO

PRINT N'Tạo SP usp_VVT_SortingErrorData_ALCase_get thành công!';
GO

-- ============================================================
-- BƯỚC 2B: TẠO SP INSERT/UPDATE/DELETE - usp_VVT_SortingErrorData_ALCase_iud
-- ============================================================
IF OBJECT_ID('dbo.usp_VVT_SortingErrorData_ALCase_iud', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_VVT_SortingErrorData_ALCase_iud;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
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
        DELETE T FROM STB_VVT_SortingErrorData_ALCase T
        JOIN OPENXML(@iDoc, @DeleteTableName, 2) WITH (SortingErrorNo INT) X
        ON T.SortingErrorNo = X.SortingErrorNo;

        -- INSERT
        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
            ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
            CreateUserID, CreateDateTime
        )
        SELECT 
            SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
            ALBuiDust, ALMoDent, ALMepDeform, ALXuocScratch, ALBongNBPlating, ALSanRoughFace, ALBanDirty, ALBanBoDentGroup, ALBienSacDiscolor, ALLoiKhacOther,
            @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            ALBuiDust INT, ALMoDent INT, ALMepDeform INT, ALXuocScratch INT, ALBongNBPlating INT, ALSanRoughFace INT, ALBanDirty INT, ALBanBoDentGroup INT, ALBienSacDiscolor INT, ALLoiKhacOther INT
        );

        -- UPDATE
        UPDATE T SET
            SortingDate = X.SortingDate, Shift = X.Shift, PersonName = X.PersonName, VendorCode = X.VendorCode, FactoryName = X.FactoryName,
            MaterialCode = X.MaterialCode, LotNo = X.LotNo, QtyCheck = X.QtyCheck, QtyOK = X.QtyOK, Remark = X.Remark,
            ALBuiDust = X.ALBuiDust, ALMoDent = X.ALMoDent, ALMepDeform = X.ALMepDeform, ALXuocScratch = X.ALXuocScratch, ALBongNBPlating = X.ALBongNBPlating,
            ALSanRoughFace = X.ALSanRoughFace, ALBanDirty = X.ALBanDirty, ALBanBoDentGroup = X.ALBanBoDentGroup, ALBienSacDiscolor = X.ALBienSacDiscolor, ALLoiKhacOther = X.ALLoiKhacOther,
            ChangeUserID = @pProcessUserID, ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        JOIN OPENXML(@iDoc, @UpdateTableName, 2) WITH (
            SortingErrorNo INT, SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            ALBuiDust INT, ALMoDent INT, ALMepDeform INT, ALXuocScratch INT, ALBongNBPlating INT, ALSanRoughFace INT, ALBanDirty INT, ALBanBoDentGroup INT, ALBienSacDiscolor INT, ALLoiKhacOther INT
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

PRINT N'Tạo SP usp_VVT_SortingErrorData_ALCase_iud thành công!';
GO
