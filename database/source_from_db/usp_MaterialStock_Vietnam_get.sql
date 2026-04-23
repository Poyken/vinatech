

CREATE PROCEDURE [dbo].[usp_MaterialStock_Vietnam_get]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pCompanyCode VARCHAR(20) = NULL,
@pWorkCenterCode VARCHAR(20) = NULL,
@pMaterialWarehouseCode VARCHAR(20) = NULL,
@pMaterialTypeCode VARCHAR(20) = NULL,
@pProductGroupCode VARCHAR(20) = NULL,
@pMaterialCode VARCHAR(50) = NULL,
@pBasicMaterialType VARCHAR(20) = NULL,
@pExcludeBasicMaterialTypes VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
    DECLARE @MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
	DECLARE @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '*' ELSE @pBasicMaterialType END
	DECLARE @ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes
    
	SELECT
	        MS.MaterialStockNo AS OldMaterialStockNo,
	        MS.MaterialStockNo,
	        MW.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        CI.CompanyDesc,
	        CI.CompanyDescL,
	        MW.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        WCI.WorkCenterDesc,
	        WCI.WorkCenterDescL,
	        MS.MaterialWarehouseCode,
	        MW.MaterialWarehouseName,
	        MW.MaterialWarehouseNameL,
	        MW.MaterialWarehouseDesc,
	        MW.MaterialWarehouseDescL,
	        MS.MaterialLocationCode,
	        ML.MaterialLocationName,
	        ML.MaterialLocationNameL,
	        MS.MaterialCode,
	        MM.MaterialName,
	        MM.MaterialNameL,
	        MM.MaterialTypeCode,
	        MT.BasicMaterialType,
	        MT.MaterialTypeName,
	        MT.MaterialTypeNameL,
	        
	        MM.ProductGroupCode,
	        PG.ProductGroupName,
	        PG.ProductGroupNameL,
	        PG.ProductGroupDesc,
	        PG.ProductGroupDescL,
	        
	        MS.MaterialStockAttribute,	        
	        MS.StockQty,
	        MS.PickingAssignQty,
	        MS.StockAttrib1,
	        MS.StockAttrib2,
	        MS.StockAttrib3
	FROM
	        STB_MaterialStock MS WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)				ON MS.MaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)				ON MS.MaterialLocationCode = ML.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MS.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MW.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MW.WorkCenterCode = WCI.WorkCenterCode
	  WHERE (@CompanyCode = '*' OR MW.CompanyCode = @CompanyCode)
		AND (@WorkCenterCode = '*' OR MW.WorkCenterCode = @WorkCenterCode)
		--AND (@MaterialWarehouseCode = '*' OR MS.MaterialWarehouseCode = @MaterialWarehouseCode)
		and MS.MaterialWarehouseCode = 'PROD_STBY_VN_WH'
		AND (@MaterialTypeCode = '*' OR MM.MaterialTypeCode = @MaterialTypeCode)
		AND (@BasicMaterialType = '*' OR MT.BasicMaterialType = @BasicMaterialType)
		AND (@ProductGroupCode = '*' OR MM.ProductGroupCode = @ProductGroupCode)
		AND (@MaterialCode = '*' OR MS.MaterialCode = @MaterialCode)
		AND MS.StockQty > 0 
		AND MT.BasicMaterialType NOT IN (
										SELECT Item
										  FROM dbo.fnSplitToTable(',',@ExcludeBasicMaterialTypes)
										)
        AND MS.stockAttrib3 <> 'X'
END