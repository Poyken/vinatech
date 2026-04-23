-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : 생산계획 구매자재 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionOrderBomForOrder]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20)  = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT
			POB.ChildMaterialCode AS MaterialCode,
			CMM.MaterialName,
			CMM.MaterialTypeCode,
			MT.MaterialTypeName,
			CMM.MaterialSpec,
			CMM.ProductGroupCode,
			PG.ProductGroupName,
			POB.ChildBomVersion,
			POB.BomUnit,
			ISNULL((
				SELECT
						SUM(MS.StockQty)
				FROM
						STB_MaterialStock MS WITH(NOLOCK)
				WHERE
						MS.CompanyCode = PO.CompanyCode AND
						MS.WorkCenterCode = PO.WorkCenterCode AND
						MS.MaterialCode = POB.ChildMaterialCode AND
						MS.MaterialStockAttribute = 'NORMAL'
			),0) AS StockQty,
			POB.UsedQty,
			SUM(POB.TotalUsedQty),
			POB.RouteCode,
			POB.IsOptionItem,
			POB.BomDetailDesc,
			POB.StdCombSec
	FROM
			STB_ProductionOrderBom POB WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK)
				ON	PO.PONo = POB.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = POB.MaterialCode
			LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
				ON	CMM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = CMM.ProductGroupCode
	WHERE
			POB.PONo = @PONo AND
			POB.MaterialCode LIKE @MaterialCode AND
			MM.IsOrder = 1 AND
			MM.IsPurchase = 1
	GROUP BY
			POB.ChildMaterialCode,
			CMM.MaterialName,
			CMM.MaterialTypeCode,
			MT.MaterialTypeName,
			CMM.MaterialSpec,
			CMM.ProductGroupCode,
			PG.ProductGroupName,
			POB.ChildBomVersion,
			POB.BomUnit,
			POB.UsedQty,
			POB.RouteCode,
			POB.IsOptionItem,
			POB.BomDetailDesc,
			POB.StdCombSec,
			PO.CompanyCode,
			PO.WorkCenterCode
	ORDER BY
			POB.ChildMaterialCode,
			POB.ChildBomVersion
END
