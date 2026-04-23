-- =============================================
-- Author: ngoloan
-- Create date: 2021/01/08

-- =============================================
CREATE PROCEDURE [dbo].[usp_VNSparepartStock_popup_040624]
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pSPWarehouseCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END

	;with table1 as
	(


				select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		from 
		(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			  sum(CurrentStockQty) as CurrentStockQty
		 from STB_VNSparePartStockInfo_TEST where WorkCenterCode =@WorkCenterCode
		 
		 group by SparePartCode,SPWarehouseCode) aa
		 group by SparePartCode

	)

	SELECT
				distinct		SPI.SparePartCode,
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
	        
	        SPSI.SPLocationCode,
			LSP.SPLocationName,
			--'Kho2_ViTriA'  as SPLocationCode,
			--'Kho2_ViTriA'  as SPLocationName,
			null SPLocationGroup,

			--case when SPWI.SPWarehouseCode='Kho1' then SPSI.CurrentStockQty else 0 end as CurrentStockQtyKho1,
			--case when SPWI.SPWarehouseCode='Kho2' then SPSI.CurrentStockQty else 0 end as CurrentStockQtyKho2,
			--SPSI.CurrentStockQty
			t1.CurrentStockQtyKho1,
			t1.CurrentStockQtyKho2,
			t1.CurrentStockQty
				FROM
						STB_VNSparePartInfo SPI WITH(NOLOCK)
						left join table1 t1 on  SPI.SparePartCode = t1.SparePartCode
						LEFT  JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK) ON SPI.SparePartCode = SPSI.SparePartCode 
						LEFT JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK) ON  SPSI.SPWarehouseCode = SPWI.SPWarehouseCode
						LEFT  JOIN STB_SparePartLocationInfo LSP WITH(NOLOCK)  ON SPSI.SPLocationCode = LSP.SPLocationCode
					WHERE 
			--((@CompanyCode = '*') OR (SPWI.CompanyCode = @CompanyCode)) AND
	  --      ((@WorkCenterCode = '*') OR (SPWI.WorkCenterCode = @WorkCenterCode)) AND
	  --      ((@SPWarehouseCode = '*') OR (SPWI.SPWarehouseCode = @SPWarehouseCode)) AND
	        (SPI.IsUsed = 1)
	END