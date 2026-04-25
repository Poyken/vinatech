USE [SmartFactoryV2]
GO
IF OBJECT_ID('usp_VVT_SortingErrorData_ALCase_iud', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_ALCase_iud;
GO
-- =========================================================================================
-- Author:      Antigravity (AI Assistant)
-- Create date: 2026-04-24
-- Description: IUD Sorting Error Data for AL Case (Supports XML Batch Save/Excel Import)
-- =========================================================================================
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_iud]
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
        INSERT INTO STB_VVT_SortingErrorData_ALCase (
            [Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, [QtyCheck], [QtyOK], 
            BurrAl, BurrPlastic, BurrRubber, PlasticPeeling, Scratch, Deform, ExposedCopper, 
            RubberDeform, CrackWood, Discoloration, OtherError, Total, 
            CreateUserID, CreateDateTime, ChangeUserID, ChangeDateTime
        )
        SELECT 
            [Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, ISNULL([QtyCheck],0), ISNULL([QtyOK],0), 
            ISNULL(BurrAl,0), ISNULL(BurrPlastic,0), ISNULL(BurrRubber,0), ISNULL(PlasticPeeling,0), ISNULL(Scratch,0), ISNULL(Deform,0), ISNULL(ExposedCopper,0), ISNULL(RubberDeform,0), ISNULL(CrackWood,0), ISNULL(Discoloration,0), ISNULL(OtherError,0),
            (ISNULL(BurrAl,0)+ISNULL(BurrPlastic,0)+ISNULL(BurrRubber,0)+ISNULL(PlasticPeeling,0)+ISNULL(Scratch,0)+ISNULL(Deform,0)+ISNULL(ExposedCopper,0)+ISNULL(RubberDeform,0)+ISNULL(CrackWood,0)+ISNULL(Discoloration,0)+ISNULL(OtherError,0)) AS Total,
            @pProcessUserID, GETDATE(), @pProcessUserID, GETDATE()
        FROM OPENXML(@iDoc, @InsertTableName, 2) WITH (
            [Date] DATE, [Shift] NVARCHAR(50), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100), MaterialCode NVARCHAR(100), LotNo NVARCHAR(100), [QtyCheck] INT, [QtyOK] INT,
            BurrAl INT, BurrPlastic INT, BurrRubber INT, PlasticPeeling INT, Scratch INT, Deform INT, ExposedCopper INT, RubberDeform INT, CrackWood INT, Discoloration INT, OtherError INT
        ) WHERE [Date] IS NOT NULL; -- Skip empty rows

        -- 2. UPDATE LOGIC
        UPDATE T SET 
            [Date]=X.[Date], [Shift]=X.[Shift], Person=X.Person, Vendor=X.Vendor, Factory=X.Factory, MaterialCode=X.MaterialCode, LotNo=X.LotNo, [QtyCheck]=ISNULL(X.[QtyCheck],0), [QtyOK]=ISNULL(X.[QtyOK],0), 
            BurrAl=ISNULL(X.BurrAl,0), BurrPlastic=ISNULL(X.BurrPlastic,0), BurrRubber=ISNULL(X.BurrRubber,0), PlasticPeeling=ISNULL(X.PlasticPeeling,0), Scratch=ISNULL(X.Scratch,0), Deform=ISNULL(X.Deform,0), ExposedCopper=ISNULL(X.ExposedCopper,0), RubberDeform=ISNULL(X.RubberDeform,0), CrackWood=ISNULL(X.CrackWood,0), Discoloration=ISNULL(X.Discoloration,0), OtherError=ISNULL(X.OtherError,0),
            Total=(ISNULL(X.BurrAl,0)+ISNULL(X.BurrPlastic,0)+ISNULL(X.BurrRubber,0)+ISNULL(X.PlasticPeeling,0)+ISNULL(X.Scratch,0)+ISNULL(X.Deform,0)+ISNULL(X.ExposedCopper,0)+ISNULL(X.RubberDeform,0)+ISNULL(X.CrackWood,0)+ISNULL(X.Discoloration,0)+ISNULL(X.OtherError,0)),
            ChangeUserID=@pProcessUserID, ChangeDateTime=GETDATE()
        FROM STB_VVT_SortingErrorData_ALCase T
        JOIN OPENXML(@iDoc, @UpdateTableName, 2) WITH (
            ID INT, [Date] DATE, [Shift] NVARCHAR(50), Person NVARCHAR(100), Vendor NVARCHAR(100), Factory NVARCHAR(100), MaterialCode NVARCHAR(100), LotNo NVARCHAR(100), [QtyCheck] INT, [QtyOK] INT, 
            BurrAl INT, BurrPlastic INT, BurrRubber INT, PlasticPeeling INT, Scratch INT, Deform INT, ExposedCopper INT, RubberDeform INT, CrackWood INT, Discoloration INT, OtherError INT
        ) X ON T.ID = X.ID;

        -- 3. DELETE LOGIC
        DELETE T FROM STB_VVT_SortingErrorData_ALCase T
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
