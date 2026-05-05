-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-16
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CompetitiveCompanyTrends_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pBaseDate DATE
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate

	SELECT CCT.CompetitiveCompanyTrendsNo
          ,CCT.BaseDate
          ,CCT.CompetitiveCompanyCode
		  ,CCI.CompetitiveCompanyName
		  ,CCT.ContactWorkerName
          ,CCT.InternetIssue
          ,CCT.HomepageIssue
          ,CCT.MainCustomers
          ,CCT.Remark
          ,CCT.CreateDateTime
          ,CCT.CreateUserID
          ,CCT.ChangeDateTime
          ,CCT.ChangeUserID
	  FROM STB_CompetitiveCompanyTrends CCT
	  LEFT OUTER JOIN STB_CompetitiveCompanyInfo CCI
	    ON CCT.CompetitiveCompanyCode = CCI.CompetitiveCompanyCode
	 WHERE CCT.BaseDate = @BaseDate
END