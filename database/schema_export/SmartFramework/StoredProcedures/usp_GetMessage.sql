-- Procedure: usp_GetMessage


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-10
-- Description:	메세지를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMessage]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pIPAddress VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@IPAddress VARCHAR(20) = @pIPAddress

	SELECT
			M.MessageId,
			M.MessageType,
			M.TargetUserID,
			M.Title,
			M.Message,
			M.CreateDateTime,
			M.CreateUserID,
			UI.UserName AS CreateUserName
	FROM
			STB_Message M WITH(NOLOCK)
			LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = M.CreateUserID
	WHERE
			M.TargetUserID = @ProcessUserID AND
			M.IsRead = 0 AND
			(M.IPAddress IS NULL OR M.IPAddress = @IPAddress)	-- 다른데서 로그인될 경우 아이디는 같아도 ip 가 다르므로 로그아웃되는 특정아이피로 지정된 메세지도 가져오기

	UPDATE STB_Message
	SET
			IsRead = 1
	WHERE
			TargetUserID = @ProcessUserID AND
			IsRead = 0 AND
			(IPAddress IS NULL OR IPAddress = @IPAddress)
END



GO

