-- Procedure: usp_BasicRoutingInfo_popup
-- =============================================
-- Author : Park Jong Seob(jspark@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-30
-- Description : 생산라우팅정보를 가져옵니다.(POPUP용)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicRoutingInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			BRI.BasicRoutingCode,
			BRI.BasicRoutingName,
			BRI.BasicRoutingDesc
	FROM
			STB_BasicRoutingInfo BRI WITH (NOLOCK)
	WHERE
			BRI.IsUsed = 1
END

GO

