-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 팝업
-- Browsable : true
-- Create date : 2021-02-13
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_CostGroupInfo_popup
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode

	SELECT CostGroupCode
	      ,CostGroupName
	  FROM STB_CostGroupInfo
	 WHERE (@CompanyCode = '*' OR CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode)
	 ORDER BY CostGroupCode
END