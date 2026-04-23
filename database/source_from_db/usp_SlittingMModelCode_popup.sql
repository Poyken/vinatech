-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-07-03
-- Browsable : true
-- Group : 생산관리
-- Description:	슬리팅 품목코드 팝업
-- =============================================
CREATE PROC usp_SlittingMModelCode_popup
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
AS
BEGIN
	SELECT MaterialCode
	      ,MaterialName
	  FROM STB_MaterialMaster MM
	 WHERE MaterialName LIKE '%Slliting-Roll%' OR MaterialName LIKE '%Slliting%'
END