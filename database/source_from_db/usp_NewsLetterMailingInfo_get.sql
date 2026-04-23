
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 메일링 대상자 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_NewsLetterMailingInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT A.NewsLetterMailingNo
          ,A.CustomerCode
		  ,B.CustomerName
          ,A.PersonName
          ,A.Email
          ,A.CreateDateTime
          ,A.CreateUserID
          ,A.ChangeDateTime
          ,A.ChangeUserID
	  FROM STB_NewsLetterMailingInfo A
	  LEFT OUTER JOIN STB_CustomerInfo B
	    ON A.CustomerCode = B.CustomerCode
	 ORDER BY NewsLetterMailingNo
END