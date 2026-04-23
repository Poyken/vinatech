-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 기록물관리
-- Browsable : true
-- Create date : 2019-10-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocFactoryInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT FactoryCode
	      ,FactoryName
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_DocFactoryInfo
	 ORDER BY CASE WHEN FactoryCode = 'VJ' THEN '0'
	               WHEN FactoryCode = 'VV' THEN '00'
				   ELSE FactoryCode END 
END