-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2022-03-07
-- Browsable : true
-- Group : 팝업
-- Description:	 VPC공정정보 - 팝업  (생산현황)쪽
-- 
-- =============================================
Create PROCEDURE [dbo].[usp_GetRouteInfoVPC_popup02]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    
    
    SELECT
			RI.RouteCode,
			--RI.RouteName,
			 CASE WHEN RI.RouteName = '커링' THEN '조립(커링)' ELSE RI.RouteName END AS RouteName,
			RI.CompanyCode,
			CI.CompanyName,
			RI.WorkCenterCode,
			WCI.WorkCenterName,
			'' AS MachineCode,
			'' AS MachineName
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)				ON (CI.CompanyCode = RI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)			ON (WCI.WorkCenterCode = RI.WorkCenterCode)
	WHERE 1=1
		    AND ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) 
		    AND ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) 
		    AND (RI.IsUsed = 1)
			AND RI.RouteCode  IN ('E-22', 'E-24', 'E-28', 'E-29', 'E-33', 'E-34')                                                                                   
END
