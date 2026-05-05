-- Procedure: usp_AgencyInfo_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-25
-- Browsable : true
-- Group : 영업관리
-- Description: 대리점정보를 관리한다.
-- Modified:
-- =============================================

CREATE PROCEDURE [dbo].[usp_AgencyInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT AI.AgencyCode
          ,AI.AgencyName
		  ,AI.AgencyAbbreviationName
		  ,AI.CountryName
          ,AI.IsUsed
		  ,AI.Remark
          ,AI.CreateDateTime
          ,AI.CreateUserID
          ,AI.ChangeDateTime
          ,AI.ChangeUserID
	  FROM STB_AgencyInfo AI
	 WHERE 1=1
	 ORDER BY AI.AgencyCode 
END
GO

