-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-03-17
-- Browsable : true
-- Group : 공통
-- Description:	시스템 메일발송 및 이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_SystemMail_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SM.SystemMailSeq, SM.TargetMailAddress, SM.MailSubject, SM.MailContents, SM.MailSendYn
	      ,SM.CreateDateTime AS MailRegDateTime, SM.ChangeDateTime AS MailSendDateTime
	  FROM STB_SystemMail SM
	 ORDER BY SM.SystemMailSeq DESC
END