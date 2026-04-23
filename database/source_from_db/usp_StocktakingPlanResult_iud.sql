
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-17
-- Browsable : true
-- Group : 재고관리 > 재고실사 기준정보 하단Grid iud프로시저
-- Description:	
-- Modified:
-- 2020.11.24  
-- =============================================
CREATE PROCEDURE [dbo].[usp_StocktakingPlanResult_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = null
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldStocktakingDocNo VARCHAR(20)
  DECLARE @OldSDNSeqNo INT
  DECLARE @StocktakingDocNo VARCHAR(20)
  DECLARE @SDNSeqNo INT
  DECLARE @MaterialLocationCode VARCHAR(20)
  DECLARE @MaterialLotNo VARCHAR(20)
  DECLARE @LotID VARCHAR(50)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @MaterialStockAttribute VARCHAR(20)
  DECLARE @StockAttrib1 VARCHAR(20)
  DECLARE @StockAttrib2 VARCHAR(20)
  DECLARE @StockAttrib3 VARCHAR(20)
  DECLARE @PackingID VARCHAR(50)
  DECLARE @BasicQty NUMERIC(20,5)
  DECLARE @LotAttr01 NVARCHAR(200)
  DECLARE @LotAttr02 NVARCHAR(200)
  DECLARE @LotAttr03 NVARCHAR(200)
  DECLARE @LotAttr04 NVARCHAR(200)
  DECLARE @LotAttr05 NVARCHAR(200)
  DECLARE @LotAttr06 NVARCHAR(200)
  DECLARE @LotAttr07 NVARCHAR(200)
  DECLARE @LotAttr08 NVARCHAR(200)
  DECLARE @LotAttr09 NVARCHAR(200)
  DECLARE @LotAttr10 NVARCHAR(200)
  DECLARE @IsStocktaking BIT
  DECLARE @StocktakingQty NUMERIC(20,5)
  DECLARE @StocktakingMaterialLocationCode VARCHAR(20)
  DECLARE @StocktakingUserID VARCHAR(20)
  DECLARE @StocktakingDateTime DATETIME
  DECLARE @IsApplied BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_StocktakingPlanResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_StocktakingPlanResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							CASE
							    WHEN OldSDNSeqNo IS NULL THEN SDNSeqNo
							    ELSE OldSDNSeqNo
							END AS OldSDNSeqNo,
							StocktakingDocNo,
							SDNSeqNo,
							MaterialLocationCode,
							MaterialLotNo,
							LotNumber,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							BasicQty,
							LotAttr01,
							LotAttr02,
							LotAttr03,
							LotAttr04,
							LotAttr05,
							LotAttr06,
							LotAttr07,
							LotAttr08,
							LotAttr09,
							LotAttr10,
							IsStocktaking,
							StocktakingQty,
							StocktakingMaterialLocationCode,
							StocktakingUserID,
							StocktakingDateTime,
							IsApplied,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										OldSDNSeqNo INT,
										StocktakingDocNo VARCHAR(20),
										SDNSeqNo INT,
										MaterialLocationCode VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										BasicQty NUMERIC(20,5),
										LotAttr01 NVARCHAR(200),
										LotAttr02 NVARCHAR(200),
										LotAttr03 NVARCHAR(200),
										LotAttr04 NVARCHAR(200),
										LotAttr05 NVARCHAR(200),
										LotAttr06 NVARCHAR(200),
										LotAttr07 NVARCHAR(200),
										LotAttr08 NVARCHAR(200),
										LotAttr09 NVARCHAR(200),
										LotAttr10 NVARCHAR(200),
										IsStocktaking BIT,
										StocktakingQty NUMERIC(20,5),
										StocktakingMaterialLocationCode VARCHAR(20),
										StocktakingUserID VARCHAR(20),
										StocktakingDateTime DATETIMEOFFSET,
										IsApplied BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.StocktakingDocNo AND
					TargetTable.SDNSeqNo = SourceTable.SDNSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					StocktakingDocNo = ISNULL(SourceTable.StocktakingDocNo,TargetTable.StocktakingDocNo),
					SDNSeqNo = ISNULL(SourceTable.SDNSeqNo,TargetTable.SDNSeqNo),
					MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode,TargetTable.MaterialLocationCode),
					MaterialLotNo = ISNULL(SourceTable.MaterialLotNo,TargetTable.MaterialLotNo),
					LotID = ISNULL(SourceTable.LotNumber,TargetTable.LotID),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute,TargetTable.MaterialStockAttribute),
					StockAttrib1 = ISNULL(SourceTable.StockAttrib1,TargetTable.StockAttrib1),
					StockAttrib2 = ISNULL(SourceTable.StockAttrib2,TargetTable.StockAttrib2),
					StockAttrib3 = ISNULL(SourceTable.StockAttrib3,TargetTable.StockAttrib3),
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					BasicQty = ISNULL(SourceTable.BasicQty,TargetTable.BasicQty),
					LotAttr01 = ISNULL(SourceTable.LotAttr01,TargetTable.LotAttr01),
					LotAttr02 = ISNULL(SourceTable.LotAttr02,TargetTable.LotAttr02),
					LotAttr03 = ISNULL(SourceTable.LotAttr03,TargetTable.LotAttr03),
					LotAttr04 = ISNULL(SourceTable.LotAttr04,TargetTable.LotAttr04),
					LotAttr05 = ISNULL(SourceTable.LotAttr05,TargetTable.LotAttr05),
					LotAttr06 = ISNULL(SourceTable.LotAttr06,TargetTable.LotAttr06),
					LotAttr07 = ISNULL(SourceTable.LotAttr07,TargetTable.LotAttr07),
					LotAttr08 = ISNULL(SourceTable.LotAttr08,TargetTable.LotAttr08),
					LotAttr09 = ISNULL(SourceTable.LotAttr09,TargetTable.LotAttr09),
					LotAttr10 = ISNULL(SourceTable.LotAttr10,TargetTable.LotAttr10),
					IsStocktaking = ISNULL(SourceTable.IsStocktaking,TargetTable.IsStocktaking),
					StocktakingQty = ISNULL(SourceTable.StocktakingQty,TargetTable.StocktakingQty),
					StocktakingMaterialLocationCode = ISNULL(SourceTable.StocktakingMaterialLocationCode,TargetTable.StocktakingMaterialLocationCode),
					StocktakingUserID = ISNULL(SourceTable.StocktakingUserID,TargetTable.StocktakingUserID),
					StocktakingDateTime = ISNULL(SourceTable.StocktakingDateTime,TargetTable.StocktakingDateTime),
					IsApplied = ISNULL(SourceTable.IsApplied,TargetTable.IsApplied),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						StocktakingDocNo,
						SDNSeqNo,
						MaterialLocationCode,
						MaterialLotNo,
						LotID,
						MaterialCode,
						MaterialStockAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						PackingID,
						BasicQty,
						LotAttr01,
						LotAttr02,
						LotAttr03,
						LotAttr04,
						LotAttr05,
						LotAttr06,
						LotAttr07,
						LotAttr08,
						LotAttr09,
						LotAttr10,
						IsStocktaking,
						StocktakingQty,
						StocktakingMaterialLocationCode,
						StocktakingUserID,
						StocktakingDateTime,
						IsApplied,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.StocktakingDocNo,
							SourceTable.SDNSeqNo,
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialLotNo,
							SourceTable.LotNumber,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.PackingID,
							SourceTable.BasicQty,
							SourceTable.LotAttr01,
							SourceTable.LotAttr02,
							SourceTable.LotAttr03,
							SourceTable.LotAttr04,
							SourceTable.LotAttr05,
							SourceTable.LotAttr06,
							SourceTable.LotAttr07,
							SourceTable.LotAttr08,
							SourceTable.LotAttr09,
							SourceTable.LotAttr10,
							SourceTable.IsStocktaking,
							SourceTable.StocktakingQty,
							SourceTable.StocktakingMaterialLocationCode,
							SourceTable.StocktakingUserID,
							SourceTable.StocktakingDateTime,
							SourceTable.IsApplied,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_StocktakingPlanResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							CASE
							    WHEN OldSDNSeqNo IS NULL THEN SDNSeqNo
							    ELSE OldSDNSeqNo
							END AS OldSDNSeqNo,
							StocktakingDocNo,
							SDNSeqNo,
							MaterialLocationCode,
							MaterialLotNo,
							LotNumber,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							BasicQty,
							LotAttr01,
							LotAttr02,
							LotAttr03,
							LotAttr04,
							LotAttr05,
							LotAttr06,
							LotAttr07,
							LotAttr08,
							LotAttr09,
							LotAttr10,
							IsStocktaking,
							StocktakingQty,
							StocktakingMaterialLocationCode,
							StocktakingUserID,
							StocktakingDateTime,
							IsApplied,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										OldSDNSeqNo INT,
										StocktakingDocNo VARCHAR(20),
										SDNSeqNo INT,
										MaterialLocationCode VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										BasicQty NUMERIC(20,5),
										LotAttr01 NVARCHAR(200),
										LotAttr02 NVARCHAR(200),
										LotAttr03 NVARCHAR(200),
										LotAttr04 NVARCHAR(200),
										LotAttr05 NVARCHAR(200),
										LotAttr06 NVARCHAR(200),
										LotAttr07 NVARCHAR(200),
										LotAttr08 NVARCHAR(200),
										LotAttr09 NVARCHAR(200),
										LotAttr10 NVARCHAR(200),
										IsStocktaking BIT,
										StocktakingQty NUMERIC(20,5),
										StocktakingMaterialLocationCode VARCHAR(20),
										StocktakingUserID VARCHAR(20),
										StocktakingDateTime DATETIMEOFFSET,
										IsApplied BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.OldStocktakingDocNo AND
					TargetTable.SDNSeqNo = SourceTable.OldSDNSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					StocktakingDocNo = ISNULL(SourceTable.StocktakingDocNo,TargetTable.StocktakingDocNo),
					SDNSeqNo = ISNULL(SourceTable.SDNSeqNo,TargetTable.SDNSeqNo),
					MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode,TargetTable.MaterialLocationCode),
					MaterialLotNo = ISNULL(SourceTable.MaterialLotNo,TargetTable.MaterialLotNo),
					LotID = ISNULL(SourceTable.LotNumber,TargetTable.LotID),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute,TargetTable.MaterialStockAttribute),
					StockAttrib1 = ISNULL(SourceTable.StockAttrib1,TargetTable.StockAttrib1),
					StockAttrib2 = ISNULL(SourceTable.StockAttrib2,TargetTable.StockAttrib2),
					StockAttrib3 = ISNULL(SourceTable.StockAttrib3,TargetTable.StockAttrib3),
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					BasicQty = ISNULL(SourceTable.BasicQty,TargetTable.BasicQty),
					LotAttr01 = ISNULL(SourceTable.LotAttr01,TargetTable.LotAttr01),
					LotAttr02 = ISNULL(SourceTable.LotAttr02,TargetTable.LotAttr02),
					LotAttr03 = ISNULL(SourceTable.LotAttr03,TargetTable.LotAttr03),
					LotAttr04 = ISNULL(SourceTable.LotAttr04,TargetTable.LotAttr04),
					LotAttr05 = ISNULL(SourceTable.LotAttr05,TargetTable.LotAttr05),
					LotAttr06 = ISNULL(SourceTable.LotAttr06,TargetTable.LotAttr06),
					LotAttr07 = ISNULL(SourceTable.LotAttr07,TargetTable.LotAttr07),
					LotAttr08 = ISNULL(SourceTable.LotAttr08,TargetTable.LotAttr08),
					LotAttr09 = ISNULL(SourceTable.LotAttr09,TargetTable.LotAttr09),
					LotAttr10 = ISNULL(SourceTable.LotAttr10,TargetTable.LotAttr10),
					IsStocktaking = ISNULL(SourceTable.IsStocktaking,TargetTable.IsStocktaking),
					StocktakingQty = ISNULL(SourceTable.StocktakingQty,TargetTable.StocktakingQty),
					StocktakingMaterialLocationCode = ISNULL(SourceTable.StocktakingMaterialLocationCode,TargetTable.StocktakingMaterialLocationCode),
					StocktakingUserID = ISNULL(SourceTable.StocktakingUserID,TargetTable.StocktakingUserID),
					StocktakingDateTime = ISNULL(SourceTable.StocktakingDateTime,TargetTable.StocktakingDateTime),
					IsApplied = ISNULL(SourceTable.IsApplied,TargetTable.IsApplied),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						StocktakingDocNo,
						SDNSeqNo,
						MaterialLocationCode,
						MaterialLotNo,
						LotID,
						MaterialCode,
						MaterialStockAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						PackingID,
						BasicQty,
						LotAttr01,
						LotAttr02,
						LotAttr03,
						LotAttr04,
						LotAttr05,
						LotAttr06,
						LotAttr07,
						LotAttr08,
						LotAttr09,
						LotAttr10,
						IsStocktaking,
						StocktakingQty,
						StocktakingMaterialLocationCode,
						StocktakingUserID,
						StocktakingDateTime,
						IsApplied,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.StocktakingDocNo,
							SourceTable.SDNSeqNo,
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialLotNo,
							SourceTable.LotNumber,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.PackingID,
							SourceTable.BasicQty,
							SourceTable.LotAttr01,
							SourceTable.LotAttr02,
							SourceTable.LotAttr03,
							SourceTable.LotAttr04,
							SourceTable.LotAttr05,
							SourceTable.LotAttr06,
							SourceTable.LotAttr07,
							SourceTable.LotAttr08,
							SourceTable.LotAttr09,
							SourceTable.LotAttr10,
							SourceTable.IsStocktaking,
							SourceTable.StocktakingQty,
							SourceTable.StocktakingMaterialLocationCode,
							SourceTable.StocktakingUserID,
							SourceTable.StocktakingDateTime,
							SourceTable.IsApplied,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_StocktakingPlanResult AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							CASE
							    WHEN OldSDNSeqNo IS NULL THEN SDNSeqNo
							    ELSE OldSDNSeqNo
							END AS OldSDNSeqNo,
							StocktakingDocNo,
							SDNSeqNo,
							MaterialLocationCode,
							MaterialLotNo,
							LotNumber,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							BasicQty,
							LotAttr01,
							LotAttr02,
							LotAttr03,
							LotAttr04,
							LotAttr05,
							LotAttr06,
							LotAttr07,
							LotAttr08,
							LotAttr09,
							LotAttr10,
							IsStocktaking,
							StocktakingQty,
							StocktakingMaterialLocationCode,
							StocktakingUserID,
							StocktakingDateTime,
							IsApplied,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										OldSDNSeqNo INT,
										StocktakingDocNo VARCHAR(20),
										SDNSeqNo INT,
										MaterialLocationCode VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										BasicQty NUMERIC(20,5),
										LotAttr01 NVARCHAR(200),
										LotAttr02 NVARCHAR(200),
										LotAttr03 NVARCHAR(200),
										LotAttr04 NVARCHAR(200),
										LotAttr05 NVARCHAR(200),
										LotAttr06 NVARCHAR(200),
										LotAttr07 NVARCHAR(200),
										LotAttr08 NVARCHAR(200),
										LotAttr09 NVARCHAR(200),
										LotAttr10 NVARCHAR(200),
										IsStocktaking BIT,
										StocktakingQty NUMERIC(20,5),
										StocktakingMaterialLocationCode VARCHAR(20),
										StocktakingUserID VARCHAR(20),
										StocktakingDateTime DATETIMEOFFSET,
										IsApplied BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.StocktakingDocNo AND
					TargetTable.SDNSeqNo = SourceTable.SDNSeqNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldStocktakingDocNo,
									OldSDNSeqNo,
									StocktakingDocNo,
									SDNSeqNo,
									MaterialLocationCode,
									MaterialLotNo,
									LotNumber,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									BasicQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									LotAttr06,
									LotAttr07,
									LotAttr08,
									LotAttr09,
									LotAttr10,
									IsStocktaking,
									StocktakingQty,
									StocktakingMaterialLocationCode,
									StocktakingUserID,
									StocktakingDateTime,
									IsApplied,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 OldSDNSeqNo INT,
											 StocktakingDocNo VARCHAR(20),
											 SDNSeqNo INT,
											 MaterialLocationCode VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 BasicQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(200),
											 LotAttr02 NVARCHAR(200),
											 LotAttr03 NVARCHAR(200),
											 LotAttr04 NVARCHAR(200),
											 LotAttr05 NVARCHAR(200),
											 LotAttr06 NVARCHAR(200),
											 LotAttr07 NVARCHAR(200),
											 LotAttr08 NVARCHAR(200),
											 LotAttr09 NVARCHAR(200),
											 LotAttr10 NVARCHAR(200),
											 IsStocktaking BIT,
											 StocktakingQty NUMERIC(20,5),
											 StocktakingMaterialLocationCode VARCHAR(20),
											 StocktakingUserID VARCHAR(20),
											 StocktakingDateTime DATETIMEOFFSET,
											 IsApplied BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
										ELSE OldStocktakingDocNo
									END AS OldStocktakingDocNo,
									CASE 
										WHEN OldSDNSeqNo IS NULL THEN SDNSeqNo
										ELSE OldSDNSeqNo
									END AS OldSDNSeqNo,
									StocktakingDocNo,
									SDNSeqNo,
									MaterialLocationCode,
									MaterialLotNo,
									LotNumber,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									BasicQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									LotAttr06,
									LotAttr07,
									LotAttr08,
									LotAttr09,
									LotAttr10,
									IsStocktaking,
									StocktakingQty,
									StocktakingMaterialLocationCode,
									StocktakingUserID,
									StocktakingDateTime,
									IsApplied,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 OldSDNSeqNo INT,
											 StocktakingDocNo VARCHAR(20),
											 SDNSeqNo INT,
											 MaterialLocationCode VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 BasicQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(200),
											 LotAttr02 NVARCHAR(200),
											 LotAttr03 NVARCHAR(200),
											 LotAttr04 NVARCHAR(200),
											 LotAttr05 NVARCHAR(200),
											 LotAttr06 NVARCHAR(200),
											 LotAttr07 NVARCHAR(200),
											 LotAttr08 NVARCHAR(200),
											 LotAttr09 NVARCHAR(200),
											 LotAttr10 NVARCHAR(200),
											 IsStocktaking BIT,
											 StocktakingQty NUMERIC(20,5),
											 StocktakingMaterialLocationCode VARCHAR(20),
											 StocktakingUserID VARCHAR(20),
											 StocktakingDateTime DATETIMEOFFSET,
											 IsApplied BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
										ELSE OldStocktakingDocNo
									END AS OldStocktakingDocNo,
									CASE 
										WHEN OldSDNSeqNo IS NULL THEN SDNSeqNo
										ELSE OldSDNSeqNo
									END AS OldSDNSeqNo,
									StocktakingDocNo,
									SDNSeqNo,
									MaterialLocationCode,
									MaterialLotNo,
									LotNumber,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									BasicQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									LotAttr06,
									LotAttr07,
									LotAttr08,
									LotAttr09,
									LotAttr10,
									IsStocktaking,
									StocktakingQty,
									StocktakingMaterialLocationCode,
									StocktakingUserID,
									StocktakingDateTime,
									IsApplied,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 OldSDNSeqNo INT,
											 StocktakingDocNo VARCHAR(20),
											 SDNSeqNo INT,
											 MaterialLocationCode VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 BasicQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(200),
											 LotAttr02 NVARCHAR(200),
											 LotAttr03 NVARCHAR(200),
											 LotAttr04 NVARCHAR(200),
											 LotAttr05 NVARCHAR(200),
											 LotAttr06 NVARCHAR(200),
											 LotAttr07 NVARCHAR(200),
											 LotAttr08 NVARCHAR(200),
											 LotAttr09 NVARCHAR(200),
											 LotAttr10 NVARCHAR(200),
											 IsStocktaking BIT,
											 StocktakingQty NUMERIC(20,5),
											 StocktakingMaterialLocationCode VARCHAR(20),
											 StocktakingUserID VARCHAR(20),
											 StocktakingDateTime DATETIMEOFFSET,
											 IsApplied BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldStocktakingDocNo,
								 @OldSDNSeqNo,
								 @StocktakingDocNo,
								 @SDNSeqNo,
								 @MaterialLocationCode,
								 @MaterialLotNo,
								 @LotID,
								 @MaterialCode,
								 @MaterialStockAttribute,
								 @StockAttrib1,
								 @StockAttrib2,
								 @StockAttrib3,
								 @PackingID,
								 @BasicQty,
								 @LotAttr01,
								 @LotAttr02,
								 @LotAttr03,
								 @LotAttr04,
								 @LotAttr05,
								 @LotAttr06,
								 @LotAttr07,
								 @LotAttr08,
								 @LotAttr09,
								 @LotAttr10,
								 @IsStocktaking,
								 @StocktakingQty,
								 @StocktakingMaterialLocationCode,
								 @StocktakingUserID,
								 @StocktakingDateTime,
								 @IsApplied,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				DECLARE @IsFinish BIT

				SELECT
						@IsFinish = SD.IsFinish
				FROM
						STB_StocktakingDoc SD
				WHERE
						SD.StocktakingDocNo = @StocktakingDocNo

				IF ISNULL(@IsFinish,0) = 1 BEGIN
						EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																			'^이미 완료된 실사번호입니다^',
																			@ERROR_MSG OUTPUT
						SET @ERROR_MSG = @ERROR_MSG + ' [%s]'
						RAISERROR(@ERROR_MSG,16,1,@StocktakingDocNo)
				END

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_StocktakingPlanResult WHERE StocktakingDocNo = @StocktakingDocNo AND SDNSeqNo = @SDNSeqNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @StocktakingDocNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StocktakingPlanResult',@StocktakingDocNo OUTPUT
                    END

					SET @SDNSeqNo = ISNULL((SELECT MAX(SDNSeqNo) FROM STB_StocktakingPlanResult WHERE StocktakingDocNo = @StocktakingDocNo),0) + 1

                    INSERT INTO STB_StocktakingPlanResult
						(
						    StocktakingDocNo,
						    SDNSeqNo,
						    MaterialLocationCode,
						    MaterialLotNo,
						    LotID,
						    MaterialCode,
						    MaterialStockAttribute,
						    StockAttrib1,
						    StockAttrib2,
						    StockAttrib3,
						    PackingID,
						    BasicQty,
						    LotAttr01,
						    LotAttr02,
						    LotAttr03,
						    LotAttr04,
						    LotAttr05,
						    LotAttr06,
						    LotAttr07,
						    LotAttr08,
						    LotAttr09,
						    LotAttr10,
						    IsStocktaking,
						    StocktakingQty,
						    StocktakingMaterialLocationCode,
						    StocktakingUserID,
						    StocktakingDateTime,
						    IsApplied,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @StocktakingDocNo,
						    @SDNSeqNo,
						    @MaterialLocationCode,
						    @MaterialLotNo,
						    @LotID,
						    @MaterialCode,
						    @MaterialStockAttribute,
						    @StockAttrib1,
						    @StockAttrib2,
						    @StockAttrib3,
						    @PackingID,
						    @BasicQty,
						    @LotAttr01,
						    @LotAttr02,
						    @LotAttr03,
						    @LotAttr04,
						    @LotAttr05,
						    @LotAttr06,
						    @LotAttr07,
						    @LotAttr08,
						    @LotAttr09,
						    @LotAttr10,
						    @IsStocktaking,
						    @StocktakingQty,
						    @StocktakingMaterialLocationCode,
						    @StocktakingUserID,
						    @StocktakingDateTime,
						    @IsApplied,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_StocktakingPlanResult
						SET
						    StocktakingDocNo =   ISNULL(@StocktakingDocNo,StocktakingDocNo),
						    SDNSeqNo =   ISNULL(@SDNSeqNo,SDNSeqNo),
						    MaterialLocationCode =   ISNULL(@MaterialLocationCode,MaterialLocationCode),
						    MaterialLotNo =   ISNULL(@MaterialLotNo,MaterialLotNo),
						    LotID =   ISNULL(@LotID,LotID),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    MaterialStockAttribute =   ISNULL(@MaterialStockAttribute,MaterialStockAttribute),
						    StockAttrib1 =   ISNULL(@StockAttrib1,StockAttrib1),
						    StockAttrib2 =   ISNULL(@StockAttrib2,StockAttrib2),
						    StockAttrib3 =   ISNULL(@StockAttrib3,StockAttrib3),
						    PackingID =   ISNULL(@PackingID,PackingID),
						    BasicQty =   ISNULL(@BasicQty,BasicQty),
						    LotAttr01 =   ISNULL(@LotAttr01,LotAttr01),
						    LotAttr02 =   ISNULL(@LotAttr02,LotAttr02),
						    LotAttr03 =   ISNULL(@LotAttr03,LotAttr03),
						    LotAttr04 =   ISNULL(@LotAttr04,LotAttr04),
						    LotAttr05 =   ISNULL(@LotAttr05,LotAttr05),
						    LotAttr06 =   ISNULL(@LotAttr06,LotAttr06),
						    LotAttr07 =   ISNULL(@LotAttr07,LotAttr07),
						    LotAttr08 =   ISNULL(@LotAttr08,LotAttr08),
						    LotAttr09 =   ISNULL(@LotAttr09,LotAttr09),
						    LotAttr10 =   ISNULL(@LotAttr10,LotAttr10),
						    IsStocktaking =   ISNULL(@IsStocktaking,IsStocktaking),
						    StocktakingQty =   ISNULL(@StocktakingQty,StocktakingQty),
						    StocktakingMaterialLocationCode =   ISNULL(@StocktakingMaterialLocationCode,StocktakingMaterialLocationCode),
						    StocktakingUserID =   ISNULL(@StocktakingUserID,StocktakingUserID),
						    StocktakingDateTime =   ISNULL(@StocktakingDateTime,StocktakingDateTime),
						    IsApplied =   ISNULL(@IsApplied,IsApplied),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    StocktakingDocNo = @OldStocktakingDocNo AND
						    SDNSeqNo = @OldSDNSeqNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_StocktakingPlanResult
						WHERE
						    StocktakingDocNo = @OldStocktakingDocNo AND
						    SDNSeqNo = @OldSDNSeqNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
