
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-10-23
-- Browsable : true
-- Group : 생산관리
-- Description: 일일 생산계획을 마감처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFinishDayProdPlan]
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

	SELECT
			@PONo = DPP.PONo,
			@PlanQty = DPP.PlanQty,
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	IF ISNULL(@IsFixed,0) = 0 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'확정되지 않은 계획입니다'
	END

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다'
	END

	--UPDATE	STB_ProductionOrderInfo
	--SET
	--		ProdOrderQty = ISNULL(ProdOrderQty,0) + @PlanQty
	--WHERE
	--		PONo = @PONo

	UPDATE	STB_DayProdPlan
	SET
			DPPExtText01 = '1',
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			DayPlanNo = @DayPlanNo
	
END

