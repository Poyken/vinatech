-- ============================================================
-- DEPLOYMENT: BẢNG + SP CHO SHEET PLATE (TÁCH RIÊNG)
-- Database: SmartFactoryV2
-- Người tạo: EA Team
-- Ngày tạo: 2026-04-23
-- Màn hình: SRT_D00 - Sorting Error Data (Plate)
-- Gốc từ: STB_VVT_SortingErrorData (bảng gộp)
-- ============================================================

USE SmartFactoryV2;
GO

-- ============================================================
-- BƯỚC 1: TẠO BẢNG STB_VVT_SortingErrorData_Plate
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'STB_VVT_SortingErrorData_Plate')
BEGIN

    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate] (
        -- === KEY ===
        [SortingErrorNo]    VARCHAR(20)     NOT NULL CONSTRAINT PK_STB_VVT_SortingErrorData_Plate PRIMARY KEY,

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
        -- CÁC CỘT LỖI DÀNH CHO PLATE
        -- ============================================================
        [PLBuuNhom]         INT             NULL DEFAULT 0, -- Bựu nhôm
        [PLBuuNhua]         INT             NULL DEFAULT 0, -- Bựu Nhựa
        [PLBuuRandom]       INT             NULL DEFAULT 0, -- Bựu random
        [PLBongTamNhieu]    INT             NULL DEFAULT 0, -- Bóng tâm nhều
        [PLXuocScratch]     INT             NULL DEFAULT 0, -- Xước/Scratch
        [PLBienDangDeform]  INT             NULL DEFAULT 0, -- Biến dạng/Deform
        [PLMoDongExposed]   INT             NULL DEFAULT 0, -- Mở dòng/Exposed
        [PLBienDangCamSu]   INT             NULL DEFAULT 0, -- Biến dạng cạm su
        [PLNutGoCrackWood]  INT             NULL DEFAULT 0, -- Nứt gỗ/Crack Wood
        [PLBienSacDiscolor] INT             NULL DEFAULT 0, -- Biến sắc/Discoloration
        [PLOther]           INT             NULL DEFAULT 0, -- Other

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
END
ELSE
BEGIN
    PRINT N'Bảng STB_VVT_SortingErrorData_Plate đã tồn tại, bỏ qua.';
END
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
        SED.SortingDate,
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
        SED.PLBuuNhom, SED.PLBuuNhua, SED.PLBuuRandom, SED.PLBongTamNhieu, SED.PLXuocScratch,
        SED.PLBienDangDeform, SED.PLMoDongExposed, SED.PLBienDangCamSu, SED.PLNutGoCrackWood, 
        SED.PLBienSacDiscolor, SED.PLOther,

        -- Tổng lỗi
        ISNULL(SED.PLBuuNhom,0) + ISNULL(SED.PLBuuNhua,0) + ISNULL(SED.PLBuuRandom,0)
        + ISNULL(SED.PLBongTamNhieu,0) + ISNULL(SED.PLXuocScratch,0) + ISNULL(SED.PLBienDangDeform,0)
        + ISNULL(SED.PLMoDongExposed,0) + ISNULL(SED.PLBienDangCamSu,0) + ISNULL(SED.PLNutGoCrackWood,0)
        + ISNULL(SED.PLBienSacDiscolor,0) + ISNULL(SED.PLOther,0) AS TotalDefect,

        SED.CreateDateTime, SED.CreateUserID, SED.ChangeDateTime, SED.ChangeUserID
    FROM STB_VVT_SortingErrorData_Plate SED WITH(NOLOCK)
    WHERE
        (@pSortingDateFrom IS NULL OR SED.SortingDate >= @pSortingDateFrom)
        AND (@pSortingDateTo IS NULL OR SED.SortingDate <= @pSortingDateTo)
        AND (@pFactoryName IS NULL OR SED.FactoryName LIKE '%' + @pFactoryName + '%')
        AND (@pMaterialCode IS NULL OR SED.MaterialCode LIKE '%' + @pMaterialCode + '%')

    ORDER BY SortingDate DESC, SortingErrorNo DESC;
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
    DECLARE @iDoc INT
    DECLARE @SortingErrorNo VARCHAR(20)
    DECLARE @ERROR_MSG NVARCHAR(MAX)

    -- Khai báo các biến tương ứng với cột của bảng
    DECLARE
        @OldSortingErrorNo  VARCHAR(20),
        @SortingDate        DATE,
        @Shift              VARCHAR(5),
        @PersonName         NVARCHAR(100),
        @VendorCode         VARCHAR(50),
        @FactoryName        NVARCHAR(100),
        @MaterialCode       VARCHAR(50),
        @LotNo              VARCHAR(100),
        @QtyCheck           INT,
        @QtyOK              INT,
        @Remark             NVARCHAR(200),
        @PLBuuNhom          INT, @PLBuuNhua           INT, @PLBuuRandom        INT,
        @PLBongTamNhieu     INT, @PLXuocScratch        INT, @PLBienDangDeform   INT,
        @PLMoDongExposed    INT, @PLBienDangCamSu      INT, @PLNutGoCrackWood   INT,
        @PLBienSacDiscolor  INT, @PLOther              INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
        BEGIN TRANSACTION;

        -- ============================================================
        -- XỬ LÝ INSERT
        -- ============================================================
        DECLARE cur_insert CURSOR FOR
        SELECT
            OldSortingErrorNo, SortingErrorNo, SortingDate, Shift, PersonName,
            VendorCode, FactoryName, MaterialCode, LotNo, 
            QtyCheck, QtyOK, Remark,
            PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch,
            PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood,
            PLBienSacDiscolor, PLOther
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            OldSortingErrorNo  VARCHAR(20),  SortingErrorNo  VARCHAR(20),
            SortingDate        DATE,          Shift           VARCHAR(5),
            PersonName         NVARCHAR(100), VendorCode      VARCHAR(50),
            FactoryName        NVARCHAR(100), MaterialCode    VARCHAR(50),
            LotNo              VARCHAR(100),  
            QtyCheck           INT,           QtyOK           INT,
            Remark             NVARCHAR(200),
            PLBuuNhom          INT,  PLBuuNhua           INT,  PLBuuRandom        INT,
            PLBongTamNhieu     INT,  PLXuocScratch        INT,  PLBienDangDeform   INT,
            PLMoDongExposed    INT,  PLBienDangCamSu      INT,  PLNutGoCrackWood   INT,
            PLBienSacDiscolor  INT,  PLOther              INT
        )

        OPEN cur_insert
        FETCH NEXT FROM cur_insert INTO
            @OldSortingErrorNo, @SortingErrorNo, @SortingDate, @Shift, @PersonName,
            @VendorCode, @FactoryName, @MaterialCode, @LotNo, 
            @QtyCheck, @QtyOK, @Remark,
            @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
            @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
            @PLBienSacDiscolor, @PLOther

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Validate bắt buộc
            IF ISNULL(@SortingDate, '') = '' 
            BEGIN
                RAISERROR(N'Ngày Sorting không được để trống!', 16, 1);
                RETURN;
            END

            -- Tạo serial number mới
            EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VVT_SortingErrorData_Plate', @SortingErrorNo OUTPUT

            INSERT INTO STB_VVT_SortingErrorData_Plate (
                SortingErrorNo, SortingDate, Shift, PersonName, VendorCode, FactoryName,
                MaterialCode, LotNo, QtyCheck, QtyOK, Remark,
                PLBuuNhom, PLBuuNhua, PLBuuRandom, PLBongTamNhieu, PLXuocScratch,
                PLBienDangDeform, PLMoDongExposed, PLBienDangCamSu, PLNutGoCrackWood,
                PLBienSacDiscolor, PLOther,
                CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
            )
            VALUES (
                @SortingErrorNo, @SortingDate, @Shift, @PersonName, @VendorCode, @FactoryName,
                @MaterialCode, @LotNo, @QtyCheck, @QtyOK, @Remark,
                @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
                @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
                @PLBienSacDiscolor, @PLOther,
                GETDATE(), @pProcessUserID, GETDATE(), @pProcessUserID
            )

            FETCH NEXT FROM cur_insert INTO
                @OldSortingErrorNo, @SortingErrorNo, @SortingDate, @Shift, @PersonName,
                @VendorCode, @FactoryName, @MaterialCode, @LotNo, 
                @QtyCheck, @QtyOK, @Remark,
                @PLBuuNhom, @PLBuuNhua, @PLBuuRandom, @PLBongTamNhieu, @PLXuocScratch,
                @PLBienDangDeform, @PLMoDongExposed, @PLBienDangCamSu, @PLNutGoCrackWood,
                @PLBienSacDiscolor, @PLOther
        END
        CLOSE cur_insert; DEALLOCATE cur_insert;

        -- ============================================================
        -- XỬ LÝ UPDATE
        -- ============================================================
        UPDATE T SET
            SortingDate        = ISNULL(X.SortingDate, T.SortingDate),
            Shift              = X.Shift,
            PersonName         = X.PersonName,
            VendorCode         = X.VendorCode,
            FactoryName        = X.FactoryName,
            MaterialCode       = X.MaterialCode,
            LotNo              = X.LotNo,
            QtyCheck           = X.QtyCheck,
            QtyOK              = X.QtyOK,
            Remark             = X.Remark,
            PLBuuNhom          = X.PLBuuNhom,
            PLBuuNhua          = X.PLBuuNhua,
            PLBuuRandom        = X.PLBuuRandom,
            PLBongTamNhieu     = X.PLBongTamNhieu,
            PLXuocScratch      = X.PLXuocScratch,
            PLBienDangDeform   = X.PLBienDangDeform,
            PLMoDongExposed    = X.PLMoDongExposed,
            PLBienDangCamSu    = X.PLBienDangCamSu,
            PLNutGoCrackWood   = X.PLNutGoCrackWood,
            PLBienSacDiscolor  = X.PLBienSacDiscolor,
            PLOther            = X.PLOther,
            ChangeDateTime     = GETDATE(),
            ChangeUserID       = @pProcessUserID
        FROM STB_VVT_SortingErrorData_Plate T
        JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 2) WITH (
                OldSortingErrorNo  VARCHAR(20),  SortingDate DATE, Shift VARCHAR(5),
                PersonName NVARCHAR(100), VendorCode VARCHAR(50), FactoryName NVARCHAR(100),
                MaterialCode VARCHAR(50), LotNo VARCHAR(100), 
                QtyCheck INT, QtyOK INT, Remark NVARCHAR(200),
                PLBuuNhom INT, PLBuuNhua INT, PLBuuRandom INT, PLBongTamNhieu INT,
                PLXuocScratch INT, PLBienDangDeform INT, PLMoDongExposed INT,
                PLBienDangCamSu INT, PLNutGoCrackWood INT, PLBienSacDiscolor INT, PLOther INT
            )
        ) X ON T.SortingErrorNo = X.OldSortingErrorNo;

        -- ============================================================
        -- XỬ LÝ DELETE
        -- ============================================================
        DELETE T
        FROM STB_VVT_SortingErrorData_Plate T
        JOIN (
            SELECT OldSortingErrorNo
            FROM OPENXML(@iDoc, @DeleteTableName, 2) WITH (OldSortingErrorNo VARCHAR(20))
        ) X ON T.SortingErrorNo = X.OldSortingErrorNo;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH
END
GO

PRINT N'Tạo SP usp_VVT_SortingErrorData_Plate_iud thành công!';
GO

-- ============================================================
-- BƯỚC 3: ĐĂNG KÝ SERIAL RULE (SmartFramework)
-- ============================================================
USE SmartFramework;
GO

IF NOT EXISTS (
    SELECT 1 FROM dbo.STB_SerialRule WHERE TableName = 'STB_VVT_SortingErrorData_Plate'
)
BEGIN
    INSERT INTO dbo.STB_SerialRule (TableName, SerialColumnName, PrefixData, SerialLen, IsAutoKey, IsLoopIUD, UseYN)
    VALUES ('STB_VVT_SortingErrorData_Plate', 'SortingErrorNo', 'SPL', 17, 1, 0, 'Y');
    PRINT N'Đã đăng ký Serial Rule cho STB_VVT_SortingErrorData_Plate.';
END
ELSE
    PRINT N'Serial Rule đã tồn tại.';
GO

-- ============================================================
-- BƯỚC 4: KIỂM TRA KẾT QUẢ
-- ============================================================
USE SmartFactoryV2;
GO

-- 4.1 Kiểm tra bảng tồn tại
SELECT 
    'TABLE EXISTS' AS CheckType,
    name AS ObjectName, 
    create_date
FROM sys.tables 
WHERE name = 'STB_VVT_SortingErrorData_Plate';

-- 4.2 Kiểm tra 2 SP tồn tại
SELECT 
    'SP EXISTS' AS CheckType,
    name AS ObjectName,
    create_date,
    modify_date
FROM sys.procedures 
WHERE name IN ('usp_VVT_SortingErrorData_Plate_get', 'usp_VVT_SortingErrorData_Plate_iud');

-- 4.3 Test gọi SP Search
EXEC usp_VVT_SortingErrorData_Plate_get
    @pProcessUserID   = 'vinaadmin',
    @pProcessLanguage = 'VI',
    @pProcessViewName = 'SortingDataPlate',
    @pSortingDateFrom = '2026-01-01',
    @pSortingDateTo   = '2026-12-31',
    @pFactoryName     = NULL,
    @pMaterialCode    = NULL;
GO

PRINT N'=== DEPLOYMENT PLATE HOÀN TẤT! ===';
GO
