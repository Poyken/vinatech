
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-18
-- Browsable : true
-- Group : 재고관리
-- Description:	안전재고현황을 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSafeStockStatus]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pMaterialLocationCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pMaterialStockAttribute VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '%' ELSE @pMaterialWarehouseCode END
	DECLARE @MaterialLocationCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialLocationCode,'') = '' THEN '%' ELSE @pMaterialLocationCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @MaterialStockAttribute VARCHAR(20) = CASE WHEN ISNULL(@pMaterialStockAttribute,'') = '' THEN '%' ELSE @pMaterialStockAttribute END

    
	SELECT
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialSpec	,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupname,
			MS.MaterialStockAttribute,
			MS.StockAttrib1,
			MS.StockAttrib2,
			MS.StockAttrib3,
			ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,
			ISNULL(MS.StockQty, 0) AS StockQty,
			CASE		
					WHEN MS.StockQty < ISNULL(MSAI.SaftyStock,0) THEN CONVERT(BIT, 1)
					ELSE CONVERT(BIT, 0)
			END AS IsNeedOrder
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN 
			(
				SELECT
						MS.MaterialCode,
						MS.MaterialStockAttribute,
						MS.StockAttrib1,
						MS.StockAttrib2,
						MS.StockAttrib3,
						SUM(MS.StockQty) AS StockQty					
				FROM 
						STB_MaterialStock MS WITH(NOLOCK)
				WHERE
						MS.MaterialWarehouseCode LIKE @MaterialWarehouseCode AND
						MS.MaterialLocationCode LIKE @MaterialLocationCode AND
						MS.MaterialStockAttribute LIKE @MaterialStockAttribute AND
						MS.MaterialCode LIKE @MaterialCode AND
						MS.StockQty > 0
				GROUP BY
						MS.MaterialCode,
						MS.MaterialStockAttribute,
						MS.StockAttrib1,
						MS.StockAttrib2,
						MS.StockAttrib3
			) MS ON	MM.MaterialCode = MS.MaterialCode
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)
				ON	MSAI.MaterialCode = MM.MaterialCode 
			LEFT OUTER JOIN STB_MaterialType MT WITH (NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG
				ON PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MM.MaterialCode LIKE @MaterialCode
END