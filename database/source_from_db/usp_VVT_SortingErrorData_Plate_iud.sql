USE [SmartFactoryV2]
GO
IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_iud;
GO
-- =========================================================================================
-- Author:      Antigravity (AI Assistant)
-- Create date: 2026-04-24
-- Description: IUD Sorting Error Data for Plate (Supports XML Batch Save/Excel Import)
-- =========================================================================================
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_iud]
    @pProcessUserID     VARCHAR(20) = NULL,
    @pProcessLanguage   VARCHAR(20) = NULL,
    @pProcessViewName   VARCHAR(50) = NULL,
    @pXml               NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
    DECLARE @iDoc INT

    BEGIN TRY
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
        BEGIN TRANSACTION;

        -- 1. INSERT LOGIC
        INSERT INTO STB_VVT_SortingErrorData_Plate (
            [Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, [QtyCheck], [QtyOK], 
            Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, Total, 
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            [Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, ISNULL([QtyCheck],0), ISNULL([QtyOK],0), 
            ISNULL(Burr,0), ISNULL(Dent,0), ISNULL(Deform,0), ISNULL(Scratch,0), ISNULL(NGPlating,0), ISNULL(RoughFace,0), ISNULL(Dirty,0), ISNULL(DentBottom,0), ISNULL(Discolor,0), ISNULL(OtherError,0),
            (ISNULL(Burr,0)+ISNULL(Dent,0)+ISNULL(Deform,0)+ISNULL(Scratch,0)+ISNULL(NGPlating,0)+ISNULL(RoughFace,0)+ISNULL(Dirty,0)+ISNULL(DentBottom,0)+ISNULL(Discolor,0)+ISNULL(OtherError,0)) AS Total,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            [Date] DATE, [Shift] NVARCHAR(50), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100), MaterialCode NVARCHAR(100), LotNo NVARCHAR(100), [QtyCheck] INT, [QtyOK] INT,
            Burr INT, Dent INT, Deform INT, Scratch INT, NGPlating INT, RoughFace INT, Dirty INT, DentBottom INT, Discolor INT, OtherError INT
        ) WHERE [Date] IS NOT NULL; -- Skip empty rows

        -- 2. UPDATE LOGIC
        UPDATE T SET 
            [Date]=X.[Date], [Shift]=X.[Shift], Person=X.Person, Vendor=X.Vendor, Factory=X.Factory, MaterialCode=X.MaterialCode, LotNo=X.LotNo, [QtyCheck]=ISNULL(X.[QtyCheck],0), [QtyOK]=ISNULL(X.[QtyOK],0), 
            Burr=ISNULL(X.Burr,0), Dent=ISNULL(X.Dent,0), Deform=ISNULL(X.Deform,0), Scratch=ISNULL(X.Scratch,0), NGPlating=ISNULL(X.NGPlating,0), RoughFace=ISNULL(X.RoughFace,0), Dirty=ISNULL(X.Dirty,0), DentBottom=ISNULL(X.DentBottom,0), Discolor=ISNULL(X.Discolor,0), OtherError=ISNULL(X.OtherError,0),
            Total=(ISNULL(X.Burr,0)+ISNULL(X.Dent,0)+ISNULL(X.Deform,0)+ISNULL(X.Scratch,0)+ISNULL(X.NGPlating,0)+ISNULL(X.RoughFace,0)+ISNULL(X.Dirty,0)+ISNULL(X.DentBottom,0)+ISNULL(X.Discolor,0)+ISNULL(X.OtherError,0)),
            ChangeUserID=@pProcessUserID, ChangeDateTime=GETDATE()
        FROM STB_VVT_SortingErrorData_Plate T
        JOIN OPENXML(@iDoc, @UpdateTableName, 2) WITH (
            ID INT, [Date] DATE, [Shift] NVARCHAR(50), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100), MaterialCode NVARCHAR(100), LotNo NVARCHAR(100), [QtyCheck] INT, [QtyOK] INT, 
            Burr INT, Dent INT, Deform INT, Scratch INT, NGPlating INT, RoughFace INT, Dirty INT, DentBottom INT, Discolor INT, OtherError INT
        ) X ON T.ID = X.ID;

        -- 3. DELETE LOGIC
        DELETE T FROM STB_VVT_SortingErrorData_Plate T
        JOIN OPENXML(@iDoc, @DeleteTableName, 2) WITH (ID INT) X ON T.ID = X.ID;

        COMMIT TRANSACTION;
        EXEC sp_xml_removedocument @iDoc;
        SELECT '0' AS ErrCode, 'Success' AS ErrMsg;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @iDoc IS NOT NULL EXEC sp_xml_removedocument @iDoc;
        SELECT '-1' AS ErrCode, ERROR_MESSAGE() AS ErrMsg;
    END CATCH
END
GO
