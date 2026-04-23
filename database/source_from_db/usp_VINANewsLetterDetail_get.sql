
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 뉴스레터 상세 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VINANewsLetterDetail_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pNewsLetterNo VARCHAR(20)
AS
BEGIN
	Declare @NewsLetterNo VARCHAR(20) = @pNewsLetterNo

	SELECT NewsLetterDetailNo
		  ,NewsLetterNo
		  ,Title
		  ,TitleAlign
		  ,ImagePath
		  ,ImageWidth
		  ,ImageAlign
		  ,ImageText
		  ,ImageTextAlign
		  ,Text
		  ,TextAlign
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
      FROM STB_VINANewsLetterDetail
	 WHERE NewsLetterNo = @NewsLetterNo
	 ORDER BY NewsLetterDetailNo
END