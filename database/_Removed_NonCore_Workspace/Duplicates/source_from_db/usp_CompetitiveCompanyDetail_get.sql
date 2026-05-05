-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 영업관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CompetitiveCompanyDetail_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pBaseDate DATE
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate

	SELECT CCD.BaseDate
          ,CCD.CompetitiveCompanyCode
		  ,CC.CompetitiveCompanyName
          ,CCD.SeparatorUsedQty
          ,CCD.StockPrice
          ,CCD.Remark
          ,CCD.CreateDateTime
          ,CCD.CreateUserID
          ,CCD.ChangeDateTime
          ,CCD.ChangeUserID
	  FROM STB_CompetitiveCompanyDetail CCD
	  LEFT OUTER JOIN STB_CompetitiveCompanyInfo CC
	    ON CC.CompetitiveCompanyCode = CCD.CompetitiveCompanyCode
	 WHERE CCD.BaseDate = @BaseDate
END