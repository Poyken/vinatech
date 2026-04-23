-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 기록물관리
-- Browsable : true
-- Create date : 2019-10-08
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocProcessInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT ProcessCode
	      ,ProcessName
		  ,Remark
	      ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_DocProcessInfo
	 ORDER BY ProcessCode
END