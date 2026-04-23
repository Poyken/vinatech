-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-03-17
-- Browsable : true
-- Group : 공통
-- Description:	시스템 메일발송 및 이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_SystemMailDummy_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT '' AS SystemMailSeq, '' AS TargetMailAddress, '' AS MailSubject, '' AS MailContents, '' AS MailSendYn
END