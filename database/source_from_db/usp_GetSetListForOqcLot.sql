
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description: 출하검사 Lot생성을 위한 Set정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSetListForOqcLot]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRouteCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode,
			@FromDate DATE = @pFromDate,
			@ToDate DATE = @pToDate

	SELECT 
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			SI.Barcode,
			SI.InputLineCode,
			LI.LineName AS InputLineName,
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
			INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MBI.ModelCode = SI.MaterialCode AND
				MBI.InspectionType NOT IN ('NONE')
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = SI.InputLineCode
	WHERE
			(SI.InputJobDate BETWEEN @FromDate AND @ToDate) AND
			(SI.LotNumber IS NULL OR SI.LotNumber = '')
END
