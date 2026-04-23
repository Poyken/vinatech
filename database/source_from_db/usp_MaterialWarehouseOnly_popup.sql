-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-03
-- Browsable : true
-- Group : 팝업
-- Description:	자재창고정보 팝업 신규
-- Modified:
-- exec usp_MaterialWarehouseOnly_popup '', '', 'ROH_WH, ROH_VN_WH'
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouseOnly_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	--@pMaterialWarehouseCode VARCHAR(20) = NULL
	@pCostGroupString VARCHAR(MAX) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	--DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')


	SELECT
	        MW.MaterialWarehouseCode,
	        MW.CompanyCode,
	        MW.WorkCenterCode,
	        MW.MaterialWarehouseName,
	        MW.MaterialWarehouseNameL,
	        MW.MaterialWarehouseDesc,
	        MW.MaterialWarehouseDescL,
	        MW.WHExtText01,
	        MW.WHExtText02,
	        MW.WHExtText03,
	        MW.WHExtText04,
	        MW.WHExtText05
	FROM  STB_MaterialWarehouse MW WITH(NOLOCK)	        
	WHERE 1=1
			AND ((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) 
			AND ((@WorkCenterCode = '*') OR (MW.WorkCenterCode = @WorkCenterCode))
			 AND MW.MaterialWarehouseCode  IN ('ROH_VN_WH', 'ROH_WH')

			 --AND MW.MaterialWarehouseCode  IN (
				--														   SELECT MaterialWarehouseCode 
				--															FROM STB_MaterialWarehouse 
				--														   WHERE 1=1 
				--															 AND MaterialWarehouseCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
				--															 --AND MaterialWarehouseCode IN ('ROH_VN_WH', 'ROH_WH')
				--														  )
            			

			--AND ((@MaterialWarehouseCode = '*') OR (MW.MaterialWarehouseCode = @MaterialWarehouseCode))          -- 2020.09.03 추가
END

