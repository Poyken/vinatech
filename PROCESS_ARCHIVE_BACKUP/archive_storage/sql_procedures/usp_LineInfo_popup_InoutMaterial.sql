-- exec usp_LineInfo_popup_InoutMaterial 'VVT','VVT_F1',''
CREATE PROCEDURE [dbo].[usp_LineInfo_popup_InoutMaterial]
	@pCompanyCode VARCHAR(20) = NULL,	
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pSourceMaterialWarehouse VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @SourceMaterialWarehouse VARCHAR(20) = CASE WHEN ISNULL(@pSourceMaterialWarehouse,'') = '' THEN '*' ELSE @pSourceMaterialWarehouse END

	IF @WorkCenterCode LIKE 'VVT_F1'
		BEGIN
			SELECT
					LI.CompanyCode,
					CI.CompanyName,
					LI.WorkCenterCode,
					WCI.WorkCenterName,
					LI.LineCode,
					LI.LineDesc AS LineName,
					LI.LineType
			FROM
					STB_LineInfo LI WITH(NOLOCK)
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK) ON CI.CompanyCode = LI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK) ON WCI.WorkCenterCode = LI.WorkCenterCode
			WHERE
					((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode)) AND
					/* vanduc update by Mrs.VanOc 20260721 START */
					--(LI.MaterialWarehouseCode = @SourceMaterialWarehouse OR (LI.LineCode IN ('HY_BN', 'HY_BG') AND @SourceMaterialWarehouse LIKE '%HY%')) AND
					/* vanduc update by Mrs.VanOc 20260721 END */
					LI.IsUsed = 1
		END
	ELSE
		BEGIN
			SELECT
					LI.CompanyCode,
					CI.CompanyName,
					LI.WorkCenterCode,
					WCI.WorkCenterName,
					LI.LineCode,
					LI.LineDesc AS LineName,
					LI.LineType
			FROM
					STB_LineInfo LI WITH(NOLOCK)
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK) ON CI.CompanyCode = LI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK) ON WCI.WorkCenterCode = LI.WorkCenterCode
			WHERE
					((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))	AND
					/*
					/* vanduc update by Mrs.VanOc 20260721 START */
					(LI.MaterialWarehouseCode = @SourceMaterialWarehouse OR (LI.LineCode IN ('HY_BN', 'HY_BG') AND @SourceMaterialWarehouse LIKE '%HY%')) AND
					/* vanduc update by Mrs.VanOc 20260721 END */

					*/
					LI.IsUsed = 1
		END
END


