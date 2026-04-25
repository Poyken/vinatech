-- ============================================================
-- DEPLOYMENT: BẢNG + SP CHO SHEET AL CASE (TÁCH RIÊNG)
-- Database: SmartFactoryV2
-- Phiên bản: Sửa lỗi map nhầm tên cột (mapping đúng theo file Excel AL Case)
-- Ngày tạo: 2026-04-24
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
    -- CÁC CỘT LỖI DÀNH CHO AL CASE (Dựa theo Sheet 1)
    -- ============================================================
    [ALBurrNhom]        INT             NULL DEFAULT 0, -- Burr nhôm Burr Al
    [ALBurrNhua]        INT             NULL DEFAULT 0, -- Burr Nhựa Burr Plastic
    [ALBurrCaoSu]       INT             NULL DEFAULT 0, -- Burr caosu
    [ALBongTamNhua]     INT             NULL DEFAULT 0, -- Bóng tấm nhựa
    [ALXuocScratch]     INT             NULL DEFAULT 0, -- Xước Scratch
    [ALBienDangDeform]  INT             NULL DEFAULT 0, -- Biến dạng Deform
    [ALHoDongExposed]   INT             NULL DEFAULT 0, -- Hở dòng Exposed copper
    [ALBienDangCaoSu]   INT             NULL DEFAULT 0, -- Biến dạng cao su Deform caosu
    [ALNutGoCrackWood]  INT             NULL DEFAULT 0, -- Nứt gỗ Crack Wood
    [ALBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc Discoloration
    [ALOther]           INT             NULL DEFAULT 0, -- Other

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
        SED.ALBurrNhom, SED.ALBurrNhua, SED.ALBurrCaoSu, SED.ALBongTamNhua, SED.ALXuocScratch,
        SED.ALBienDangDeform, SED.ALHoDongExposed, SED.ALBienDangCaoSu, SED.ALNutGoCrackWood, SED.ALBienSacDiscolor, SED.ALOther,

        -- Tổng lỗi
        ISNULL(SED.ALBurrNhom,0) + ISNULL(SED.ALBurrNhua,0) + ISNULL(SED.ALBurrCaoSu,0)
        + ISNULL(SED.ALBongTamNhua,0) + ISNULL(SED.ALXuocScratch,0) + ISNULL(SED.ALBienDangDeform,0)
        + ISNULL(SED.ALHoDongExposed,0) + ISNULL(SED.ALBienDangCaoSu,0) + ISNULL(SED.ALNutGoCrackWood,0)
        + ISNULL(SED.ALBienSacDiscolor,0) + ISNULL(SED.ALOther,0) AS TotalDefect,

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
            ALBurrNhom, ALBurrNhua, ALBurrCaoSu, ALBongTamNhua, ALXuocScratch, ALBienDangDeform, ALHoDongExposed, ALBienDangCaoSu, ALNutGoCrackWood, ALBienSacDiscolor, ALOther,
            CreateUserID, CreateDateTime
        )
        SELECT 
            SortingDate, Shift, PersonName, VendorCode, FactoryName, MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
            ALBurrNhom, ALBurrNhua, ALBurrCaoSu, ALBongTamNhua, ALXuocScratch, ALBienDangDeform, ALHoDongExposed, ALBienDangCaoSu, ALNutGoCrackWood, ALBienSacDiscolor, ALOther,
            @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            ALBurrNhom INT, ALBurrNhua INT, ALBurrCaoSu INT, ALBongTamNhua INT, ALXuocScratch INT, ALBienDangDeform INT, ALHoDongExposed INT, ALBienDangCaoSu INT, ALNutGoCrackWood INT, ALBienSacDiscolor INT, ALOther INT
        );

        -- UPDATE
        UPDATE T SET
            SortingDate = X.SortingDate, Shift = X.Shift, PersonName = X.PersonName, VendorCode = X.VendorCode, FactoryName = X.FactoryName,
            MaterialCode = X.MaterialCode, LotNo = X.LotNo, QtyCheck = X.QtyCheck, QtyOK = X.QtyOK, Remark = X.Remark,
            ALBurrNhom = X.ALBurrNhom, ALBurrNhua = X.ALBurrNhua, ALBurrCaoSu = X.ALBurrCaoSu, ALBongTamNhua = X.ALBongTamNhua, ALXuocScratch = X.ALXuocScratch,
            ALBienDangDeform = X.ALBienDangDeform, ALHoDongExposed = X.ALHoDongExposed, ALBienDangCaoSu = X.ALBienDangCaoSu, ALNutGoCrackWood = X.ALNutGoCrackWood, ALBienSacDiscolor = X.ALBienSacDiscolor, ALOther = X.ALOther,
            ChangeUserID = @pProcessUserID, ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        JOIN OPENXML(@iDoc, @UpdateTableName, 2) WITH (
            SortingErrorNo INT, SortingDate DATE, Shift VARCHAR(5), PersonName NVARCHAR(100), VendorCode VARCHAR(50), 
            FactoryName NVARCHAR(100), MaterialCode VARCHAR(50), LotNo VARCHAR(100), QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
            ALBurrNhom INT, ALBurrNhua INT, ALBurrCaoSu INT, ALBongTamNhua INT, ALXuocScratch INT, ALBienDangDeform INT, ALHoDongExposed INT, ALBienDangCaoSu INT, ALNutGoCrackWood INT, ALBienSacDiscolor INT, ALOther INT
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
