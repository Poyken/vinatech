-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : 생산출고 출고창고 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionGISourceWarehouse_popup]
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
			STB_MaterialMaster MM WITH(NOLOCK)
			INNER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.RequestProductGroupCode LIKE '%' + MM.ProductGroupCode + '%'			
	WHERE
			MM.MaterialCode = @MaterialCode AND
			MW.IsUsed = 1

END