-- Procedure: usp_DoAddSlackMessage

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-21
-- Description:	슬랙에 전송할 메세지를 추가합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddSlackMessage]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUrl VARCHAR(200),
	@pTitle NVARCHAR(200),
	@pText NVARCHAR(200),
	@pAuthor NVARCHAR(50) = NULL,
	@pUser NVARCHAR(50) = NULL,
	@pBarColor VARCHAR(20) = NULL,
	@pFields NVARCHAR(MAX) = NULL,
	@pId BIGINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	INSERT INTO STB_SlackMessage
	(
		[Url],
		Title,
		[Text],
		Author,
		[User],
		BarColor,
		Fields,
		CreateDateTime,
		CreateUserID,
		IsSend
	)
	VALUES
	(
		@pUrl,
		@pTitle,
		@pText,
		@pAuthor,
		@pUser,
		@pBarColor,
		@pFields,
		GETDATE(),
		@pProcessUserID,
		0
	)

	SET @pId = SCOPE_IDENTITY()
END


GO

