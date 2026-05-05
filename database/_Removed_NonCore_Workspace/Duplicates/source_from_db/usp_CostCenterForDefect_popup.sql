

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 팝업
-- Description: 불량원인 귀책종류 팝업용
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostCenterForDefect_popup]
	@pDefectCauseType VARCHAR(10) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectCauseType VARCHAR(10) = ISNULL(@pDefectCauseType,'S')
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode

	IF @DefectCauseType = 'S' BEGIN
			SELECT
					CCI.CostCenterCode,
					CCI.CostCenterName
			FROM 
					STB_CostCenterInfo CCI WITH(NOLOCK)
			WHERE
					CCI.CompanyCode LIKE @CompanyCode AND
					CCI.WorkCenterCode LIKE @WorkCenterCode AND
					CCI.IsUsed = 1
	END ELSE BEGIN
			SELECT
					CI.CustomerCode AS CostCenterCode,
					CI.CustomerName AS CostCenterName
			FROM
					STB_CustomerInfo CI WITH(NOLOCK)
					LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
						ON MVM.CustomerCode = CI.CustomerCode
			WHERE
					CI.IsUsed = 1 AND
					CI.IsVendor = 1 AND
					MVM.MaterialCode = @MaterialCode
	END
END
