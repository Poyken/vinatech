-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 기록물관리
-- Browsable : true
-- Create date : 2019-10-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocProductInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT ProductCode
	      ,ProductName
		  ,CreateDateTime
          ,CreateUserID
          ,ChangeDateTime
          ,ChangeUserID
	  FROM STB_DocProductInfo
	 ORDER BY ProductCode
	 
END