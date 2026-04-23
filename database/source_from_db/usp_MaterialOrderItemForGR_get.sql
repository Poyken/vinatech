
-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-18
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주상세정보 조회((입고대상발주자재만 조회)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialOrderItemForGR_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialOrderNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @MaterialOrderNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialOrderNo,'') = '' THEN '' ELSE @pMaterialOrderNo END

	
	SELECT
	        MOI.MaterialOrderItemNo AS OldMaterialOrderItemNo,
			MOI.MaterialOrderItemNo AS OrderDetailNo,
	        MOI.MaterialOrderItemNo,
	        MOI.MaterialOrderNo AS OldMaterialOrderNo,
	        MOI.MaterialOrderNo,
	        MOI.MaterialCode,
	        MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
			MM.AvgGrDay,
			MM.IsPurchase,
			MM.IsOrder,
			MM.IsClosed,
			MM.BeforeMaterialCode,
			MM.MMExtText01,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04,
			MM.MMExtText05,
			MM.MMExtText06,
			MM.MMExtText07,
			MM.MMExtText08,
			MM.MMExtText09,
			MM.MMExtText10,
			MM.MMExtInt01,
			MM.MMExtInt02,
			MM.MMExtInt03,
			MM.MMExtInt04,
			MM.MMExtInt05,
			MM.MMExtReal01,
			MM.MMExtReal02,
			MM.MMExtReal03,
			MM.MMExtReal04,
			MM.MMExtReal05,
			MM.MMExtLongText01,
			MM.MMExtLongText02,
			MM.MMExtLongText03,
			MM.MMExtLongText04,
			MM.MMExtLongText05,
			MM.MMExtImage01,
			MM.MMExtImage02,
			MM.MMExtImage03,
			MM.MMExtImage04,
			MM.MMExtImage05,
	        
	        MOI.MaterialStockAttribute,
	        MOI.MaterialAttribute,
	        MOI.StockAttrib1,
	        MOI.StockAttrib2,
	        MOI.StockAttrib3,
	        
	        MOI.MaterialOrderQty,
	        MOI.MaterialOrderUnitPriceQty,
	        MOI.MaterialOrderUnitPrice,
	        MOI.MaterialOrderTotalPrice,
	        MOI.MaterialOrderItemDesc,
	        ISNULL(MOI.IsCancel,0) AS IsCancel,
	        MOI.MaterialOrderRemainQty,
			MOI.MaterialOrderRemainQty AS DeliveryPlanQty,
	        MOI.PlanGrDate,

	        MOI.MOIExtText01,
	        MOI.MOIExtText02,
	        MOI.MOIExtText03,
	        MOI.CreateDateTime,
	        MOI.CreateUserID,
	        MOI.ChangeDateTime,
	        MOI.ChangeUserID,
			
			
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
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialOrder MO WITH(NOLOCK)
				ON MOI.MaterialOrderNo = MO.MaterialOrderNo
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
				ON MOI.MaterialCode = MVM.MaterialCode
				AND MO.CustomerCode = MVM.CustomerCode				
	WHERE
	        (MOI.MaterialOrderNo = @MaterialOrderNo)  AND
			(ISNULL(MOI.MaterialOrderRemainQty,0) > 0)

END
