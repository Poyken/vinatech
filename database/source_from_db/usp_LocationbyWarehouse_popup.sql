
CREATE PROCEDURE [dbo].[usp_LocationbyWarehouse_popup] 
	@pSPWarehouseCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '' ELSE @pSPWarehouseCode END
	
	SELECT
			SPSI.SPLocationCode,
			SPLI.SPLocationName,
			SPLI.SPLocationGroup,
			ISNULL(SPSI.CurrentStockQty,0) AS CurrentStockQty
	FROM
			STB_SparePartStockInfo SPSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPSI.SPWarehouseCode = SPLI.SPWarehouseCode
				AND SPSI.SPLocationCode = SPLI.SPLocationCode
			
	WHERE
			((@SPWarehouseCode = '*') OR (SPSI.SPWarehouseCode = @SPWarehouseCode)) 
			AND ((SPLI.IsUsed = 1))

END

