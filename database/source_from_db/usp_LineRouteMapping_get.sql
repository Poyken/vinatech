-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 생산관리공통
-- Description:	라인공정구성정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineRouteMapping_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pLineCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
    DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '' ELSE @pLineCode END
	
	
	SELECT
			@LineCode AS LineCode,
			RI.RouteCode,
			RI.RouteName,
			CASE 
				WHEN LRM.RouteCode IS NULL THEN CONVERT(BIT, 0)
				ELSE CONVERT(BIT, 1)
			END AS IsUsed,
			LRM.RouteIndex,
			CASE 
				WHEN LRM.IsProcessLineProduct IS NULL THEN CONVERT(BIT, 0)
				ELSE LRM.IsProcessLineProduct
			END AS IsProcessLineProduct,
			LRM.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			LRM.GILocationCode,
			ML.MaterialLocationName AS GILocationName,
			LRM.GRWarehouseCode,
			MW_GR.MaterialWarehouseName AS GRWarehouseName,
			LRM.GRLocationCode,
			ML2.MaterialLocationName AS GRLocationName
	FROM
			STB_RouteInfo RI WITH (NOLOCK)
			LEFT OUTER JOIN STB_LineRouteMapping LRM WITH (NOLOCK)
				ON (LRM.LineCode = @LineCode AND LRM.RouteCode = RI.RouteCode)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH (NOLOCK)
				ON (MW.MaterialWarehouseCode = LRM.MaterialWarehouseCode)
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON ML.MaterialLocationCode = LRM.GILocationCode
			LEFT OUTER JOIN STB_MaterialLocation ML2 WITH(NOLOCK)
				ON ML2.MaterialLocationCode = LRM.GRLocationCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW_GR WITH (NOLOCK)
				ON (MW_GR.MaterialWarehouseCode = LRM.GRWarehouseCode)
	WHERE
			RI.CompanyCode = @CompanyCode AND
			RI.WorkCenterCode = @WorkCenterCode
	ORDER BY
			RI.RouteCode
			
   

END