
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-10-23
-- Browsable : true
-- Group : 생산관리
-- Description: 마감처리된 계회을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDayProdPlanFinished]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@FromDate DATE = @pFromDate,
			@ToDate DATE = @pToDate

	SELECT
			DPP.PONo AS OldPONo,
			NDPP.PONo AS NewPONo,
			NDPP.PONo,
			DPP.DayPlanNo,
			DPP.CompanyCode AS OldCompanyCode,
			CI.CompanyName AS OldCompanyName,
			DPP.WorkCenterCode AS OldWorkCenterCode,
			WCI.WorkCenterName AS OldWorkCenterName,
			DPP.LineCode AS OldLineCode,
			LI.LineName AS OldLineName,

			NDPP.CompanyCode,
			NCI.CompanyName,
			NDPP.WorkCenterCode,
			NWCI.WorkCenterName,
			NDPP.LineCode,
			NLI.LineName,
			DPP.MaterialCode,
			MM.MaterialName,
			DPP.BomVersion,
			DPP.PlanQty,

			NDPP.PlanDate,
			NDPP.PlanShiftCode,
			SC.Shift,
			NDPP.ProdPrior
	FROM
			STB_DayProdPlan DPP WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = DPP.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = DPP.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DPP.MaterialCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = DPP.LineCode
			LEFT OUTER JOIN STB_DayProdPlan NDPP WITH(NOLOCK)
				ON NDPP.DPPExtText02 = DPP.DayPlanNo
			LEFT OUTER JOIN STB_LineInfo NLI WITH(NOLOCK)
				ON NLI.LineCode = NDPP.LineCode
			LEFT OUTER JOIN VW_ShiftCode SC WITH(NOLOCK)
				ON SC.ShiftCode = NDPP.PlanShiftCode
			LEFT OUTER JOIN STB_CompanyInfo NCI WITH(NOLOCK)
				ON NCI.CompanyCode = NDPP.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo NWCI WITH(NOLOCK)
				ON NWCI.WorkCenterCode = NDPP.WorkCenterCode
	WHERE
			(DPP.PlanDate BETWEEN @FromDate AND @ToDate) AND
			DPP.CompanyCode LIKE @CompanyCode AND
			DPP.WorkCenterCode LIKE @WorkCenterCode AND
			DPP.DPPExtText01 = '1'
END