-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-04-23
-- Browsable : true
-- Group : 품질관리
-- Description:	불량 유형 분포도
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectDistribution]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT
			DRI.DefectCode,
			DI.BasicDefectName,
			SUM(DRI.DefectQty) AS DefectQty
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON DI.DefectCode = DRI.DefectCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DRI.MaterialCode
	WHERE
			DRI.CompanyCode LIKE @CompanyCode AND
			DRI.WorkCenterCode LIKE @WorkCenterCode AND
			DRI.FindLineCode LIKE @LineCode AND
			DRI.MaterialCode LIKE @MaterialCode AND
			DRI.RepairType NOT IN ('MISSING')
	GROUP BY
			DRI.DefectCode,
			DI.BasicDefectName
END
