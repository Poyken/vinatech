-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트표준저장위치 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SparePartBasicLocation_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pSPWarehouseCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END
    
	
	SELECT
			Master.SPWarehouseCode AS OldSPWarehouseCode,
			Master.SPWarehouseCode,
			Master.SPWarehouseName,
			
			Master.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			Master.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			Master.SparePartCode AS OldSparePartCode,
			Master.SparePartCode,
			
			Master.SparePartName,
			Master.SparePartSpec01,
			Master.SparePartSpec02,
			Master.SparePartSpec03,
			Master.SparePartSpec04,
			Master.SparePartSpec05,
			Master.SparePartImage,
			Master.BasicUnitPrice,
			Master.BasicDeliveryDay,
			Master.BasicUnit,
			Master.SafeQty,
			Master.LastDeliveryVendor,
			Master.CompatibilityGroup,
			
			Detail.SPLocationCode,
			Detail.SPLocationGroup,
			Detail.SPLocationName
			
			
	FROM
			(
				SELECT
						SPWI.SPWarehouseCode,
						SPWI.SPWarehouseName,
						SPWI.CompanyCode,
						SPWI.WorkCenterCode,
						SPI.SparePartCode,
						SPI.SparePartName,
						SPI.SparePartSpec01,
						SPI.SparePartSpec02,
						SPI.SparePartSpec03,
						SPI.SparePartSpec04,
						SPI.SparePartSpec05,
						SPI.SparePartImage,
						SPI.BasicUnitPrice,
						SPI.BasicDeliveryDay,
						SPI.BasicUnit,
						SPI.SafeQty,
						SPI.LastDeliveryVendor,
						SPI.CompatibilityGroup
				FROM
						STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
						CROSS JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				WHERE
						(SPWI.CompanyCode = @CompanyCode) AND
						(SPWI.WorkCenterCode = @WorkCenterCode) AND 
						(SPWI.SPWarehouseCode = @SPWarehouseCode) AND
						(SPI.IsUsed = 1)
			)Master
			LEFT OUTER JOIN 
			(
				SELECT	
						SPBL.SPWarehouseCode,
						SPBL.SparePartCode,
						SPBL.SPLocationCode,
						SPLI.SPLocationGroup,
						SPLI.SPLocationName
				FROM
						STB_SparePartBasicLocation SPBL WITH(NOLOCK)
						LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
							ON SPBL.SPWarehouseCode = SPLI.SPWarehouseCode
							AND SPBL.SPLocationCode = SPLI.SPLocationCode
				WHERE
						SPBL.SPWarehouseCode = @SPWarehouseCode
			)Detail
				ON Master.SPWarehouseCode = Detail.SPWarehouseCode
				AND Master.SparePartCode = Detail.SparePartCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON Master.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)	
				ON Master.CompanyCode = CI.CompanyCode
	WHERE
			(Master.CompanyCode = @CompanyCode) AND
			(Master.WorkCenterCode = @WorkCenterCode) AND
			(Master.SPWarehouseCode = @SPWarehouseCode) 

END


