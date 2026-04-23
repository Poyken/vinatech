
-- =============================================
-- Author:	    Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-10-18
-- Browsable : true
-- Group : 자재수불관리
-- Description:	공정패킹구성정보를 생성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateLabelForReturn]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @iDoc INT
	DECLARE	@UpdateTableName VARCHAR(200)

	DECLARE
			@MaterialLotNo VARCHAR(20),
			@LotID VARCHAR(50),
			@CompanyCode VARCHAR(20),
			@WorkCenterCode VARCHAR(20),
			@MaterialWarehouseCode VARCHAR(20),
			@MaterialLocationCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@MaterialStockAttribute VARCHAR(20),
			@StockAttrib1 VARCHAR(20),
			@StockAttrib2 VARCHAR(20),
			@StockAttrib3 VARCHAR(20),
			@PackingID VARCHAR(50),
			@GRDate VARCHAR(10),
			@MaterialDeliveryNo VARCHAR(20),
			@MaterialDeliveryDetailNo VARCHAR(20),
			@InitialQty NUMERIC(20,5),
			@CurrentQty NUMERIC(20,5),
			@PickingQty NUMERIC(20,5),
			@VendorLotNo VARCHAR(100),
			@LifeBasicDate DATE,
			@ProductionDate DATE,
			@EndOfLifeDate DATE,
			@LotNo VARCHAR(100),
			@IsSplitLot BIT,
			@BefMaterialLotNo VARCHAR(20),
			@LotAttr01 NVARCHAR(100),
			@LotAttr02 NVARCHAR(100),
			@LotAttr03 NVARCHAR(100),
			@LotAttr04 NVARCHAR(100),
			@LotAttr05 NVARCHAR(100),
			@LotAttr06 NVARCHAR(100),
			@LotAttr07 NVARCHAR(100),
			@LotAttr08 NVARCHAR(100),
			@LotAttr09 NVARCHAR(100),
			@LotAttr10 NVARCHAR(100),
			@BoxQty INT,
			@UnitQty INT,
			@RowCnt INT,
			@NewSerialNo INT,
			@MarshallingPONumber VARCHAR(50),
			@MarshallingMODEL VARCHAR(50)

	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
	DECLARE @RealMaterialLotNo VARCHAR(20)





	SET @UpdateTableName = '/DataSet/GetMaterialLotInfoForReturn_UPDATE'

	BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
               
				SELECT
						XMLData.MaterialLotNo,
						XMLData.LotID,
						XMLData.CompanyCode,
						XMLData.WorkCenterCode,
						XMLData.MaterialWarehouseCode,
						XMLData.MaterialLocationCode,
						XMLData.MaterialCode,
						XMLData.MaterialStockAttribute,
						XMLData.StockAttrib1,
						XMLData.StockAttrib2,
						XMLData.StockAttrib3,
						XMLData.PackingID,
						XMLData.GRDate,
						XMLData.MaterialDeliveryNo,
						XMLData.MaterialDeliveryDetailNo,
						XMLData.InitialQty,
						XMLData.CurrentQty,
						XMLData.PickingQty,
						XMLData.VendorLotNo,
						XMLData.LifeBasicDate,
						XMLData.ProductionDate,
						XMLData.EndOfLifeDate,
						XMLData.LotNo,
						XMLData.IsSplitLot,
						XMLData.BefMaterialLotNo,
						XMLData.LotAttr01,
						XMLData.LotAttr02,
						XMLData.LotAttr03,
						XMLData.LotAttr04,
						XMLData.LotAttr05,
						XMLData.LotAttr06,
						XMLData.LotAttr07,
						XMLData.LotAttr08,
						XMLData.LotAttr09,
						XMLData.LotAttr10,
						XMLData.BoxQty,
						XMLData.UnitQty,
						XMLData.MarshallingPONumber,
						XMLData.MarshallingMODEL
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
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
								LifeBasicDate DATE,
								ProductionDate DATE,
								EndOfLifeDate DATE,
								LotNo VARCHAR(100),
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
								BoxQty INT,
								UnitQty INT,
								MarshallingPONumber VARCHAR(50),
								MarshallingMODEL VARCHAR(50)
							) XMLData
							

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
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
								@BoxQty,
								@UnitQty,
								@MarshallingPONumber,
								@MarshallingMODEL


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				DECLARE @InitRowCnt INT 
				SET @InitRowCnt = 1

				WHILE @InitRowCnt <= @BoxQty
				BEGIN

					EXEC SmartFramework.dbo.usp_GetSerialRule 
																@pTableName = 'STB_MaterialLotInfo',
																@pIsAutoKey = @IsAutoKey OUTPUT,
																@pIsLoopIUD = @IsLoopIUD OUTPUT,
																@pPrefixData = @PrefixString OUTPUT,
																@pSerialLen = @SerialLen OUTPUT,
																@pNewSerialNo = @NewSerialNo OUTPUT

					SET @RealMaterialLotNo = @PrefixString + dbo.fnMakeZeroNumber(@NewSerialNo, @SerialLen) 

					SET @PrefixString = ''
					SET @SerialLen = 0
					SET @NewSerialNo = 0

					EXEC SmartFramework.dbo.usp_GetSerialRule	@pTableName = 'STB_MaterialDocLotInfo',
													@pPrefixData = @PrefixString OUTPUT,
													@pSerialLen = @SerialLen OUTPUT,
													@pNewSerialNo = @NewSerialNo OUTPUT

					SET @LotID = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR,@NewSerialNo), @SerialLen)

					INSERT INTO STB_RouteMaterialLotInfo
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
						IsPrint,
						CreateDateTime,
						CreateUserID
					)
					VALUES
					(
						@RealMaterialLotNo,
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
						@RealMaterialLotNo,
						@GRDate,
						@MaterialDeliveryNo,
						@MaterialDeliveryDetailNo,
						@UnitQty,
						@UnitQty,
						0,
						@VendorLotNo,
						@LifeBasicDate,
						@ProductionDate,
						@EndOfLifeDate,
						--@LotNo,
						@MarshallingPONumber,
						@IsSplitLot,
						@MaterialLotNo,
						--@LotAttr01,
						--@LotAttr02,
						@MarshallingMODEL,
						@MarshallingPONumber,
						@LotAttr03,
						@LotAttr04,
						@LotAttr05,
						@LotAttr06,
						@LotAttr07,
						@LotAttr08,
						@LotAttr09,
						@LotAttr10,
						0,
						GETDATE(),
						@pProcessUserID
					)

					SET @InitRowCnt = @InitRowCnt + 1

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
