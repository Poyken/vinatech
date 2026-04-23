

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-27
-- Browsable : true
-- Group : 팝업
-- Description: 불량원인 귀책종류 팝업용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostCenter_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SELECT
			CCI.CostCenterCode,
			CCI.CostCenterName
	FROM 
			STB_CostCenterInfo CCI WITH(NOLOCK)
	WHERE
			CCI.CompanyCode LIKE @CompanyCode AND
			CCI.WorkCenterCode LIKE @WorkCenterCode AND
			CCI.IsUsed = 1

END




