

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-19
-- Browsable : true
-- Group : 자재수불관리
-- Description:	재고 제품리스트를 조회합니다.
-- Modified:
-- =============================================
--          exec usp_GetStockMaterial_ForSelectDialog '','','','','','',''

CREATE PROCEDURE [dbo].[usp_GetStockMaterial_ForSelectDialog]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '%' ELSE @pMaterialWarehouseCode END
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '%' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END

    
	SELECT
			--DISTINCT
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			MAX(MLI.StockAttrib1) AS StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3,
			SUM(ISNULL(MLI.CurrentQty,0) - ISNULL(MLI.PickingQty,0)) AS CurrentQty
	FROM
			STB_MaterialLotInfo MLI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON	PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MLI.CompanyCode LIKE @CompanyCode AND
			MLI.WorkCenterCode LIKE @WorkCenterCode AND
			MLI.MaterialWarehouseCode LIKE @MaterialWarehouseCode AND
			MLI.MaterialLocationCode LIKE @MaterialLocationCode AND
			MLI.MaterialCode LIKE @MaterialCode AND
			MM.MaterialTypeCode LIKE @MaterialTypeCode AND
			((MM.ProductGroupCode IS NULL) OR (MM.ProductGroupCode LIKE @ProductGroupCode))
	GROUP BY
			MLI.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MLI.MaterialStockAttribute,
			--MLI.StockAttrib1,
			MLI.StockAttrib2,
			MLI.StockAttrib3

END


