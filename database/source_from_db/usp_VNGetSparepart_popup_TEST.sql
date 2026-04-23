
-- usp_VNGetSparepart_popup_TEST '','VVT_F1'
CREATE procedure [dbo].[usp_VNGetSparepart_popup_TEST]
	@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
          select  A.SparePartCode,
			A.SparePartName,
			A.SparePartSpec01,
			A.SparePartSpec02,
			A.SparePartSpec03,
			A.SparePartSpec04,
			A.SparePartSpec05,
			A.BasicUnitPrice,
			A.BasicDeliveryDay,
			A.BasicUnit,
			A.SafeQty,
			A.Position,
	        A.LastDeliveryVendor,
	        A.CompatibilityGroup,
		--	,SPLocationCodeKho1,SPLocationNameKho1,SPLocationGroupKho1,SPLocationCodeKho2,SPLocationName2,SPLocationGroupKho2,
			sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2,sum(CurrentStockQty) as CurrentStockQty
			from
(
SELECT
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
			SPI.Position,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup,
	        
	        --SPSI.SPLocationCode,
			--LSP.SPLocationName,
			--'Kho2_ViTriA'  as SPLocationCode,
			--'Kho2_ViTriA'  as SPLocationName,
			'Kho1_ViTriA' as SPLocationCodeKho1,
			'Kho1_ViTriA' as SPLocationNameKho1,
		     null SPLocationGroupKho1,
			'Kho2_ViTriA' as SPLocationCodeKho2,
			'Kho2_ViTriA' as SPLocationName2,
		    null SPLocationGroupKho2,
			case when SPWI.SPWarehouseCode = 'Kho1' then (SPSI.CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			case when SPWI.SPWarehouseCode = 'Kho2' then (SPSI.CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			(SPSI.CurrentStockQty) as CurrentStockQty
			
				FROM
						STB_VNSparePartInfo SPI WITH(NOLOCK)
						LEFT  JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK) ON SPI.SparePartCode = SPSI.SparePartCode 
						LEFT JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK) ON  SPSI.SPWarehouseCode = SPWI.SPWarehouseCode
						LEFT  JOIN STB_SparePartLocationInfo LSP WITH(NOLOCK)  ON SPSI.SPLocationCode = LSP.SPLocationCode
					WHERE 
		---	(('VVT' = '*') OR (SPWI.CompanyCode = 'VVT')) AND
	   --     (('VVT_F1' = '*') OR (SPWI.WorkCenterCode = 'VVT_F1')) AND
	        --(('Kho2' = '*') OR (SPWI.SPWarehouseCode = 'Kho2')) AND
				SPWI.WorkCenterCode = @pWorkCenterCode AND 
				--SPI.SparePartCode='CSP000617' and
	        (SPI.IsUsed = 1) ) A

			group by A.SparePartCode,
			A.SparePartName,
			A.SparePartSpec01,
			A.SparePartSpec02,
			A.SparePartSpec03,
			A.SparePartSpec04,
			A.SparePartSpec05,
			A.BasicUnitPrice,
			A.BasicDeliveryDay,
			A.BasicUnit,
			A.SafeQty,
			A.Position,
	        A.LastDeliveryVendor,
	        A.CompatibilityGroup
		--	,SPLocationCodeKho1,SPLocationNameKho1,SPLocationGroupKho1,SPLocationCodeKho2,SPLocationName2,SPLocationGroupKho2

END