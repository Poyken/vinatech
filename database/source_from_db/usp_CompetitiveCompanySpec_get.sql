-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-14
-- Browsable : true
-- Group : 영업관리
-- Description: 경쟁사별 특이규격
-- =============================================
CREATE PROCEDURE [dbo].[usp_CompetitiveCompanySpec_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBaseDate DATE
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate

	SELECT CCS.CompetitiveCompanySpecNo
	      ,CCS.BaseDate
		  ,CCS.CompetitiveCompanyCode
		  ,CCI.CompetitiveCompanyName
		  ,CCS.ProductSize
		  ,CCS.ProductSpec
		  ,CCS.ProductType
		  ,CCS.Remark
		  ,CCS.CreateDateTime
		  ,CCS.CreateUserID
		  ,CCS.ChangeDateTime
		  ,CCS.ChangeUserID
	  FROM STB_CompetitiveCompanySpec CCS
	  LEFT OUTER JOIN STB_CompetitiveCompanyInfo CCI
		ON CCS.CompetitiveCompanyCode = CCI.CompetitiveCompanyCode
	 WHERE CCS.BaseDate = @BaseDate

END