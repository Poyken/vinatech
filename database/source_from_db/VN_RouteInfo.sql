
CREATE PROC [dbo].[VN_RouteInfo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
		SET NOCOUNT ON;

		SELECT 
				RouteCode,
				RouteName
		FROM 
				STB_RouteInfo WITH(NOLOCK)

		WHERE
				IsUsed=1 AND CompanyCode='VVT'

		ORDER BY RouteCode asc
END