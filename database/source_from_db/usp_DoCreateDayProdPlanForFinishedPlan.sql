
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-10-23
-- Browsable : true
-- Group : 생산관리
-- Description: 사업장이동 계획생성
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateDayProdPlanForFinishedPlan]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pLineCode VARCHAR(20),
	@pPlanDate DATE,
	@pPlanShiftCode VARCHAR(1),
	@pProdPrior INT = NULL,
	@pDayPlanNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PONo VARCHAR(20) = @pPONo,
			@LineCode VARCHAR(20) = @pLineCode,
			@PlanDate DATE = @pPlanDate,
			@PlanShiftCode VARCHAR(1) = @pPlanShiftCode,
			@ProdPrior INT = @pProdPrior,
			@OldDayPlanNo VARCHAR(20) = @pDayPlanNo

	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @IsFix BIT
	DECLARE @IsCancel BIT
	DECLARE @IsFinish BIT
	DECLARE @DayPlanNo VARCHAR(20)

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode =POI.WorkCenterCode,
			@IsFix = POI.IsFix,
			@IsCancel = POI.IsCancel,
			@IsFinish = POI.IsFinish
	FROM
			STB_ProductionOrderInfo POI
	WHERE
			POI.PONo = @PONo

	IF ISNULL(@IsFix,0) = 0 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '확정되지 않은 생산계획번호입니다 [%s]', @PONo
			RETURN
	END

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '취소된 생산계획번호입니다 [%s]', @PONo
			RETURN
	END

	IF ISNULL(@IsFinish,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '생산이 완료된 생산계획번호입니다 [%s]', @PONo
			RETURN
	END

	SELECT
			@DayPlanNo = DPP.DayPlanNo
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DPPExtText02 = @OldDayPlanNo AND
			DPP.IsCancel = 0

	IF ISNULL(@DayPlanNo,'') <> '' BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '생성한 계획이 있습니다 [%s]',@OldDayPlanNo
	END

	EXEC usp_DoCreateSerial 'STB_DayProdPlan', @DayPlanNo OUTPUT

	INSERT INTO STB_DayProdPlan
	(
		DayPlanNo,
		CompanyCode,
		WorkCenterCode,
		PONo,
		MaterialCode,
		BomVersion,
		LineCode,
		PlanDate,
		PlanShiftCode,
		ProdPrior,
		PlanQty,
		IsFixed,
		IsCancel,
		DPPExtText02,		-- 이전 일일생산계획번호
		CreateDateTime,
		CreateUserID
	)
		SELECT
				@DayPlanNo,
				@CompanyCode,
				@WorkCenterCode,
				@PONo,
				DPP.MaterialCode,
				DPP.BomVersion,
				@LineCode,
				@PlanDate,
				@PlanShiftCode,
				@ProdPrior,
				DPP.PlanQty,
				1,
				0,
				DPP.DayPlanNo,
				GETDATE(),
				@pProcessUserID
		FROM
				STB_DayProdPlan DPP
		WHERE
				DPP.DayPlanNo = @OldDayPlanNo

		DECLARE @SetInfo TABLE
		(
			IDX INT IDENTITY(1,1),
			ControlNo VARCHAR(20),
			Barcode VARCHAR(50)
		)

		INSERT INTO @SetInfo
		(
			ControlNo,
			Barcode
		)
		SELECT
				ControlNo,
				Barcode
		FROM
				STB_SetInfo
		WHERE
				DayPlanNo = @OldDayPlanNo
				
		UPDATE	STB_SetInfo
		SET
				Barcode = 'MV_' + Barcode
		WHERE
				DayPlanNo = @OldDayPlanNo

		DECLARE @Count INT = (SELECT COUNT(*) FROM @SetInfo)
		DECLARE @Row INT = 1
		DECLARE @OldControlNo VARCHAR(20)
		DECLARE @Barcode VARCHAR(50)
		DECLARE @ControlNo VARCHAR(20)
		
		WHILE @Count >= @Row BEGIN
				SELECT
						@OldControlNo = SI.ControlNo,
						@Barcode = SI.Barcode
				FROM
						@SetInfo SI
				WHERE
						SI.IDX = @Row
						
				EXEC usp_DoCreateSerial 'STB_SetInfo', @ControlNo OUTPUT

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
					SIExtText02,
					SIExtText03,
					SIExtText04,
					SIExtText05,
					CreateDateTime,
					CreateUserID
				)
				SELECT
						@ControlNo,
						@PONo,
						@DayPlanNo,
						SI.MaterialCode,
						1,
						0,
						0,
						0,
						@Barcode,
						SI.DefectQty,
						0,
						0,
						0,
						SI.GradeCode,
						SI.ProdQty,
						SI.SIExtText01,
						SI.SIExtText02,
						SI.SIExtText03,
						SI.SIExtText04,
						SI.SIExtText05,
						GETDATE(),
						@pProcessUserID
				FROM
						STB_SetInfo SI
				WHERE
						SI.ControlNo = @OldControlNo

				SET @Row =  @Row + 1
		END
END