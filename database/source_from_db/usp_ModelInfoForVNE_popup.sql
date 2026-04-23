-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-06-21
-- Browsable : true
-- Group :
-- Description:	제품종류별 비나에너솔 품목정보 popup 조회용
-- =============================================
CREATE PROCEDURE [usp_ModelInfoForVNE_popup] 
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pMBIExtText03 VARCHAR(50)
AS
BEGIN

	Declare @MBIExtText03 VARCHAR(50) = @pMBIExtText03
	
	
	SELECT ModelCode
	      ,ModelName
		  ,MBIExtText04 + 'V' AS MBIExtText04
		  ,MBIExtText05 + 'μF' AS MBIExtText05
		  ,MBIExtInt02 
		  ,MBIExtInt03
	  FROM VW_ModelBasicInfo
	 WHERE MBIExtText03 = @MBIExtText03

END
