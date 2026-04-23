-- =============================================
-- Author:		Mr,Duy
-- Create date: 2024-01-10
-- Description:	Phân biệt các line sản xuất với các nhà máy và mã kho có thể xuất hàng.
-- =============================================
CREATE PROCEDURE  [dbo].[usp_LineInfo_popup_InoutMaterial]
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
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
			WHERE
					((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))  AND
					LI.MaterialWarehouseCode = @SourceMaterialWarehouse  AND
					LI.IsUsed = 1

			-- 2025-11-13 Thêm 1 line xuất Module BG theo yêu cầu của Ms.Vân Warehouse
			--UNION ALL
			--	SELECT 
			--		LI.CompanyCode,
			--		CI.CompanyName,
			--		LI.WorkCenterCode,
			--		WCI.WorkCenterName,
			--		LI.LineCode,
			--		LI.LineDesc AS LineName,
			--		LI.LineType
			--	FROM
			--		STB_LineInfo LI WITH(NOLOCK)
			--		LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
			--		LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
			--	WHERE
			--		LI.IsUsed = 1 AND
			--		LI.LineCode = 'VVBGMDL'
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
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
			WHERE
					((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))  AND
					LI.MaterialWarehouseCode = @SourceMaterialWarehouse  AND
					LI.IsUsed = 1
		END


	
END