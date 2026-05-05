-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-07-26
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckPartInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT CheckPartNo
          ,CheckPartName
		  ,Remark
		  ,DisplayIndex
		  ,IsUsed
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_CheckPartInfo
     ORDER BY CheckPartNo
END

