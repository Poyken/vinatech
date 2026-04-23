
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 팝업
-- Description:	자재발주상세정보 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrderItem_popup] 
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pCustomerCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkcenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkcenterCode,'') = '' THEN '*' ELSE @pWorkcenterCode END
    DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END
    DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
    
    
    
    SELECT
			MOI.MaterialOrderItemNo,
	        MOI.MaterialOrderNo,
	        
	        MOI.MaterialCode,
	        MM.MaterialName,
			MM.MaterialNameL,
			
			MOI.MaterialStockAttribute,
--			MOI.MaterialAttribute,
			MOI.StockAttrib1,
			MOI.StockAttrib2,
			MOI.StockAttrib3,
			
			MO.CompanyCode,
			C.CompanyName,
	        C.CompanyNameL,
	        
			MO.WorkCenterCode,
			WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        
			MO.CustomerCode,
			CI.CustomerName,
	        CI.CustomerNameL,
	        
			MO.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
	        MW.MaterialWarehouseNameL,
	        
	        MOI.MaterialOrderQty,
	        MOI.MaterialOrderUnitPriceQty,
	        MOI.MaterialOrderUnitPrice,
	        MOI.MaterialOrderTotalPrice,
	        MOI.MaterialOrderItemDesc,
	        ISNULL(MOI.IsCancel,0) AS IsCancel,
	        MOI.MaterialOrderRemainQty,
	        MOI.MOIExtText01,
	        MOI.MOIExtText02,
	        MOI.MOIExtText03,
	        
	        ISNULL(MVM.InspectionType,'None') AS InspectionType,
	        MVM.InspectionLevel,
	        MVM.AQL,
	        MOI.MaterialOrderUnitPriceQty AS UnitPriceQty,
	        MOI.MaterialOrderUnitPrice AS UnitPrice,
	        MVM.BasicDeliveryDay
	FROM
			STB_MaterialOrderItem MOI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MOI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialOrder MO WITH(NOLOCK)
				ON MOI.MaterialOrderNo = MO.MaterialOrderNo
			LEFT OUTER JOIN STB_MaterialWareHouse MW WITH(NOLOCK)
				ON MO.MaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON MO.CustomerCode = CI.CustomerCode
			LEFT OUTER JOIN STB_CompanyInfo C WITH(NOLOCK)
				ON MO.CompanyCode = C.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MO.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
				ON MOI.MaterialCode = MVM.MaterialCode
				AND MO.CustomerCode = MVM.CustomerCode
	WHERE
			((@CompanyCode = '*') OR (MO.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MO.WorkCenterCode = @WorkCenterCode)) AND
	        ((@CustomerCode = '*') OR (MO.CustomerCode = @CustomerCode)) AND
	        ((@MaterialWarehouseCode = '*') OR (MO.MaterialWarehouseCode = @MaterialWarehouseCode)) AND
	        ((MO.OrderStatus NOT IN ('REQUEST', 'FINISH'))) AND
	        (MOI.IsCancel <> 1) AND
	        (MO.IsAllCancel <> 1)
	        --(MVM.IsUsed = 1)
END
