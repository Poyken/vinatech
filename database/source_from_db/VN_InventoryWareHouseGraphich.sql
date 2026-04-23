CREATE PROCEDURE [dbo].[VN_InventoryWareHouseGraphich]
	@pFromBasicDate DATE = NULL,
	@pToBasicDate DATE = NULL,
	@pMaterialDocType VARCHAR(20) = NULL,
	@pMaterialDocTypeCode VARCHAR(20) = NULL,
	@pMaterialCode varchar(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromBasicDate DATE = @pFromBasicDate
	DECLARE @ToBasicDate DATE = @pToBasicDate
	DECLARE @FromBasicDate1   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromBasicDate, 120) + ' 10:30:00'    
	DECLARE @ToBasicDate1      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToBasicDate)), 120) + ' 10:30:00'

	DECLARE @MaterialDocType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '%' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '%' ELSE @pMaterialDocTypeCode END
	DECLARE @MaterialCode varchar(50) = CASE WHEN RTRIM(@pMaterialCode) = '' THEN '*' ELSE @pMaterialCode END
    
	;with data1 as (
	SELECT
			MDI.MaterialDocNo AS OldMaterialDocNo,
			MDI.MaterialDocNo,
			MDI.BasicDate,
			MDI.MaterialDocType,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName as MaterialDocTypeName1 ,
			MDI.DocStatus,

			(case when MDI.MaterialDocType='GR' and MDT.MaterialDocTypeName='G/R BY ORDER'	and  (DocStatusName='CREATE' or  DocStatusName='ARRIVAL') then 'Fix G/R' else DocStatusName end) 
			as DocStatusName,
			(case when MDI.MaterialDocType='GR' and MDT.MaterialDocTypeName='G/R BY ORDER'	and  (DocStatusName='CREATE' or  DocStatusName='ARRIVAL') then 'IQC' else '' end) 
			as  StatusPos,
			MaterialTypeCode,	
			MaterialUnit,		
			isnull(MQI.DecisionResult,
					(
					    select  top 1 DecisionResult   from	STB_MaterialQcInfo where MaterialqcNo in
						(
					   	    select top 1 MaterialIqcNo from		 STB_MaterialDocDetail where MaterialDocDetailNo in
								(select  MaterialDocDetailNo from	STB_MaterialDocLotInfo  where LotID = mdli.LotID )
						) and DecisionResult is not null and DecisionResult<>'' 
					)
				) as IQCResult,	
			--case when MDI.MaterialDocType<>'MOVE' then 
			--  --1 is
			--  (select  top 1 DecisionResult  from	STB_MaterialQcInfo where MaterialqcNo in (
			--	select MaterialIqcNo from		 STB_MaterialDocDetail where MaterialDocDetailNo = MDD.MaterialDocDetailNo) 
			--  ) 
			--  else
			--  ' '
			--   --2 is
			 -- 	(
				----select	STUFF((
				--	    select  max(DecisionResult)   from	STB_MaterialQcInfo where MaterialqcNo = (
				--	   	    select top 1 MaterialIqcNo from		 STB_MaterialDocDetail where MaterialDocDetailNo in
				--     (select  MaterialDocDetailNo from	STB_MaterialDocLotInfo  where LotID = mdli.LotID )
				--))
			--		--FOR XML PATH('')), 1, LEN(','), '') AS IQCResult)
			--end 
			--as IQCResult,
					
			MDI.SourceCustomerCode,
			SOURCE_CUS.CustomerName AS SOURCE_CustomerName,
			MDI.SourceCompanyCode,
			SOURCE_CI.CompanyName AS SOURCE_CompanyName,
			MDI.SourceWorkCenterCode,
			SOURCE_WCI.WorkCenterName AS SOURCE_WorkCenterName,
			MDI.SourceRouteCode,
			SOURCE_RI.RouteCode AS SOURCE_RouteName,
			MDI.SourceMaterialWarehouseCode,
			SOURCE_MW.MaterialWarehouseName AS SOURCE_MaterialWarehouseName,
			SOURCE_MW.DefaultLocationCode AS MaterialLocationCode,
			
			MDI.TargetCustomerCode,
			TARGET_CUS.CustomerName AS TARGET_CustomerName,
			MDI.TargetCompanyCode,
			TARGET_CI.CompanyName AS TARGET_CompanyName,
			MDI.TargetWorkCenterCode,
			TARGET_WCI.WorkCenterName AS TARGET_WorkCenterName,
			MDI.TargetRouteCode,
			TARGET_RI.RouteName AS TARGET_RouteName,
			MDI.TargetMaterialWarehouseCode,
			TARGET_MW.MaterialWarehouseName AS TARGET_MaterialWarehouseName,

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

			MDD.MaterialCode,
			MM.MaterialName,
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
			LEFT OUTER JOIN VW_DocStatus DS WITH(NOLOCK)
				ON (DS.DocType = MDI.MaterialDocType AND DS.DocStatus = MDI.DocStatus)
			LEFT OUTER JOIN STB_CustomerInfo SOURCE_CUS WITH(NOLOCK)
				ON (SOURCE_CUS.CustomerCode = MDI.SourceCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo SOURCE_CI WITH(NOLOCK)
				ON (SOURCE_CI.CompanyCode = MDI.SourceCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo SOURCE_WCI WITH(NOLOCK)
				ON (SOURCE_WCI.WorkCenterCode = MDI.SourceWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo SOURCE_RI WITH(NOLOCK)
				ON (SOURCE_RI.RouteCode = MDI.SourceRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse SOURCE_MW WITH(NOLOCK)
				ON (SOURCE_MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode)
			LEFT OUTER JOIN STB_CustomerInfo TARGET_CUS WITH(NOLOCK)
				ON (TARGET_CUS.CustomerCode = MDI.TargetCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo TARGET_CI WITH(NOLOCK)
				ON (TARGET_CI.CompanyCode = MDI.TargetCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo TARGET_WCI WITH(NOLOCK)
				ON (TARGET_WCI.WorkCenterCode = MDI.TargetWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo TARGET_RI WITH(NOLOCK)
				ON (TARGET_RI.RouteCode = MDI.TargetRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse TARGET_MW WITH(NOLOCK)
				ON (TARGET_MW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode)
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialDocLotInfo mdli   WITH(NOLOCK)
				on MDD.MaterialDocDetailNo = mdli.MaterialDocDetailNo 
			LEFT OUTER JOIN STB_MaterialQcInfo MQI   WITH(NOLOCK)
				on MQI.MaterialQcNo = MDD.MaterialIqcNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MDD.MaterialCode
			
	WHERE 
			MDI.TargetCompanyCode='VVT' and 
			--((MDI.BasicDate > @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) or (MDI.BasicDate = @FromBasicDate and isnull(MDI.SourceProcessDateTime,MDI.TargetProcessDateTime)>=@FromBasicDate1) or (MDI.BasicDate > @ToBasicDate and isnull(MDI.SourceProcessDateTime,MDI.TargetProcessDateTime)<=@ToBasicDate1) ) AND 
			(MDI.BasicDate >= @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) AND 
			(MDI.MaterialDocType LIKE @MaterialDocType) AND 
			(MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode) AND 
			MDI.IsCancel = 0 and 
			(MDI.SourceRouteCode  is null or MDI.SourceRouteCode not like '%V-28%') 
			)	
		,
		data3 as (
		 select LotID, MaterialDocTypeName1 
		 from data1
		 where  MaterialDocTypeCode = 'GR_RETURN_MATERIAL' 
		)

		select 
			*,	
			 (case when data1.MaterialDocType='MOVE' then 			 
				 isnull(data3.MaterialDocTypeName1,data1.MaterialDocTypeName1)
			else 
				data1.MaterialDocTypeName1
			end ) 
			as 
			MaterialDocTypeName 

			from data1 
				left outer join data3 
					on data1.LotID=data3.LotID
END
