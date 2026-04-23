-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2018-09-10
-- Description:	생산Lot을 삭제합니다(슬리팅)
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteSetInfoForLotNo_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL,
	@pSIExtText01 VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @LotID VARCHAR(50) = @pSIExtText01
	DECLARE @DayPlanNo VARCHAR(20) = ISNULL(@pDayPlanNo,'')

	DECLARE @LotCount INT
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
			@Barcode = MAX(SI.Barcode),
			@ProdQty = MAX(SI.ProdQty)
	FROM
			STB_SetInfo SI
	WHERE
			SI.SIExtText01 = @LotID

	SET @LotCount = (SELECT COUNT(*) FROM STB_SetInfo SI WHERE SI.SIExtText01 = @LotID)
	SET @StockQty = @ProdQty * @LotCount

	DELETE FROM	STB_SetInfo
	WHERE
			Barcode = @Barcode

	IF NOT EXISTS (
					SELECT	1
					FROM
							STB_SetInfo SI
					WHERE
							SI.SIExtText01 = @LotID
				) BEGIN
			SELECT
					@MaterialDocNo = MDLI.MaterialDocNo
			FROM
					STB_MaterialDocLotInfo MDLI
					INNER JOIN STB_MaterialDocInfo MDI
						ON MDI.MaterialDocNo = MDLI.MaterialDocNo
			WHERE
					MDLI.LotID = @LotID AND
					MDI.MaterialDocTypeCode = 'GI_PRODUCTION' AND
					MDI.DocStatus = 'FIX' AND
					MDI.IsCancel = 0

			EXEC usp_DoCancelMaterialDoc	@pProcessLanguage = @ProcessLanguage,
											@pProcessUserID = @ProcessUserID,
											@pMaterialDocNo = @MaterialDocNo
	END ELSE BEGIN
			UPDATE	STB_SetInfo
			SET
					ProdQty = @StockQty /  (@LotCount - 1)
			WHERE
					SIExtText01 = @LotID
	END
END


