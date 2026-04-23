-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-09
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified: 
-- =============================================

CREATE PROCEDURE usp_ManufacturingCostApplyInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT ApplyDate
	      ,IsApply
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_ManufacturingCostApplyInfo
	 ORDER BY ApplyDate
END