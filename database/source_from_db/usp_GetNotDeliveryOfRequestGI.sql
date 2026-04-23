-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2018-07-25
-- Description : 출고의뢰 미출하 상세내역
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetNotDeliveryOfRequestGI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			MDI.MaterialDocNo,
			MDI.DocStatus,
			DS.DocStatusName,
			MDI.BasicDate,
			MDI.RequestPlanDate,
			MDI.SourceCompanyCode,
			MDI.SourceWorkCenterCode,
			MDI.SourceMaterialWarehouseCode,
			MW.MaterialWarehouseName AS SourceMaterialWarehouseName,
			MDI.TargetCustomerCode,
			CI.CustomerName AS TargetCustomerName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MDD.MaterialCode,
			MM.MaterialName,
			MDD.RequestQty,
			MDD.PickingAssignQty,
			MDD.PickingQty,
			MDD.ProcessFixQty,
			MDI.RequestDateTime,
			MDI.RequestUserID,
			MDI.IsRequestApproval,
			MDI.RequestApprovalDateTime,
			MDI.RequestApprovalUserID,
			MDI.CreateDateTime,
			MDI.CreateUserID
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN VW_DocStatus DS
				ON	DS.DocType = 'GI' AND DS.DocStatus = MDI.DocStatus
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON	CI.CustomerCode = MDI.TargetCustomerCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MDI.MaterialDocTypeCode = 'GI_SALES' AND
			MDI.DocStatus <> 'FIX'
	ORDER BY
			MDI.MaterialDocNo
END
