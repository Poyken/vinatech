

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 전개정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpTargetMaterial_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMrpTargetNo VARCHAR(20) = NULL,
	@pMrpNo VARCHAR(20) = NULL,
	@pCustomerCode VARCHAR(20) = NULL,
	@pIncludeOrdered BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MrpTargetNo VARCHAR(20) = CASE WHEN ISNULL(@pMrpTargetNo,'') = '' THEN '*' ELSE @pMrpTargetNo END
	DECLARE @MrpNo VARCHAR(20) = CASE WHEN ISNULL(@pMrpNo,'') = '' THEN '*' ELSE @pMrpNo END
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '*' ELSE @pCustomerCode END
	DECLARE @IncludeOrdered BIT = ISNULL(@pIncludeOrdered, 1)

    
	SELECT
			MTM.MrpTargetNo AS OldMrpTargetNo,
			MTM.MrpTargetNo,
			MTM.MrpNo,
			MTM.MaterialCode,
			MM.MaterialName,
			MM.MaterialSpec,
			PG.ProductGroupName,
			MTM.CalcQty,
			MTM.AdjustQty,
			MTM.FixedQty,
			MM.MaterialUnit,
			MTM.ProdPlanDate,
			MTM.AgvGrDay,
			MTM.PlanOrderDate,
			MTM.CustomerCode,
			CI.CustomerName,
			MTM.MaterialOrderNo,
			MTM.MaterialOrderItemNo,
			MM.BasicGrQty,
			MVM.BasicDeliveryDay,
			MTM.PlanGrDate,
			MVM.UnitPriceQty,
			MVM.UnitPrice,
			MTM.CreateDateTime,
			MTM.CreateUserID,
			MTM.ChangeDateTime,
			MTM.ChangeUserID
	FROM
			STB_MrpTargetMaterial MTM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MTM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH (NOLOCK)
				ON (CI.CustomerCode = MTM.CustomerCode)
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH (NOLOCK)
				ON (MVM.MaterialCode = MTM.MaterialCode AND MVM.CustomerCode = MTM.CustomerCode)
			LEFT OUTER JOIN STB_ProductGroup PG
			    ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
			((@MrpTargetNo = '*') OR (MTM.MrpTargetNo = @MrpTargetNo)) AND
			--((@MrpNo = '*') OR (MTM.MrpNo = @MrpNo)) AND
			MTM.MrpNo = @MrpNo AND
			((@CustomerCode = '*') OR (MTM.CustomerCode = @CustomerCode)) AND
			((@IncludeOrdered = 1) OR (ISNULL(MTM.MaterialOrderItemNo,'') = ''))
	ORDER BY
			MTM.CustomerCode
END
