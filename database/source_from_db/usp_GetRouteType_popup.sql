

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-10
-- Browsable : true
-- Group : 팝업
-- Description:	공정타입을 가져옵니다. - 팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRouteType_popup]
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			ItemCode AS RouteType,
			Description AS RouteTypeName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'RouteType'
END


