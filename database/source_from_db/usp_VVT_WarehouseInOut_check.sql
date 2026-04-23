
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-27
-- Browsable : true
-- Group : 자재관리
-- Description:	자재 입출고 이력조회
-- Modified: Mr.Tung
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_WarehouseInOut_check]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromBasicDate DATE = NULL,
	@pToBasicDate DATE = NULL,
	@pMaterialDocType VARCHAR(20) = NULL,
	@pMaterialDocTypeCode VARCHAR(20) = NULL,
	@pMaterialCode varchar(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- exec usp_VVT_WarehouseInOut_check 'nguyentung','Vietnamese','2022-10-01','2022-10-31','','',NULL

	DECLARE @FromBasicDate DATE = isnull(@pFromBasicDate,@pFromDate)
	DECLARE @ToBasicDate DATE = isnull(@pToBasicDate,@pToDate)

	DECLARE @FromBasicDate1   VARCHAR(19) = CONVERT(VARCHAR(10), @FromBasicDate, 120) + ' 10:30:00'    
	DECLARE @ToBasicDate1      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @ToBasicDate)), 120) + ' 10:30:00'


	DECLARE @MaterialDocType VARCHAR(20) = '%'
	DECLARE @MaterialDocTypeCode VARCHAR(20) = '%'
	DECLARE @MaterialCode varchar(50) = coalesce(@pMaterialCode,'*')
    

;with tmpInput as (
	 	SELECT
			MDI.MaterialDocNo AS OldMaterialDocNo,
			MDI.MaterialDocNo,
			--convert(varchar(10),mdli.createdatetime,120) as RequireDate,
			--convert(varchar(10),MDI.SourceProcessDateTime,120) as RequireDate1,
			--isnull(MDI.SourceProcessDateTime,MDI.RequestDateTime) as ConfirmDate,
			--(case when MDI.MaterialDocType='GR' then mdli.createdatetime else mdli.RequestDateTime end ) as ConfirmDate,
			-- mdli.createdatetime  as ConfirmDate,
			MDI.MaterialDocType,
			MDI.MaterialDocTypeCode,
			MDI.MaterialDocType as MaterialDocTypeName1 ,
			MDI.DocStatus,
			--DocStatusName as StatusPos,
			--(case when MDI.MaterialDocType='GR' and MDT.MaterialDocTypeName='G/R BY ORDER'	and  (DocStatusName='CREATE' or  DocStatusName='ARRIVAL') then 'Fix G/R' else DocStatusName end) 
			--as DocStatusName,
			--MaterialTypeCode,	
			--MaterialUnit,		
			MQI.DecisionResult,
				
			MDI.SourceCustomerCode,
			--SOURCE_CUS.CustomerName AS SOURCE_CustomerName,
			MDI.SourceCompanyCode,
			--SOURCE_CI.CompanyName AS SOURCE_CompanyName,
			MDI.SourceWorkCenterCode,
			--SOURCE_WCI.WorkCenterName AS SOURCE_WorkCenterName,
			MDI.SourceRouteCode,
			--SOURCE_RI.RouteCode AS SOURCE_RouteName,
			MDI.SourceMaterialWarehouseCode,
			--SOURCE_MW.MaterialWarehouseName AS SOURCE_MaterialWarehouseName,
			--SOURCE_MW.DefaultLocationCode AS MaterialLocationCode,
			
			MDI.TargetCustomerCode,
			--TARGET_CUS.CustomerName AS TARGET_CustomerName,
			MDI.TargetCompanyCode,
			--TARGET_CI.CompanyName AS TARGET_CompanyName,
			MDI.TargetWorkCenterCode,
			--TARGET_WCI.WorkCenterName AS TARGET_WorkCenterName,
			MDI.TargetRouteCode,
			--TARGET_RI.RouteName AS TARGET_RouteName,
			MDI.TargetMaterialWarehouseCode,
			--TARGET_MW.MaterialWarehouseName AS TARGET_MaterialWarehouseName,

			MDI.RefMaterialDocNo,
			MDI.PONo,
			MDI.FPItemWorkNo,
			MDI.RequestDateTime,
			MDI.RequestUserID,
			MDI.RequestPlanDate,
			MDI.RequestDesc,
			MDI.RequestFixDateTime,
			MDI.RequestFixUserID,
			MDI.IsRequestFix,
			MDI.RequestApprovalDateTime,
			MDI.RequestApprovalUserID,
			MDI.IsRequestApproval,
			MDI.IsAssignPicking,
			MDI.PickingStartDateTime,
			MDI.PickingEndDateTime,
			MDI.PickingUserID,
			MDI.IsPickingFix,
			MDI.IsSourceFinish,
			MDI.SourceProcessDateTime,
			MDI.SourceProcessUserID,
			MDI.IsTargetFinish,
			MDI.TargetProcessDateTime,
			MDI.TargetProcessUserID,
			MDI.TotalPlanPrice,
			MDI.TotalActualPrice,
			MDD.MRMDExtText01 as PaperNoImport,
			MDD.MRMDExtText02 as PaperNoExport,
			MDD.MRMDExtText03 as CustomsDeclare,
			--isnull(substring(MDD.MRMDExtText04,1,10),convert(varchar(10),mdd.createdatetime,120)) as DateImport,
			--isnull(substring(MDD.MRMDExtText05,1,10),convert(varchar(10),mdd.createdatetime,120)) as DateExport,
			MDD.MaterialCode,
			--MM.MaterialName,
			--MDD.RequestQty,
			--MDD.AllowQty as ProcessFixQty,
			--MDD.ProcessFixQty as AllowQty,
			MDD.VendorLotNo,			
			MDD.InspectionType,
			MDD.PickingAssignQty,
			MDD.PickingQty,
			MDD.StockAttrib1,
			MDI.MRMIExtText02 as StockAttrib2,
			MDD.StockAttrib2 as StockAttrib3,
			MDD.UnitPrice,
			MDD.UnitPriceQty
			--MDD.MaterialDocDetailNo,
			--MM.MaterialTypeCode,	
			--MM.MaterialUnit,
			--DS.DocStatusName as DocStatusName1
			,mdli.LotID
			 ,isnull(mdli.StockQty,MDD.RequestQty)     as RequestQty
			 ,isnull(mdli.StockQty,MDD.ProcessFixQty)  as ProcessFixQty
			 ,isnull(mdli.StockQty,MDD.AllowQty)       as AllowQty
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialDocType MDT WITH(NOLOCK)
				ON (MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode)
			--LEFT OUTER JOIN VW_DocStatus DS WITH(NOLOCK)
			--	ON (DS.DocType = MDI.MaterialDocType AND DS.DocStatus = MDI.DocStatus)
			--LEFT OUTER JOIN STB_CustomerInfo SOURCE_CUS WITH(NOLOCK)
			--	ON (SOURCE_CUS.CustomerCode = MDI.SourceCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo SOURCE_CI WITH(NOLOCK)
				ON (SOURCE_CI.CompanyCode = MDI.SourceCompanyCode)
			--LEFT OUTER JOIN STB_WorkCenterInfo SOURCE_WCI WITH(NOLOCK)
			--	ON (SOURCE_WCI.WorkCenterCode = MDI.SourceWorkCenterCode)
			--LEFT OUTER JOIN STB_RouteInfo SOURCE_RI WITH(NOLOCK)
			--	ON (SOURCE_RI.RouteCode = MDI.SourceRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse SOURCE_MW WITH(NOLOCK)
				ON (SOURCE_MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode)
			--LEFT OUTER JOIN STB_CustomerInfo TARGET_CUS WITH(NOLOCK)
			--	ON (TARGET_CUS.CustomerCode = MDI.TargetCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo TARGET_CI WITH(NOLOCK)
				ON (TARGET_CI.CompanyCode = MDI.TargetCompanyCode)
			--LEFT OUTER JOIN STB_WorkCenterInfo TARGET_WCI WITH(NOLOCK)
			--	ON (TARGET_WCI.WorkCenterCode = MDI.TargetWorkCenterCode)
			--LEFT OUTER JOIN STB_RouteInfo TARGET_RI WITH(NOLOCK)
			--	ON (TARGET_RI.RouteCode = MDI.TargetRouteCode)
			--LEFT OUTER JOIN STB_MaterialWarehouse TARGET_MW WITH(NOLOCK)
			--	ON (TARGET_MW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode)
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialDocLotInfo mdli   WITH(NOLOCK)
				on MDD.MaterialDocDetailNo = mdli.MaterialDocDetailNo 
			LEFT OUTER JOIN STB_MaterialQcInfo MQI   WITH(NOLOCK)
				on MQI.MaterialQcNo = MDD.MaterialIqcNo
			--LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
			--	ON MM.MaterialCode = MDD.MaterialCode
			
	WHERE 
			MDI.TargetCompanyCode='VVT' and 
			((MDI.BasicDate > @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) 
			or (MDI.BasicDate = @FromBasicDate and isnull(MDI.SourceProcessDateTime,MDI.RequestDateTime)>=@FromBasicDate1) 
			or (MDI.BasicDate > @ToBasicDate and isnull(MDI.SourceProcessDateTime,MDI.RequestDateTime)<=@ToBasicDate1) ) AND 
			--(MDI.BasicDate >= @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) AND 
			(MDI.MaterialDocType LIKE @MaterialDocType) AND 
			(MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode) AND 
			MDI.IsCancel = 0 and 
			(MDI.SourceRouteCode  is null --or MDI.SourceRouteCode <> 'V-28'
			) 
			and (mdd.MaterialCode=@MaterialCode	or @MaterialCode='*')		
			and mdi.MaterialDocType='GR' and LotID is not null
	)
	,
input as (
	select  		MaterialDocType
	--,MaterialUnit
	--,materialname
	,MaterialCode, sum(AllowQty) inputqty--,--PaperNoImport, 	DateImport,	CustomsDeclare ,		
		--(case when DATEPART(HOUR,ConfirmDate)>10 
		--				or (DATEPART(HOUR,ConfirmDate)=10 and DATEPART(MINUTE,ConfirmDate)>=30) then CONVERT(varchar(10),ConfirmDate,120) 
		--			 else CONVERT(varchar(10),DATEADD(DAY,-1,ConfirmDate),120)  end) as RequireDate     

	from tmpInput 
	where 
	--MaterialDocType='GR' and LotID is not null
	 --and 
	 (MaterialCode=@MaterialCode		or @MaterialCode='*')			
	group by 		MaterialDocType 
	--,MaterialUnit
	--,materialname
	,MaterialCode--, 
	--PaperNoImport,	DateImport,			CustomsDeclare ,
	
	--(case when DATEPART(HOUR,ConfirmDate)>10 
	--					or (DATEPART(HOUR,ConfirmDate)=10 and DATEPART(MINUTE,ConfirmDate)>=30) then CONVERT(varchar(10),ConfirmDate,120) 
	--				 else CONVERT(varchar(10),DATEADD(DAY,-1,ConfirmDate),120)  end)    
 
	)
	,
tmpOutput as (
	--select  		MaterialDocType,MaterialDocType as MaterialDocType1,MaterialUnit,materialname,MaterialCode, sum(AllowQty) outputqty,PaperNoExport,	DateExport,		
	--				 		(case when DATEPART(HOUR,ConfirmDate)>10 
	--					or (DATEPART(HOUR,ConfirmDate)=10 and DATEPART(MINUTE,ConfirmDate)>=30) then CONVERT(varchar(10),ConfirmDate,120) 
	--				 else CONVERT(varchar(10),DATEADD(DAY,-1,ConfirmDate),120)  end) as RequireDate   
	--				   ,
	--				  ((case when MaterialDocType='GR' and ConfirmDate > convert(varchar(10),convert(varchar(10),(ConfirmDate),120) ,120) + ' 10:30:00' 
	--		     then 0 else -1 end)) as ConfirmDate    
	--from tmpInput 
	--where MaterialDocType='MOVE'  and LotID is not null
	--group by 	MaterialDocType ,MaterialUnit,materialname,MaterialCode, PaperNoExport,	DateExport,		
	--				 		(case when DATEPART(HOUR,ConfirmDate)>10 
	--					or (DATEPART(HOUR,ConfirmDate)=10 and DATEPART(MINUTE,ConfirmDate)>=30) then CONVERT(varchar(10),ConfirmDate,120) 
	--				 else CONVERT(varchar(10),DATEADD(DAY,-1,ConfirmDate),120)  end)    
	--				   ,
	--				  ((case when MaterialDocType='GR' and ConfirmDate > convert(varchar(10),convert(varchar(10),(ConfirmDate),120) ,120) + ' 10:30:00' 
	--		     then 0 else -1 end))     

	select --createdatetime,
	--convert(varchar(10),createdatetime,120) RequireDate1,
	--convert(varchar(10),createdatetime,120) ConfirmDate1,
	
	max(MaterialWarehouseInOutHistNo)MaterialWarehouseInOutHistNo,
	lotid,SourceMaterialWarehouseCode,TargetMaterialWarehouseCode
	from STB_MaterialWarehouseInOutHist with(nolock) 
	where CreateDateTime>@FromBasicDate1 and CreateDateTime<@ToBasicDate1
	and TargetMaterialWarehouseCode  in ( 'ROUTE_VN_WH' ,'NOI_DIA_VN','NUOC_NGOAI_VN','HEADQUARTER_VN_WH','MODULE_VN_WH')
	and isnull(ProcessedLotID,'') <> ''
	group by lotid,TargetMaterialWarehouseCode,SourceMaterialWarehouseCode,
	createdatetime

	

	)
,ouput as (
	select sum(mli.CurrentQty) outputqty, mli.MaterialCode--,--mm.MaterialName,mm.MaterialUnit ,
	--'' PaperNoExport,
	--''MaterialDocType,''MaterialDocType1--,
	--convert(varchar(10),tmpOutput.createdatetime,120) DateExport,

	--convert(varchar(10),tmpOutput.createdatetime,120)  ConfirmDate
	--(case when DATEPART(HOUR,tmpOutput.createdatetime)>10 
	--					or (DATEPART(HOUR,tmpOutput.createdatetime)=10 and DATEPART(MINUTE,tmpOutput.createdatetime)>=30) then CONVERT(varchar(10),tmpOutput.createdatetime,120) 
	--				 else CONVERT(varchar(10),DATEADD(DAY,-1,tmpOutput.createdatetime),120)  end) ConfirmDate 
	--1 RequireDate, 1 ConfirmDate
	from tmpOutput
	left outer join STB_MaterialLotInfo mli with(nolock) on tmpOutput.lotid=mli.lotid
	--left outer join STB_MaterialMaster mm with(nolock) on mli.MaterialCode = mm.MaterialCode
	where  (mli.MaterialCode=@MaterialCode		or @MaterialCode='*')	
	group by mli.MaterialCode
	--,mm.MaterialName,mm.MaterialUnit ,
	--,(case when DATEPART(HOUR,tmpOutput.createdatetime)>10 
	--					or (DATEPART(HOUR,tmpOutput.createdatetime)=10 and DATEPART(MINUTE,tmpOutput.createdatetime)>=30) then CONVERT(varchar(10),tmpOutput.createdatetime,120) 
	--				 else CONVERT(varchar(10),DATEADD(DAY,-1,tmpOutput.createdatetime),120)  end)
	)
	,
inoutput as (
select 
	--input.*,
	--(case when input.AllowQty is null then ouput.MaterialDocType else input.MaterialDocType end) as MaterialDocType,
	--(case when input.AllowQty is null then ouput.MaterialDocTypeCode else input.MaterialDocTypeCode end) as MaterialDocTypeCode,  /*DocStatusName,*/
	--case when input.MaterialDocType is null or input.MaterialDocType='' then ouput.MaterialDocType else  input.MaterialDocType end as MaterialDocType,
	--MaterialDocType1,
	--PaperNoImport,
	--PaperNoExport,	
	--	CustomsDeclare ,
		--DateImport,		
		--DateExport,
	--isnull(input.RequireDate,ouput.RequireDate) as RequireDate,	
	--input.RequireDate  RequireDate,
	--input.RequireDate  ,
	--ouput.ConfirmDate,	
	--(case when input.inputqty is null then ouput.MaterialCode else input.MaterialCode end) as MaterialCode,
	--(case when input.inputqty is null then ouput.MaterialName else input.MaterialName end) as MaterialName,
	--(case when input.inputqty is null then ouput.MaterialUnit else input.MaterialUnit end) as MaterialUnit,

		case when input.MaterialCode is null or input.MaterialCode='' then ouput.MaterialCode else  input.MaterialCode end as MaterialCode,

	--isnull(input.MaterialCode,ouput.MaterialCode) as MaterialCode,
	--isnull(input.MaterialName,ouput.MaterialName) as MaterialName,
	--isnull(input.MaterialUnit,ouput.MaterialUnit) as MaterialUnit,
	
	-- exec usp_VVT_WarehouseInOut_check 'nguyentung','Vietnamese','2022-10-01','2022-10-31','','','GBAKAC-039'
	sum(isnull(input.inputqty,0))  as  inputqty,
	sum(isnull(ouput.outputqty,0)) as  outputqty
from input 
	full outer join ouput 
	on input.MaterialCode = ouput.MaterialCode  
	and (--input.RequireDate =  ouput.ConfirmDate or 
	input.MaterialCode is null or ouput.MaterialCode is null)
	group by 
	--case when input.MaterialDocType is null or input.MaterialDocType='' then ouput.MaterialDocType else  input.MaterialDocType end ,
	--MaterialDocType1,
	--PaperNoImport,
	--PaperNoExport,	
	--	CustomsDeclare ,
		--DateImport,		
		--DateExport,
 --input.RequireDate  , ouput.ConfirmDate,

			case when input.MaterialCode is null or input.MaterialCode='' then ouput.MaterialCode else  input.MaterialCode end 

	--isnull(input.MaterialName,ouput.MaterialName),
	--isnull(input.MaterialUnit,ouput.MaterialUnit)  
	)
	,
snapBegin as (
SELECT top (1000000)
      --replace(LotID,'-snap','') as LotID
      --,[CompanyCode]
      --,[WorkCenterCode]
      --[MaterialWarehouseCode]
      --,[MaterialLocationCode]
      [MaterialCode]
	  ,(select MaterialName from [SmartFactoryV2].[dbo].[STB_MaterialMaster]  with(nolock) where MaterialCode=mls.MaterialCode ) as MaterialName
	  --,convert(varchar(10),DATEADD(DAY,0,changedatetime),120) as ProductionDate
	  --,convert(varchar(10),DATEADD(DAY,0,changedatetime),120) as LotAttr10
      --,[MaterialStockAttribute]
      --,[StockAttrib1]
      --,[StockAttrib2]
      --,[StockAttrib3]      
      ,sum([CurrentQty]) as OriginalQTY
      --,[PickingQty]
	  ,(select MaterialUnit from [SmartFactoryV2].[dbo].[STB_MaterialMaster]  with(nolock) where MaterialCode=mls.MaterialCode ) as MaterialUnit
      
FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls  with(nolock) 
		where       LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and 
		(MaterialCode like @MaterialCode 	or @MaterialCode='*')	and  
		CONVERT(VARCHAR(10), ChangeDateTime,120) =  CONVERT(VARCHAR(10), @FromBasicDate1, 120)
		--	CONVERT(VARCHAR(10), ChangeDateTime,120) >=  CONVERT(VARCHAR(10), @FromBasicDate1, 120)
		--and CONVERT(VARCHAR(10), ChangeDateTime,120) <  CONVERT(VARCHAR(10), @ToBasicDate1, 120)
			group by MaterialCode --, convert(varchar(10),DATEADD(DAY,0,changedatetime),120) --,[StockAttrib1],[StockAttrib2],[StockAttrib3]--,MaterialUnit
		),
-- x1 AS
--( 	
--	select 'n=' as giatriN, 1 as n, @FromBasicDate as datetang
--	union all
--	select 'n=', (x1.n+1) as n , dateadd(day,1,x1.datetang) as datetang
--		from x1	 
--		where datetang<=@ToBasicDate
--)
--,
--snapBegin as(
--select 
----LotAttr10,
--MaterialCode,MaterialName,
--MaterialUnit, OriginalQTY, isnull(ProductionDate,datetang) ProductionDate
--from x1
--left outer join snapBegin1 on x1.datetang = snapBegin1.ProductionDate
--)
--,
snapEnd as (
SELECT top (1000000)
      --replace(LotID,'-snap','') as LotID
      --,[CompanyCode]
      --,[WorkCenterCode]
      --[MaterialWarehouseCode]
      --,[MaterialLocationCode]
      [MaterialCode]
	  --,(select MaterialName from [SmartFactoryV2].[dbo].[STB_MaterialMaster]  with(nolock) where MaterialCode=mls.MaterialCode ) as MaterialName
	  --,convert(varchar(10),DATEADD(DAY,0,changedatetime),120) as ProductionDate
	  --,convert(varchar(10),DATEADD(DAY,0,changedatetime),120) as LotAttr10
      --,[MaterialStockAttribute]
      --,[StockAttrib1]
      --,[StockAttrib2]
      --,[StockAttrib3]      
      ,sum([CurrentQty]) as LastQTY
      --,[PickingQty]
	  --,(select MaterialUnit from [SmartFactoryV2].[dbo].[STB_MaterialMaster]  with(nolock) where MaterialCode=mls.MaterialCode ) as MaterialUnit
      
FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls  with(nolock) 
		where       LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and (MaterialCode like @MaterialCode	or @MaterialCode='*')	 and  
		--	CONVERT(VARCHAR(10), ChangeDateTime,120) >  CONVERT(VARCHAR(10), @FromBasicDate1, 120)
		--and CONVERT(VARCHAR(10), ChangeDateTime,120) <=  CONVERT(VARCHAR(10), @ToBasicDate1, 120)
		CONVERT(VARCHAR(10), ChangeDateTime,120) =  CONVERT(VARCHAR(10), @ToBasicDate1, 120)
			group by MaterialCode --, convert(varchar(10),DATEADD(DAY,0,changedatetime),120) --,[StockAttrib1],[StockAttrib2],[StockAttrib3]--,MaterialUnit
		)
--,
--snapEnd as(
--select 
--LotAttr10,MaterialCode,MaterialName,
--MaterialUnit, LastQTY, isnull(ProductionDate,datetang) ProductionDate
--from x1
--left outer join snapEnd1 on x1.datetang = snapEnd1.ProductionDate
--)
,Ton_Kho_Khac as (
select --convert(varchar(10),dateadd(day,1,@ToBasicDate)) RequireDate ,
materialcode,max(MaterialWarehouseCode) MaterialDocType,sum(CurrentQty) as qty
FROM [SmartFactoryV2].[dbo].[STB_MaterialLotinfo] with(nolock) 
where (materialcode=@MaterialCode or @MaterialCode='*')--and MaterialWarehouseCode like '%VN%' 
and MaterialWarehouseCode  in ('HOLDING_VN_WH')
group by materialcode,MaterialWarehouseCode
)
,Ton_Kho_Khac1 as (

select materialcode,max(MaterialWarehouseCode) MaterialDocType,sum(CurrentQty) as qty

FROM [SmartFactoryV2].[dbo].[STB_MaterialLotinfo] with(nolock) 
where  
(materialcode=@MaterialCode or @MaterialCode='*')and MaterialWarehouseCode like '%VN%' 
and lotid in (
	select 	
	lotid
	from STB_MaterialWarehouseInOutHist with(nolock) 
	where 
	CreateDateTime>'2022-10-01' and CreateDateTime<= '2022-10-31' 
	and TargetMaterialWarehouseCode like '%VN%' and 
	TargetMaterialWarehouseCode 
	not in ( 'ROUTE_VN_WH' ,'NOI_DIA_VN','NUOC_NGOAI_VN','HEADQUARTER_VN_WH','MODULE_VN_WH')
	and isnull(ProcessedLotID,'') <> ''
	and lotid in (
				select lotid 
			FROM [SmartFactoryV2].[dbo].[STB_MaterialLotinfo] with(nolock) 
			where  MaterialWarehouseCode like '%VN%'
	)
	)	 
and MaterialWarehouseCode  in ('NG_RAW_VN_WH','HOLDING_VN_WH')
group by materialcode,MaterialWarehouseCode

)
--,Xuat_Kho_Khac as (
--select convert(varchar(10),dateadd(day,1,@ToBasicDate)) RequireDate ,materialcode,max(MaterialWarehouseCode) MaterialDocType,sum(CurrentQty) as qty
--FROM [SmartFactoryV2].[dbo].[STB_MaterialLotinfo] with(nolock) 
--where (materialcode=@MaterialCode or @MaterialCode='*')--and MaterialWarehouseCode like '%VN%' 
--and MaterialWarehouseCode  in ('NOI_DIA_VN','NUOC_NGOAI_VN','HEADQUARTER_VN_WH','MODULE_VN_WH')
--and ChangeDateTime between @FromBasicDate1 and @ToBasicDate1
--group by materialcode,MaterialWarehouseCode
--)
--,


--		,
--snap as (	
--	SELECT top (1000000)
--      --replace(LotID,'-snap','') as LotID
--      --,[CompanyCode]
--      --,[WorkCenterCode]
--      --[MaterialWarehouseCode]
--      --,[MaterialLocationCode]
--      [MaterialCode]
--	  ,(select MaterialName from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialName
--	  ,ProductionDate
--	  ,LotAttr10
--      --,[MaterialStockAttribute]
--      --,[StockAttrib1]
--      --,[StockAttrib2]
--      --,[StockAttrib3]      
--      ,sum([CurrentQty]) as OriginalQTY
--      --,[PickingQty]
--	  ,(select MaterialUnit from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialUnit
      
--FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls 
--		where       LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and --MaterialCode like @MaterialCode and  
--			CONVERT(VARCHAR(10), ChangeDateTime,120) =  CONVERT(VARCHAR(10), @FromBasicDate1,120)
--			group by MaterialCode , ProductionDate  ,LotAttr10--,[StockAttrib1],[StockAttrib2],[StockAttrib3]--,MaterialUnit
--		),
--snaplast as (	
--	  SELECT top (1000000)
--      --replace(LotID,'-snap','') as LotID
--      --,[CompanyCode]
--      --,[WorkCenterCode]
--      --[MaterialWarehouseCode]
--      --,[MaterialLocationCode]
--      [MaterialCode]
--	  ,ProductionDate
--	  ,LotAttr10
--	  ,(select MaterialName from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialName
--      --,[MaterialStockAttribute]
--      --,[StockAttrib1]
--      --,[StockAttrib2]
--      --,[StockAttrib3]      
--      ,sum([CurrentQty]) as LastQTY
--      --,[PickingQty]
--	  ,(select MaterialUnit from [SmartFactoryV2].[dbo].[STB_MaterialMaster] where MaterialCode=mls.MaterialCode ) as MaterialUnit
      
--FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls 
--		where       
--		LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and --MaterialCode like @MaterialCode and  
--			CONVERT(VARCHAR(10), ChangeDateTime,120) =  CONVERT(VARCHAR(10), @ToBasicDate1,120)
--			group by [MaterialCode],ProductionDate  ,LotAttr10--,[StockAttrib1],[StockAttrib2],[StockAttrib3]--,MaterialUnit
--		),


,solaptong as 
		(
				select 
				Ton_Kho_Khac.MaterialDocType,
		isnull(sna.MaterialCode,snala.MaterialCode) as MaterialCode,
		---isnull(sna.MaterialName,snala.MaterialName) as MaterialName,
		--isnull(sna.MaterialUnit,snala.MaterialUnit) as MaterialUnit,
		(isnull(OriginalQTY,0)) as OriginalQTY,
		(isnull(Ton_Kho_Khac.qty,0)) as tonkhokhacqty,
		(isnull(Ton_Kho_Khac1.qty,0)) as tonkhokhacqty1,
		(isnull(LastQTY,0)) --- sum(isnull(Xuat_Kho_Khac.qty,0))
		as LastQTY--,
		--case when sna.ProductionDate is null then DATEADD(DAY,-1,isnull(snala.ProductionDate,getdate() )) else sna.ProductionDate end as ProductionDate ,
		--convert(varchar(10),case when sna.LotAttr10 is null then DATEADD(DAY,-1,isnull(snala.LotAttr10,getdate() )) else sna.LotAttr10 end,120) as LotAttr10 --,
	   -- isnull(sna.LotAttr10,snala.LotAttr10)           as LotAttr10
from snapBegin sna   
	full outer join snapEnd snala  on snala.MaterialCode = sna.MaterialCode   
	left outer join Ton_Kho_Khac on (snala.MaterialCode=Ton_Kho_Khac.MaterialCode or sna.MaterialCode=Ton_Kho_Khac.MaterialCode) --and Ton_Kho_Khac.RequireDate=snala.LotAttr10
	left outer join Ton_Kho_Khac1 on (snala.MaterialCode=Ton_Kho_Khac1.MaterialCode or sna.MaterialCode=Ton_Kho_Khac1.MaterialCode) --and Ton_Kho_Khac.RequireDate=snala.LotAttr10
	--left outer join Xuat_Kho_Khac on (snala.MaterialCode=Xuat_Kho_Khac.MaterialCode) and Xuat_Kho_Khac.RequireDate=snala.LotAttr10

	
	--and DATEADD(DAY,0,sna.ProductionDate) = DATEADD(DAY,-1,snala.ProductionDate) 
--	group by 
	--Ton_Kho_Khac.MaterialDocType,
--		isnull(sna.MaterialCode,snala.MaterialCode)--,
		--isnull(sna.MaterialName,snala.MaterialName),
		--isnull(sna.MaterialUnit,snala.MaterialUnit),
		--isnull(sna.ProductionDate,snala.ProductionDate),
		--case when sna.ProductionDate is null then DATEADD(DAY,-1,isnull(snala.ProductionDate,getdate() )) else sna.ProductionDate end ,
		--convert(varchar(10),case when sna.LotAttr10 is null then DATEADD(DAY,-1,isnull(snala.LotAttr10,getdate() )) else sna.LotAttr10 end,120)

		)
		,
ola as  (
		select 
		isnull(sna.MaterialCode,inoutput.MaterialCode) as MaterialCode,
		--isnull(sna.MaterialName,inoutput.MaterialName) as MaterialName,
		--isnull(sna.MaterialUnit,inoutput.MaterialUnit) as MaterialUnit,
		(isnull(OriginalQTY,0)) as OriginalQTY,
		tonkhokhacqty,
		tonkhokhacqty1,
				--			(case when MaterialDocType='GR' and ConfirmDate > convert(varchar(10),convert(varchar(10),isnull(RequireDate,LotAttr10),120) ,120) + ' 10:30:00' 
			     --then max(isnull(LastQTY,0))+inputqty else max(isnull(LastQTY,0)) end) as LastQTY,
			(isnull(LastQTY,0)) as LastQTY,
			(isnull(inoutput.outputqty,0)) as outputqty,
			(isnull(inoutput.inputqty,0)) as inputqty,
			--inoutput.MaterialName,
			--(case when sna.LastQTY is null and sna.OriginalQTY is null 
			--then inoutput.MaterialName 	else isnull(sna.MaterialName,sna.MaterialName) 	end) as MaterialName,
			--(case when sna.LastQTY is null and sna.OriginalQTY is null 
			--then inoutput.MaterialUnit 	else isnull(sna.MaterialUnit,sna.MaterialUnit) 	end) as MaterialUnit,
			--inoutput.MaterialUnit
		MaterialDocType--,
	--max(PaperNoImport) as PaperNoImport,
	/*STUFF(
              (SELECT 
                ', ' + PaperNoExport 
               FOR XML PATH ('')
		      ), 1, 2, ''
             ) as PaperNoExport1,*/

-- max(PaperNoExport) as PaperNoExport,

	--	max(CustomsDeclare ) as CustomsDeclare,
		--max(DateImport) as DateImport,	
	--	max(DateExport) as DateExport,
		--convert(varchar(10),isnull(RequireDate,LotAttr10),120) as RequireDate,	
		-- ConfirmDate
from inoutput
	full outer join solaptong sna   
	on sna.MaterialCode = inoutput.MaterialCode --and inoutput.RequireDate=sna.LotAttr10
	--group by 
		--isnull(sna.MaterialCode,inoutput.MaterialCode),
		--isnull(sna.MaterialName,inoutput.MaterialName),
		--isnull(sna.MaterialUnit,inoutput.MaterialUnit),
		--sna.MaterialDocType,
	--(PaperNoImport),
	--(PaperNoExport),
	--	CustomsDeclare ,
		--(DateImport),	
		--(DateExport),
		--isnull(RequireDate,LotAttr10),
	--	ConfirmDate,
		--inputqty,
	--	(isnull(inoutput.inputqty,0))--,
		--convert(varchar(10),isnull(RequireDate,LotAttr10),120) --,
		--(isnull(OriginalQTY,0)),
		--			(isnull(inoutput.outputqty,0)) ,
		--	(isnull(inoutput.inputqty,0)) ,
		--	(isnull(LastQTY,0))

			--and sna.MaterialUnit=inoutput.MaterialUnit
			--full outer join snap snala  on snala.MaterialCode = inoutput.MaterialCode  --and snala.MaterialUnit=inoutput.MaterialUnit
			--full outer join ouput on snala.MaterialCode = ouput.MaterialCode
		)
--		,
--total as (
--			select				
--			(case when sna.MaterialCode is null then iop.MaterialCode else sna.MaterialCode end) as MaterialCode,
--				MM.MaterialUnit, 
--				MM.MaterialName,
--				isnull(iop.inputqty,0) as inputqty,
--				isnull(iop.outputqty,0) as outputqty,
--				isnull(sna.OriginalQTY,0) as OriginalQTY,
--				isnull(sna.LastQTY,0) as LastQTY				
--			FROM inoutput iop 	full join ola  sna  on iop.MaterialCode = sna.MaterialCode
--				left OUTER JOIN STB_MaterialMaster MM --WITH(NOLOCK)
--				ON MM.MaterialCode = iop.MaterialCode
--		 )
--select*from inoutput
--where MaterialCode='GBAKAC-032'
--select*from solaptong
--where MaterialCode='GBAKAC-032'
--inoutput








--,lastdata as (
select 
				ola.MaterialCode,
				MaterialUnit, 
				MaterialName,
				MMExtText03 as NameHQ,
				MMExtText04 as CodeHQ,
				max((inputqty)) as ALL_NHAP,
				max((outputqty)) as ALL_XUAT,
				max((OriginalQTY)) as  openninginventory,
				max((LastQTY)) as TON_CUOI_CO_BAN,
				max(tonkhokhacqty) as ALL_HOLDING,
				max(tonkhokhacqty1) as CHUYEN_KHO_TRONG_KY,
				max((LastQTY))  + max(tonkhokhacqty1) as ALL_Ton_CUOI_gom_Holding_va_Ton_Khac,
				max(((OriginalQTY+inputqty-outputqty))) as CheckLastQTY,
				max(((OriginalQTY+inputqty-outputqty-LastQTY-tonkhokhacqty1))) as Different,
	MaterialDocType--,
	-- 	PaperNoImport,
	--PaperNoExport,	
	--	CustomsDeclare ,
		--DateImport,		
		--DateExport,
	 --isnull(RequireDate,	 ConfirmDate) RequireDate
from ola
left outer join STB_MaterialMaster mm with(nolock) on ola.MaterialCode=mm.MaterialCode
--where (inputqty>0 or outputqty>0 or (OriginalQTY+inputqty-outputqty-LastQTY) <> 0)
--where MaterialCode='GBAKAC-032'
		group by 
			ola.MaterialCode,
				MaterialUnit, 
				MaterialName,
					MMExtText03 ,
				MMExtText04,
			MaterialDocType--,
		--		 PaperNo,	
			--	 RequireDate,	
			--	 ConfirmDate--,
		--		 inputqty
	--	 isnull(RequireDate,	 ConfirmDate) 
	--	order by  MaterialCode, RequireDate
	--)
--,last1 as (
--	select t1.MaterialCode,sum(t1.LastQTY) LastQTY
--	from lastdata t1 
--		cross apply (
--			select max(RequireDate) MAXDATE,materialcode
--			from lastdata  group by materialcode
--		) t2
--	where (t1.RequireDate = t2.MAXDATE ) and t1.materialcode=t2.materialcode
--	group by t1.materialcode
--)
--,last2 as (
--	select t1.MaterialCode,sum(t1.OriginalQTY) OriginalQTY
--	from lastdata t1 
--		cross apply (
--			select min(RequireDate) mindate,materialcode
--			from lastdata  
--			group by materialcode
--		) t2
--	where (t1.RequireDate = t2.mindate ) and t1.materialcode=t2.materialcode
--	group by t1.materialcode
--)
--select lastdata.MaterialCode,sum(lastdata.inputqty) inputqty, sum(lastdata.outputqty)outputqty,
--	last1.LastQTY,last2.OriginalQTY,max(MaterialDocType) MaterialDocType,
--	(last2.OriginalQTY + sum(lastdata.inputqty)  - sum(lastdata.outputqty)) as CheckLastQTY,
--	(last2.OriginalQTY + sum(lastdata.inputqty)  - sum(lastdata.outputqty)-last1.LastQTY) as Different
--from lastdata
-- join last1 on lastdata.MaterialCode=last1.MaterialCode
-- join last2 on lastdata.MaterialCode=last2.MaterialCode
--group by lastdata.MaterialCode,last1.LastQTY,last2.OriginalQTY

--select MaterialCode,sum( OriginalQTY) OriginalQTY from lastdata where  RequireDate = (select min(RequireDate) from lastdata group by MaterialCode )
--group by MaterialCode




		--order by MaterialDocType

		-- exec usp_VVT_WarehouseInOut_check 'nguyentung','Vietnamese','2020-05-30','2020-06-30','','',''
		
		/*
		select top 10000 *
			FROM
			STB_MaterialDocInfo
			where TargetCompanyCode='VVT' and SourceRouteCode is null'
			
			select*from STB_MaterialLotSnapshot
			where convert(varchar(10),changedatetime,120)='2020-07-02'
			
			
			select * from STB_MaterialDocInfo
			where  targetcompanycode='VVT' and TargetMaterialWarehouseCode<>'PROD_STBY_VN_WH'
			and convert(varchar(19),SourceProcessDateTime,120)>='2020-05-30 08:00:00'
			and convert(varchar(19),SourceProcessDateTime,120)<'2020-06-30 08:00:00'
			union
			select * from STB_MaterialDocInfo
			where  targetcompanycode='VVT' and TargetMaterialWarehouseCode<>'PROD_STBY_VN_WH'
			and convert(varchar(19),TargetProcessDateTime,120)>='2020-05-30 08:00:00'
			and convert(varchar(19),TargetProcessDateTime,120)<'2020-06-30 08:00:00'
									
			select * from STB_MaterialDocInfo
			where  targetcompanycode='VVT' and TargetMaterialWarehouseCode<>'PROD_STBY_VN_WH'
			and basicdate>='2020-05-30' and basicdate<='2020-06-30'
			*/
END



/*
	SELECT *
FROM [SmartFactoryV2].[dbo].[STB_MaterialLotSnapshot]  mls 
		where       LotID like '%-snap%' and MaterialWarehouseCode='ROH_VN_WH' and --MaterialCode like @MaterialCode and  
			CONVERT(VARCHAR(10), ChangeDateTime,120) =  CONVERT(VARCHAR(10), '2020-12-01',120)


			select *
from [STB_MaterialLotSnapshot]
where  convert(varchar(10),changedatetime,120)='2022-04-01'


*/


