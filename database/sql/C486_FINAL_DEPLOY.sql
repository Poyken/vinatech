USE SmartFactoryV2;
GO

-----------------------------------------------------------------------------------------
-- PART 1: RECREATE TABLES (Keep original table names, clean physical structure)
-----------------------------------------------------------------------------------------

-- 1A: Recreate ALCase table
BEGIN TRANSACTION;
BEGIN TRY
    IF OBJECT_ID('[dbo].[STB_VVT_SortingErrorData_ALCase]', 'U') IS NOT NULL
        DROP TABLE [dbo].[STB_VVT_SortingErrorData_ALCase];

    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_ALCase] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NULL, [Shift] NVARCHAR(10) NULL, [Person] NVARCHAR(100) NULL,
        [Vendor] NVARCHAR(100) NULL, [Factory] NVARCHAR(100) NULL,
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL,
        [LotNo] NVARCHAR(50) NULL,
        [QtyCheck] INT NULL, [QtyOK] INT NULL,
        [BurrAl] INT NULL, [BurrPlastic] INT NULL, [BurrRubber] INT NULL,
        [PlasticPeeling] INT NULL, [Scratch] INT NULL, [Deform] INT NULL,
        [ExposedCopper] INT NULL, [RubberDeform] INT NULL, [CrackWood] INT NULL,
        [Discoloration] INT NULL, [OtherError] INT NULL, [Total] INT NULL,
        [Note] NVARCHAR(500) NULL,
        [CreateUserID] VARCHAR(20) NULL, [CreateDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL, [ChangeDateTime] DATETIME NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_ALCase] PRIMARY KEY CLUSTERED ([ID])
    );
    COMMIT TRANSACTION;
    PRINT 'OK: ALCase table recreated';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'FAILED ALCase recreation: ' + ERROR_MESSAGE(); THROW;
END CATCH
GO

-- 1B: Recreate Plate table
BEGIN TRANSACTION;
BEGIN TRY
    IF OBJECT_ID('[dbo].[STB_VVT_SortingErrorData_Plate]', 'U') IS NOT NULL
        DROP TABLE [dbo].[STB_VVT_SortingErrorData_Plate];

    CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate] (
        [ID] INT IDENTITY(1,1) NOT NULL,
        [Date] DATE NULL, [Shift] NVARCHAR(10) NULL, [Person] NVARCHAR(100) NULL,
        [Vendor] NVARCHAR(100) NULL, [Factory] NVARCHAR(100) NULL,
        [MaterialCode] NVARCHAR(50) NULL,
        [Invoice] NVARCHAR(100) NULL,
        [LotNo] NVARCHAR(50) NULL,
        [QtyCheck] INT NULL, [QtyOK] INT NULL,
        [Burr] INT NULL, [Dent] INT NULL, [Deform] INT NULL, [Scratch] INT NULL,
        [NGPlating] INT NULL, [RoughFace] INT NULL, [Dirty] INT NULL,
        [DentBottom] INT NULL, [Discolor] INT NULL, [OtherError] INT NULL,
        [Total] INT NULL,
        [Note] NVARCHAR(500) NULL,
        [CreateUserID] VARCHAR(20) NULL, [CreateDateTime] DATETIME NULL,
        [ChangeUserID] VARCHAR(20) NULL, [ChangeDateTime] DATETIME NULL,
        CONSTRAINT [PK_STB_VVT_SortingErrorData_Plate] PRIMARY KEY CLUSTERED ([ID])
    );
    COMMIT TRANSACTION;
    PRINT 'OK: Plate table recreated';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'FAILED Plate recreation: ' + ERROR_MESSAGE(); THROW;
END CATCH
GO

-----------------------------------------------------------------------------------------
-- PART 2: UPDATE 4 SPs (Remove duplicate columns, map directly with pure English names)
-----------------------------------------------------------------------------------------

-- 2.1 ALCase GET
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_get]
    @pFrom_Date NVARCHAR(10)=NULL, @pToDate_ NVARCHAR(10)=NULL, @pMaterial_Code NVARCHAR(50)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode,
        Invoice,
        LotNo,
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK],
        CAST([BurrAl] AS VARCHAR(10)) AS [BurrAl],
        CAST([BurrPlastic] AS VARCHAR(10)) AS [BurrPlastic],
        CAST([BurrRubber] AS VARCHAR(10)) AS [BurrRubber],
        CAST([PlasticPeeling] AS VARCHAR(10)) AS [PlasticPeeling],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch],
        CAST([Deform] AS VARCHAR(10)) AS [Deform],
        CAST([ExposedCopper] AS VARCHAR(10)) AS [ExposedCopper],
        CAST([RubberDeform] AS VARCHAR(10)) AS [RubberDeform],
        CAST([CrackWood] AS VARCHAR(10)) AS [CrackWood],
        CAST([Discoloration] AS VARCHAR(10)) AS [Discoloration],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError],
        CAST([Total] AS VARCHAR(10)) AS [Total],
        Note,
        [Status] = ''
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
PRINT 'OK: ALCase GET updated';
GO

-- 2.2 ALCase IUD
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
    @pProcessUserID VARCHAR(20)=NULL, @pProcessLanguage VARCHAR(20)=NULL,
    @pProcessViewName VARCHAR(50)=NULL, @pXml NVARCHAR(MAX)=NULL
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
        DELETE T FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)) S ON T.ID = S.ID;

        UPDATE T SET 
            T.[Date]=S.[Date], T.[Shift]=S.[Shift], T.Person=S.Person, T.Vendor=S.Vendor, T.Factory=S.Factory,
            T.MaterialCode=S.MaterialCode, T.Invoice=S.Invoice, T.LotNo=S.LotNo,
            T.QtyCheck=S.QtyCheck, T.QtyOK=S.QtyOK,
            T.BurrAl=S.BurrAl, T.BurrPlastic=S.BurrPlastic, T.BurrRubber=S.BurrRubber, T.PlasticPeeling=S.PlasticPeeling,
            T.Scratch=S.Scratch, T.Deform=S.Deform, T.ExposedCopper=S.ExposedCopper, T.RubberDeform=S.RubberDeform,
            T.CrackWood=S.CrackWood, T.Discoloration=S.Discoloration, T.OtherError=S.OtherError, T.Total=S.Total,
            T.Note=S.Note,
            T.ChangeUserID=@pProcessUserID, T.ChangeDateTime=GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        INNER JOIN (
            SELECT 
                ID, [Date], [Shift], Person, Vendor, Factory,
                MaterialCode, Invoice, LotNo,
                ISNULL(TRY_CAST(QtyCheck AS INT),0) AS QtyCheck,
                ISNULL(TRY_CAST(QtyOK AS INT),0) AS QtyOK,
                ISNULL(TRY_CAST(BurrAl AS INT),0) AS BurrAl,
                ISNULL(TRY_CAST(BurrPlastic AS INT),0) AS BurrPlastic,
                ISNULL(TRY_CAST(BurrRubber AS INT),0) AS BurrRubber,
                ISNULL(TRY_CAST(PlasticPeeling AS INT),0) AS PlasticPeeling,
                ISNULL(TRY_CAST(Scratch AS INT),0) AS Scratch,
                ISNULL(TRY_CAST(Deform AS INT),0) AS Deform,
                ISNULL(TRY_CAST(ExposedCopper AS INT),0) AS ExposedCopper,
                ISNULL(TRY_CAST(RubberDeform AS INT),0) AS RubberDeform,
                ISNULL(TRY_CAST(CrackWood AS INT),0) AS CrackWood,
                ISNULL(TRY_CAST(Discoloration AS INT),0) AS Discoloration,
                ISNULL(TRY_CAST(OtherError AS INT),0) AS OtherError,
                ISNULL(TRY_CAST(Total AS INT),0) AS Total,
                Note
            FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT,
                [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50),
                QtyCheck VARCHAR(50), QtyOK VARCHAR(50), BurrAl VARCHAR(50), BurrPlastic VARCHAR(50),
                BurrRubber VARCHAR(50), PlasticPeeling VARCHAR(50), Scratch VARCHAR(50), Deform VARCHAR(50),
                ExposedCopper VARCHAR(50), RubberDeform VARCHAR(50), CrackWood VARCHAR(50), Discoloration VARCHAR(50),
                OtherError VARCHAR(50), Total VARCHAR(50), Note NVARCHAR(500)
            )
        ) S ON T.ID = S.ID;

        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            [Date],[Shift],[Person],[Vendor],[Factory],MaterialCode,Invoice,LotNo,[QtyCheck],[QtyOK],
            BurrAl,BurrPlastic,BurrRubber,PlasticPeeling,Scratch,Deform,ExposedCopper,
            RubberDeform,CrackWood,Discoloration,OtherError,Total,Note,
            CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime)
        SELECT 
            ISNULL(T.[Date], GETDATE()), T.[Shift], T.Person, T.Vendor, T.Factory,
            T.MaterialCode, T.Invoice, T.LotNo,
            ISNULL(TRY_CAST(T.QtyCheck AS INT),0),
            ISNULL(TRY_CAST(T.QtyOK AS INT),0),
            ISNULL(TRY_CAST(T.BurrAl AS INT),0),
            ISNULL(TRY_CAST(T.BurrPlastic AS INT),0),
            ISNULL(TRY_CAST(T.BurrRubber AS INT),0),
            ISNULL(TRY_CAST(T.PlasticPeeling AS INT),0),
            ISNULL(TRY_CAST(T.Scratch AS INT),0),
            ISNULL(TRY_CAST(T.Deform AS INT),0),
            ISNULL(TRY_CAST(T.ExposedCopper AS INT),0),
            ISNULL(TRY_CAST(T.RubberDeform AS INT),0),
            ISNULL(TRY_CAST(T.CrackWood AS INT),0),
            ISNULL(TRY_CAST(T.Discoloration AS INT),0),
            ISNULL(TRY_CAST(T.OtherError AS INT),0),
            ISNULL(TRY_CAST(T.Total AS INT),0),
            T.Note,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
            MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50),
            QtyCheck VARCHAR(50), QtyOK VARCHAR(50), BurrAl VARCHAR(50), BurrPlastic VARCHAR(50),
            BurrRubber VARCHAR(50), PlasticPeeling VARCHAR(50), Scratch VARCHAR(50), Deform VARCHAR(50),
            ExposedCopper VARCHAR(50), RubberDeform VARCHAR(50), CrackWood VARCHAR(50), Discoloration VARCHAR(50),
            OtherError VARCHAR(50), Total VARCHAR(50), Note NVARCHAR(500)
        ) AS T
        WHERE T.MaterialCode IS NOT NULL;
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
PRINT 'OK: ALCase IUD updated';
GO

-- 2.3 Plate GET
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @pFrom_Date NVARCHAR(10)=NULL, @pToDate_ NVARCHAR(10)=NULL, @pMaterial_Code NVARCHAR(50)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode,
        Invoice,
        LotNo,
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK],
        CAST([Burr] AS VARCHAR(10)) AS [Burr],
        CAST([Dent] AS VARCHAR(10)) AS [Dent],
        CAST([Deform] AS VARCHAR(10)) AS [Deform],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch],
        CAST([NGPlating] AS VARCHAR(10)) AS [NGPlating],
        CAST([RoughFace] AS VARCHAR(10)) AS [RoughFace],
        CAST([Dirty] AS VARCHAR(10)) AS [Dirty],
        CAST([DentBottom] AS VARCHAR(10)) AS [DentBottom],
        CAST([Discolor] AS VARCHAR(10)) AS [Discolor],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError],
        CAST([Total] AS VARCHAR(10)) AS [Total],
        Note,
        [Status] = ''
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
PRINT 'OK: Plate GET updated';
GO

-- 2.4 Plate IUD
ALTER PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @pProcessUserID VARCHAR(20)=NULL, @pProcessLanguage VARCHAR(20)=NULL,
    @pProcessViewName VARCHAR(50)=NULL, @pXml NVARCHAR(MAX)=NULL
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
        DELETE T FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (SELECT ID FROM OPENXML(@iDoc, @DeleteTableName, 3) WITH (ID INT)) S ON T.ID = S.ID;

        UPDATE T SET 
            T.[Date]=S.[Date], T.[Shift]=S.[Shift], T.Person=S.Person, T.Vendor=S.Vendor, T.Factory=S.Factory,
            T.MaterialCode=S.MaterialCode, T.Invoice=S.Invoice, T.LotNo=S.LotNo,
            T.QtyCheck=S.QtyCheck, T.QtyOK=S.QtyOK,
            T.Burr=S.Burr, T.Dent=S.Dent, T.Deform=S.Deform, T.Scratch=S.Scratch, T.NGPlating=S.NGPlating,
            T.RoughFace=S.RoughFace, T.Dirty=S.Dirty, T.DentBottom=S.DentBottom, T.Discolor=S.Discolor,
            T.OtherError=S.OtherError, T.Total=S.Total,
            T.Note=S.Note,
            T.ChangeUserID=@pProcessUserID, T.ChangeDateTime=GETDATE()
        FROM STB_VVT_SortingErrorData_Plate T
        INNER JOIN (
            SELECT 
                ID, [Date], [Shift], Person, Vendor, Factory,
                MaterialCode, Invoice, LotNo,
                ISNULL(TRY_CAST(QtyCheck AS INT),0) AS QtyCheck,
                ISNULL(TRY_CAST(QtyOK AS INT),0) AS QtyOK,
                ISNULL(TRY_CAST(Burr AS INT),0) AS Burr,
                ISNULL(TRY_CAST(Dent AS INT),0) AS Dent,
                ISNULL(TRY_CAST(Deform AS INT),0) AS Deform,
                ISNULL(TRY_CAST(Scratch AS INT),0) AS Scratch,
                ISNULL(TRY_CAST(NGPlating AS INT),0) AS NGPlating,
                ISNULL(TRY_CAST(RoughFace AS INT),0) AS RoughFace,
                ISNULL(TRY_CAST(Dirty AS INT),0) AS Dirty,
                ISNULL(TRY_CAST(DentBottom AS INT),0) AS DentBottom,
                ISNULL(TRY_CAST(Discolor AS INT),0) AS Discolor,
                ISNULL(TRY_CAST(OtherError AS INT),0) AS OtherError,
                ISNULL(TRY_CAST(Total AS INT),0) AS Total,
                Note
            FROM OPENXML(@iDoc, @UpdateTableName, 3) WITH (
                ID INT,
                [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
                MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50),
                QtyCheck VARCHAR(50), QtyOK VARCHAR(50), Burr VARCHAR(50), Dent VARCHAR(50), Deform VARCHAR(50),
                Scratch VARCHAR(50), NGPlating VARCHAR(50), RoughFace VARCHAR(50), Dirty VARCHAR(50),
                DentBottom VARCHAR(50), Discolor VARCHAR(50), OtherError VARCHAR(50), Total VARCHAR(50), Note NVARCHAR(500)
            )
        ) S ON T.ID = S.ID;

        INSERT INTO STB_VVT_SortingErrorData_Plate (
            [Date],[Shift],[Person],[Vendor],[Factory],MaterialCode,Invoice,LotNo,[QtyCheck],[QtyOK],
            Burr,Dent,Deform,Scratch,NGPlating,RoughFace,Dirty,DentBottom,Discolor,OtherError,Total,Note,
            CreateUserID,CreateDateTime,ChangeUserID,ChangeDateTime)
        SELECT 
            ISNULL(T.[Date], GETDATE()), T.[Shift], T.Person, T.Vendor, T.Factory,
            T.MaterialCode, T.Invoice, T.LotNo,
            ISNULL(TRY_CAST(T.QtyCheck AS INT),0),
            ISNULL(TRY_CAST(T.QtyOK AS INT),0),
            ISNULL(TRY_CAST(T.Burr AS INT),0),
            ISNULL(TRY_CAST(T.Dent AS INT),0),
            ISNULL(TRY_CAST(T.Deform AS INT),0),
            ISNULL(TRY_CAST(T.Scratch AS INT),0),
            ISNULL(TRY_CAST(T.NGPlating AS INT),0),
            ISNULL(TRY_CAST(T.RoughFace AS INT),0),
            ISNULL(TRY_CAST(T.Dirty AS INT),0),
            ISNULL(TRY_CAST(T.DentBottom AS INT),0),
            ISNULL(TRY_CAST(T.Discolor AS INT),0),
            ISNULL(TRY_CAST(T.OtherError AS INT),0),
            ISNULL(TRY_CAST(T.Total AS INT),0),
            T.Note,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 3) WITH (
            [Date] DATE, [Shift] NVARCHAR(10), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100),
            MaterialCode NVARCHAR(50), Invoice NVARCHAR(100), LotNo NVARCHAR(50),
            QtyCheck VARCHAR(50), QtyOK VARCHAR(50), Burr VARCHAR(50), Dent VARCHAR(50), Deform VARCHAR(50),
            Scratch VARCHAR(50), NGPlating VARCHAR(50), RoughFace VARCHAR(50), Dirty VARCHAR(50),
            DentBottom VARCHAR(50), Discolor VARCHAR(50), OtherError VARCHAR(50), Total VARCHAR(50), Note NVARCHAR(500)
        ) AS T
        WHERE T.MaterialCode IS NOT NULL;
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
PRINT 'OK: Plate IUD updated';
GO
