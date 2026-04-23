-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 팝업
-- Description:	공정정보 - 팝업
-- 
-- =============================================
--exec usp_GetRouteInfoAll_popup
CREATE PROCEDURE [dbo].[usp_GetRouteInfoAll_popup] -- exec usp_GetRouteInfoAll_popup
	@pCompanyCode VARCHAR(20) = NULL,
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
			WCI.WorkCenterName,
			'' AS MachineCode,
			'' AS MachineName
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)				ON (CI.CompanyCode = RI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)			ON (WCI.WorkCenterCode = RI.WorkCenterCode)
	WHERE 1=1
			--Duy mở tạm
		    AND ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) 
		    AND ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) 
		    AND (RI.IsUsed = 1)
			--AND RI.RouteCode  IN ('E-22', 'E-23', 'E-24', 'E-25', 'E-26', 'E-27', 'E-28')                                                                                              -- kilee 임시추가 (2019.07.11)
END
-- exec usp_GetRouteInfoAll_popup