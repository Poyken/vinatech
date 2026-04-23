
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리
-- Description: 일일 생산계획을 확정처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoFixDayProdPlan]
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
	DECLARE @LineCod VARCHAR(20)
	DECLARE @Companycod VARCHAR(20)

	SELECT
			@PONo = DPP.PONo,
			@PlanQty = DPP.PlanQty,
			@IsFixed = DPP.IsFixed,
			@IsCancel = DPP.IsCancel,
			@LineCod = LineCode, 
			@Companycod = CompanyCode
	FROM
			STB_DayProdPlan DPP
	WHERE
			DPP.DayPlanNo = @DayPlanNo


	IF (@Companycod ='VVT' and @LineCod = '%')
	BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage, 'Chua chon ma Line, ma Line van la %'
			RETURN
	END


	IF ISNULL(@IsFixed,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 확정된 계획입니다 (Kế hoạch đã được xác định rồi)'
	END


	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다 (Kế hoạch đã bị hủy bỏ)'
	END

	UPDATE	STB_ProductionOrderInfo
	SET
			ProdOrderQty = ISNULL(ProdOrderQty,0) + @PlanQty
	WHERE
			PONo = @PONo

	UPDATE	STB_DayProdPlan
	SET
			IsFixed = 1,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			DayPlanNo = @DayPlanNo

	
END

