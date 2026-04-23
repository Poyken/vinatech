-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 팝업
-- Description:	경쟁사정보 입력일자
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CompetitiveCompanyInfoDetailDate_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT CONVERT(VARCHAR(10), BaseDate, 121) AS BaseDate
	  FROM STB_CompetitiveCompanyDetail
	 GROUP BY BaseDate
	 ORDER BY BaseDate
END