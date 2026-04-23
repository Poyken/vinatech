-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 팝업
-- Description:	라우팅별 공정정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBasicRouteingDetailForRoute_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pBasicRoutingCode VARCHAR(20) = NULL,
	@pIsUse CHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BasicRoutingCode VARCHAR(20) = @pBasicRoutingCode
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @IsUse VARCHAR(20) = CASE WHEN ISNULL(@pIsUse,'') = '' THEN '%' ELSE @pIsUse END
 
	SELECT
			BRD.BasicRoutingDetailNo AS OldBasicRoutingDetailNo,
			BRD.BasicRoutingDetailNo,
			@BasicRoutingCode AS BasicRoutingCode,
			RI.RouteCode,
			RI.RouteName,
			CONVERT(BIT,CASE WHEN BRD.BasicRoutingDetailNo IS NULL THEN 0 ELSE 1 END) AS IsUse,
			BRD.RouteIndex,
			ISNULL(BRD.IsInputRoute,0) AS IsInputRoute,
			ISNULL(BRD.IsOutputRoute,0) AS IsOutputRoute,
			BRD.CreateDateTime,
			BRD.CreateUserID,
			BRD.ChangeDateTime,
			BRD.ChangeUserID
	FROM
			STB_RouteInfo RI WITH(NOLOCK)
			LEFT OUTER JOIN STB_BasicRoutingDetail BRD WITH(NOLOCK)
				ON BRD.BasicRoutingCode = @BasicRoutingCode AND
				BRD.RouteCode = RI.RouteCode
    WHERE
			RI.CompanyCode LIKE @CompanyCode AND
			RI.WorkCenterCode LIKE @WorkCenterCode AND
			CONVERT(BIT,CASE WHEN BRD.BasicRoutingDetailNo IS NULL THEN 0 ELSE 1 END) LIKE @IsUse
	ORDER BY BRD.RouteIndex
END