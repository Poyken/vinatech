-- =============================================
-- Author:		<DinhManh>
-- Create date: <12-30-2024>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteInfoHN_popup] 
	-- Add the parameters for the stored procedure here
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
			AND RI.CompanyCode = 'VVT' 
			AND RI.WorkCenterCode = 'VVT_F3'
		    --AND ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) 
		    --AND ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) 
		    --AND (RI.IsUsed = 1)
			  
END
