

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 팝업
-- Description:	공정정보 - 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pRouteType VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @RouteType VARCHAR(20) = CASE WHEN ISNULL(@pRouteType,'') = '' THEN '%' ELSE @pRouteType END
    
    SELECT
			RI.RouteCode,
			RI.RouteName
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
	WHERE
		    RI.CompanyCode LIKE @CompanyCode AND 
			RI.WorkCenterCode LIKE @WorkCenterCode AND
			RI.RouteType LIKE @RouteType AND
			RI.IsUsed = 1
END
