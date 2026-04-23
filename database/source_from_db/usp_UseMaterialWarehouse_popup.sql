-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 자재 소요공정 창고 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_UseMaterialWarehouse_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@MaterialCode VARCHAR(50) = @pMaterialCode

	SELECT
			MW.MaterialWarehouseCode,
			MW.MaterialWarehouseName
	FROM
			STB_ProductionOrderBom POB WITH(NOLOCK)
			INNER JOIN STB_LineRouteMapping LRM WITH(NOLOCK)
				ON	LRM.RouteCode = POB.RouteCode
			INNER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.MaterialWarehouseCode = LRM.MaterialWarehouseCode
	WHERE
			POB.PONo = @PONo AND
			POB.ChildMaterialCode = @MaterialCode
END
