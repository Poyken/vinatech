-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2016-01-15
-- Browsable : true
-- Group : 시스템관리
-- Description:	사용자 리스트를 조회합니다. Get User List
-- Modified: 
-- =============================================
CREATE PROC [dbo].[usp_SetSystemMail] 
	@pProcessUserID VARCHAR(20),
	@pUserID VARCHAR(20) = NULL,
	@pUserType VARCHAR(50), 
	@pMailSubject VARCHAR(200), 
	@pMailContents NVARCHAR(MAX)
AS
BEGIN
	Declare @UserType VARCHAR(50) = @pUserType
	Declare @MailSubject VARCHAR(50) = @pMailSubject
	Declare @MailContents VARCHAR(MAX) = @pMailContents

	Declare @TargetMailAddress VARCHAR(500)

	SELECT @TargetMailAddress = dbo.fnGetSystemMailTargetAddress (@UserType)

	IF @MailSubject IS NULL OR @MailSubject = '' BEGIN
		RAISERROR('메일 제목을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	IF @MailContents IS NULL OR @MailContents = '' BEGIN
		RAISERROR('메일 내용을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
					SELECT @TargetMailAddress, @MailSubject, @MailContents
END
