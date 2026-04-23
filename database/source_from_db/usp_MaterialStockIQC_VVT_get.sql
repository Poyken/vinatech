

-- =============================================
-- Author: nguyentung
-- Create date: 2016-04-14
-- Browsable  : true
-- Group : 자재관리
-- Description:	자재재고정보 조회
-- Modified:
--                 2021.02.05 
-- =============================================
-- exec  [usp_MaterialStockIQC_VVT_get]  '','','VVT', 'VVT_F1',''
CREATE PROCEDURE [dbo].[usp_MaterialStockIQC_VVT_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pMaterialWarehouseCode VARCHAR(30) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	
;with tung as (
			select a1.materialcode as mat,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute, sum(stockqty) as stock,max(isnull(MDI.SourceCustomerCode,MaterialDocTypeCode)) as SourceCustomerCode--,cI2.CustomerName
			from	[SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo] a1 WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = a1.MaterialDocDetailNo 
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo
						left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDi.SourceCustomerCode = ci2.CustomerCode 

			 where  MaterialLocationCode like @pMaterialWarehouseCode+'%'
			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialDocLotInfo]  WITH(NOLOCK) where LotID=a1.lotid and materiallotno is not null ) = 0
			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0 
			and (select  count(*) from [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  WITH(NOLOCK) where LotID=a1.lotid  ) = 0  
			and lotid>'ML20191120' and lotid not in ('ML20210630000413','ML20210630000414')
			group by a1.MaterialCode,a1.StockAttrib1,a1.StockAttrib2,a1.StockAttrib3,a1.MaterialStockAttribute,MaterialDocTypeCode--MDI.SourceCustomerCode,cI2.CustomerName,
	  ), 
tung1 as(
	  			select  MLI.materialcode,mli.MaterialWarehouseCode,MLI.MaterialLocationCode,		
							sum(MLI.PickingQty) as PickingQty,			
							max(MQI.DecisionResult) as DecisionResult,
							(
								select isnull(sum(MLI1.CurrentQty),0)
								from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
								LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
								LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
								LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
								where MDD1.MaterialDocDetailNo=MDD.MaterialDocDetailNo and MaterialWarehouseCode  = @pMaterialWarehouseCode and MQI1.DecisionResult='Reject' and MaterialDocType<>'GI'
							) 
							--as HoldingQty,
							--(
							--	select isnull(sum(MLI1.CurrentQty),0)
							--	from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
							--	LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
							--	LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
							--	LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo 
							--	where MDD1.MaterialDocDetailNo=MDD.MaterialDocDetailNo and MaterialWarehouseCode <> @pMaterialWarehouseCode and MQI1.DecisionResult='Reject' and MaterialDocType<>'GI'
							--) 
							as isOutROUTE,
							(
								select isnull(sum(MLI1.CurrentQty),0)
								from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
								LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
								LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
								LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
								where MDD1.MaterialDocDetailNo=MDD.MaterialDocDetailNo   and MQI1.DecisionResult='Reject' and MaterialDocType<>'GI'
							) 
							as isOutROUTETotal,
							--isnull(max(case when MQI.DecisionResult='Reject'  then MDD.AllowQty end),0) as HoldingQty,
							--isnull(sum(case when MQI.DecisionResult ='Reject' then MLI.CurrentQty end),0) as HoldingQty,
							isnull(sum( MLI.CurrentQty ),0) as qty,
							--isnull(sum(case when MQI.DecisionResult<>'Reject' then MLI.CurrentQty end),0) as qty
							--case when SourceCustomerCode is null then MaterialDocTypeCode else SourceCustomerCode end as SourceCustomerCode
							isnull(MDI.SourceCustomerCode,MaterialDocTypeCode) as SourceCustomerCode--,
							--cI2.CustomerName
				from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI WITH(NOLOCK) 
						LEFT OUTER JOIN STB_MaterialDocLotInfo mdli   WITH(NOLOCK) on MLi.LotID = Mdli.lotid
						LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = mdli.MaterialDocDetailNo 
						LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)   on MDD.MaterialDocNo = MDI.MaterialDocNo
						LEFT OUTER JOIN STB_MaterialQcInfo MQI   WITH(NOLOCK) on MQI.MaterialQcNo = MDD.MaterialIqcNo
									left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on MDI.SourceCustomerCode = ci2.CustomerCode 

				where    --MLI.MaterialWarehouseCode = @pMaterialWarehouseCode  and MaterialDocType<>'GI'
				--and TargetMaterialWarehouseCode=@pMaterialWarehouseCode and MaterialDocTypeCode not like '%RETURN%'
				(@pCompanyCode = '*' OR MLI.CompanyCode = @pCompanyCode) AND
		
			--(@WorkCenterCode = '*' OR MLI.WorkCenterCode = @WorkCenterCode) AND
			(@pMaterialWarehouseCode = '*' OR MLI.MaterialWarehouseCode LIKE @pMaterialWarehouseCode) AND		
			
			len(isnull(mdli.materiallotno,'')) = ( case when MLI.MaterialWarehouseCode LIKE 'ROH_VN_WH' then 0 else len(mdli.materiallotno) end  ) --and

			--(@MaterialLocationCode = '*' OR MLI.MaterialLocationCode LIKE @MaterialLocationCode) AND
			--(@pMaterialCode = '*' OR MLI.MaterialCode LIKE @pMaterialCode) AND

				--or (substring(mdli.LotID,1,2) = 'SP' and mli.MaterialWarehouseCode=@MaterialWarehouseCode)
				group by MLI.MaterialCode, MLI.MaterialWarehouseCode,MLI.MaterialLocationCode,MDD.MaterialDocDetailNo,MaterialDocType,MDI.SourceCustomerCode/*,cI2.CustomerName*/ ,isnull(MDI.SourceCustomerCode,MaterialDocTypeCode)--,PickingQty
			  --select materialcode,MaterialWarehouseCode,MaterialLocationCode, sum(PickingQty) as PickingQty,sum(CurrentQty) as qty
				 -- from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  WITH(NOLOCK) where   MaterialWarehouseCode = @pMaterialWarehouseCode  
			  --group by MaterialCode,MaterialWarehouseCode,MaterialLocationCode--,PickingQty
			  )
			  ,  
data21 as
			(	  
			select			materialcode,
							MaterialWarehouseCode,
							MaterialLocationCode,		
							max (SourceCustomerCode) as SourceCustomerCode,
							--max (CustomerName) as CustomerName,
							max (DecisionResult) as DecisionResult,

							sum(PickingQty) as PickingQty,					  
							--sum(HoldingQty) as HoldingQty,
							sum(isOutROUTE) as isOutROUTE,

							sum(isOutROUTETotal) as isOutROUTETotal,
							sum(qty) as qty
			 from	tung1 		 
			 group by MaterialCode, MaterialWarehouseCode,MaterialLocationCode
			 )
			 ,
data2 as
			(	  
			 select isnull(materialcode,mat) as MaterialCode, isnull(qty,0)+isnull(stock,0) as StockQty,StockAttrib1,
			 isnull(data21.SourceCustomerCode,tung.SourceCustomerCode) as SourceCustomerCode ,--isnull(data21.CustomerName,tung.CustomerName) as CustomerName,
				StockAttrib2,StockAttrib3,MaterialStockAttribute,isnull(MaterialWarehouseCode,@pMaterialWarehouseCode) as MaterialWarehouseCode,
				isnull(MaterialLocationCode,@pMaterialWarehouseCode+'_01') as MaterialLocationCode, isnull(PickingQty,0) as PickingQty/*,HoldingQty*/,isOutROUTE,DecisionResult,isOutROUTETotal
			 from	tung 
			 full outer join data21 on tung.mat = data21.MaterialCode 	--and 		data21.SourceCustomerCode=tung.SourceCustomerCode 
			 )
SELECT
	        --MS.MaterialStockNo AS OldMaterialStockNo,
	        --MS.MaterialStockNo,
	        MW.CompanyCode,
	        --CI.CompanyName,
	        --CI.CompanyNameL,
	        CI.CompanyDesc,
	        --CI.CompanyDescL,
	        MW.WorkCenterCode,
	        WCI.WorkCenterName,
	        --WCI.WorkCenterNameL,
	        --WCI.WorkCenterDesc,
	        --WCI.WorkCenterDescL,
	        MS.MaterialWarehouseCode,
	        MW.MaterialWarehouseName,
	        --MW.MaterialWarehouseNameL,
	        MW.MaterialWarehouseDesc,
	        --MW.MaterialWarehouseDescL,
	        --MS.MaterialLocationCode,
	        --ML.MaterialLocationName,
	        --ML.MaterialLocationNameL,
	        MS.MaterialCode,
	        MM.MaterialName,
	        --MM.MaterialNameL,
			MM.ProductGroupCode,
	        MM.MaterialTypeCode,
	        MT.BasicMaterialType,
	        MT.MaterialTypeName,
	        --MT.MaterialTypeNameL,	        
	        PG.ProductGroupName,
	        --PG.ProductGroupNameL,
	        PG.ProductGroupDesc,
	        --PG.ProductGroupDescL,	        
	        MS.MaterialStockAttribute,	        
	        MS.StockQty ,
			MM.MaterialUnit,
	        MS.PickingQty,			
			DecisionResult as IQC_Result,
			(case when lower(DecisionResult)='reject' then isOutROUTE else 0 end) as Reject_Out_Qty,
			--(case when lower(DecisionResult)='reject' then isOutROUTETotal else 0 end) as Reject_Total,
			--HoldingQty,
	        MS.StockAttrib1,
	        MS.StockAttrib2,
	        MS.StockAttrib3,
			(
				case 
				when (MS.StockQty /*-  HoldingQty*/ ) < 0  then 0 
				else (MS.StockQty /*-  HoldingQty*/  ) end
			) as ValidQty,
			MM.BasicCostPriceVVT AS BasicCostPrice,                                   -- 표준원가
			(MM.BasicCostPriceVVT * MS.StockQty)  AS CurrentAmount,        -- 금액
			SourceCustomerCode as CustomerCode --,
			--CustomerName
	FROM
	        data2 MS WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)			ON MS.MaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)			ON MS.MaterialLocationCode = ML.MaterialLocationCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MS.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)					ON MW.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON MW.WorkCenterCode = WCI.WorkCenterCode
			--LEFT OUTER JOIN [STB_MaterialVendorMapping] mvm  WITH(NOLOCK) on MS.MaterialCode = mvm.MaterialCode
			--left outer join STB_CustomerInfo ci2  WITH(NOLOCK) on ms.SourceCustomerCode = ci2.CustomerCode 
	WHERE
			--MW.CompanyCode LIKE 'VVT'
			--AND			MW.WorkCenterCode LIKE 'VVT_F1' 
			/*AND	*/        MS.MaterialWarehouseCode LIKE @pMaterialWarehouseCode
		
			--AND	        MM.MaterialTypeCode LIKE @MaterialTypeCode 
			--AND			MT.BasicMaterialType LIKE @BasicMaterialType 
			--AND			MM.ProductGroupCode LIKE @ProductGroupCode 
			--AND			MS.MaterialCode LIKE @MaterialCode 
			--AND			MS.StockQty >= 0 
	order by MS.MaterialCode		
END




--select text from
--sys.syscomments 
--where text like '%usp_DoCreateMaterialIQCInfo%'






--select*from STB_MaterialDocLotInfo
--where lotid='ML20191119000159' MaterialDocDetailNo >='210401000000' and MaterialLocationCode='ROUTE%' --= ('191207000118')





--select*from STB_MaterialDocDetail
--where MaterialDocDetailNo = ('191207000118')





--select top 10*from STB_MaterialLotInfo
--where  MaterialWarehouseCode like 'ROUTE%' --= ('191207000118')





--select *from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI WITH(NOLOCK) 
--						LEFT OUTER JOIN STB_MaterialDocLotInfo mdli   WITH(NOLOCK) on MLi.LotID = Mdli.lotid
--						LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK) ON MDD.MaterialDocDetailNo = mdli.MaterialDocDetailNo 
--where mli.lotid='ML20191119000159' and MaterialWarehouseCode = 'ROUTE_VN_WH'





--	select *
--	from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
--	LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = mdli1.LotID
--	LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
--	where MDD1.MaterialDocDetailNo='200327000003' and MLi1.MaterialWarehouseCode = 'ROUTE_VN_WH'


--select *from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI WITH(NOLOCK) 
--where Materialcode='GBAKAC-021'


--19350.00000


--								select sum(distinct MDD1.AllowQty)
--								from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
--								LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
--								LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
--								LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
--								where mli1.Materialcode='GBAKAC-033'  and MQI1.DecisionResult='Reject'


								--select MLI1.* --,isnull(sum(MLI1.CurrentQty),0)
								--from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
								--LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
								--LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
								--LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
								--where mli1.Materialcode='GBAKAC-033' and MaterialWarehouseCode  = @pMaterialWarehouseCode and MQI1.DecisionResult='Reject'
					

								--select MLI1.* --,isnull(sum(MLI1.CurrentQty),0)
								--from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
								--LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
								--LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
								--LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
								--where  mli1.Materialcode='GBAKAC-033'   and MaterialWarehouseCode <> @pMaterialWarehouseCode and MQI1.DecisionResult='Reject'
					

								--select MLI1.* --,isnull(sum(MLI1.CurrentQty),0)
								--from	[SmartFactoryV2].[dbo].[STB_MaterialLotInfo]  MLI1 WITH(NOLOCK) 
								--LEFT OUTER JOIN STB_MaterialDocLotInfo mdli1   WITH(NOLOCK) on mdli1.LotID = MLI1.LotID
								--LEFT OUTER JOIN STB_MaterialDocDetail MDD1 WITH(NOLOCK) ON MDD1.MaterialDocDetailNo = mdli1.MaterialDocDetailNo 
								--LEFT OUTER JOIN STB_MaterialQcInfo MQI1   WITH(NOLOCK) on MQI1.MaterialQcNo = MDD1.MaterialIqcNo
								--where  mli1.Materialcode='GBAKAC-033'     and MQI1.DecisionResult='Reject'
