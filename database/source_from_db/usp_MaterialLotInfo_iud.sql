
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-06-11
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialLotInfo_iud]
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
  DECLARE @OldMaterialLotNo VARCHAR(20)
  DECLARE @MaterialLotNo VARCHAR(20)
  DECLARE @LotID VARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @MaterialLocationCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @MaterialStockAttribute VARCHAR(20)
  DECLARE @StockAttrib1 VARCHAR(20)
  DECLARE @StockAttrib2 VARCHAR(20)
  DECLARE @StockAttrib3 VARCHAR(20)
  DECLARE @PackingID VARCHAR(50)
  DECLARE @GRDate VARCHAR(10)
  DECLARE @MaterialDeliveryNo VARCHAR(20)
  DECLARE @MaterialDeliveryDetailNo VARCHAR(20)
  DECLARE @InitialQty NUMERIC(20,5)
  DECLARE @CurrentQty NUMERIC(20,5)
  DECLARE @PickingQty NUMERIC(20,5)
  DECLARE @VendorLotNo VARCHAR(100)
  DECLARE @LifeBasicDate DATE
  DECLARE @ProductionDate DATE
  DECLARE @EndOfLifeDate DATE
  DECLARE @LotNo VARCHAR(500)
  DECLARE @IsSplitLot BIT
  DECLARE @BefMaterialLotNo VARCHAR(20)
  DECLARE @LotAttr01 NVARCHAR(100)
  DECLARE @LotAttr02 NVARCHAR(100)
  DECLARE @LotAttr03 NVARCHAR(100)
  DECLARE @LotAttr04 NVARCHAR(100)
  DECLARE @LotAttr05 NVARCHAR(100)
  DECLARE @LotAttr06 NVARCHAR(100)
  DECLARE @LotAttr07 NVARCHAR(100)
  DECLARE @LotAttr08 NVARCHAR(100)
  DECLARE @LotAttr09 NVARCHAR(100)
  DECLARE @LotAttr10 NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialLotInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MaterialLotInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
							    ELSE OldMaterialLotNo
							END AS OldMaterialLotNo,
							MaterialLotNo,
							LotID,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialLocationCode,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							GRDate,
							MaterialDeliveryNo,
							MaterialDeliveryDetailNo,
							InitialQty,
							CurrentQty,
							PickingQty,
							VendorLotNo,
							LifeBasicDate,
							ProductionDate,
							EndOfLifeDate,
							LotNo,
							IsSplitLot,
							BefMaterialLotNo,
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
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialLotNo VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotID VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										GRDate VARCHAR(10),
										MaterialDeliveryNo VARCHAR(20),
										MaterialDeliveryDetailNo VARCHAR(20),
										InitialQty NUMERIC(20,5),
										CurrentQty NUMERIC(20,5),
										PickingQty NUMERIC(20,5),
										VendorLotNo VARCHAR(100),
										LifeBasicDate DATETIMEOFFSET,
										ProductionDate DATETIMEOFFSET,
										EndOfLifeDate DATETIMEOFFSET,
										LotNo VARCHAR(500),
										IsSplitLot BIT,
										BefMaterialLotNo VARCHAR(20),
										LotAttr01 NVARCHAR(100),
										LotAttr02 NVARCHAR(100),
										LotAttr03 NVARCHAR(100),
										LotAttr04 NVARCHAR(100),
										LotAttr05 NVARCHAR(100),
										LotAttr06 NVARCHAR(100),
										LotAttr07 NVARCHAR(100),
										LotAttr08 NVARCHAR(100),
										LotAttr09 NVARCHAR(100),
										LotAttr10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLotNo = SourceTable.MaterialLotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialLotNo = ISNULL(SourceTable.MaterialLotNo,TargetTable.MaterialLotNo),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode,TargetTable.MaterialLocationCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute,TargetTable.MaterialStockAttribute),
					StockAttrib1 = ISNULL(SourceTable.StockAttrib1,TargetTable.StockAttrib1),
					StockAttrib2 = ISNULL(SourceTable.StockAttrib2,TargetTable.StockAttrib2),
					StockAttrib3 = ISNULL(SourceTable.StockAttrib3,TargetTable.StockAttrib3),
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					GRDate = ISNULL(SourceTable.GRDate,TargetTable.GRDate),
					MaterialDeliveryNo = ISNULL(SourceTable.MaterialDeliveryNo,TargetTable.MaterialDeliveryNo),
					MaterialDeliveryDetailNo = ISNULL(SourceTable.MaterialDeliveryDetailNo,TargetTable.MaterialDeliveryDetailNo),
					InitialQty = ISNULL(SourceTable.InitialQty,TargetTable.InitialQty),
					CurrentQty = ISNULL(SourceTable.CurrentQty,TargetTable.CurrentQty),
					PickingQty = ISNULL(SourceTable.PickingQty,TargetTable.PickingQty),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					LifeBasicDate = ISNULL(SourceTable.LifeBasicDate,TargetTable.LifeBasicDate),
					ProductionDate = ISNULL(SourceTable.ProductionDate,TargetTable.ProductionDate),
					EndOfLifeDate = ISNULL(SourceTable.EndOfLifeDate,TargetTable.EndOfLifeDate),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					IsSplitLot = ISNULL(SourceTable.IsSplitLot,TargetTable.IsSplitLot),
					BefMaterialLotNo = ISNULL(SourceTable.BefMaterialLotNo,TargetTable.BefMaterialLotNo),
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
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialLotNo,
						LotID,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode,
						MaterialLocationCode,
						MaterialCode,
						MaterialStockAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						PackingID,
						GRDate,
						MaterialDeliveryNo,
						MaterialDeliveryDetailNo,
						InitialQty,
						CurrentQty,
						PickingQty,
						VendorLotNo,
						LifeBasicDate,
						ProductionDate,
						EndOfLifeDate,
						LotNo,
						IsSplitLot,
						BefMaterialLotNo,
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
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialLotNo,
							SourceTable.LotID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.PackingID,
							SourceTable.GRDate,
							SourceTable.MaterialDeliveryNo,
							SourceTable.MaterialDeliveryDetailNo,
							SourceTable.InitialQty,
							SourceTable.CurrentQty,
							SourceTable.PickingQty,
							SourceTable.VendorLotNo,
							SourceTable.LifeBasicDate,
							SourceTable.ProductionDate,
							SourceTable.EndOfLifeDate,
							SourceTable.LotNo,
							SourceTable.IsSplitLot,
							SourceTable.BefMaterialLotNo,
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
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MaterialLotInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
							    ELSE OldMaterialLotNo
							END AS OldMaterialLotNo,
							MaterialLotNo,
							LotID,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialLocationCode,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							GRDate,
							MaterialDeliveryNo,
							MaterialDeliveryDetailNo,
							InitialQty,
							CurrentQty,
							PickingQty,
							VendorLotNo,
							LifeBasicDate,
							ProductionDate,
							EndOfLifeDate,
							LotNo,
							IsSplitLot,
							BefMaterialLotNo,
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
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialLotNo VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotID VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										GRDate VARCHAR(10),
										MaterialDeliveryNo VARCHAR(20),
										MaterialDeliveryDetailNo VARCHAR(20),
										InitialQty NUMERIC(20,5),
										CurrentQty NUMERIC(20,5),
										PickingQty NUMERIC(20,5),
										VendorLotNo VARCHAR(100),
										LifeBasicDate DATETIMEOFFSET,
										ProductionDate DATETIMEOFFSET,
										EndOfLifeDate DATETIMEOFFSET,
										LotNo VARCHAR(500),
										IsSplitLot BIT,
										BefMaterialLotNo VARCHAR(20),
										LotAttr01 NVARCHAR(100),
										LotAttr02 NVARCHAR(100),
										LotAttr03 NVARCHAR(100),
										LotAttr04 NVARCHAR(100),
										LotAttr05 NVARCHAR(100),
										LotAttr06 NVARCHAR(100),
										LotAttr07 NVARCHAR(100),
										LotAttr08 NVARCHAR(100),
										LotAttr09 NVARCHAR(100),
										LotAttr10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLotNo = SourceTable.OldMaterialLotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialLotNo = ISNULL(SourceTable.MaterialLotNo,TargetTable.MaterialLotNo),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode,TargetTable.MaterialLocationCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute,TargetTable.MaterialStockAttribute),
					StockAttrib1 = ISNULL(SourceTable.StockAttrib1,TargetTable.StockAttrib1),
					StockAttrib2 = ISNULL(SourceTable.StockAttrib2,TargetTable.StockAttrib2),
					StockAttrib3 = ISNULL(SourceTable.StockAttrib3,TargetTable.StockAttrib3),
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					GRDate = ISNULL(SourceTable.GRDate,TargetTable.GRDate),
					MaterialDeliveryNo = ISNULL(SourceTable.MaterialDeliveryNo,TargetTable.MaterialDeliveryNo),
					MaterialDeliveryDetailNo = ISNULL(SourceTable.MaterialDeliveryDetailNo,TargetTable.MaterialDeliveryDetailNo),
					InitialQty = ISNULL(SourceTable.InitialQty,TargetTable.InitialQty),
					CurrentQty = ISNULL(SourceTable.CurrentQty,TargetTable.CurrentQty),
					PickingQty = ISNULL(SourceTable.PickingQty,TargetTable.PickingQty),
					VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
					LifeBasicDate = ISNULL(SourceTable.LifeBasicDate,TargetTable.LifeBasicDate),
					ProductionDate = ISNULL(SourceTable.ProductionDate,TargetTable.ProductionDate),
					EndOfLifeDate = ISNULL(SourceTable.EndOfLifeDate,TargetTable.EndOfLifeDate),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					IsSplitLot = ISNULL(SourceTable.IsSplitLot,TargetTable.IsSplitLot),
					BefMaterialLotNo = ISNULL(SourceTable.BefMaterialLotNo,TargetTable.BefMaterialLotNo),
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
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialLotNo,
						LotID,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode,
						MaterialLocationCode,
						MaterialCode,
						MaterialStockAttribute,
						StockAttrib1,
						StockAttrib2,
						StockAttrib3,
						PackingID,
						GRDate,
						MaterialDeliveryNo,
						MaterialDeliveryDetailNo,
						InitialQty,
						CurrentQty,
						PickingQty,
						VendorLotNo,
						LifeBasicDate,
						ProductionDate,
						EndOfLifeDate,
						LotNo,
						IsSplitLot,
						BefMaterialLotNo,
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
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialLotNo,
							SourceTable.LotID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialLocationCode,
							SourceTable.MaterialCode,
							SourceTable.MaterialStockAttribute,
							SourceTable.StockAttrib1,
							SourceTable.StockAttrib2,
							SourceTable.StockAttrib3,
							SourceTable.PackingID,
							SourceTable.GRDate,
							SourceTable.MaterialDeliveryNo,
							SourceTable.MaterialDeliveryDetailNo,
							SourceTable.InitialQty,
							SourceTable.CurrentQty,
							SourceTable.PickingQty,
							SourceTable.VendorLotNo,
							SourceTable.LifeBasicDate,
							SourceTable.ProductionDate,
							SourceTable.EndOfLifeDate,
							SourceTable.LotNo,
							SourceTable.IsSplitLot,
							SourceTable.BefMaterialLotNo,
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
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MaterialLotInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
							    ELSE OldMaterialLotNo
							END AS OldMaterialLotNo,
							MaterialLotNo,
							LotID,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialLocationCode,
							MaterialCode,
							MaterialStockAttribute,
							StockAttrib1,
							StockAttrib2,
							StockAttrib3,
							PackingID,
							GRDate,
							MaterialDeliveryNo,
							MaterialDeliveryDetailNo,
							InitialQty,
							CurrentQty,
							PickingQty,
							VendorLotNo,
							LifeBasicDate,
							ProductionDate,
							EndOfLifeDate,
							LotNo,
							IsSplitLot,
							BefMaterialLotNo,
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
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialLotNo VARCHAR(20),
										MaterialLotNo VARCHAR(20),
										LotID VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialLocationCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										MaterialStockAttribute VARCHAR(20),
										StockAttrib1 VARCHAR(20),
										StockAttrib2 VARCHAR(20),
										StockAttrib3 VARCHAR(20),
										PackingID VARCHAR(50),
										GRDate VARCHAR(10),
										MaterialDeliveryNo VARCHAR(20),
										MaterialDeliveryDetailNo VARCHAR(20),
										InitialQty NUMERIC(20,5),
										CurrentQty NUMERIC(20,5),
										PickingQty NUMERIC(20,5),
										VendorLotNo VARCHAR(100),
										LifeBasicDate DATETIMEOFFSET,
										ProductionDate DATETIMEOFFSET,
										EndOfLifeDate DATETIMEOFFSET,
										LotNo VARCHAR(500),
										IsSplitLot BIT,
										BefMaterialLotNo VARCHAR(20),
										LotAttr01 NVARCHAR(100),
										LotAttr02 NVARCHAR(100),
										LotAttr03 NVARCHAR(100),
										LotAttr04 NVARCHAR(100),
										LotAttr05 NVARCHAR(100),
										LotAttr06 NVARCHAR(100),
										LotAttr07 NVARCHAR(100),
										LotAttr08 NVARCHAR(100),
										LotAttr09 NVARCHAR(100),
										LotAttr10 NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialLotNo = SourceTable.MaterialLotNo
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
									OldMaterialLotNo,
									MaterialLotNo,
									LotID,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialLocationCode,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									GRDate,
									MaterialDeliveryNo,
									MaterialDeliveryDetailNo,
									InitialQty,
									CurrentQty,
									PickingQty,
									VendorLotNo,
									LifeBasicDate,
									ProductionDate,
									EndOfLifeDate,
									LotNo,
									IsSplitLot,
									BefMaterialLotNo,
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
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialLotNo VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotID VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 GRDate VARCHAR(10),
											 MaterialDeliveryNo VARCHAR(20),
											 MaterialDeliveryDetailNo VARCHAR(20),
											 InitialQty NUMERIC(20,5),
											 CurrentQty NUMERIC(20,5),
											 PickingQty NUMERIC(20,5),
											 VendorLotNo VARCHAR(100),
											 LifeBasicDate DATETIMEOFFSET,
											 ProductionDate DATETIMEOFFSET,
											 EndOfLifeDate DATETIMEOFFSET,
											 LotNo VARCHAR(500),
											 IsSplitLot BIT,
											 BefMaterialLotNo VARCHAR(20),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 LotAttr06 NVARCHAR(100),
											 LotAttr07 NVARCHAR(100),
											 LotAttr08 NVARCHAR(100),
											 LotAttr09 NVARCHAR(100),
											 LotAttr10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
										ELSE OldMaterialLotNo
									END AS OldMaterialLotNo,
									MaterialLotNo,
									LotID,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialLocationCode,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									GRDate,
									MaterialDeliveryNo,
									MaterialDeliveryDetailNo,
									InitialQty,
									CurrentQty,
									PickingQty,
									VendorLotNo,
									LifeBasicDate,
									ProductionDate,
									EndOfLifeDate,
									LotNo,
									IsSplitLot,
									BefMaterialLotNo,
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
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialLotNo VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotID VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 GRDate VARCHAR(10),
											 MaterialDeliveryNo VARCHAR(20),
											 MaterialDeliveryDetailNo VARCHAR(20),
											 InitialQty NUMERIC(20,5),
											 CurrentQty NUMERIC(20,5),
											 PickingQty NUMERIC(20,5),
											 VendorLotNo VARCHAR(100),
											 LifeBasicDate DATETIMEOFFSET,
											 ProductionDate DATETIMEOFFSET,
											 EndOfLifeDate DATETIMEOFFSET,
											 LotNo VARCHAR(500),
											 IsSplitLot BIT,
											 BefMaterialLotNo VARCHAR(20),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 LotAttr06 NVARCHAR(100),
											 LotAttr07 NVARCHAR(100),
											 LotAttr08 NVARCHAR(100),
											 LotAttr09 NVARCHAR(100),
											 LotAttr10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
										ELSE OldMaterialLotNo
									END AS OldMaterialLotNo,
									MaterialLotNo,
									LotID,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialLocationCode,
									MaterialCode,
									MaterialStockAttribute,
									StockAttrib1,
									StockAttrib2,
									StockAttrib3,
									PackingID,
									GRDate,
									MaterialDeliveryNo,
									MaterialDeliveryDetailNo,
									InitialQty,
									CurrentQty,
									PickingQty,
									VendorLotNo,
									LifeBasicDate,
									ProductionDate,
									EndOfLifeDate,
									LotNo,
									IsSplitLot,
									BefMaterialLotNo,
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
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialLotNo VARCHAR(20),
											 MaterialLotNo VARCHAR(20),
											 LotID VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialLocationCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 MaterialStockAttribute VARCHAR(20),
											 StockAttrib1 VARCHAR(20),
											 StockAttrib2 VARCHAR(20),
											 StockAttrib3 VARCHAR(20),
											 PackingID VARCHAR(50),
											 GRDate VARCHAR(10),
											 MaterialDeliveryNo VARCHAR(20),
											 MaterialDeliveryDetailNo VARCHAR(20),
											 InitialQty NUMERIC(20,5),
											 CurrentQty NUMERIC(20,5),
											 PickingQty NUMERIC(20,5),
											 VendorLotNo VARCHAR(100),
											 LifeBasicDate DATETIMEOFFSET,
											 ProductionDate DATETIMEOFFSET,
											 EndOfLifeDate DATETIMEOFFSET,
											 LotNo VARCHAR(500),
											 IsSplitLot BIT,
											 BefMaterialLotNo VARCHAR(20),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 LotAttr06 NVARCHAR(100),
											 LotAttr07 NVARCHAR(100),
											 LotAttr08 NVARCHAR(100),
											 LotAttr09 NVARCHAR(100),
											 LotAttr10 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialLotNo,
								 @MaterialLotNo,
								 @LotID,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialWarehouseCode,
								 @MaterialLocationCode,
								 @MaterialCode,
								 @MaterialStockAttribute,
								 @StockAttrib1,
								 @StockAttrib2,
								 @StockAttrib3,
								 @PackingID,
								 @GRDate,
								 @MaterialDeliveryNo,
								 @MaterialDeliveryDetailNo,
								 @InitialQty,
								 @CurrentQty,
								 @PickingQty,
								 @VendorLotNo,
								 @LifeBasicDate,
								 @ProductionDate,
								 @EndOfLifeDate,
								 @LotNo,
								 @IsSplitLot,
								 @BefMaterialLotNo,
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
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WHERE MaterialLotNo = @MaterialLotNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialLotNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT
                    END

                    INSERT INTO STB_MaterialLotInfo
						(
						    MaterialLotNo,
						    LotID,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialWarehouseCode,
						    MaterialLocationCode,
						    MaterialCode,
						    MaterialStockAttribute,
						    StockAttrib1,
						    StockAttrib2,
						    StockAttrib3,
						    PackingID,
						    GRDate,
						    MaterialDeliveryNo,
						    MaterialDeliveryDetailNo,
						    InitialQty,
						    CurrentQty,
						    PickingQty,
						    VendorLotNo,
						    LifeBasicDate,
						    ProductionDate,
						    EndOfLifeDate,
						    LotNo,
						    IsSplitLot,
						    BefMaterialLotNo,
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
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialLotNo,
						    @LotID,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialWarehouseCode,
						    @MaterialLocationCode,
						    @MaterialCode,
						    @MaterialStockAttribute,
						    @StockAttrib1,
						    @StockAttrib2,
						    @StockAttrib3,
						    @PackingID,
						    @GRDate,
						    @MaterialDeliveryNo,
						    @MaterialDeliveryDetailNo,
						    @InitialQty,
						    @CurrentQty,
						    @PickingQty,
						    @VendorLotNo,
						    @LifeBasicDate,
						    @ProductionDate,
						    @EndOfLifeDate,
						    @LotNo,
						    @IsSplitLot,
						    @BefMaterialLotNo,
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
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MaterialLotInfo
						SET
						    MaterialLotNo =   ISNULL(@MaterialLotNo,MaterialLotNo),
						    LotID =   ISNULL(@LotID,LotID),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    MaterialWarehouseCode =   ISNULL(@MaterialWarehouseCode,MaterialWarehouseCode),
						    MaterialLocationCode =   ISNULL(@MaterialLocationCode,MaterialLocationCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    MaterialStockAttribute =   ISNULL(@MaterialStockAttribute,MaterialStockAttribute),
						    StockAttrib1 =   ISNULL(@StockAttrib1,StockAttrib1),
						    StockAttrib2 =   ISNULL(@StockAttrib2,StockAttrib2),
						    StockAttrib3 =   ISNULL(@StockAttrib3,StockAttrib3),
						    PackingID =   ISNULL(@PackingID,PackingID),
						    GRDate =   ISNULL(@GRDate,GRDate),
						    MaterialDeliveryNo =   ISNULL(@MaterialDeliveryNo,MaterialDeliveryNo),
						    MaterialDeliveryDetailNo =   ISNULL(@MaterialDeliveryDetailNo,MaterialDeliveryDetailNo),
						    InitialQty =   ISNULL(@InitialQty,InitialQty),
						    CurrentQty =   ISNULL(@CurrentQty,CurrentQty),
						    PickingQty =   ISNULL(@PickingQty,PickingQty),
						    VendorLotNo =   ISNULL(@VendorLotNo,VendorLotNo),
						    LifeBasicDate =   ISNULL(@LifeBasicDate,LifeBasicDate),
						    ProductionDate =   ISNULL(@ProductionDate,ProductionDate),
						    EndOfLifeDate =   ISNULL(@EndOfLifeDate,EndOfLifeDate),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    IsSplitLot =   ISNULL(@IsSplitLot,IsSplitLot),
						    BefMaterialLotNo =   ISNULL(@BefMaterialLotNo,BefMaterialLotNo),
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
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialLotNo = @OldMaterialLotNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialLotInfo
						WHERE
						    MaterialLotNo = @OldMaterialLotNo
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
