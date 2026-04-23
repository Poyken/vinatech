-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 팝업
-- Description:	자재창고정보 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialWarehouse_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

	IF @WorkCenterCode = 'VNT_F1' BEGIN
		SET @WorkCenterCode = @WorkCenterCode + ',VNT_F4'
	END

	IF @WorkCenterCode = 'VNT_F4' BEGIN
		SET @WorkCenterCode = @WorkCenterCode + ',VNT_F1'
	END
		

	IF @WorkCenterCode = 'VVT_F1'
		BEGIN

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
			FROM
					STB_MaterialWarehouse MW WITH(NOLOCK)
	        
			WHERE
					((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (MW.WorkCenterCode IN (SELECT item FROM dbo.fnSplitToTable(',', @WorkCenterCode))))

			--UNION ALL
			--SELECT
			--		MW.MaterialWarehouseCode,
			--		MW.CompanyCode,
			--		MW.WorkCenterCode,
			--		MW.MaterialWarehouseName,
			--		MW.MaterialWarehouseNameL,
			--		MW.MaterialWarehouseDesc,
			--		MW.MaterialWarehouseDescL,
			--		MW.WHExtText01,
			--		MW.WHExtText02,
			--		MW.WHExtText03,
			--		MW.WHExtText04,
			--		MW.WHExtText05
			--FROM
			--		STB_MaterialWarehouse MW WITH(NOLOCK)
			--WHERE
			--		MW.MaterialWarehouseCode = 'MODULE_BG2_WH'

		END

	ELSE
		BEGIN
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
			FROM
					STB_MaterialWarehouse MW WITH(NOLOCK)
	        
			WHERE
					((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (MW.WorkCenterCode IN (SELECT item FROM dbo.fnSplitToTable(',', @WorkCenterCode))))
		END
END

