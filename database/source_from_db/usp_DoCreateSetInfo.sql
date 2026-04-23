-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리
-- Description:	생산제품(Lot)을 생성합니다
-- Modified: Lot생성
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSetInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPONo VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL,
	@pProdQty NUMERIC(20,5) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pSIExtText01 VARCHAR(50) = NULL,
	@pControlNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @ProdQty NUMERIC(20,5) = ISNULL(@pProdQty,1)
	DECLARE @Barcode VARCHAR(50) = ISNULL(@pBarcode,'')
	DECLARE @SIExtText01 VARCHAR(50) = ISNULL(@pSIExtText01,'')

	DECLARE @ControlNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @POSeqNo INT
	DECLARE @IsFixed BIT
	DECLARE @IsCancel BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel,
			@MaterialCode = POI.MaterialCode
	FROM
			STB_DayProdPlan DPP
			LEFT OUTER JOIN STB_ProductionOrderInfo POI
				ON POI.PONo = DPP.PONo
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	IF ISNULL(@IsFIxed,0) = 0 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage,'확정된 계획만 Lot을 생성할수 있습니다'
	END

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage,'이미 취소된 계획입니다'
	END	

	IF @Barcode <> '' AND EXISTS (
									SELECT	1
									FROM
											STB_SetInfo SI
									WHERE
											SI.Barcode = @Barcode
									) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
								'^이미 등록된 바코드입니다^',
								@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@Barcode)
			RETURN
	END

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SetInfo',@ControlNo OUTPUT

	INSERT INTO STB_SetInfo
	(
		ControlNo,
		PONo,
		DayPlanNo,
		MaterialCode,
		SetSeq,
		IsLineInput,
		IsLoss,
		IsDefect,
		Barcode,
		DefectQty,
		IsProdFinish,
		IsOutboundFinalInspection,
		IsFinalInspection,
		GradeCode,
		ProdQty,
		SIExtText01,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@ControlNo,
		@PONo,
		@DayPlanNo,
		@MaterialCode,
		1,
		0,
		0,
		0,
		@Barcode,
		0,
		0,
		0,
		0,
		'A',
		@ProdQty,
		@SIExtText01,
		GETDATE(),
		@pProcessUserID
	)

	SET @pControlNo = @ControlNo

END
