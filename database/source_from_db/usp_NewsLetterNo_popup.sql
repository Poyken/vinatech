
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 팝업
-- Description: 뉴스레터번호 조회(팝업)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_NewsLetterNo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT NewsLetterNo
	  FROM STB_VINANewsLetterMaster
	 ORDER BY NewsLetterNo
END