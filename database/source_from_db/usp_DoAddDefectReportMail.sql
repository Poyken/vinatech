-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-28
-- Browsable : true
-- Group : 시스템관리
-- Description:	부적합보고서 메일을 입력합니다. 
-- 권취실적 메일을 입력합니다. (2022-03-02)
-- Modified: 
-- =============================================
CREATE PROC [dbo].[usp_DoAddDefectReportMail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pToMailAddress VARCHAR(MAX), 
	@pCcMailAddress VARCHAR(MAX), 
	@pMailSubject NVARCHAR(200), 
	@pMailContents NVARCHAR(MAX)
AS
BEGIN
	Declare @ToMailAddress VARCHAR(MAX) = @pToMailAddress
	Declare @CcMailAddress VARCHAR(MAX) = @pCcMailAddress
	Declare @MailSubject NVARCHAR(50) = @pMailSubject
	Declare @MailContents NVARCHAR(MAX) = @pMailContents

	IF @MailSubject IS NULL OR @MailSubject = '' BEGIN
		RAISERROR('메일 제목을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	IF @MailContents IS NULL OR @MailContents = '' BEGIN
		RAISERROR('메일 내용을 입력하셔야 합니다.', 16, 1)
		RETURN
	END

	BEGIN TRY
		INSERT INTO [110.11.27.5].SmartFactoryV2.dbo.STB_DefectReportMail (ToAddress, CcAddress, MailSubject, MailContents)
						SELECT @ToMailAddress
							  ,@CcMailAddress
							  ,@MailSubject
							  ,@MailContents
	END TRY

	BEGIN CATCH
		RAISERROR('메일 데이터 입력에 실패하였습니다.', 16, 1)
		RETURN
	END CATCH
END