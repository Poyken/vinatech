
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 품질관리
-- Description:	수리자재별 유형별 불량현황을 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairForMaterial]
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

	DECLARE @CompanyCode VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate

	DECLARE @DataTable TABLE
	(
		MaterialCode VARCHAR(20),
		MaterialName NVARCHAR(200),
		DefectCode VARCHAR(20),
		DefectName NVARCHAR(100),
		LossQty NUMERIC(20,5)
	)

	INSERT INTO @DataTable
    SELECT
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.DefectCode,
			DI.BasicDefectName,
			SUM(DRPI.LossQty) AS LossQty
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			INNER JOIN STB_DefectRepairPartInfo DRPI WITH(NOLOCK)
				ON DRPI.DefectSummaryNo = DRI.DefectSummaryNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DRPI.MaterialCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON	DI.DefectCode = DRPI.DefectCode
	WHERE
			(DRI.CompanyCode LIKE @CompanyCode) AND
			(DRI.WorkCenterCode LIKE @WorkCenterCode) AND
			MM.ProductGroupCode LIKE @ProductGroupCode AND
			DRI.MaterialCode LIKE @MaterialCode AND
			(DRI.FindLineCode LIKE @LineCode) AND
			(DRI.FindJobdate >= @FromDate AND DRI.FindJobdate <= @ToDate) AND
			DRI.RepairType NOT IN ('MISSING')
	GROUP BY
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.DefectCode,
			DI.BasicDefectName

	SELECT
			DT.MaterialCode,
			DT.MaterialName,
			SUM(DT.LossQty) AS LossQty,
			'' AS NumericField
	FROM
			@DataTable DT
	GROUP BY
			DT.MaterialCode,
			DT.MaterialName

	SELECT
			DISTINCT
			'불량유형' AS BandName,
			'NumericField' AS NumericField,
			'double' AS DataType,
			DT.DefectName
	FROM
			@DataTable DT
			
	SELECT
			DT.MaterialCode,
			DT.MaterialName,
			'불량유형' AS BandName,
			DT.DefectCode,
			DT.DefectName,
			DT.LossQty
	FROM
			@DataTable DT			

END
