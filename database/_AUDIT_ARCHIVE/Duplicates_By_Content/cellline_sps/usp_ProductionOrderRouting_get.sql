-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-20
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionOrderRouting_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo

	SELECT
			POR.PoRoutingSeqNo AS OldPoRoutingSeqNo,
			POR.PoRoutingSeqNo,
			POR.PONo,
			POR.RouteCode,
			RI.RouteName,
			POR.RouteIndex,
			POR.IsInputRoute,
			POR.IsOutputRoute,
			POR.CreateDateTime,
			POR.CreateUserID,
			POR.ChangeDateTime,
			POR.ChangeUserID
	FROM
			STB_ProductionOrderRouting POR WITH(NOLOCK)
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = POR.RouteCode
	WHERE
			POR.PONo = @PONo

END
