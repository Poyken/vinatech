CREATE PROC [dbo].[VN_CongDoan]
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
				IsUsed=1

		ORDER BY RouteCode DESC
END