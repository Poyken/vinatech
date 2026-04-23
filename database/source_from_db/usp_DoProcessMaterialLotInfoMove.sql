

-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Browsable : false
-- Group : 시스템
-- Create date: 2016.07.16
-- Description:	자재를 이동처리 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessMaterialLotInfoMove]
/*
	@pSourceCompanyCode VARCHAR(20),
	@pSourceWorkCenterCode VARCHAR(20),
	@pSourceRouteCode VARCHAR(20),
	@pSourceMaterialWarehouseCode VARCHAR(20),
	@pSourceMaterialLocationCode VARCHAR(20),
	@pSourceMaterialStockAttribute VARCHAR(20),
*/
	@pTargetCompanyCode VARCHAR(20),
	@pTargetWorkCenterCode VARCHAR(20),
	@pTargetRouteCode VARCHAR(20),
	@pTargetMaterialWarehouseCode VARCHAR(20),
	--@pTargetMaterialLocationCode VARCHAR(20),
	@pTargetMaterialStockAttribute VARCHAR(20),
	
	@pMaterialLotNo VARCHAR(20),
	@pPackingID VARCHAR(50),
/*	
	@pLotID VARCHAR(50),
	@pStockAttrib1 VARCHAR(20),
	@pStockAttrib2 VARCHAR(20),
	@pStockAttrib3 VARCHAR(20),
	@pMaterialCode VARCHAR(50),
*/	
	@pUsedQty NUMERIC(20,5),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefaultLocation VARCHAR(20)

	SELECT
			@DefaultLocation = MW.DefaultLocationCode
	FROM
			STB_MaterialWarehouse MW WITH (NOLOCK)
	WHERE
			MW.MaterialWarehouseCode = @pTargetMaterialWarehouseCode
		
			
			
	UPDATE STB_MaterialLotInfo
	SET
			CompanyCode = @pTargetCompanyCode,
			WorkCenterCode = @pTargetWorkCenterCode,
			MaterialWarehouseCode = @pTargetMaterialWarehouseCode,
			MaterialStockAttribute = @pTargetMaterialStockAttribute,
			MaterialLocationCode = @DefaultLocation,
			PackingID = @pPackingID,
			PickingQty = 0 -- 이동이므로 전량 Picking 수량 0으로 설정
	WHERE
			MaterialLotNo = @pMaterialLotNo
	
/*
	DECLARE @StockInfo TABLE
	(
		SeqNo INT,
		MaterialLotNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		CurrentQty NUMERIC(20,5)
	)

	INSERT INTO @StockInfo
	SELECT
			ROW_NUMBER() OVER (ORDER BY MLI.GRDate) AS SeqNo,
			MLI.MaterialLotNo,
			MLI.MaterialCode,
			MLI.CurrentQty
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.CompanyCode = @pCompanyCode AND
			MLI.WorkCenterCode = @pWorkCenterCode AND
			MLI.LotID = @pLotID AND
			MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
			MLI.MaterialLocationCode = @pMaterialLocationCode AND
			MLI.MaterialStockAttribute = @pMaterialStockAttribute AND
			MLI.StockAttrib1 = @pStockAttrib1 AND
			MLI.StockAttrib2 = @pStockAttrib2 AND
			MLI.StockAttrib3 = @pStockAttrib3 AND
			MLI.MaterialCode = @pMaterialCode AND
			MLI.CurrentQty >= 0

	DECLARE @MaterialLotNo VARCHAR(20),
			@Count INT = 1,
			@RemainQty NUMERIC(20,5) = @pUsedQty,
			@TotalCount INT = (SELECT COUNT(*) FROM @StockInfo)

	WHILE @TotalCount >= @Count
	BEGIN
		SELECT
				@MaterialLotNo = MaterialLotNo
		FROM
				@StockInfo
		WHERE
				SeqNo = @Count
		
		UPDATE STB_MaterialLotInfo
		SET
			CurrentQty = CASE 
							WHEN CurrentQty > @pUsedQty THEN CurrentQty - @pUsedQty
							ELSE 0
						 END,
			@RemainQty = CASE
							WHEN CurrentQty > @pUsedQty THEN 0
							ELSE @pUsedQty - CurrentQty
						 END
		WHERE
			MaterialLotNo = @MaterialLotNo

		IF @RemainQty > 0
		BEGIN
			IF @TotalCount = @Count
			BEGIN
				UPDATE STB_MaterialLotInfo
				SET
					CurrentQty = CurrentQty - @RemainQty
				WHERE
					MaterialLotNo = @MaterialLotNo

				RETURN
			END

			SET @pUsedQty = @RemainQty
			SET @Count = @Count + 1
			DELETE FROM @StockInfo WHERE MaterialLotNo = @MaterialLotNo
		END
		ELSE BEGIN
			RETURN
		END
	END

	IF @RemainQty > 0
	BEGIN
		SET @RemainQty = @RemainQty * -1

		SELECT
				@MaterialLotNo = MLI.MaterialLotNo
		FROM
				STB_MaterialLotInfo MLI
		WHERE
				MLI.CompanyCode = @pCompanyCode AND
				MLI.WorkCenterCode = @pWorkCenterCode AND
				MLI.LotID = @pLotID AND
				MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
				MLI.MaterialLocationCode = @pMaterialLocationCode AND
				MLI.MaterialStockAttribute = @pMaterialStockAttribute AND
				MLI.StockAttrib1 = @pStockAttrib1 AND
				MLI.StockAttrib2 = @pStockAttrib2 AND
				MLI.StockAttrib3 = @pStockAttrib3 AND
				MLI.MaterialCode = @pMaterialCode AND
				MLI.CurrentQty < 0

		IF ISNULL(@MaterialLotNo,'') = ''
		BEGIN
			EXEC usp_DoProcessNewMaterialLotNo
				@pCompanyCode = @pCompanyCode,
				@pWorkCenterCode = @pWorkCenterCode,
				@pLotID = @pLotID,
				@pMaterialWarehouseCode = @pMaterialWarehouseCode,
				@pMaterialLocationCode = @pMaterialLocationCode,
				@pMaterialStockAttribute = @pMaterialStockAttribute,
				@pStockAttrib1 = @pStockAttrib1,
				@pStockAttrib2 = @pStockAttrib2,
				@pStockAttrib3 = @pStockAttrib3,
				@pMaterialCode = @pMaterialCode,
				@pUsedQty = @RemainQty,
				@pProcessUserID = @pProcessUserID
			
		END
		ELSE BEGIN
			UPDATE STB_MaterialLotInfo
			SET
				CurrentQty = CurrentQty + @RemainQty
			WHERE
				MaterialLotNo = @MaterialLotNo
		END
	END
*/
END

