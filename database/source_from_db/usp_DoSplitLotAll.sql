

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2016-09-26
-- Description: 재고를 전체 Split 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSplitLotAll]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialLotNo VARCHAR(20),
	@pSplitQty NUMERIC(20,5)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
			@SplitQty NUMERIC(20,5) = @pSplitQty,
			@LotID VARCHAR(50),
			@MaterialCode VARCHAR(50),
			@CurrentQty NUMERIC(20,5),
			@PickingQty NUMERIC(20,5),
			@ErrorMessage NVARCHAR(MAX),
			@SameSplitPackingQty INT,
			@RemainSplitQty NUMERIC(20,5),
			@TotalSplitPackingQty INT,
			@LoopCount INT,
			@TargetSplitQty NUMERIC(20,5)
	
	SELECT
			@LotID = MLI.LotID,
			@MaterialCode =  MLI.MaterialCode,
			@CurrentQty = MLI.CurrentQty,
			@PickingQty = ISNULL(MLI.PickingQty,0)
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @MaterialLotNo

	IF ISNULL(@MaterialCode,'') = '' BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^재고정보를 찾을 수 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF ISNULL(@LotID,'') = '' BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^바코드가 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @PickingQty > 0 BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^피킹중인 재고는 분리할 수 없습니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @SplitQty < 0 BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^Disallow minus q''ty^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END

	IF @CurrentQty <= @SplitQty BEGIN
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
											'^분리할 수량은 재고보다 적어야 합니다.^',
											@ErrorMessage OUTPUT

		RAISERROR(@ErrorMessage,16,1)
		RETURN
	END


	SET @SameSplitPackingQty = CONVERT(INT, @CurrentQty) / CONVERT(INT, @SplitQty)
	SET @RemainSplitQty = CONVERT(INT, @CurrentQty) % CONVERT(INT, @SplitQty)

	IF @RemainSplitQty > 0
	BEGIN
		SET @TotalSplitPackingQty = @SameSplitPackingQty + 1
	END ELSE BEGIN
		SET @TotalSplitPackingQty = @SameSplitPackingQty 
	END

	DECLARE @NewMaterialLotNo VARCHAR(20)

	SET @LoopCount = 0
	
	WHILE @LoopCount < @TotalSplitPackingQty
	BEGIN
			IF @LoopCount < @SameSplitPackingQty
			BEGIN
				SET @TargetSplitQty = @SplitQty
			END ELSE BEGIN
				SET @TargetSplitQty = @RemainSplitQty
			END

			EXEC SmartFramework.dbo.usp_DoCreateSerial @pTableName = 'STB_MaterialLotInfo',
									@pSerialNo = @NewMaterialLotNo OUTPUT
			DECLARE @NewLotID VARCHAR(20)
			EXEC SmartFramework.dbo.usp_DoCreateSerial @pTableName = 'STB_MaterialDocLotInfo',
									@pSerialNo = @NewLotID OUTPUT

			INSERT INTO [dbo].[STB_MaterialLotInfo]
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
			SELECT
					@NewMaterialLotNo,
					@NewLotID,
					CompanyCode,
					WorkCenterCode,
					MaterialWarehouseCode,
					MaterialLocationCode,
					MaterialCode,
					MaterialStockAttribute,
					StockAttrib1,
					StockAttrib2,
					StockAttrib3,
					--PackingID,
					@NewLotID,
					GRDate,
					MaterialDeliveryNo,
					MaterialDeliveryDetailNo,
					@TargetSplitQty AS InitialQty,
					@TargetSplitQty AS CurrentQty,
					0 AS PickingQty,
					VendorLotNo,
					LifeBasicDate,
					ProductionDate,
					EndOfLifeDate,
					LotNo,
					1 AS IsSplitLot,
					MaterialLotNo, --바로 이전 Lot번호를 따라가는 경우
					--CASE 
					--	WHEN ISNULL(BefMaterialLotNo,'') = '' THEN MaterialLotNo
					--	ELSE BefMaterialLotNo 
					--END, -- 맨처음 Lot번호를 따라가는 경우
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
					GETDATE(),
					@ProcessUserID
			FROM
					STB_MaterialLotInfo MLI
			WHERE
					MLI.MaterialLotNo = @MaterialLotNo

			SET @LoopCount = @LoopCount + 1
	END

	DELETE FROM STB_MaterialLotInfo
	WHERE
			MaterialLotNo = @MaterialLotNo

	--UPDATE
	--		STB_MaterialLotInfo
	--SET
	--		CurrentQty = CurrentQty - @SplitQty,
	--		ChangeDateTime = GETDATE(),
	--		ChangeUserID = @ProcessUserID
	--WHERE
	--		MaterialLotNo = @MaterialLotNo
END


