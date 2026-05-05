-- Procedure: usp_DoLogout


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-10
-- Description:	로그아웃 처리를 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoLogout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	UPDATE STB_UserInfo
	SET
			IsLogin = 0,
			IPAddress = NULL
	WHERE
			UserID = @ProcessUserID
END



GO

