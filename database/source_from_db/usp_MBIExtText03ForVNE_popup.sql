-- 7. 제품종류 팝업
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-06-21
-- Browsable : true
-- Group :
-- Description:	제품종류 popup 조회용
-- =============================================
CREATE PROCEDURE [usp_MBIExtText03ForVNE_popup] 
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
AS
BEGIN
	SELECT MBIExtText03
	  FROM VW_ModelBasicInfo
	 WHERE (MBIExtText03 LIKE '%미만%' OR MBIExtText03 LIKE '%이상%')
	 GROUP BY MBIExtText03
	 ORDER BY MBIExtText03

END