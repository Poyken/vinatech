-- Procedure: usp_DoSendMessage


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-10
-- Description:	메세지를 전송합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSendMessage]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pTargetUserID VARCHAR(20),
	@pMessageType VARCHAR(20),
	@pTitle NVARCHAR(100),
	@pMessage NVARCHAR(MAX),
	@pIPAddress VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MessageId VARCHAR(20)

	EXEC usp_DoCreateSerial 'STB_Message',
							@MessageId OUTPUT

	INSERT INTO STB_Message
	(
		MessageId,
		MessageType,
		TargetUserID,
		Title,
		Message,
		IsRead,
		IPAddress,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@MessageId,
		@pMessageType,
		@pTargetUserID,
		@pTitle,
		@pMessage,
		0,
		@pIPAddress,
		GETDATE(),
		@ProcessUserID
	)
END



GO

