-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2018-07-25
-- Description : 출고의뢰 미출하 상세내역
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetNotDeliveryOfSalesOrder]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			SO.SalesOrderNo,
			SO.OrderType,
			SOT.OrderTypeName,
			SO.OrderDate,
			SO.CustomerCode,
			CI.CustomerName,
			SO.IsFixedOrder,
			SO.ApprovalUserID,
			SO.ApprovalDateTime,
			SO.RequestDeliveryDate,
			SO.DestInfomation,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			SOI.ModelCode,
			MM.MaterialName AS ModelName,
			SOI.OrderQty,
			SOI.FixedQty,
			SOI.GIPlanQty,
			SOI.GIFixQty,
			SOI.DeliveryDate,
			MDI.MaterialDocNo,
			MDI.DocStatus,
			DS.DocStatusName,
			MDI.BasicDate,
			MDI.RequestPlanDate,
			MDI.SourceCompanyCode,
			MDI.SourceWorkCenterCode,
			MDI.SourceMaterialWarehouseCode,
			MW.MaterialWarehouseName AS SourceMaterialWarehouseName,			
			MDD.PickingAssignQty,
			MDD.PickingQty,
			MDD.ProcessFixQty,
			MDI.RequestDateTime,
			MDI.RequestUserID,
			MDI.IsRequestApproval,
			MDI.RequestApprovalDateTime,
			MDI.RequestApprovalUserID,
			SOI.CreateDateTime,
			SOI.CreateUserID
	FROM
			STB_SalesOrderItem SOI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SalesOrder SO WITH(NOLOCK)
				ON	SO.SalesOrderNo = SOI.SalesOrderNo
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON	CI.CustomerCode = SO.CustomerCode
			LEFT OUTER JOIN VW_SalesOrderType SOT
				ON	SOT.OrderTypeCode = SO.OrderType
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = SOI.ModelCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.OrderDetailNo = SOI.SOISequence
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
				ON	MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN VW_DocStatus DS
				ON	DS.DocType = 'GI' AND DS.DocStatus = MDI.DocStatus				
	WHERE
			SO.IsCancel = 0 AND
			(	
				MDI.MaterialDocNo IS NULL OR
				(
					MDI.MaterialDocTypeCode = 'GI_SALES' AND
					MDI.DocStatus <> 'FIX'
				)
			)
	ORDER BY
			SO.SalesOrderNo
END
