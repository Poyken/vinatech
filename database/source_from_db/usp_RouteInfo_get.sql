-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-10
-- Browsable : true
-- Group : 공통
-- Description:	공정정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_RouteInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pRouteType VARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
      DECLARE @RouteType VARCHAR(100) = CASE WHEN ISNULL(@pRouteType,'') = '' THEN '*' ELSE @pRouteType END

    
	SELECT
	        RI.RouteCode AS OldRouteCode,
	        RI.RouteCode,
	        RI.RouteName,
	        
	        RI.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        RI.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        RI.RouteType,
			BC.Description AS RouteTypeName,
			
			--RI.IsExternalRoute,
	        RI.IsUsed,
	        RI.CreateDateTime,
	        RI.CreateUserID,
	        RI.ChangeDateTime,
	        RI.ChangeUserID,
			ISNULL(RI.IsInterfaceRoute, CONVERT(BIT, 0)) AS IsInterfaceRoute,
			IsRequireMachine,
			RI.StandardTaktTime
	FROM
	        STB_RouteInfo RI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		   ON RI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)		   		   ON RI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC			   ON BC.CodeGroup = 'RouteType'			   AND BC.ItemCode = RI.RouteType
	WHERE
	        ((@CompanyCode = '*') OR (RI.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (RI.WorkCenterCode = @WorkCenterCode)) AND
	        ((@RouteType = '*') OR (RI.RouteType IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteType)))) 

END