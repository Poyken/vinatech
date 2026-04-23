
CREATE PROCEDURE VN_STAGE
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
			WCI.WorkCenterName
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH (NOLOCK)				ON (CI.CompanyCode = RI.CompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH (NOLOCK)			ON (WCI.WorkCenterCode = RI.WorkCenterCode)
	WHERE 1=1
		    AND ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) 
		    AND ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) 
		    AND (RI.IsUsed = 1)
			--AND RI.RouteCode  IN ('E-22', 'E-23', 'E-24', 'E-25', 'E-26', 'E-27', 'E-28')                                                                                              -- kilee 임시추가 (2019.07.11)
END
