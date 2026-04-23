-- =============================================
-- Author: kilee
-- Create date: 2019-11-19
-- Browsable : true
-- Group : 팝업
-- Description:	베트남생산실적 > 공정코드 팝업
-- 
-- 실행 : usp_GetRouteInfo_Vietnam_popup '',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteInfo_Vietnam_popup]
	@pCompanyCode VARCHAR(20) = 'VVT',
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    
    
    SELECT
			RI.RouteCode,
			RI.RouteName,
			RI.CompanyCode,
			CI.CompanyName,
			RI.WorkCenterCode,
			WCI.WorkCenterName
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)				ON (CI.CompanyCode = RI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)			ON (WCI.WorkCenterCode = RI.WorkCenterCode)
	WHERE 1=1
		    --AND ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) 
			AND RI.CompanyCode = 'VVT'
		    AND ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) 
		    AND (RI.IsUsed = 1)
			--AND RI.RouteCode  IN ('E-22', 'E-23', 'E-24', 'E-25', 'E-26', 'E-27', 'E-28')                                                                                              -- kilee 임시추가 (2019.07.11)
END
