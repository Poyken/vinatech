-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-16
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_MainCustomerTrends_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pBaseDate DATE
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate

	SELECT MCT.MainCustomerTrendsNo
          ,MCT.BaseDate
          ,MCT.CustomerName
          ,MCT.ContactWorkerName
          ,MCT.StockPrice
          ,MCT.SalesPrice
          ,MCT.InternetIssue
          ,MCT.HomepageIssue
          ,MCT.Remark
          ,MCT.CreateDateTime
          ,MCT.CreateUserID
          ,MCT.ChangeDateTime
          ,MCT.ChangeUserID
	  FROM STB_MainCustomerTrends MCT
	 WHERE MCT.BaseDate = @BaseDate
END
