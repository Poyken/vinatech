-- Procedure: usp_CompetitiveCompanyInfo_popup
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 팝업
-- Description:	경쟁사코드정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CompetitiveCompanyInfo_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT CompetitiveCompanyCode
	      ,CompetitiveCompanyName
	  FROM STB_CompetitiveCompanyInfo
	 WHERE IsUsed = CONVERT(BIT, 1)
	 ORDER BY CompetitiveCompanyCode ASC
END
GO

