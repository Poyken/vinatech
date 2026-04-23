
-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.11.22
-- Browsable: false
-- Description:	STB_RouteMaterialLotInfo --> STB_MaterialLotInfo
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialLotInfoToRouteMaterialLotInfo]
	@pMaterialLotNo VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MaterialLotNo VARCHAR(20) = @pMaterialLotNo
	DECLARE @MaterialLocationCode VARCHAR(20),
			@MaterialCode VARCHAR(50),
			@CurrentQty NUMERIC(20,5)

	DECLARE @IsAutoKey BIT,
			@IsLoopIUD BIT,
			@PrefixString VARCHAR(20),
			@SerialLen INT,
			@NewSerialNo VARCHAR(20),
			@NewMaterialLotNo VARCHAR(20),
			@LotAttr01 NVARCHAR(200),
			@LotAttr02 NVARCHAR(200),
			@LotAttr03 NVARCHAR(200)

	SELECT
			@MaterialCode = MLI.MaterialCode,
			@MaterialLocationCode = MLI.MaterialLocationCode,
			@CurrentQty = MLI.CurrentQty,
			@LotAttr01 = MLI.LotAttr01,
			@LotAttr02 = MLI.LotAttr02,
			@LotAttr03 = MLI.LotAttr03
	FROM
			STB_MaterialLotInfo MLI 
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo 

	IF  (
			SELECT
					COUNT(*)
			FROM
					STB_MaterialLotInfo MLI WITH (NOLOCK)
			WHERE
					MLI.LotID = (CONVERT(VARCHAR, @MaterialCode)  + ':' + CONVERT(VARCHAR, @MaterialLocationCode))
		) > 0
	BEGIN
			UPDATE STB_MaterialLotInfo 
			SET
					CurrentQty = CurrentQty + @CurrentQty,
					LotAttr01 = CASE
									WHEN ISNULL(LotAttr01, '') = '' THEN @LotAttr01
									ELSE LotAttr01
								END,
					LotAttr02 = CASE
									WHEN ISNULL(LotAttr02, '') = '' THEN @LotAttr02
									ELSE LotAttr02
								END,
					LotAttr03 = CASE
									WHEN ISNULL(LotAttr03, '') = '' THEN @LotAttr03
									ELSE LotAttr03
								END
			WHERE
					LotID = (CONVERT(VARCHAR, @MaterialCode)  + ':' +  CONVERT(VARCHAR, @MaterialLocationCode)) 
	END ELSE BEGIN
			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialLotInfo',
														@NewMaterialLotNo OUTPUT

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
					,[CurrentQty]
					,0
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
					STB_MaterialLotInfo MLI
				WHERE
					MLI.MaterialLotNo = @MaterialLotNo
	END


	INSERT INTO STB_RouteMaterialLotInfo
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
			,[PackingID] -- Break Packing
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
			,[IsPrint])
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
			,1 AS IsPrint
		FROM 
			STB_MaterialLotInfo MLI
		WHERE
			MLI.MaterialLotNo = @MaterialLotNo


		DELETE FROM STB_MaterialLotInfo
		WHERE
			MaterialLotNo = @MaterialLotNo	   

END

