
---[usp_Vietnam_PlanDayBom_VVT_get] '','','','','2022-08-25',''

CREATE PROCEDURE [dbo].[usp_Vietnam_PlanDayBom_VVT_get]
	@pProcessUserID VARCHAR(20)=null,
	@pProcessLanguage VARCHAR(20)=null,
	@pDayPlanNo VARCHAR(50) = NULL,
	@pLotID VARCHAR(50) = NULL,
	@pPlanDate date = null,
	@pProductCode VARCHAR(50) = NULL
AS
BEGIN



	SET NOCOUNT ON;
	   
	    set @pDayPlanNo = case when isnull(@pDayPlanNo,'')='' then '' else @pDayPlanNo end
		set @pLotID = case when isnull(@pLotID,'')='' then '' else @pLotID end
		set @pPlanDate = case when isnull(@pPlanDate,'')='' then '' else @pPlanDate end
		set @pProductCode = case when isnull(@pProductCode,'')='' then '' else @pProductCode end
					

					--if(@pDayPlanNo is not null and ltrim(rtrim(@pDayPlanNo))<>'' and @pLotID is not null and ltrim(rtrim(@pLotID))<>'') begin						
						
					--	declare @Qty float=0
					--	declare @materiacode varchar(200)= ''

					--	select @Qty = convert(float,CurrentQty),@materiacode=MaterialCode 
					--	from STB_MaterialLotInfo     
					--	where LotID=@pLotID          --and MaterialWarehouseCode not like '%ROH%';

					--	if(@materiacode is not null and @Qty>0)
					--		insert into STB_Vietnam_MaterialOrderHist (DayPlanNo,MaterialCode,LotID,Qty,CreateDateTime,CreateUserId)
					--			values (@pDayPlanNo,@materiacode,@pLotID,@Qty,getdate(),@pProcessUserID);
					--end
					

				SELECT
					--CASE
					--	WHEN ParentId IS NULL THEN 1
					--	ELSE 2
					--END AS Seq,
					--POB.Id,
					--POB.ParentId,
					POB.MaterialCode,
					MM.MaterialName,
					--POB.BomVersion,
			
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
					(POB.UsedQty) as UnitQty,

					--POB.IsOptionItem,
					--POB.BomDetailDesc,
					--POB.StdCombSec,
					--dpp.LineCode,
					--dpp.DayPlanNo,

					dpp.PlanDate,
					sum(dpp.PlanQty)PlanQty,
									cast(POB.UsedQty as float) *	sum(   cast(dpp.PlanQty as float) ) as NeedQty,
					(
						select sum(isnull(Qty,0)) 
						from STB_Vietnam_MaterialOrderHist with(nolock) 
						where orderdate=dpp.PlanDate and ( ProductCode=pob.MaterialCode)
						and MaterialCode=POB.ChildMaterialCode
					) as IssuedQty,
					--dpp.PlanShiftCode,
					--POB.RouteCode,
							POB.ChildMaterialCode,
					CMM.MaterialName AS ChildMaterialName,
					--CMM.MaterialTypeCode,
					--MT.MaterialTypeName,
					--CMM.MaterialSpec,
					--CMM.ProductGroupCode,
					--PG.ProductGroupName,
					--POB.ChildBomVersion,
					--POB.BomUnit--,
					CMM.MaterialUnit
			FROM
					STB_ProductionOrderBom POB WITH(NOLOCK)
					INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK)
						ON	PO.PONo = POB.PONo
					join STB_DayProdPlan dpp WITH(NOLOCK) on pob.PONo=dpp.PONo and pob.MaterialCode=dpp.MaterialCode
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
						ON	MM.MaterialCode = POB.MaterialCode
					LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
						ON	CMM.MaterialCode = POB.ChildMaterialCode
					LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
						ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
					LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
						ON	PG.ProductGroupCode = CMM.ProductGroupCode
			WHERE
					dpp.CreateDateTime> dateadd(day,-30,getdate()) 
					and (@pDayPlanNo='' or dpp.DayPlanNo  = @pDayPlanNo)					
					and (@pPlanDate='' or dpp.PlanDate  = @pPlanDate)
					and (@pProductCode='' or POB.MaterialCode  = @pProductCode)
					and (POB.RouteCode like 'MV%' or POB.RouteCode like 'V%' or POB.RouteCode is null)
			GROUP by 
					--POB.Id,
					--POB.ParentId,
					POB.MaterialCode,
					MM.MaterialName,
					--POB.BomVersion,
					POB.ChildMaterialCode,
					CMM.MaterialName, --AS ChildMaterialName,
					--CMM.MaterialTypeCode,
					MT.MaterialTypeName,
					POB.UsedQty,
					--CMM.MaterialSpec,
					--CMM.ProductGroupCode,
					--PG.ProductGroupName,
					--POB.ChildBomVersion,
					--POB.BomUnit,
					CMM.MaterialUnit,			
					--POB.RouteCode,
					--POB.IsOptionItem,
					--POB.BomDetailDesc,
					--PO.CompanyCode,
					--PO.WorkCenterCode,
					--POB.StdCombSec,
					--					dpp.LineCode,
					--dpp.DayPlanNo,
					dpp.PlanDate--,
					--dpp.PlanQty--,
					--dpp.PlanShiftCode
			ORDER BY
					
					dpp.PlanDate,
					POB.ChildMaterialCode--,
					--pob.PONo,
					--pob.BomVersion,
					--dpp.DayPlanNo,
					--CASE WHEN ParentId IS NULL THEN 1
					--	ELSE 2
					--END,
					--dpp.LineCode,
					--pob.RouteCode,
					--BomVersion

END 
