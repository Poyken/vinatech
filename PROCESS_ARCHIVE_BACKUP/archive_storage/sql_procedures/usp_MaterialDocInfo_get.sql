
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : true
-- Group : 공통
-- Description:	[F330] 자재입출 및 라벨발행화면 > Grid1.수불문서 / [F414] 사내창고이동의 상단탭 - 사내창고이동내역

-- Modified: 2019-03-11 Line정렬 (kilee)
-- 2020.07.06  LotID나 LotNo를 통해 수불문서를 찾을 수 있도록 검색 조건 추가 구보겸님 요청  By Jackaroe #200706
-- 2022.02.03  TradeDate, Remark Add

--  exec usp_MaterialDocInfo_get 'kilee','Korean','','2020-06-03','2020-06-05','','','','','','','','','VNT','','','','','','',''
--  exec usp_MaterialDocInfo_get 'kilee','Korean','','2021-02-01','2021-02-17','','MV_WH_WH','','','','','','','VVT','','','','','','',''            -- [F414] 화면에는 MV_WH_WH 박혀있음
-- =====================================================================================================================

CREATE PROCEDURE [dbo].[usp_MaterialDocInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialDocNo VARCHAR(20) = NULL,
						@pFromBasicDate DATE = NULL,
						@pToBasicDate DATE = NULL,
						@pMaterialDocType VARCHAR(20) = NULL,
						@pMaterialDocTypeCode VARCHAR(20) = NULL,
						@pDocStatus VARCHAR(20) = NULL,
						@pSourceCustomerCode VARCHAR(20) = NULL,
						@pSourceCompanyCode VARCHAR(20) = NULL,
						@pSourceWorkCenterCode VARCHAR(20) = NULL,
						@pSourceRouteCode VARCHAR(20) = NULL,
						@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
						@pTargetCustomerCode VARCHAR(20) = NULL,
						@pTargetCompanyCode VARCHAR(20) = NULL,
						@pTargetWorkCenterCode VARCHAR(20) = NULL,
						@pTargetRouteCode VARCHAR(20) = NULL,
						@pTargetMaterialWarehouseCode VARCHAR(20) = NULL,
						@pFromRequestPlanDate DATE = NULL,
						@pToRequestPlanDate DATE = NULL,
						@pMaterialCode varchar(50) = '',
						@pLotID VARCHAR(100) = NULL
						
AS

BEGIN

	SET NOCOUNT ON;
	DECLARE @MaterialDocNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '%' ELSE @pMaterialDocNo END
	DECLARE @FromBasicDate DATE = @pFromBasicDate
	DECLARE @ToBasicDate DATE = @pToBasicDate
	DECLARE @MaterialDocType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '%' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '%' ELSE @pMaterialDocTypeCode END
	DECLARE @DocStatus VARCHAR(20) = CASE WHEN ISNULL(@pDocStatus,'') = '' THEN '%' ELSE @pDocStatus END
	DECLARE @SourceCustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceCustomerCode,'') = '' THEN '%' ELSE @pSourceCustomerCode END
	DECLARE @SourceCompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceCompanyCode,'') = '' THEN '%' ELSE @pSourceCompanyCode END
	DECLARE @SourceWorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceWorkCenterCode,'') = '' THEN '%' ELSE @pSourceWorkCenterCode END
	DECLARE @SourceRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceRouteCode,'') = '' THEN '%' ELSE @pSourceRouteCode END
	DECLARE @SourceMaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSourceMaterialWarehouseCode,'') = '' THEN '%' ELSE @pSourceMaterialWarehouseCode END
	DECLARE @TargetCustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pTargetCustomerCode,'') = '' THEN '%' ELSE @pTargetCustomerCode END
	DECLARE @TargetCompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pTargetCompanyCode,'') = '' THEN '%' ELSE @pTargetCompanyCode END
	DECLARE @TargetWorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pTargetWorkCenterCode,'') = '' THEN '%' ELSE @pTargetWorkCenterCode END
	DECLARE @TargetRouteCode VARCHAR(20) = CASE WHEN ISNULL(@pTargetRouteCode,'') = '' THEN '%' ELSE @pTargetRouteCode END
	DECLARE @TargetMaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pTargetMaterialWarehouseCode,'') = '' THEN '%' ELSE @pTargetMaterialWarehouseCode END
	DECLARE @FromRequestPlanDate DATE = @pFromRequestPlanDate
	DECLARE @ToRequestPlanDate DATE = @pToRequestPlanDate
	DECLARE @MaterialCode varchar(50) = CASE WHEN RTRIM(@pMaterialCode) = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @LotID VARCHAR(100) = CASE WHEN ISNULL(@pLotID, '') = '' THEN '*' ELSE @pLotID END


	SELECT
			MDI.MaterialDocNo AS OldMaterialDocNo,
			MDI.MaterialDocNo,
			MDI.BasicDate,
			MDI.MaterialDocType,
			DT.DocTypeName AS DocTypeName,
			MDI.MaterialDocTypeCode,
			MDT.MaterialDocTypeName,
			MDI.DocStatus,
			DS.DocStatusName,
			
			MDI.SourceCustomerCode,
			SOURCE_CUS.CustomerName AS SOURCE_CustomerName,
			MDI.SourceCompanyCode,
			SOURCE_CI.CompanyName AS SOURCE_CompanyName,
			MDI.SourceWorkCenterCode,
			SOURCE_WCI.WorkCenterName AS SOURCE_WorkCenterName,
			MDI.SourceRouteCode,
			SOURCE_RI.RouteName AS SOURCE_RouteName,
			MDI.SourceMaterialWarehouseCode,
			SOURCE_MW.MaterialWarehouseName AS SOURCE_MaterialWarehouseName,
			SOURCE_MW.DefaultLocationCode      AS MaterialLocationCode,
			
			MDI.TargetCustomerCode,
			TARGET_CUS.CustomerName AS TARGET_CustomerName,
			MDI.TargetCompanyCode,
			TARGET_CI.CompanyName      AS TARGET_CompanyName,
			MDI.TargetWorkCenterCode,
			TARGET_WCI.WorkCenterName          AS TARGET_WorkCenterName,
			MDI.TargetRouteCode,
			TARGET_RI.RouteName                     AS TARGET_RouteName,
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
			MDI.MRMIExtText01,
			MDI.MRMIExtText02,
			MDI.MRMIExtText03,
			MDI.MRMIExtText04,	
			MDI.MRMIExtText05,
			MDI.MRMIExtText06,
			MDI.MRMIExtText07,
			MDI.MRMIExtText08,
			MDI.MRMIExtText09,
			MDI.MRMIExtText10,
			MDI.MRMIExtText11,
			MDI.MRMIExtText12,
			MDI.MRMIExtText13,
			MDI.MRMIExtText14,
			MDI.MRMIExtText15,
			MDI.MRMIExtBit01,
			MDI.MRMIExtBit02,
			MDI.MRMIExtBit03,
			MDI.MRMIExtBit04,    --CBU
			MDI.IsUploadERP,
			MDI.IsCancel,
			MDI.CancelUserID,
			MDI.CancelReason,
			MDI.CancelDateTime,
			MDI.CreateDateTime,
			MDI.CreateUserID,
			MDI.ChangeDateTime,
			MDI.ChangeUserID	
			,MDI.MRMIExtText02        -- invoice		
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select max(VendorLotNo  )   from STB_MaterialDocDetail with(nolock) where MaterialDocNo = MDI.MaterialDocNo and VendorLotNo   is not null) else '' end  as VendorLotNo 
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select max(MRMDExtText01)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText01 is not null) else '' end   as MRMDExtText01  -- no of importing
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select max(MRMDExtText02)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText02 is not null) else '' end   as MRMDExtText02  -- no of exporting
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select max(MRMDExtText03)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText03 is not null) else '' end   as MRMDExtText03  -- no of customs declare
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select convert(date,max(MRMDExtText04),120)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText04 is not null) else getdate() end   as MRMDExtText04  -- date of importing
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select convert(date,max(MRMDExtText05),120)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText05 is not null) else getdate() end   as MRMDExtText05  -- date of exporting
			,case when @pProcessUserID like '%hop%' or @pProcessUserID like '%khoa%' or @pProcessUserID like '%minh%' or @pProcessUserID like '%tha%' then (select max(MRMDExtText06)   from STB_MaterialDocDetail with(nolock)  where MaterialDocNo = MDI.MaterialDocNo and MRMDExtText06 is not null) else '' end   as MRMDExtText06  -- kind of paper declare
			,MDI.TradeDate	--220203 TradeDate Add
			,MDI.Remark		--220203 Remark Add
			
	FROM    STB_MaterialDocInfo MDI WITH(NOLOCK)   
			LEFT OUTER JOIN STB_MaterialDocType MDT WITH(NOLOCK)				ON (MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode)
			LEFT OUTER JOIN VW_DocStatus DS WITH(NOLOCK)				        ON (DS.DocType = MDI.MaterialDocType AND DS.DocStatus = MDI.DocStatus)
			LEFT OUTER JOIN STB_CustomerInfo SOURCE_CUS WITH(NOLOCK)		ON (SOURCE_CUS.CustomerCode = MDI.SourceCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo SOURCE_CI WITH(NOLOCK)		    ON (SOURCE_CI.CompanyCode = MDI.SourceCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo SOURCE_WCI WITH(NOLOCK)	ON (SOURCE_WCI.WorkCenterCode = MDI.SourceWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo SOURCE_RI WITH(NOLOCK)				ON (SOURCE_RI.RouteCode = MDI.SourceRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse SOURCE_MW WITH(NOLOCK)	ON (SOURCE_MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode)
			LEFT OUTER JOIN STB_CustomerInfo TARGET_CUS WITH(NOLOCK)		ON (TARGET_CUS.CustomerCode = MDI.TargetCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo TARGET_CI WITH(NOLOCK)			ON (TARGET_CI.CompanyCode = MDI.TargetCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo TARGET_WCI WITH(NOLOCK)	ON (TARGET_WCI.WorkCenterCode = MDI.TargetWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo TARGET_RI WITH(NOLOCK)				    ON (TARGET_RI.RouteCode = MDI.TargetRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse TARGET_MW WITH(NOLOCK)	ON (TARGET_MW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode)
			LEFT OUTER JOIN VW_DocType DT				                                ON DT.DocType = MDI.MaterialDocType			
	WHERE 1=1
			AND (MDI.MaterialDocNo LIKE @MaterialDocNo) 
			AND
						(
									((@FromBasicDate IS NULL) OR (MDI.BasicDate >= @FromBasicDate)) 	 
							AND 	((@ToBasicDate IS NULL)     OR (MDI.BasicDate <= @ToBasicDate))
						 ) 
			--AND MDI.RequestPlanDate BETWEEN @FromRequestPlanDate AND  @ToRequestPlanDate
			AND (MDI.MaterialDocType LIKE @MaterialDocType) 
			AND (MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode) 
			AND (MDI.DocStatus LIKE @DocStatus) 
			AND (MDI.SourceCustomerCode IS NULL OR MDI.SourceCustomerCode LIKE @SourceCustomerCode) 
			AND (MDI.SourceCompanyCode IS NULL OR MDI.SourceCompanyCode LIKE @SourceCompanyCode) 
			AND (MDI.SourceWorkCenterCode IS NULL OR MDI.SourceWorkCenterCode LIKE @SourceWorkCenterCode) 
			AND (MDI.SourceRouteCode IS NULL OR MDI.SourceRouteCode LIKE @SourceRouteCode) 
			AND (MDI.SourceMaterialWarehouseCode IS NULL OR MDI.SourceMaterialWarehouseCode LIKE @SourceMaterialWarehouseCode) 
			AND (MDI.TargetCustomerCode IS NULL OR MDI.TargetCustomerCode LIKE @TargetCustomerCode) 
			AND (MDI.TargetCompanyCode IS NULL OR MDI.TargetCompanyCode LIKE @TargetCompanyCode) 
			AND (MDI.TargetWorkCenterCode IS NULL OR MDI.TargetWorkCenterCode LIKE @TargetWorkCenterCode) 
			AND (MDI.TargetRouteCode IS NULL OR MDI.TargetRouteCode = @TargetRouteCode) 
			AND (MDI.TargetMaterialWarehouseCode IS NULL OR MDI.TargetMaterialWarehouseCode LIKE @TargetMaterialWarehouseCode) 
			AND MDI.IsCancel = 0		
				
			-- #200706
			AND (@LotID = '*' OR
					MDI.MaterialDocNo IN (   SELECT MaterialDocNo
														FROM STB_MaterialDocDetail
													   WHERE MaterialDocDetailNo IN (
																								  SELECT MaterialDocDetailNo 
																									FROM STB_MaterialDocLotInfo 
																								   WHERE (LotID = @LotID OR LotNo = @LotID)
																								  )
										               )
				   )

END
