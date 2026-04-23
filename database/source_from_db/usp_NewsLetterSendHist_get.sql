
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 뉴스레터발송이력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_NewsLetterSendHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT A.NewsLetterSendHistNo
		  ,B.PersonName
		  ,B.Email
		  ,C.CustomerName
		  ,A.NewsLetterNo
		  ,A.CreateDateTime AS SendDateTime
		  ,A.CreateUserID
	  FROM STB_NewsLetterSendHist A
	  LEFT OUTER JOIN STB_NewsLetterMailingInfo B 
	    ON A.NewsLetterMailingNo = B.NewsLetterMailingNo
	  LEFT OUTER JOIN STB_CustomerInfo C
	    ON C.CustomerCode = B.CustomerCode

	 ORDER BY NewsLetterSendHistNo DESC
END