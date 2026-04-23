-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 팝업
-- Description:	자재창고로케이션정보 팝업(해당창고의 로케이션만 가져오기)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialLocationForWarehouse_popup]
	@pMaterialWarehouseCode VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '' ELSE @pMaterialWarehouseCode END
	
	SELECT
			ML.MaterialLocationCode,
			ML.MaterialLocationName,
			ML.MaterialLocationNameL
	FROM
			STB_MaterialLocation ML
	WHERE
			ML.MaterialWarehouseCode = @MaterialWarehouseCode
END
