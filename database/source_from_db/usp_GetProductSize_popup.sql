-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	사이즈코드 관리 조회_POPUP
-- Modified:
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetProductSize_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- 사이즈 팝업
	SELECT RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END AS ProductSize
	  FROM STB_ModelBasicInfo MBI
	 WHERE MBI.MBISizeW IS NOT NULL and MBI.MBISizeH IS NOT NULL
	 GROUP BY RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END
	 ORDER BY RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2)
					 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 0) > 0 THEN 'L' ELSE '' END
END