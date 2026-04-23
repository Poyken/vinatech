-- =============================================
-- Author : Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-08-22
-- Description : Production Order BOM 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionOrderBomForControl]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pControlNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ControlNo VARCHAR(20) = @pControlNo

	SELECT
			POB.MaterialCode,
			MM.MaterialName,
			POB.BomVersion,
			POB.ChildMaterialCode,
			CMM.MaterialName AS ChildMaterialName,
			CMM.MaterialTypeCode,
			MT.MaterialTypeName,
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
						MS.CompanyCode = POI.CompanyCode AND
						MS.WorkCenterCode = POI.WorkCenterCode AND
						MS.MaterialCode = POB.ChildMaterialCode AND
						MS.MaterialStockAttribute = 'NORMAL'
			),0) AS StockQty,
			POB.UsedQty,
			POB.TotalUsedQty,
			POB.RouteCode,
			POB.IsOptionItem,
			POB.BomDetailDesc,
			POB.StdCombSec
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
				ON POI.PONo = SI.PONo
			INNER JOIN STB_ProductionOrderBom POB WITH(NOLOCK)
				ON POB.PONo = SI.PONo AND
				POB.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = POB.MaterialCode
			LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
				ON	CMM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = CMM.ProductGroupCode
	WHERE
			SI.ControlNo = @ControlNo
	ORDER BY
			POB.MaterialCode,
			POB.BomVersion
END
