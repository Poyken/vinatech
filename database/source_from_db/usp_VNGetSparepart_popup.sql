
-- usp_VNGetSparepart_popup '','VVT_F3'
CREATE procedure [dbo].[usp_VNGetSparepart_popup]
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	
	 DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END


	 ;with table1 as
	(
	
		select SparePartCode,SPWarehouseCode,SPLocationCode,WorkCenterCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		from 
		(select SparePartCode,SPWarehouseCode,SPLocationCode,WorkCenterCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			  sum(CurrentStockQty) as CurrentStockQty
		 from STB_VNSparePartStockInfo_TEST where WorkCenterCode =@WorkCenterCode
		 
		 group by SparePartCode,SPWarehouseCode,SPLocationCode,WorkCenterCode) aa
		 group by SparePartCode,SPWarehouseCode,SPLocationCode,WorkCenterCode

	),  table2 as (
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
			--SPI.Position,

			CASE
				WHEN @pWorkCenterCode ='VVT_F2' THEN SPI.PositionBG
				ELSE SPI.Position
			END AS Position,

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
			 t2.CurrentStockQtyKho1 as CurrentStockQtyKho1,
			 t2.CurrentStockQtyKho2 as CurrentStockQtyKho2,
			 t2.CurrentStockQty as CurrentStockQty
		
			from STB_VNSparePartInfo SPI WITH(NOLOCK)
						left join table1 t2  WITH(NOLOCK) ON SPI.SparePartCode = t2.SparePartCode   and t2.WorkCenterCode =@WorkCenterCode
						LEFT JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK) ON  t2.SPWarehouseCode = SPWI.SPWarehouseCode and t2.WorkCenterCode = SPWI.WorkCenterCode
						LEFT  JOIN STB_SparePartLocationInfo LSP WITH(NOLOCK)  ON t2.SPLocationCode = LSP.SPLocationCode

						where  (SPI.IsUsed = 1)
	)select  A.SparePartCode,
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
			-- A.CurrentStockQtyKho1 as CurrentStockQtyKho1,
			--A.CurrentStockQtyKho2,
			--A.CurrentStockQty
			from table2 A 	
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


	
		
END