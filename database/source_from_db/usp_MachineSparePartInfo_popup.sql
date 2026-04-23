-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016/05/19
-- Browsable : true
-- Group : 팝업
-- Description:	스페어파트정보 조회(입고) - 팝업용
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSparePartInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '*' ELSE @pMachineCode END
    
    
    --Machine별로 동일한 스페어파트코드가 등록된 것이 있어 distinct 적용함
    SELECT	DISTINCT 
			--MSPI.MachineCode,
			MSPI.SparePartCode,
			SPI.SparePartName
			--SPI.SparePartSpec01,
			--SPI.SparePartSpec02,
			--SPI.SparePartSpec03,
			--SPI.SparePartSpec04,
			--SPI.SparePartSpec05,
			--SPI.BasicUnitPrice,
			--SPI.BasicDeliveryDay,
			--SPI.BasicUnit,
			--SPI.SafeQty,
	  --      SPI.LastDeliveryVendor,
	  --      SPI.CompatibilityGroup,
	        
	  --      MSPI.ChangePlanType,
	  --      MSPI.ChangePlan,
	  --      MSPI.LastChangeDate
	FROM
			STB_MachineSparePartInfo MSPI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MachineMaster MM WITH(NOLOCK)
				ON MSPI.MachineCode = MM.MachineCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON MSPI.SparePartCode = SPI.SparePartCode
			
	WHERE
			((@CompanyCode = '*') OR (MM.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (MM.WorkCenterCode = @WorkCenterCode)) AND
	        ((@MachineCode = '*') OR (MSPI.MachineCode = @MachineCode))
			
    /*
    SELECT
			Master.SparePartCode,
			Master.SparePartName,
			Master.SparePartSpec01,
			Master.SparePartSpec02,
			Master.SparePartSpec03,
			Master.SparePartSpec04,
			Master.SparePartSpec05,
			Master.BasicUnitPrice,
			Master.BasicDeliveryDay,
			Master.BasicUnit,
			Master.SafeQty,
	        Master.LastDeliveryVendor,
	        Master.CompatibilityGroup,
	        
	        SPBL.SPLocationCode,
	        SPLI.SPLocationName,
	        SPLI.SPLocationGroup,
	        
	        SPSI.CurrentStockQty
	FROM
			(
				SELECT
						SPWI.CompanyCode,
						SPWI.WorkCenterCode,
						SPWI.SPWarehouseCode,
						SPWI.SPWarehouseName,
						SPI.SparePartCode,
						SPI.SparePartName,
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
						SPI.CompatibilityGroup,
						SPI.IsUsed
				FROM
						STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
						CROSS JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				WHERE
						((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) AND
						((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode)) AND
						((@SPWarehouseCode = '*') OR (SPWI.SPWarehouseCode = @SPWarehouseCode)) AND
						(SPI.IsUsed = 1)
			)Master		
			LEFT OUTER JOIN STB_SparePartBasicLocation SPBL WITH(NOLOCK)
				ON Master.SparePartCode = SPBL.SparePartCode
				AND Master.SPWarehouseCode = SPBL.SPWarehouseCode	
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON Master.SPWarehouseCode = SPLI .SPWarehouseCode
				AND SPBL.SPLocationCode = SPLI.SPLocationCode
			LEFT OUTER JOIN STB_SparePartStockInfo SPSI WITH(NOLOCK)
				ON Master.SPWarehouseCode = SPSI.SPWarehouseCode
				AND SPBL.SPLocationCode = SPSI.SPLocationCode
				AND Master.SparePartCode = SPSI.SparePartCode
	WHERE
			((@CompanyCode = '*') OR (Master.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (Master.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseCode = '*') OR (Master.SPWarehouseCode = @SPWarehouseCode)) AND
	        (Master.IsUsed = 1)
	*/
END

