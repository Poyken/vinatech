
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 뉴스레터번호 새발행
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateNewsLetter]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @NewsLetterNo VARCHAR(20) 

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VINANewsLetterMaster',@NewsLetterNo OUTPUT

	INSERT INTO STB_VINANewsLetterMaster (NewsLetterNo, Header, Contents, Footer, OriginalArticleLinkUrl)
		SELECT TOP 1 @NewsLetterNo, Header, Contents, Footer, OriginalArticleLinkUrl
		  FROM STB_VINANewsLetterMaster
		 ORDER BY NewsLetterNo DESC
END

