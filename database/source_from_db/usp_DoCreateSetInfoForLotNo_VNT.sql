-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2018-08-03
-- Description:	입력한 수량만큼 생산Lot을 생성합니다(슬리팅)
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSetInfoForLotNo_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL,
	@pLotID VARCHAR(50),
	@pLotCount INT,
	@pIsAddLot BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LotCount INT = @pLotCount
	DECLARE @LotID VARCHAR(50) = @pLotID
	DECLARE @DayPlanNo VARCHAR(20) = ISNULL(@pDayPlanNo,'')
	DECLARE @IsAddLot BIT = ISNULL(@pIsAddLot,0)

	DECLARE @MaterialDocNo VARCHAR(20)
	DECLARE @MaterialLotNo VARCHAR(20)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @Idx INT = 0
	DECLARE @Index INT
	DECLARE @IsFix BIT
	DECLARE @IsCancel BIT
	DECLARE @ErrorMsg NVARCHAR(400)
	DECLARE @StockQty NUMERIC(20,5)
	DECLARE @LotMaterialCode VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @BefLotCount INT

	SELECT
			@IsFix = POI.IsFix,
			@IsCancel = POI.IsCancel
	FROM
			STB_ProductionOrderInfo POI
	WHERE
			POI.PONo = @PONo

	IF @IsFix = 0 BEGIN
			SET @ErrorMsg = '확정되지 않은 PO입니다 [' + @PONo + ']'
			EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
			RETURN
	END

	IF @IsCancel = 1 BEGIN
			SET @ErrorMsg = '이미 취소된 PO입니다 [' + @PONo + ']'
			EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
			RETURN
	END

	IF @DayPlanNo <> '' BEGIN
			SELECT
					@IsFix = DPP.IsFixed,
					@IsCancel = DPP.IsCancel
			FROM
					STB_DayProdPlan DPP
			WHERE
					DPP.DayPlanNo = @DayPlanNo

			IF @IsFix = 0 BEGIN
					SET @ErrorMsg = '확정되지 않은 일일계획입니다 [' + @DayPlanNo + ']'
					EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
					RETURN
			END

			IF @IsCancel = 1 BEGIN
					SET @ErrorMsg = '이미 취소된 일일계획입니다 [' + @PONo + ']'
					EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
					RETURN
			END
	END	

	SELECT
			@LotMaterialCode = MLI.MaterialCode,
			@MaterialLotNo = MLI.MaterialLotNo,
			@StockQty = MLI.CurrentQty
	FROM
			STB_MaterialLotInfo MLI
	WHERE
			MLI.LotID = @LotID
		
	IF @IsAddLot = 0 BEGIN
			IF ISNULL(@StockQty,0) <= 0 BEGIN
					SET @ErrorMsg = '재고에 없는 Lot 입니다 [' + @LotID + ']'
					EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
					RETURN
			END
	END ELSE BEGIN
			SELECT
					@LotMaterialCode = MLI.MaterialCode,
					@MaterialLotNo = MLI.MaterialLotNo,
					@StockQty = MLI.CurrentQty
			FROM
					STB_MaterialLotSnapshot MLI
			WHERE
					MLI.LotID = @LotID
	END
	
	IF NOT EXISTS (
					SELECT	1
					FROM
							STB_ProductionOrderBom POB
					WHERE
							POB.PONo = @PONo AND
							POB.ChildMaterialCode = @LotMaterialCode
				) BEGIN
			SET @ErrorMsg = 'BOM해당하지 않는 Lot 입니다 [' + @LotID + ']'
			EXEC usp_RaiseLocalizedError @ProcessLanguage, @ErrorMsg
			RETURN
	END
	
	SELECT
			@Barcode = MAX(SI.Barcode)
	FROM
			STB_SetInfo SI
	WHERE
			SI.SIExtText01 = @LotID

	IF ISNULL(@Barcode,'') = '' BEGIN
			SET @Index = 1
	END ELSE BEGIN
			SET @Index = CONVERT(INT,SUBSTRING(@Barcode,LEN(@LotID) + 2,LEN(@Barcode) - LEN(@LotID) + 1)) + 1
	END

	IF @IsAddLot = 0 BEGIN
		SET @ProdQty = @StockQty /  @LotCount
	END ELSE BEGIN
		SELECT
				@ProdQty = SI.ProdQty
		FROM
				STB_SetInfo SI
		WHERE
				SI.SIExtText01 = @LotID
	END

	WHILE @LotCount > @Idx BEGIN
			SET @Barcode = @LotID + +'-' + RIGHT('000' + CONVERT(VARCHAR,@Idx + @Index),3)

			EXEC usp_DoCreateSetInfo	@pProcessUserID = @ProcessUserID,
										@pProcessLanguage = @ProcessLanguage,
										@pPONo = @pPONo,
										@pDayPlanNo = @pDayPlanNo,
										@pProdQty = @ProdQty,
										@pBarcode = @Barcode,
										@pSIExtText01 = @LotID		-- 코팅롤 바코드

			SET @Idx = @Idx + 1
	END	

	
	IF @IsAddLot = 0 BEGIN
			-- 코팅롤 자재 출고
			EXEC usp_DoProcessProdGIMaterialForBarcode	@pProcessUserID = @ProcessUserID,
														@pProcessLanguage = @ProcessLanguage,
														@pPONo = @PONo,
														@pLotID = @LotID,
														@pProdQty = @StockQty,
														@pMaterialDocNo = @MaterialDocNo OUTPUT

			EXEC usp_DoFinishMaterialDoc	@pProcessLanguage = @ProcessLanguage,
											@pProcessUserID = @ProcessUserID,
											@pMaterialDocNo = @MaterialDocNo

			EXEC usp_DoFixMaterialDoc	@pProcessUserID = @ProcessUserID,
										@pProcessLanguage = @ProcessLanguage,
										@pMaterialDocNo = @MaterialDocNo
	END ELSE BEGIN
			SET @BefLotCount = (SELECT COUNT(*) FROM STB_SetInfo SI WHERE SI.SIExtText01 = @LotID)
			SET @StockQty = @ProdQty * @BefLotCount
			SET @LotCount = @LotCount + @BefLotCount

			UPDATE	STB_SetInfo
			SET
					ProdQty = @StockQty /  @LotCount
			WHERE
					SIExtText01 = @LotID
	END
END


