-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016/05/23
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트재고정보조회 - 팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSparePartStockInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '' ELSE @pMachineCode END
    
	SELECT
			SPSI.SparePartCode,
			SPI.SparePartName,
			SPSI.SPWarehouseCode,
			SPWI.SPWarehouseName,
			SPSI.SPLocationCode,
			SPLI.SPLocationGroup,
			SPLI.SPLocationName,
			ISNULL(SPSI.CurrentStockQty,0) AS CurrentStockQty,
			SPI.SparePartSpec01,
			SPI.SparePartSpec02,
			SPI.SparePartSpec03,
			SPI.SparePartSpec04,
			SPI.SparePartSpec05,
			SPI.BasicUnitPrice,
			SPI.BasicDeliveryDay,
			SPI.BasicUnit,
			SPI.SafeQty,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup
	        
	FROM
			STB_SparePartStockInfo SPSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPSI.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPSI.SPWarehouseCode = SPLI.SPWarehouseCode
				AND SPSI.SPLocationCode = SPLI.SPLocationCode
			LEFT OUTER JOIN STB_MachineSparePartInfo MSPI WITH(NOLOCK)
				ON SPSI.SparePartCode = MSPI.SparePartCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON SPSI.SparePartCode = SPI.SparePartCode
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MSPI.MachineCode = MM.MachineCode
	WHERE
			((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode))
			AND ((@MachineCode = '*') OR (MSPI.MachineCode = @MachineCode))
	

END

