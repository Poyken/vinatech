-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 팝업
-- Description:	공정정보 - 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_RouteInfoForLine_popup]
	@pLineCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @LineCode VARCHAR(20) = @pLineCode
    
    SELECT
			LRM.RouteCode,
			RI.RouteName
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = LRM.RouteCode
	WHERE
		    LRM.LineCode = @LineCode
END


--  SELECT
--			*
--	FROM
--			STB_LineRouteMapping LRM WITH(NOLOCK)
--			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = LRM.RouteCode


--select * from STB_LineRouteMapping

--select * from STB_RouteInfo