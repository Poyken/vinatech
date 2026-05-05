

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-27
-- Browsable : true
-- Group : 자재관리
-- Description: 발주서 생성을 위한 미발주 MRP 를 조회합니다.
-- Modified: exec usp_GetMrpTargetMaterial_ForOrder_TEST'','','2018-01-01','2021-12-30'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMrpTargetMaterial_ForOrder_TEST]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE,
	@pMaterialCode VARCHAR(20) = NULL,
	@pIsAll BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = @pFromDate,
			@ToDate DATE = DATEADD(DD, 1, @pToDate),
			@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END,
			@IsALL BIT = ISNULL(@pIsAll,0)
    
	--DECLARE @test varchar(max) = @FromDate
	-- raiserror(@test,16,1)
	SELECT
			MTM.MrpTargetNo AS OldMrpTargetNo,
			MTM.MrpTargetNo,
			MTM.MrpNo,
			MTM.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			(
				SELECT
						SUM(MS.StockQty)
				FROM
						STB_MaterialStock MS WITH(NOLOCK)
				WHERE
						MS.MaterialCode = MTM.MaterialCode AND
						MS.MaterialStockAttribute = 'NORMAL'
			) AS CurrentQty,	-- 현재고
			(
				SELECT
						SUM(MOI.MaterialOrderRemainQty)
				FROM
						STB_MaterialOrder MO WITH(NOLOCK)
						INNER JOIN STB_MaterialOrderItem MOI WITH(NOLOCK)
							ON	MOI.MaterialOrderNo = MO.MaterialOrderNo
				WHERE
						MO.IsFinished = 0 AND
						MOI.MaterialCode = MTM.MaterialCode
						
			) AS NotGrQty,		-- 미입고
			(
				SELECT
						SUM(POB.MaterialUnitTotalUsedQty)
				FROM
						STB_ProductionOrderInfo PO WITH(NOLOCK)
						INNER JOIN STB_ProductionOrderBom POB WITH(NOLOCK)
							ON	POB.PONo = PO.PONo
				WHERE
						PO.IsFix = 1 AND
						PO.IsFinish = 0 AND
						PO.IsCancel = 0 AND
						POB.ChildMaterialCode = MTM.MaterialCode
			) AS TotalPOUsedQty,	-- 총소요량
			MTM.CalcQty,
			MTM.AdjustQty,
			MTM.FixedQty,
			MTM.FixedQty AS OrderQty,
			MTM.ProdPlanDate,
			MTM.AgvGrDay,
			MTM.PlanOrderDate,
			MTM.PlanGrDate,
			MTM.CustomerCode,
			CI.CustomerName,
			MVM.UnitPrice,
			MTM.MaterialOrderNo,
			MTM.MaterialOrderItemNo,
			MTM.CreateDateTime,
			MTM.CreateUserID,
			UI.UserName AS CreateUserName,
			MM.IsInternalProd,	-- 가공품여부			
			MTM.ChangeDateTime,
			MTM.ChangeUserID
	FROM
			STB_MrpMaster MRM WITH(NOLOCK)			
			INNER JOIN STB_MrpTargetMaterial MTM WITH(NOLOCK)
				ON	MTM.MrpNo = MRM.MrpNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MTM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON	CI.CustomerCode = MTM.CustomerCode
			LEFT OUTER JOIN VW_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = MTM.CreateUserID
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)
				ON MVM.MaterialCode = MTM.MaterialCode
				AND MVM.CustomerCode = MTM.CustomerCode
	WHERE
			MRM.IsFixedMRP = 1 AND
			ISNULL(MRM.IsCancel,0) = 0 AND
			((@IsALL = 1) OR (@FromDate <= MTM.PlanOrderDate AND MTM.PlanOrderDate < @ToDate)) AND
			((@MaterialCode = '*') OR (MTM.MaterialCode = @MaterialCode)) AND
			(MTM.MaterialOrderItemNo IS NULL OR MTM.MaterialOrderItemNo = '')
	ORDER BY
			MTM.CustomerCode,
			MTM.MaterialCode,
			MTM.PlanOrderDate

END