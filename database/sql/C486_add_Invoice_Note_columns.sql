-- ============================================================
-- C486 ErrorDataSorting: Thêm cột Invoice (trước LotNo) và Note (sau Total)
-- Áp dụng cho: STB_VVT_SortingErrorData_ALCase + STB_VVT_SortingErrorData_Plate
-- Ngày: 2026-05-21  |  Yêu cầu: chị Thu QC
-- LƯU Ý: ALTER TABLE chỉ THÊM cột mới, data cũ KHÔNG bị mất
-- ============================================================

USE SmartFactoryV2;
GO

-- ============================================================
-- BƯỚC 1: TẠO LẠI BẢNG ĐÚNG THỨ TỰ CỘT (data cũ giữ nguyên)
-- Lý do: SQL Server không hỗ trợ ALTER COLUMN để đổi vị trí.
-- Cách duy nhất: tạo bảng mới đúng thứ tự → copy data → drop cũ → rename.
-- ============================================================

-- ============================================================
-- 1A. BẢNG ALCase: thứ tự đúng
--     ... MaterialCode | Invoice | LotNo | ... | Total | Note | ...
-- ============================================================
BEGIN TRANSACTION;
BEGIN TRY

    -- Tạo bảng tạm với đúng thứ tự cột
    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (
        [ID]              INT             IDENTITY(1,1) NOT NULL,
        [Date]            DATE            NULL,
        [Shift]           NVARCHAR(10)    NULL,
        [Person]          NVARCHAR(100)   NULL,
        [Vendor]          NVARCHAR(100)   NULL,
        [Factory]         NVARCHAR(100)   NULL,
        [MaterialCode]    NVARCHAR(50)    NULL,
        [Invoice]         NVARCHAR(100)   NULL,   -- << CỘT MỚI: trước LotNo
        [LotNo]           NVARCHAR(50)    NULL,
        [QtyCheck]        INT             NULL,
        [QtyOK]           INT             NULL,
        [BurrAl]          INT             NULL,
        [BurrPlastic]     INT             NULL,
        [BurrRubber]      INT             NULL,
        [PlasticPeeling]  INT             NULL,
        [Scratch]         INT             NULL,
        [Deform]          INT             NULL,
        [ExposedCopper]   INT             NULL,
        [RubberDeform]    INT             NULL,
        [CrackWood]       INT             NULL,
        [Discoloration]   INT             NULL,
        [OtherError]      INT             NULL,
        [Total]           INT             NULL,
        [Note]            NVARCHAR(500)   NULL,   -- << CỘT MỚI: sau Total
        [CreateUserID]    VARCHAR(20)     NULL,
        [CreateDateTime]  DATETIME        NULL,
        [ChangeUserID]    VARCHAR(20)     NULL,
        [ChangeDateTime]  DATETIME        NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_ALCase_NEW] PRIMARY KEY CLUSTERED ([ID] ASC)
    );

    -- Copy toàn bộ data cũ (Invoice và Note sẽ = NULL cho record cũ)
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] (
        ID, [Date], Shift, Person, Vendor, Factory, MaterialCode,
        Invoice, LotNo, QtyCheck, QtyOK,
        BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform,
        ExposedCopper, RubberDeform, CrackWood, Discoloration, OtherError, Total,
        Note, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
    )
    SELECT
        ID, [Date], Shift, Person, Vendor, Factory, MaterialCode,
        NULL AS Invoice, LotNo, QtyCheck, QtyOK,
        BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform,
        ExposedCopper, RubberDeform, CrackWood, Discoloration, OtherError, Total,
        NULL AS Note, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
    FROM [dbo].[STB_VVT_SortingErrorData_ALCase];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_ALCase_NEW] OFF;

    -- Drop bảng cũ và rename bảng mới
    DROP TABLE [dbo].[STB_VVT_SortingErrorData_ALCase];
    EXEC sp_rename 'STB_VVT_SortingErrorData_ALCase_NEW', 'STB_VVT_SortingErrorData_ALCase';
    EXEC sp_rename 'PK_STB_VVT_SortingErrorData_ALCase_NEW', 'PK_STB_VVT_SortingErrorData_ALCase';

    COMMIT TRANSACTION;
    PRINT 'BƯỚC 1A DONE: Bảng ALCase đã được tạo lại đúng thứ tự cột, data cũ giữ nguyên.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'LỖI BƯỚC 1A: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

-- ============================================================
-- 1B. BẢNG Plate: thứ tự đúng
--     ... MaterialCode | Invoice | LotNo | ... | Total | Note | ...
-- ============================================================
BEGIN TRANSACTION;
BEGIN TRY

    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate_NEW] (
        [ID]            INT             IDENTITY(1,1) NOT NULL,
        [Date]          DATE            NULL,
        [Shift]         NVARCHAR(10)    NULL,
        [Person]        NVARCHAR(100)   NULL,
        [Vendor]        NVARCHAR(100)   NULL,
        [Factory]       NVARCHAR(100)   NULL,
        [MaterialCode]  NVARCHAR(50)    NULL,
        [Invoice]       NVARCHAR(100)   NULL,   -- << CỘT MỚI: trước LotNo
        [LotNo]         NVARCHAR(50)    NULL,
        [QtyCheck]      INT             NULL,
        [QtyOK]         INT             NULL,
        [Burr]          INT             NULL,
        [Dent]          INT             NULL,
        [Deform]        INT             NULL,
        [Scratch]       INT             NULL,
        [NGPlating]     INT             NULL,
        [RoughFace]     INT             NULL,
        [Dirty]         INT             NULL,
        [DentBottom]    INT             NULL,
        [Discolor]      INT             NULL,
        [OtherError]    INT             NULL,
        [Total]         INT             NULL,
        [Note]          NVARCHAR(500)   NULL,   -- << CỘT MỚI: sau Total
        [CreateUserID]  VARCHAR(20)     NULL,
        [CreateDateTime] DATETIME       NULL,
        [ChangeUserID]  VARCHAR(20)     NULL,
        [ChangeDateTime] DATETIME       NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_Plate_NEW] PRIMARY KEY CLUSTERED ([ID] ASC)
    );

    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_Plate_NEW] ON;
    INSERT INTO [dbo].[STB_VVT_SortingErrorData_Plate_NEW] (
        ID, [Date], Shift, Person, Vendor, Factory, MaterialCode,
        Invoice, LotNo, QtyCheck, QtyOK,
        Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total,
        Note, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
    )
    SELECT
        ID, [Date], Shift, Person, Vendor, Factory, MaterialCode,
        NULL AS Invoice, LotNo, QtyCheck, QtyOK,
        Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total,
        NULL AS Note, CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
    FROM [dbo].[STB_VVT_SortingErrorData_Plate];
    SET IDENTITY_INSERT [dbo].[STB_VVT_SortingErrorData_Plate_NEW] OFF;

    DROP TABLE [dbo].[STB_VVT_SortingErrorData_Plate];
    EXEC sp_rename 'STB_VVT_SortingErrorData_Plate_NEW', 'STB_VVT_SortingErrorData_Plate';
    EXEC sp_rename 'PK_STB_VVT_SortingErrorData_Plate_NEW', 'PK_STB_VVT_SortingErrorData_Plate';

    COMMIT TRANSACTION;
    PRINT 'BƯỚC 1B DONE: Bảng Plate đã được tạo lại đúng thứ tự cột, data cũ giữ nguyên.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'LỖI BƯỚC 1B: ' + ERROR_MESSAGE();
    THROW;
END CATCH
GO

-- ============================================================
-- BƯỚC 2: CẬP NHẬT SP GET - ALCase
-- ============================================================
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_get]
    @pFrom_Date          NVARCHAR(10) = NULL,
    @pToDate_            NVARCHAR(10) = NULL,
    @pMaterial_Code      NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, MaterialCode AS [Material Code], MaterialCode AS [Marterial],
        -- Invoice trước LotNo
        Invoice,
        LotNo, LotNo AS [Lot no],
        -- Ép kiểu VARCHAR để Grid linh hoạt khi Import dữ liệu từ Excel (tránh lỗi Int32)
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck], CAST([QtyCheck] AS VARCHAR(10)) AS [Q'Ty Check],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK], CAST([QtyOK] AS VARCHAR(10)) AS [Q'ty OK],
        CAST([BurrAl] AS VARCHAR(10)) AS [BurrAl], CAST([BurrAl] AS VARCHAR(10)) AS [Burr nhômBurr Al],
        CAST([BurrPlastic] AS VARCHAR(10)) AS [BurrPlastic], CAST([BurrPlastic] AS VARCHAR(10)) AS [Burr NhựaBurr Plastic],
        CAST([BurrRubber] AS VARCHAR(10)) AS [BurrRubber], CAST([BurrRubber] AS VARCHAR(10)) AS [Burr caosu],
        CAST([PlasticPeeling] AS VARCHAR(10)) AS [PlasticPeeling], CAST([PlasticPeeling] AS VARCHAR(10)) AS [Bong tấm nhựa],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch], CAST([Scratch] AS VARCHAR(10)) AS [Xước Scratch],
        CAST([Deform] AS VARCHAR(10)) AS [Deform], CAST([Deform] AS VARCHAR(10)) AS [Biến dạngDeform],
        CAST([ExposedCopper] AS VARCHAR(10)) AS [ExposedCopper], CAST([ExposedCopper] AS VARCHAR(10)) AS [Hở đồngExposed copper],
        CAST([RubberDeform] AS VARCHAR(10)) AS [RubberDeform], CAST([RubberDeform] AS VARCHAR(10)) AS [Biến dạng cao suDeform caosu],
        CAST([CrackWood] AS VARCHAR(10)) AS [CrackWood], CAST([CrackWood] AS VARCHAR(10)) AS [Nứt gỗCrack Wood],
        CAST([Discoloration] AS VARCHAR(10)) AS [Discoloration], CAST([Discoloration] AS VARCHAR(10)) AS [Biến sắcDiscoloration],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError], CAST([OtherError] AS VARCHAR(10)) AS [Other],
        CAST([Total] AS VARCHAR(10)) AS [Total],
        -- Note sau Total
        Note,
        [Status] = ''
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
PRINT 'BƯỚC 2 DONE: usp_VVT_SortingErrorData_ALCase_get đã cập nhật.'
GO

-- ============================================================
-- BƯỚC 3: CẬP NHẬT SP IUD - ALCase
-- ============================================================
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_ALCase') + '_DELETE'
    DECLARE @iDoc INT
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. XỬ LÝ XÓA (DELETE)
        DELETE T FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (
            SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)
        ) S ON T.ID = S.ID;

        -- B. XỬ LÝ CẬP NHẬT (UPDATE)
        UPDATE T SET 
            T.[Date] = S.[Date], T.[Shift] = S.[Shift], T.Person = S.Person, T.Vendor = S.Vendor, T.Factory = S.Factory,
            T.MaterialCode = S.MaterialCode, T.Invoice = S.Invoice, T.LotNo = S.LotNo,
            T.QtyCheck = S.QtyCheck, T.QtyOK = S.QtyOK,
            T.BurrAl = S.BurrAl, T.BurrPlastic = S.BurrPlastic, T.BurrRubber = S.BurrRubber, T.PlasticPeeling = S.PlasticPeeling,
            T.Scratch = S.Scratch, T.Deform = S.Deform, T.ExposedCopper = S.ExposedCopper, T.RubberDeform = S.RubberDeform,
            T.CrackWood = S.CrackWood, T.Discoloration = S.Discoloration, T.OtherError = S.OtherError, T.Total = S.Total,
            T.Note = S.Note,
            T.ChangeUserID = @pProcessUserID, T.ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT, [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50), QtyCheck INT, QtyOK INT,
                BurrAl INT, BurrPlastic INT, BurrRubber INT, PlasticPeeling INT, Scratch INT, Deform INT,
                ExposedCopper INT, RubberDeform INT, CrackWood INT, Discoloration INT, OtherError INT, Total INT,
                Note NVARCHAR(500)
            )
        ) S ON T.ID = S.ID;

        -- C. XỬ LÝ LƯU MỚI (INSERT)
        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            [Date], [Shift], [Person], [Vendor], [Factory], MaterialCode, Invoice, LotNo, [QtyCheck], [QtyOK], 
            BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, 
            RubberDeform, CrackWood, Discoloration, OtherError, Total, Note,
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            COALESCE(T.D1, T.D2, GETDATE()), T.[Shift], 
            COALESCE(T.atP, T.Person), 
            COALESCE(T.atV, T.Vendor), 
            COALESCE(T.atF, T.Factory), 
            COALESCE(T.A_Mat, T.A_MatU, T.A_MatS, T.MaterialCode, T.Material_Code, T.Marterial),
            T.Invoice,
            COALESCE(T.A_Lot, T.LotNo, T.Lot_no), 
            ISNULL(TRY_CAST(COALESCE(T.A_QC, T.QtyCheck) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_QO, T.QtyOK) AS INT), 0),
            ISNULL(TRY_CAST(COALESCE(T.A_B1, T.BurrAl) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_B2, T.BurrPlastic) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB3, T.BurrRubber) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB4, T.PlasticPeeling) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB5, T.Scratch) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB6, T.Deform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB7, T.ExposedCopper) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB8, T.RubberDeform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB9, T.CrackWood) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB10, T.Discoloration) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB11, T.OtherError) AS INT), 0),
            ISNULL(TRY_CAST(T.Total AS INT), 0),
            T.Note,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            D1 DATE '@Date', D2 DATE 'Date', [Date] DATE, [Shift] NVARCHAR(50), 
            atP NVARCHAR(100) '@Person', Person NVARCHAR(100),
            atV NVARCHAR(100) '@Vendor', Vendor NVARCHAR(100),
            atF NVARCHAR(100) '@Factory', Factory NVARCHAR(100),
            A_Mat NVARCHAR(100) '@MaterialCode', A_MatU NVARCHAR(100) '@Material_Code', A_MatS NVARCHAR(100) '@Material_x0020_Code', 
            MaterialCode NVARCHAR(100), Material_Code NVARCHAR(100), Marterial NVARCHAR(100),
            Invoice NVARCHAR(100),
            A_Lot NVARCHAR(100) '@LotNo', LotNo NVARCHAR(100), Lot_no NVARCHAR(100),
            A_QC VARCHAR(50) '@QtyCheck', QtyCheck VARCHAR(50),
            A_QO VARCHAR(50) '@QtyOK', QtyOK VARCHAR(50),
            A_B1 VARCHAR(50) '@BurrAl', BurrAl VARCHAR(50),
            A_B2 VARCHAR(50) '@BurrPlastic', BurrPlastic VARCHAR(50),
            atB3 VARCHAR(50) '@BurrRubber', BurrRubber VARCHAR(50),
            atB4 VARCHAR(50) '@PlasticPeeling', PlasticPeeling VARCHAR(50),
            atB5 VARCHAR(50) '@Scratch', Scratch VARCHAR(50),
            atB6 VARCHAR(50) '@Deform', Deform VARCHAR(50),
            atB7 VARCHAR(50) '@ExposedCopper', ExposedCopper VARCHAR(50),
            atB8 VARCHAR(50) '@RubberDeform', RubberDeform VARCHAR(50),
            atB9 VARCHAR(50) '@CrackWood', CrackWood VARCHAR(50),
            atB10 VARCHAR(50) '@Discoloration', Discoloration VARCHAR(50),
            atB11 VARCHAR(50) '@OtherError', OtherError VARCHAR(50),
            Total VARCHAR(50),
            Note NVARCHAR(500)
        ) AS T
        WHERE COALESCE(T.D1, T.D2, T.A_Mat, T.MaterialCode, T.Marterial) IS NOT NULL;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
PRINT 'BƯỚC 3 DONE: usp_VVT_SortingErrorData_ALCase_iud đã cập nhật.'
GO

-- ============================================================
-- BƯỚC 4: CẬP NHẬT SP GET - Plate
-- ============================================================
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @pFrom_Date          NVARCHAR(10) = NULL,
    @pToDate_            NVARCHAR(10) = NULL,
    @pMaterial_Code      NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, MaterialCode AS [Material Code], MaterialCode AS [Marterial],
        -- Invoice trước LotNo
        Invoice,
        LotNo, LotNo AS [Lot no],
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck], CAST([QtyCheck] AS VARCHAR(10)) AS [Q'Ty Check],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK], CAST([QtyOK] AS VARCHAR(10)) AS [Q'ty OK],
        CAST([Burr] AS VARCHAR(10)) AS [Burr],
        CAST([Dent] AS VARCHAR(10)) AS [Dent], CAST([Dent] AS VARCHAR(10)) AS [MẻDent],
        CAST([Deform] AS VARCHAR(10)) AS [Deform], CAST([Deform] AS VARCHAR(10)) AS [MópDeform],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch], CAST([Scratch] AS VARCHAR(10)) AS [XướcScratch],
        CAST([NGPlating] AS VARCHAR(10)) AS [NGPlating], CAST([NGPlating] AS VARCHAR(10)) AS [Bong mạNG Plating],
        CAST([RoughFace] AS VARCHAR(10)) AS [RoughFace], CAST([RoughFace] AS VARCHAR(10)) AS [SầnRough face],
        CAST([Dirty] AS VARCHAR(10)) AS [Dirty], CAST([Dirty] AS VARCHAR(10)) AS [BẩnDirty],
        CAST([DentBottom] AS VARCHAR(10)) AS [DentBottom], CAST([DentBottom] AS VARCHAR(10)) AS [Lõm đáyDent Bottom],
        CAST([Discolor] AS VARCHAR(10)) AS [Discolor], CAST([Discolor] AS VARCHAR(10)) AS [Biến sắcDiscolor],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError], CAST([OtherError] AS VARCHAR(10)) AS [Lỗi khácOther],
        CAST([Total] AS VARCHAR(10)) AS [Total],
        -- Note sau Total
        Note,
        [Status] = ''
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
PRINT 'BƯỚC 4 DONE: usp_VVT_SortingErrorData_Plate_get đã cập nhật.'
GO

-- ============================================================
-- BƯỚC 5: CẬP NHẬT SP IUD - Plate
-- ============================================================
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + ISNULL(@pProcessViewName, 'VVT_SortingErrorData_Plate') + '_DELETE'
    DECLARE @iDoc INT
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. XỬ LÝ XÓA (DELETE)
        DELETE T FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (
            SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)
        ) S ON T.ID = S.ID;

        -- B. XỬ LÝ CẬP NHẬT (UPDATE)
        UPDATE T SET 
            T.[Date] = S.[Date], T.[Shift] = S.[Shift], T.Person = S.Person, T.Vendor = S.Vendor, T.Factory = S.Factory,
            T.MaterialCode = S.MaterialCode, T.Invoice = S.Invoice, T.LotNo = S.LotNo,
            T.QtyCheck = S.QtyCheck, T.QtyOK = S.QtyOK,
            T.Burr = S.Burr, T.Dent = S.Dent, T.Deform = S.Deform, T.Scratch = S.Scratch, T.NGPlating = S.NGPlating,
            T.RoughFace = S.RoughFace, T.Dirty = S.Dirty, T.DentBottom = S.DentBottom, T.Discolor = S.Discolor,
            T.OtherError = S.OtherError, T.Total = S.Total,
            T.Note = S.Note,
            T.ChangeUserID = @pProcessUserID, T.ChangeDateTime = GETDATE()
        FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (
            SELECT * FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT, [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50), QtyCheck INT, QtyOK INT,
                Burr INT, Dent INT, Deform INT, Scratch INT, NGPlating INT, RoughFace INT,
                Dirty INT, DentBottom INT, Discolor INT, OtherError INT, Total INT,
                Note NVARCHAR(500)
            )
        ) S ON T.ID = S.ID;

        -- C. XỬ LÝ LƯU MỚI (INSERT)
        INSERT INTO STB_VVT_SortingErrorData_Plate (
            [Date], [Shift], [Person], [Vendor], [Factory], MaterialCode, Invoice, LotNo, [QtyCheck], [QtyOK], 
            Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total, Note,
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            COALESCE(T.D1, T.D2, GETDATE()), T.[Shift], 
            COALESCE(T.atP, T.Person), 
            COALESCE(T.atV, T.Vendor), 
            COALESCE(T.atF, T.Factory), 
            COALESCE(T.A_Mat, T.A_MatU, T.A_MatS, T.MaterialCode, T.Material_Code, T.Marterial),
            T.Invoice,
            COALESCE(T.A_Lot, T.LotNo, T.Lot_no), 
            ISNULL(TRY_CAST(COALESCE(T.A_QC, T.QtyCheck) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_QO, T.QtyOK) AS INT), 0),
            ISNULL(TRY_CAST(COALESCE(T.A_B1, T.Burr) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.A_B2, T.Dent) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB3, T.Deform) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB4, T.Scratch) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB5, T.NGPlating) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB6, T.RoughFace) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB7, T.Dirty) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB8, T.DentBottom) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB9, T.Discolor) AS INT), 0), 
            ISNULL(TRY_CAST(COALESCE(T.atB10, T.OtherError) AS INT), 0),
            ISNULL(TRY_CAST(T.Total AS INT), 0),
            T.Note,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            D1 DATE '@Date', D2 DATE 'Date', [Date] DATE, [Shift] NVARCHAR(50), 
            atP NVARCHAR(100) '@Person', Person NVARCHAR(100),
            atV NVARCHAR(100) '@Vendor', Vendor NVARCHAR(100),
            atF NVARCHAR(100) '@Factory', Factory NVARCHAR(100),
            A_Mat NVARCHAR(100) '@MaterialCode', A_MatU NVARCHAR(100) '@Material_Code', A_MatS NVARCHAR(100) '@Material_x0020_Code', 
            MaterialCode NVARCHAR(100), Material_Code NVARCHAR(100), Marterial NVARCHAR(100),
            Invoice NVARCHAR(100),
            A_Lot NVARCHAR(100) '@LotNo', LotNo NVARCHAR(100), Lot_no NVARCHAR(100),
            A_QC VARCHAR(50) '@QtyCheck', QtyCheck VARCHAR(50),
            A_QO VARCHAR(50) '@QtyOK', QtyOK VARCHAR(50),
            A_B1 VARCHAR(50) '@Burr', Burr VARCHAR(50),
            A_B2 VARCHAR(50) '@Dent', Dent VARCHAR(50),
            atB3 VARCHAR(50) '@Deform', Deform VARCHAR(50),
            atB4 VARCHAR(50) '@Scratch', Scratch VARCHAR(50),
            atB5 VARCHAR(50) '@NGPlating', NGPlating VARCHAR(50),
            atB6 VARCHAR(50) '@RoughFace', RoughFace VARCHAR(50),
            atB7 VARCHAR(50) '@Dirty', Dirty VARCHAR(50),
            atB8 VARCHAR(50) '@DentBottom', DentBottom VARCHAR(50),
            atB9 VARCHAR(50) '@Discolor', Discolor VARCHAR(50),
            atB10 VARCHAR(50) '@OtherError', OtherError VARCHAR(50),
            Total VARCHAR(50),
            Note NVARCHAR(500)
        ) AS T
        WHERE COALESCE(T.D1, T.D2, T.A_Mat, T.MaterialCode, T.Marterial) IS NOT NULL;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO
PRINT 'BƯỚC 5 DONE: usp_VVT_SortingErrorData_Plate_iud đã cập nhật.'
GO

-- ============================================================
-- KIỂM TRA SAU KHI CHẠY
-- ============================================================
-- Xác nhận cột đã thêm vào 2 bảng:
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('STB_VVT_SortingErrorData_ALCase','STB_VVT_SortingErrorData_Plate')
  AND COLUMN_NAME IN ('Invoice','Note')
ORDER BY TABLE_NAME, COLUMN_NAME;
