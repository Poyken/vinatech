
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 뉴스레터 마스터 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VINANewsLetterMaster_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pNewsLetterNo VARCHAR(20)
AS
BEGIN
	Declare @NewsLetterNo VARCHAR(20) = @pNewsLetterNo

	SELECT NewsLetterNo
		  ,Header
		  ,Contents
		  ,Footer
		  ,OriginalArticleLinkUrl
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
      FROM STB_VINANewsLetterMaster
	 WHERE NewsLetterNo = @NewsLetterNo
END