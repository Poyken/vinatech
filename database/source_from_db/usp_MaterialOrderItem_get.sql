

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	Tab2 자재발주상세(디테일)정보 조회
-- Modified: 
-- =============================================
-- exec usp_MaterialOrderItem_get '','','20190626000011'

CREATE PROCEDURE [dbo].[usp_MaterialOrderItem_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialOrderNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @MaterialOrderNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialOrderNo,'') = '' THEN '' ELSE @pMaterialOrderNo END

	
	SELECT
	        MOI.MaterialOrderItemNo AS OldMaterialOrderItemNo,
	        MOI.MaterialOrderItemNo,
	        MOI.MaterialOrderNo       AS OldMaterialOrderNo,
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
	        ISNULL(MOI.IsCancel,0)         AS IsCancel,
	        MOI.MaterialOrderRemainQty,
			MOI.PlanGrDate,
	        
	        MOI.MOIExtText01,
	        MOI.MOIExtText02,
	        MOI.MOIExtText03,

			MOI.MrpTargetNo,
	        MOI.CreateDateTime,
	        MOI.CreateUserID,
	        MOI.ChangeDateTime,
	        MOI.ChangeUserID,

			MV.CustomerCode,
			SC.FaxNo,
			SC.TelNo,
			SC.AddressText,
			SC.ContactTel1,
			SC.ContactName1 
	FROM
	                              STB_MaterialOrderItem MOI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MaterialMaster MM    WITH(NOLOCK)		ON MOI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT      WITH(NOLOCK)		ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG     WITH(NOLOCK)		ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialOrder MO    WITH(NOLOCK)		ON MOI.MaterialOrderNo = MO.MaterialOrderNo

			LEFT OUTER JOIN STB_MaterialVendorMapping MV WITH(NOLOCK)			ON MV.MaterialCode = MO.MaterialOrderNo
			LEFT OUTER JOIN STB_CustomerInfo                SC WITH(NOLOCK)			ON SC.CustomerCode = MO.CustomerCode

	WHERE 1=1
	   AND ((@MaterialOrderNo = '*') OR (MOI.MaterialOrderNo = @MaterialOrderNo))
   -- AND ((MO.MOCreateType = 'MANUAL'))

END


-- SELECT * FROM STB_MaterialOrderItem
-- SELECT * FROM STB_MaterialMaster
-- SELECT CustomerCode, * FROM STB_CustomerInfo
-- SELECT CustomerCode, * FROM STB_MaterialVendorMapping