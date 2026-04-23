

CREATE PROCEDURE [dbo].[usp_Vietnam_PlanDayBom_VVT_popup]
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pDayPlanNo VARCHAR(50) = NULL,
	@pLotID VARCHAR(50) = NULL,
		@pPlanDate date = null
AS
BEGIN
	SET NOCOUNT ON;


	--declare @err1 varchar(30)= convert(varchar(30),@pPlanDate)
	--raiserror(@err1,16,1);
	--return;

	   
		SELECT	
				
					--CASE
					--	WHEN ParentId IS NULL THEN 1
					--	ELSE 2
					--END AS Seq,
					--POB.Id,
					--POB.ParentId,
					dpp.MaterialCode,
					MM.MaterialName,
					--POB.BomVersion,
					--pob.PONo,
					--POB.ChildMaterialCode,
					--CMM.MaterialName AS ChildMaterialName,
					--CMM.MaterialTypeCode,
					--MT.MaterialTypeName,
					--CMM.MaterialSpec,
					--CMM.ProductGroupCode,
					--PG.ProductGroupName,
					--POB.ChildBomVersion,
					--POB.BomUnit,
					--CMM.MaterialUnit,
					--ISNULL((
					--	SELECT
					--			SUM(MS.StockQty)
					--	FROM
					--			STB_MaterialStock MS WITH(NOLOCK)
					--	WHERE
					--			MS.CompanyCode = PO.CompanyCode AND
					--			MS.WorkCenterCode = PO.WorkCenterCode AND
					--			MS.MaterialCode = POB.ChildMaterialCode AND
					--			MS.MaterialStockAttribute = 'NORMAL'
					--),0) AS StockQty,
					--sum(POB.UsedQty) as UnitQty,
					--sum(POB.UsedQty * dpp.PlanQty) as NeedQty,
					--POB.RouteCode,
					--POB.IsOptionItem,
					--POB.BomDetailDesc,
					--POB.StdCombSec,
					--dpp.LineCode,
					--min(dpp.DayPlanNo) as DayPlanNo,
					
					--dpp.PlanDate,
					sum(dpp.PlanQty) as PlanQty--,
					--dpp.PlanShiftCode
			FROM
					--STB_ProductionOrderBom POB WITH(NOLOCK) 
					--INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK)
					--	ON	PO.PONo = POB.PONo
					 STB_DayProdPlan dpp WITH(NOLOCK) --on pob.PONo=dpp.PONo and pob.MaterialCode=dpp.MaterialCode
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON	MM.MaterialCode = dpp.MaterialCode
					--LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
					--	ON	CMM.MaterialCode = POB.ChildMaterialCode
					--LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
					--	ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
					--LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					--	ON	PG.ProductGroupCode = CMM.ProductGroupCode
			WHERE
					dpp.CreateDateTime > DATEADD(day,-30, dpp.CreateDateTime )
					and dpp.CompanyCode='VVT'
					and (@pPlanDate is null or @pPlanDate='' or dpp.PlanDate=@pPlanDate)
						
			group by dpp.MaterialCode,
					MM.MaterialName--,
					--POB.BomVersion,
					--pob.PONo,
					--dpp.LineCode--,
					--dpp.DayPlanNo,					
					--dpp.PlanDate--,
					--dpp.PlanShiftCode
			order by MaterialCode
					   	
END

