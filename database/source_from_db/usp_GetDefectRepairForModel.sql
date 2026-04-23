
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 품질관리
-- Description:	제품별 유형별 불량현황을 조회합니다
-- Modified: 2019-03-25 라인정렬
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairForModel]
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
		LineCode VARCHAR(20),
		LineName NVARCHAR(100),
		MaterialCode VARCHAR(20),
		MaterialName NVARCHAR(200),
		DefectCode VARCHAR(20),
		DefectName NVARCHAR(100),
		DefectQty NUMERIC(20,5)
	)

	INSERT INTO @DataTable
    SELECT
			DRI.FindLineCode,
			FLI.LineName,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.DefectCode,
			DI.BasicDefectName,
			SUM(DRI.DefectQty) AS DefectQty
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)	    			ON	FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)				ON	DI.DefectCode = DRI.DefectCode
	WHERE 1=1
	  AND 	(DRI.CompanyCode LIKE @CompanyCode) 
	  AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 
	  AND	MM.ProductGroupCode LIKE @ProductGroupCode 
	  AND   DRI.MaterialCode LIKE @MaterialCode 
	  AND   (DRI.FindLineCode LIKE @LineCode) 
	  AND  (DRI.FindJobdate >= @FromDate AND DRI.FindJobdate <= @ToDate) 
	  AND  DRI.RepairType NOT IN ('MISSING', 'FINISH')
	GROUP BY
			DRI.FindLineCode,
			FLI.LineName,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.DefectCode,
			DI.BasicDefectName

	SELECT
			DT.LineCode,
			DT.LineName,
			DT.MaterialCode,
			DT.MaterialName,
			SUM(DT.DefectQty) AS DefectQty,
			'' AS NumericField
	FROM
			@DataTable DT
	GROUP BY
			DT.LineCode,
			DT.LineName,
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
			DT.LineCode,
			DT.LineName,
			DT.MaterialCode,
			DT.MaterialName,
			'불량유형' AS BandName,
			DT.DefectCode,
			DT.DefectName,
			DT.DefectQty
	FROM
			@DataTable DT			

END




--SELECT  FindLINECode
--     ,     SUM(DefectQty)   
--FROM STB_DefectRepairInfo WHERE FindLINECode LIKE 'VVC%'  AND FindjobDate = '2020-01-07'
--GROUP BY FindLINECode
