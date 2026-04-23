-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-24
-- Browsable : true
-- Group : 시스템관리
-- Description:	시스템 메일을 입력합니다.
-- Modified: 
-- =============================================
CREATE PROC [dbo].[usp_DoAddSystemMail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pTargetMailAddress VARCHAR(MAX), 
	@pMailSubject NVARCHAR(MAX), 
	@pMailContents NVARCHAR(MAX)
AS
BEGIN
	Declare @TargetMailAddress VARCHAR(MAX) = @pTargetMailAddress
	Declare @MailSubject NVARCHAR(MAX) = @pMailSubject
	Declare @MailContents VARCHAR(MAX) = @pMailContents

	IF @MailSubject IS NULL OR @MailSubject = '' BEGIN
		RAISERROR('메일 제목을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	IF @MailContents IS NULL OR @MailContents = '' BEGIN
		RAISERROR('메일 내용을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	INSERT INTO OLDNAISSVR.SmartFactoryV2.dbo.STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
					SELECT @TargetMailAddress, @MailSubject, @MailContents
END