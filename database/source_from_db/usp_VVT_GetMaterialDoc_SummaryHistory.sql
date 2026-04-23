
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2023-07-06
-- Browsable : true
-- Group : 자재관리
-- Description:	자재 입출고 이력조회
-- Modified: Mr.Tung                                usp_VVT_GetMaterialDoc_SummaryHistory '','','2023-06-01','2023-08-06','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_GetMaterialDoc_SummaryHistory] -- exec usp_VVT_GetMaterialDoc_SummaryHistory '','','2023-09-01','2023-09-11','','',''
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
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
	DECLARE @FromBasicDate1   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromBasicDate, 120) + ' 10:00:00'    
	DECLARE @ToBasicDate1      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToBasicDate)), 120) + ' 10:00:00'

	DECLARE @MaterialDocType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '%' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '%' ELSE @pMaterialDocTypeCode END
	DECLARE @MaterialCode varchar(50) = CASE WHEN RTRIM(@pMaterialCode) = '' THEN '*' ELSE @pMaterialCode END
    
	;with data1 as (
	    SELECT
			--MDI.MaterialDocNo AS OldMaterialDocNo,
			--MDI.MaterialDocNo,
			--MDI.BasicDate,
			MDI.MaterialDocType,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName as MaterialDocTypeName1 ,
			MDI.DocStatus,
			DocStatusName as StatusPos,
			(case when MDI.MaterialDocType='GR' and MDT.MaterialDocTypeName='G/R BY ORDER'	and  (DocStatusName='CREATE' or  DocStatusName='ARRIVAL') then 'Fix G/R' else DocStatusName end) 
			as DocStatusName,
			MaterialTypeCode,	
			MaterialUnit,		
			MQI.DecisionResult,
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
			
			MDI.TotalPlanPrice,
			MDI.TotalActualPrice,

			MDD.MaterialCode,
			MM.MaterialName,
			MDD.RequestQty   as RequestQty1,
			MDD.AllowQty as AllowQty1,
			MDD.ProcessFixQty as ProcessFixQty1
			,sum(isnull(mdli.StockQty,isnull(MDD.RequestQty,0)))     as RequestQty
			 ,sum(isnull(mdli.StockQty,isnull(MDD.ProcessFixQty,0)))  as ProcessFixQty
			 ,sum(isnull(mdli.StockQty,isnull(MDD.AllowQty,0)))       as AllowQty,
			--MDD.VendorLotNo,			
			--MDD.InspectionType,
			--MDD.PickingAssignQty,
			--MDD.PickingQty,
			--MDD.StockAttrib1,
			MDI.MRMIExtText02,
			--MDD.StockAttrib2,
			MDD.UnitPrice,
			MDD.UnitPriceQty
			--MDD.MaterialDocDetailNo,
			--MM.MaterialTypeCode,	
			--MM.MaterialUnit,
			--DS.DocStatusName as DocStatusName1
			--,mdli.LotID
			,	MDD.MRMDExtText01,-- as PaperNoImport,
			MDD.MRMDExtText02,-- as PaperNoExport,
			MDD.MRMDExtText03,-- as CustomsDeclaration,
			--DATEADD(DAY,1,convert(date,isnull(MDD.MRMDExtText04,mdd.createdatetime),120)) as MRMDExtText04,			--MODEL
			DATEADD(DAY,1,isnull(substring(MDD.MRMDExtText04,1,10),convert(varchar(10),mdd.createdatetime,120))) as MRMDExtText04,
			DATEADD(DAY,1,isnull(substring(MDD.MRMDExtText05,1,10),convert(varchar(10),mdd.createdatetime,120))) as MRMDExtText05
			
			,(tigia.muack) as TiGiaUsd
			,dinhkho.taikhoan
			,dinhkho.makho
			,InfoEcus.*
			,case when InfoEcus.MaGiaoHang in ('DDU', 'DDP', 'DAP') then NgayDangKy else isnull(NgayVanDon,NgayInvoice) end as NgayApDung
			--,case when SO_HDTM in ('DDU', 'DDP', 'DAP') then NGAY_DK    else isnull(NGAY_VAN_DON,NGAY_HDTM) end as NgayApDung 

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
			outer apply (select top 1 * from stb_vietnam_invoiceEcus  WITH(NOLOCK)  where soinvoice = MDI.MRMIExtText02 and LUONG = MDD.RequestQty) InfoEcus

			outer apply (
				select top 1 muack from Stb_vvt_TiGiaHoiDoai   WITH(NOLOCK) 
				where bankname='vietcombank' and [type]='usd' and DATEPART(HOUR,createdatetime) between 8 and 12  
				and convert(date,createdatetime) = 
				convert(date,(case when InfoEcus.SoInvoice in ('DDU', 'DDP', 'DAP') 
									then InfoEcus.NgayDangKy 
									else isnull(InfoEcus.NgayVanDon,InfoEcus.NgayInvoice) end))
				--order by id
			) tigia
			outer apply (select top 1 * from [dbo].[fn_VVT_AccountTypeWarehouseType]() where materialcode=MDD.materialcode) dinhkho
			
	 WHERE 
			MDI.TargetCompanyCode='VVT' and 
			MDT.MaterialDocTypeName not like '%INTERNAL%' and
			((MDI.BasicDate > @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) 
			or (MDI.BasicDate = @FromBasicDate and isnull(MDI.SourceProcessDateTime,MDI.RequestDateTime)>=@FromBasicDate1) 
			or (MDI.BasicDate > @ToBasicDate and isnull(MDI.SourceProcessDateTime,MDI.RequestDateTime)<=@ToBasicDate1) ) AND 
			--(MDI.BasicDate >= @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) AND 
			(MDI.MaterialDocType LIKE @MaterialDocType) AND 
			(MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode) AND 
			MDI.IsCancel = 0 and 
			(MDI.SourceRouteCode  is null or MDI.SourceRouteCode <> 'V-28') 
			and MDI.MaterialDocTypeCode <> 'GR_RETURN_MATERIAL' 
	 group by 
				MDI.MaterialDocType,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName ,
			MDI.DocStatus,
			DocStatusName 
			,(case when MDI.MaterialDocType='GR' and MDT.MaterialDocTypeName='G/R BY ORDER'	and  (DocStatusName='CREATE' or  DocStatusName='ARRIVAL') then 'Fix G/R' else DocStatusName end) 
			,MaterialTypeCode,	
			MaterialUnit,		
			MQI.DecisionResult,
						
			MDI.TotalPlanPrice,
			MDI.TotalActualPrice,

			MDD.MaterialCode,
			MM.MaterialName,
						MDD.RequestQty   ,
			MDD.AllowQty ,
			MDD.ProcessFixQty ,

			MDI.MRMIExtText02,
			--MDD.StockAttrib2,
			MDD.UnitPrice,
			MDD.UnitPriceQty
						 ,	MDD.MRMDExtText01,-- as PaperNoImport,
			MDD.MRMDExtText02,-- as PaperNoExport,
			MDD.MRMDExtText03,-- as CustomsDeclaration,
			DATEADD(DAY,1,isnull(substring(MDD.MRMDExtText04,1,10),convert(varchar(10),mdd.createdatetime,120))) ,
			DATEADD(DAY,1,isnull(substring(MDD.MRMDExtText05,1,10),convert(varchar(10),mdd.createdatetime,120))) 

			, tigia.muack
			,dinhkho.taikhoan
			,dinhkho.makho
			,NgayDangKy, NgayVanDon, NgayInvoice, SoInvoice, MaGiaoHang, SOTK, MA_LH, DV_DT, MA_PTTT, MA_NT, TYGIA_VND, TONGTGKB, TONGTGTT, TONGTG_HDTM, MA_SAC_THUE, TEN_SAC_THUE, TONG_THUE, MA_SAC_THUE2, TEN_SAC_THUE2, TONG_THUE2, MA_SAC_THUE3, TEN_SAC_THUE3, TONG_THUE3, _DHangMDDKID, _DToKhaiMDID, MA_NPL_SP, MA_PHU, TEN_HANG, MA_DVT, LUONG, DGIA_KB, LOAITSXNK, TS_XNK, TS_TTDB, TS_VAT, MA_NT_THUE_XNK, THUE_XNK, THUE_TTDB, THUE_VAT, GHI_CHU, MA_THKE, TongTienThue

			)	
		--,
		--data3 as (
		-- select 
		-- --LotID, 
		-- MaterialDocTypeName1 as MaterialDocTypeName3
		-- from data1
		-- where  MaterialDocTypeCode = 'GR_RETURN_MATERIAL' 
		--)

		select 
			*,	
			(case when MaterialDocType='GR' and MaterialDocTypeName1='G/R BY ORDER'	and  (StatusPos='CREATE' or  StatusPos='ARRIVAL') then 'Fix G/R' else StatusPos end) 
			as DocStatusName,

			/*isnull(*/ DecisionResult /*, 
					( 
					    select  top 1 DecisionResult   from	STB_MaterialQcInfo where MaterialqcNo in 
						( 
					   	    select top 1 MaterialIqcNo from		 STB_MaterialDocDetail where MaterialDocDetailNo in 
								(select  MaterialDocDetailNo from	STB_MaterialDocLotInfo  where LotID = data1.LotID ) 
						) and DecisionResult is not null and DecisionResult<>'' 
					) 
				) */ as IQCResult,	

			 --(case when data1.MaterialDocType='MOVE' then 
			--	 isnull(data3.MaterialDocTypeName3,data1.MaterialDocTypeName1) 
			--else  
				data1.MaterialDocTypeName1 
			--end ) 
			as 
			MaterialDocTypeName 

			from data1 
				--left outer join data3 
					--on data1.LotID=data3.LotID 

END


---   select top 10000 *  from Stb_vvt_TiGiaHoiDoai   WITH(NOLOCK) 

---   select  * from [dbo].[fn_VVT_AccountTypeWarehouseType]()