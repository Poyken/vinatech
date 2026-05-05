
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리
-- Description: 일일 생산계획을 취소처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCancelDayProdPlan]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @IsFixed BIT
	DECLARE @IsCancel BIT
	DECLARE @PONo VARCHAR(20)
	DECLARE @PlanQty NUMERIC(20,5)
	DECLARE @ErrorMessage NVARCHAR(500)

	SELECT
			@PONo = DPP.PONo,
			@PlanQty = DPP.PlanQty,
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	IF EXISTS (
				SELECT	1
				FROM
						STB_SetInfo SI
				WHERE
						SI.PONo = @PONo AND
						SI.DayPlanNo = @DayPlanNo
				) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
											'^Lot이 생성된 일일 계획은 취소할 수 없습니다^',
											@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@DayPlanNo)
			RETURN

	END

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다'
	END

	IF @IsFixed = 1 BEGIN
			UPDATE	STB_ProductionOrderInfo
			SET
					ProdOrderQty = ProdOrderQty - @PlanQty
			WHERE
					PONo = @PONo
	END

	UPDATE	STB_DayProdPlan
	SET
			IsCancel = 1,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			DayPlanNo = @DayPlanNo

END

