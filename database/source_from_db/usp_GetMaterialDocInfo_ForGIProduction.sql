
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-09-04
-- Browsable : true
-- Group : 공통
-- Description: [F412] 생산출고 조회
-- Modified: 2019-06-10 자재그룹 추가 (주영진요청)
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialDocInfo_ForGIProduction]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL,
	@pFromBasicDate DATE = NULL,
	@pToBasicDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaterialDocNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocNo,'') = '' THEN '%' ELSE @pMaterialDocNo END
	DECLARE @FromBasicDate DATE = @pFromBasicDate
	DECLARE @ToBasicDate DATE = @pToBasicDate
    
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
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialDocType MDT WITH(NOLOCK)				ON (MDT.MaterialDocTypeCode = MDI.MaterialDocTypeCode)
			LEFT OUTER JOIN VW_DocStatus DS WITH(NOLOCK)							ON (DS.DocType = MDI.MaterialDocType AND DS.DocStatus = MDI.DocStatus)
			LEFT OUTER JOIN STB_CustomerInfo SOURCE_CUS WITH(NOLOCK)		ON (SOURCE_CUS.CustomerCode = MDI.SourceCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo SOURCE_CI WITH(NOLOCK)			ON (SOURCE_CI.CompanyCode = MDI.SourceCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo SOURCE_WCI WITH(NOLOCK)		ON (SOURCE_WCI.WorkCenterCode = MDI.SourceWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo SOURCE_RI WITH(NOLOCK)				ON (SOURCE_RI.RouteCode = MDI.SourceRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse SOURCE_MW WITH(NOLOCK)	ON (SOURCE_MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode)
			LEFT OUTER JOIN STB_CustomerInfo TARGET_CUS WITH(NOLOCK)			ON (TARGET_CUS.CustomerCode = MDI.TargetCustomerCode)
			LEFT OUTER JOIN STB_CompanyInfo TARGET_CI WITH(NOLOCK)			ON (TARGET_CI.CompanyCode = MDI.TargetCompanyCode)
			LEFT OUTER JOIN STB_WorkCenterInfo TARGET_WCI WITH(NOLOCK)		ON (TARGET_WCI.WorkCenterCode = MDI.TargetWorkCenterCode)
			LEFT OUTER JOIN STB_RouteInfo TARGET_RI WITH(NOLOCK)				ON (TARGET_RI.RouteCode = MDI.TargetRouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse TARGET_MW WITH(NOLOCK)	ON (TARGET_MW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode)
			LEFT OUTER JOIN VW_DocType DT											    ON DT.DocType = MDI.MaterialDocType			
	WHERE 1=1
			AND (MDI.MaterialDocNo LIKE @MaterialDocNo) 
			AND
			(
				((@FromBasicDate IS NULL) OR (MDI.BasicDate >= @FromBasicDate)) AND
				((@ToBasicDate IS NULL) OR (MDI.BasicDate <= @ToBasicDate))
			) 
			-- 2018-09-10 JGH 수정
			--MDI.MaterialDocTypeCode IN ('GI_PRODUCTION','MV_WH_ROUTE') AND
			AND  MDI.MaterialDocTypeCode IN ('GI_WH_ROUTE','MV_WH_ROUTE') 
			AND	MDI.DocStatus <> 'CREATE' 
			AND	MDI.IsCancel = 0
END
