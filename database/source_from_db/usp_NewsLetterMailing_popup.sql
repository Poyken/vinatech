
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 팝업
-- Description: 뉴스레터 대상자 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_NewsLetterMailing_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT A.NewsLetterMailingNo
	      ,A.CustomerCode
		  ,B.CustomerName
		  ,A.PersonName
		  ,A.Email
	  FROM STB_NewsLetterMailingInfo A
	  LEFT OUTER JOIN STB_CustomerInfo B
	    ON A.CustomerCode = B.CustomerCode
	 ORDER BY A.NewsLetterMailingNo
END

