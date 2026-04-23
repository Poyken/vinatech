
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-27
-- Browsable : true
-- Group : 자재관리
-- Description:	자재 입출고 이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialDocDetailHistory]
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
	DECLARE @MaterialDocType VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocType,'') = '' THEN '%' ELSE @pMaterialDocType END
	DECLARE @MaterialDocTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialDocTypeCode,'') = '' THEN '%' ELSE @pMaterialDocTypeCode END
	DECLARE @MaterialCode varchar(50) = CASE WHEN RTRIM(@pMaterialCode) = '' THEN '*' ELSE @pMaterialCode END
    
	SELECT
			MDI.MaterialDocNo AS OldMaterialDocNo,
			MDI.MaterialDocNo,
			MDI.BasicDate,
			MDI.MaterialDocType,
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

			MDD.MaterialCode,
			MM.MaterialName,
			MDD.RequestQty,
			MDD.AllowQty,
			MDD.ProcessFixQty,
			MDD.InspectionType,
			MDD.PickingAssignQty,
			MDD.PickingQty,
			MDD.StockAttrib1,
			MDD.StockAttrib2,
			MDD.StockAttrib3,
			MDD.UnitPrice,
			MDD.UnitPriceQty
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
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MDD.MaterialCode
			
	WHERE
			(MDI.BasicDate >= @FromBasicDate AND MDI.BasicDate <= @ToBasicDate) AND
			(MDI.MaterialDocType LIKE @MaterialDocType) AND
			(MDI.MaterialDocTypeCode LIKE @MaterialDocTypeCode) AND
			MDI.IsCancel = 0
END
