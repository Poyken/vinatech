-- Procedure: usp_BasicRoutingDetail_get
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	BOM Detail 조회 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicRoutingDetail_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBasicRoutingCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BasicRoutingCode VARCHAR(20) = @pBasicRoutingCode
 
	SELECT
			BRD.BasicRoutingDetailNo AS OldBasicRoutingDetailNo,
			BRD.BasicRoutingDetailNo,
			BRD.BasicRoutingCode,
			BRD.RouteCode,
			BRD.RouteIndex,
			BRD.IsInputRoute,
			BRD.IsOutputRoute,
			BRD.CreateDateTime,
			BRD.CreateUserID,
			BRD.ChangeDateTime,
			BRD.ChangeUserID
	FROM
			STB_BasicRoutingDetail BRD WITH(NOLOCK)
	WHERE
			BRD.BasicRoutingCode = @BasicRoutingCode
    
END

GO

