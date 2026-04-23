
-- =============================================
-- Author:	    OnJeongMin(jmon@vina.co.kr)
-- Create date: 2019-01-08
-- Browsable : true
-- Group : 생산현황
-- Description:	생산실적현황
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdRouteSummary_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromJobDate DATE = NULL,
	@pToJobDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @FromJobDate DATE = @pFromJobDate 
	DECLARE @ToJobDate DATE = @pToJobDate 
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '%' ELSE @pRouteCode END

    
	SELECT
			PRS.ProductSummaryID AS OldProductSummaryID,
			PRS.ProductSummaryID,
			PRS.CompanyCode,
			CI.CompanyName,
			PRS.WorkCenterCode,
			WI.WorkCenterName,
			PRS.JobDate,
			PRS.ShiftCode,
			PRS.TimeCode,
			PRS.PONo,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			PRS.RouteCode,
			RI.RouteName,
			PRS.SubRouteCode,
			PRS.MachineCode,
			PRS.MoldNumber,
			PRS.InputQty,
			PRS.OutputQty,
			PRS.DefectQty,
			PRS.RepairQty,
			PRS.LossQty,
			PRS.BackFlushQty
	FROM
			STB_ProdRouteSummary PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)		 ON	PRS.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WI WITH(NOLOCK)	 ON	PRS.CompanyCode = WI.CompanyCode AND	PRS.WorkCenterCode	= WI.WorkcenterCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON	PRS.MaterialCode	= MM.MaterialCode			
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)	ON PRS.LineCode	= LI.LineCode    AND PRS.CompanyCode = LI.CompanyCode  AND	PRS.WorkCenterCode	= LI.WorkCenterCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)			  ON	PRS.RouteCode		= RI.RouteCode 
			     AND					PRS.CompanyCode		= RI.CompanyCode 
			     AND					PRS.WorkCenterCode	= RI.WorkCenterCode
	WHERE 1=1
	   AND (PRS.CompanyCode LIKE @CompanyCode) 
	   AND (PRS.WorkCenterCode LIKE @WorkCenterCode) 
	   AND (PRS.JobDate BETWEEN @pFromJobDate AND @pToJobDate) 
	   AND (PRS.LineCode LIKE @LineCode) 
	   AND (PRS.RouteCode LIKE @RouteCode) 

END


-- SELECT * FROM STB_LineInfo
-- SELECT * FROM STB_RouteInfo