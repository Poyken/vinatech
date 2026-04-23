
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description: 출하검사 Lot생성을 위한 Set정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSetInfoForOqcLot_DayPlan]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL,
	@pDayPlanNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = CASE WHEN ISNULL(@pDayPlanNo,'') = '' THEN '%' ELSE @pDayPlanNo END

	SELECT 
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			SI.Barcode,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotDecisionResult,
			SI.LotCreateDateTime,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.GradeCode,
			SI.ProdQty
	FROM 
			STB_SetInfo SI WITH(NOLOCK)
	WHERE
			SI.PONo = @PONo AND
			SI.DayPlanNo LIKE @DayPlanNo
END

