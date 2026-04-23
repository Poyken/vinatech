-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.11.22
-- Browsable: false
-- Description:	STB_RouteMaterialLotInfo --> STB_MaterialLotInfo
-- =============================================
CREATE PROCEDURE [dbo].[usp_RouteMaterialLotInfoToMaterialLotInfo]
	@pMaterialLotNo VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MaterialLotNo VARCHAR(20) = @pMaterialLotNo
	DECLARE @MaterialLocationCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@CurrentQty NUMERIC(20,5),
			@AllCurrentQty NUMERIC(20,5)

	DECLARE @IsAutoKey BIT,
			@IsLoopIUD BIT,
			@PrefixString VARCHAR(20),
			@SerialLen INT,
			@NewSerialNo VARCHAR(20),
			@NewMaterialLotNo VARCHAR(20)


	IF  (
			SELECT
					COUNT(*)
			FROM
					STB_RouteMaterialLotInfo RMLI 
			WHERE
					RMLI.MaterialLotNo = @MaterialLotNo 
		) > 0
	BEGIN
			SELECT
					@MaterialCode = RMLI.MaterialCode,
					@MaterialLocationCode = RMLI.MaterialLocationCode,
					@CurrentQty = RMLI.CurrentQty
			FROM
					STB_RouteMaterialLotInfo RMLI 
			WHERE
					RMLI.MaterialLotNo = @MaterialLotNo 

			INSERT INTO [dbo].[STB_MaterialLotInfo]
					   ([MaterialLotNo]
					   ,[LotID]
					   ,[CompanyCode]
					   ,[WorkCenterCode]
					   ,[MaterialWarehouseCode]
					   ,[MaterialLocationCode]
					   ,[MaterialCode]
					   ,[MaterialStockAttribute]
					   ,[StockAttrib1]
					   ,[StockAttrib2]
					   ,[StockAttrib3]
					   ,[PackingID]
					   ,[GRDate]
					   ,[MaterialDeliveryNo]
					   ,[MaterialDeliveryDetailNo]
					   ,[InitialQty]
					   ,[CurrentQty]
					   ,[PickingQty]
					   ,[VendorLotNo]
					   ,[LifeBasicDate]
					   ,[ProductionDate]
					   ,[EndOfLifeDate]
					   ,[LotNo]
					   ,[IsSplitLot]
					   ,[BefMaterialLotNo]
					   ,[LotAttr01]
					   ,[LotAttr02]
					   ,[LotAttr03]
					   ,[LotAttr04]
					   ,[LotAttr05]
					   ,[LotAttr06]
					   ,[LotAttr07]
					   ,[LotAttr08]
					   ,[LotAttr09]
					   ,[LotAttr10]
					   ,[CreateDateTime]
					   ,[CreateUserID]
					   ,[ChangeDateTime]
					   ,[ChangeUserID])
			SELECT [MaterialLotNo]
				  ,[LotID]
				  ,[CompanyCode]
				  ,[WorkCenterCode]
				  ,[MaterialWarehouseCode]
				  ,[MaterialLocationCode]
				  ,[MaterialCode]
				  ,[MaterialStockAttribute]
				  ,[StockAttrib1]
				  ,[StockAttrib2]
				  ,[StockAttrib3]
				  ,[LotID]
				  ,[GRDate]
				  ,[MaterialDeliveryNo]
				  ,[MaterialDeliveryDetailNo]
				  ,[InitialQty]
				  ,[CurrentQty]
				  ,[PickingQty]
				  ,[VendorLotNo]
				  ,[LifeBasicDate]
				  ,[ProductionDate]
				  ,[EndOfLifeDate]
				  ,[LotNo]
				  ,[IsSplitLot]
				  ,[BefMaterialLotNo]
				  ,[LotAttr01]
				  ,[LotAttr02]
				  ,[LotAttr03]
				  ,[LotAttr04]
				  ,[LotAttr05]
				  ,[LotAttr06]
				  ,[LotAttr07]
				  ,[LotAttr08]
				  ,[LotAttr09]
				  ,[LotAttr10]
				  ,[CreateDateTime]
				  ,[CreateUserID]
				  ,[ChangeDateTime]
				  ,[ChangeUserID]
			  FROM 
					STB_RouteMaterialLotInfo RMLI
			  WHERE
					RMLI.MaterialLotNo = @MaterialLotNo




			IF  (
					SELECT
							COUNT(*)
					FROM
							STB_MaterialLotInfo MLI --WITH (NOLOCK)
					WHERE
							MLI.LotID = (CONVERT(VARCHAR, @MaterialCode)  + ':' + CONVERT(VARCHAR, @MaterialLocationCode))
				) > 0
			BEGIN
					SELECT 
							@AllCurrentQty = MLI.CurrentQty - @CurrentQty
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							LotID = (CONVERT(VARCHAR, @MaterialCode)  + ':' +  CONVERT(VARCHAR, @MaterialLocationCode)) 

					UPDATE STB_MaterialLotInfo 
					SET
							CurrentQty = @AllCurrentQty,
							LotAttr01 = CASE
											WHEN @AllCurrentQty <= 0 THEN ''
											ELSE LotAttr01
										END,
							LotAttr02 = CASE
											WHEN @AllCurrentQty <= 0 THEN ''
											ELSE LotAttr02
										END,
							LotAttr03 = CASE
											WHEN @AllCurrentQty <= 0 THEN ''
											ELSE LotAttr03
										END
					WHERE
							LotID = (CONVERT(VARCHAR, @MaterialCode)  + ':' +  CONVERT(VARCHAR, @MaterialLocationCode)) 
			END ELSE BEGIN
					EXEC SmartFramework.dbo.usp_GetSerialRule 
								@pTableName = 'STB_MaterialLotInfo',
								@pIsAutoKey = @IsAutoKey OUTPUT,
								@pIsLoopIUD = @IsLoopIUD OUTPUT,
								@pPrefixData = @PrefixString OUTPUT,
								@pSerialLen = @SerialLen OUTPUT,
								@pNewSerialNo = @NewSerialNo OUTPUT

					SET @NewMaterialLotNo = @PrefixString + dbo.fnMakeZeroNumber(@NewSerialNo, @SerialLen) --RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)

					INSERT INTO [dbo].[STB_MaterialLotInfo]
								([MaterialLotNo]
								,[LotID]
								,[CompanyCode]
								,[WorkCenterCode]
								,[MaterialWarehouseCode]
								,[MaterialLocationCode]
								,[MaterialCode]
								,[MaterialStockAttribute]
								,[StockAttrib1]
								,[StockAttrib2]
								,[StockAttrib3]
								,[PackingID]
								,[GRDate]
								,[MaterialDeliveryNo]
								,[MaterialDeliveryDetailNo]
								,[InitialQty]
								,[CurrentQty]
								,[PickingQty]
								,[VendorLotNo]
								,[LifeBasicDate]
								,[ProductionDate]
								,[EndOfLifeDate]
								,[LotNo]
								,[IsSplitLot]
								,[BefMaterialLotNo]
								,[LotAttr01]
								,[LotAttr02]
								,[LotAttr03]
								,[LotAttr04]
								,[LotAttr05]
								,[LotAttr06]
								,[LotAttr07]
								,[LotAttr08]
								,[LotAttr09]
								,[LotAttr10]
								,[CreateDateTime]
								,[CreateUserID]
								,[ChangeDateTime]
								,[ChangeUserID])
					SELECT @NewMaterialLotNo AS [MaterialLotNo]
							,(CONVERT(VARCHAR, @MaterialCode) + ':' + CONVERT(VARCHAR, @MaterialLocationCode))  AS [LotID]
							,[CompanyCode]
							,[WorkCenterCode]
							,[MaterialWarehouseCode]
							,[MaterialLocationCode]
							,[MaterialCode]
							,[MaterialStockAttribute]
							,[StockAttrib1]
							,[StockAttrib2]
							,[StockAttrib3]
							,(CONVERT(VARCHAR, @MaterialCode) + ':' + CONVERT(VARCHAR, @MaterialLocationCode)) AS [PackingID]
							,[GRDate]
							,[MaterialDeliveryNo]
							,[MaterialDeliveryDetailNo]
							,0
							,[CurrentQty] * -1 AS CurrentQty
							,0
							,[VendorLotNo]
							,[LifeBasicDate]
							,[ProductionDate]
							,[EndOfLifeDate]
							,[LotNo]
							,[IsSplitLot]
							,[BefMaterialLotNo]
							,''
							,''
							,''
							,[LotAttr04]
							,[LotAttr05]
							,[LotAttr06]
							,[LotAttr07]
							,[LotAttr08]
							,[LotAttr09]
							,[LotAttr10]
							,[CreateDateTime]
							,[CreateUserID]
							,[ChangeDateTime]
							,[ChangeUserID]
						FROM 
							STB_RouteMaterialLotInfo RMLI
						WHERE
							RMLI.MaterialLotNo = @MaterialLotNo

 			END

			DELETE FROM STB_RouteMaterialLotInfo 
			WHERE MaterialLotNo = @MaterialLotNo
	END
	   

END
