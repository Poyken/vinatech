
-- =============================================
-- Author:		<Jeon Gyeong Ho>
-- Browsable : false
-- Group : 시스템
-- Create date: <2016-06-17>
-- Description:	자재를 출고처리 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessMaterialLotInfoOutput]
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pMaterialLotNo VARCHAR(20) = NULL,
	@pLotID VARCHAR(50),
	@pMaterialWarehouseCode VARCHAR(20),
	@pMaterialLocationCode VARCHAR(20),
	@pMaterialStockAttribute VARCHAR(20),
	@pStockAttrib1 VARCHAR(20),
	@pStockAttrib2 VARCHAR(20),
	@pStockAttrib3 VARCHAR(20),
	@pMaterialCode VARCHAR(50),
	@pUsedQty NUMERIC(20,5),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialLotNo VARCHAR(20),
			@MaterialLotCurrentQty NUMERIC(20,5),
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@MaterialDocDetailNo VARCHAR(20) = @pMaterialDocDetailNo,
			@ProcessQty NUMERIC(20,5),
			@TotalQty NUMERIC(20,5) = @pUsedQty,
			@IsUseLotID BIT,
			@Barcode VARCHAR(20),
			@ProductGroupCode VARCHAR(20)

	DECLARE @StockInfo TABLE
	(
		SeqNo INT,
		MaterialLotNo VARCHAR(20),
		MaterialCode VARCHAR(50),
		CurrentQty NUMERIC(20,5)
	)


	/**********원자재 투입시 STB_MEARawMaterialInputHist 에서 제품 Barcode 가져오기  2022. 09. 06 SJC ****/
				-- 내부호출 프로시저에서의 값 확인
	IF OBJECT_ID('tempdb..#LotNoList') IS NOT NULL BEGIN
		SELECT TOP 1 @Barcode = Barcode
					,@ProductGroupCode = ProductGroupCode
		  FROM #LotNoList
				
		--EXEC usp_RaiseLocalizedError 'Korean', @Barcode
		--RETURN

	END

	DECLARE @LotID VARCHAR(30)
		   ,@CurrentQty Numeric(20, 5)
	       ,@Msg VARCHAR(100)

	SELECT
			@LotID = MLI.LotID,
			@CurrentQty = MLI.CurrentQty
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.MaterialLotNo = @pMaterialLotNo

	--SET @Msg = ISNULL(@pMaterialLotNo, '1') + '/' + ISNULL(@LotID, '2') + '/' + @CurrentQty

	--EXEC usp_RaiseLocalizedError 'Korean', @CurrentQty
	--RETURN

	/**********원자재 투입시 STB_MEARawMaterialInputHist 에서 제품 Barcode 가져오기  2022. 09. 06 SJC ****/



	SET @MaterialLotNo = ISNULL(@pMaterialLotNo, '')
	IF @MaterialLotNo = ''
	BEGIN
			

			SELECT
					@IsUseLotID = ISNULL(ML.IsUseLotID, 0)
			FROM
					STB_MaterialLocation ML WITH (NOLOCK)
			WHERE
					ML.MaterialLocationCode = @pMaterialLocationCode
			
			IF @IsUseLotID = 0
			BEGIN
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
							MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
							MLI.MaterialLocationCode = @pMaterialLocationCode AND
							MLI.MaterialStockAttribute = @pMaterialStockAttribute AND
							MLI.StockAttrib1 = @pStockAttrib1 AND
							MLI.StockAttrib2 = @pStockAttrib2 AND
							MLI.StockAttrib3 = @pStockAttrib3 AND
							MLI.MaterialCode = @pMaterialCode AND
							MLI.CurrentQty > 0
			END ELSE BEGIN

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
					ORDER BY
							MLI.GRDate ASC
			END

			DECLARE
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


				-- 여기에 처리
				SET @ProcessQty = @pUsedQty - @RemainQty

				EXEC usp_DoCreateMaterialDocLot_ForGIBackFlush
							@pMaterialDocNo = @MaterialDocNo,
							@pMaterialDocDetailNo = @MaterialDocDetailNo,
							@pMaterialLotNo = @MaterialLotNo,
							@pProcessQty = @ProcessQty,
							@pProcessUserID = @pProcessUserID

				-- 2016-08-22 JGH 수정
				UPDATE STB_MaterialLotInfo
				SET
					PickingQty = PickingQty - @ProcessQty
				WHERE
					MaterialLotNo = @MaterialLotNo

				IF @RemainQty > 0
				BEGIN
					IF @TotalCount = @Count
					BEGIN
						--UPDATE STB_MaterialLotInfo
						--SET
						--	CurrentQty = CurrentQty - @RemainQty
						--WHERE
						--	MaterialLotNo = @MaterialLotNo
						BREAK
					END

					SET @pUsedQty = @RemainQty
					SET @Count = @Count + 1
					DELETE FROM @StockInfo WHERE MaterialLotNo = @MaterialLotNo
				END
				ELSE BEGIN
					BREAK
				END
			END

			IF @RemainQty > 0
			BEGIN
				SET @RemainQty = @RemainQty * -1

		
				IF @IsUseLotID = 0
				BEGIN
						SELECT
								TOP 1
								@MaterialLotNo = MLI.MaterialLotNo
						FROM
								STB_MaterialLotInfo MLI
						WHERE
								MLI.CompanyCode = @pCompanyCode AND
								MLI.WorkCenterCode = @pWorkCenterCode AND
								MLI.MaterialWarehouseCode = @pMaterialWarehouseCode AND
								MLI.MaterialLocationCode = @pMaterialLocationCode AND
								MLI.MaterialStockAttribute = @pMaterialStockAttribute AND
								MLI.StockAttrib1 = @pStockAttrib1 AND
								MLI.StockAttrib2 = @pStockAttrib2 AND
								MLI.StockAttrib3 = @pStockAttrib3 AND
								MLI.MaterialCode = @pMaterialCode AND
								MLI.CurrentQty <= 0
				END ELSE BEGIN
						SELECT
								TOP 1
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
								MLI.CurrentQty <= 0
				END

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
						@pProcessUserID = @pProcessUserID,
						@pMaterialLOtNo = @MaterialLotNo OUTPUT

					SET @ProcessQty = @RemainQty * -1

					EXEC usp_DoCreateMaterialDocLot_ForGIBackFlush
								@pMaterialDocNo = @MaterialDocNo,
								@pMaterialDocDetailNo = @MaterialDocDetailNo,
								@pMaterialLotNo = @MaterialLotNo,
								@pProcessQty = @ProcessQty,
								@pProcessUserID = @pProcessUserID
				END
				ELSE BEGIN
					UPDATE STB_MaterialLotInfo
					SET
						CurrentQty = CurrentQty + @RemainQty
					WHERE
						MaterialLotNo = @MaterialLotNo

					SET @ProcessQty = @RemainQty * -1

					EXEC usp_DoCreateMaterialDocLot_ForGIBackFlush
								@pMaterialDocNo = @MaterialDocNo,
								@pMaterialDocDetailNo = @MaterialDocDetailNo,
								@pMaterialLotNo = @MaterialLotNo,
								@pProcessQty = @ProcessQty,
								@pProcessUserID = @pProcessUserID
				END

				-- 2016-08-22 JGH 수정
				UPDATE STB_MaterialLotInfo
				SET
					PickingQty = PickingQty - @ProcessQty
				WHERE
					MaterialLotNo = @MaterialLotNo
			END

			UPDATE STB_MaterialDocDetail
			SET
					ProcessFixQty = ISNULL(ProcessFixQty,0) + @TotalQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo

	END ELSE BEGIN -- Material Lot 이 지정된 경우
			IF (
					SELECT
							COUNT(*) 
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.MaterialLotNo = @MaterialLotNo
				) < 1
			BEGIN
					SET @pUsedQty = @pUsedQty * -1
					
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
						@pUsedQty =  @pUsedQty,
						@pProcessUserID = @pProcessUserID,
						@pMaterialLotNo = @MaterialLotNo
			
			END ELSE BEGIN

					UPDATE STB_MaterialLotInfo
					SET
						PickingQty = PickingQty - @pUsedQty,
						CurrentQty = CurrentQty - @pUsedQty
					WHERE
						MaterialLotNo = @MaterialLotNo

					SELECT
							@MaterialLotCurrentQty = MLI.CurrentQty
					FROM
							STB_MaterialLotInfo MLI
					WHERE
							MLI.MaterialLotNo = @MaterialLotNo

					/**********원자재 투입시 STB_MEARawMaterialInputHist 생성  2022. 09. 06 SJC ****/
					
					--IF @Barcode IS NOT NULL BEGIN
					--	DECLARE @MEARawMaterialInputHistNo VARCHAR(20)

					--	EXEC usp_DoCreateSerial 'STB_MEARawMaterialInputHist',@MEARawMaterialInputHistNo OUTPUT

					--	INSERT INTO STB_MEARawMaterialInputHist
					--		(
					--			MEARawMaterialInputHistNo,
					--			Barcode,
					--			ProductGroupCode,
					--			RawMaterialBarcode,
					--			Qty,
					--			CreateDateTime,
					--			CreateUserID,
					--			ChangeDateTime,
					--			ChangeUserID
					--		)
					--		VALUES
					--		(
					--			@MEARawMaterialInputHistNo,
					--			@Barcode,
					--			@ProductGroupCode,
					--			@LotID,
					--			@pUsedQty,
					--			GETDATE(),
					--			@pProcessUserID,
					--			GETDATE(),
					--			@pProcessUserID
					--		)
					-- END
					/**********원자재 투입시 STB_MEARawMaterialInputHist 생성  2022. 09. 06 SJC ****/

					IF @MaterialLotCurrentQty = 0
					BEGIN
							DELETE FROM STB_MaterialLotInfo
							WHERE
									MaterialLotNo = @MaterialLotNo
					END						
			END	

			UPDATE STB_MaterialDocDetail
			SET
					ProcessFixQty = ISNULL(ProcessFixQty,0) + @TotalQty
			WHERE
					MaterialDocDetailNo = @MaterialDocDetailNo
	END

END
