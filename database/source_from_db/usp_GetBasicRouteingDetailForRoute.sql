-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	BOM Detail 조회 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBasicRouteingDetailForRoute]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pBasicRoutingCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BasicRoutingCode VARCHAR(20) = @pBasicRoutingCode
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
 
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
				ON BRD.BasicRoutingCode = @BasicRoutingCode 
			   AND BRD.RouteCode = RI.RouteCode
			   AND BRD.CompanyCode = @CompanyCode
			   AND BRD.WorkCenterCode = @WorkCenterCode
    WHERE
			RI.CompanyCode LIKE @CompanyCode AND
			RI.WorkCenterCode LIKE @WorkCenterCode
END
