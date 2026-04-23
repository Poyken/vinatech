-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 입고이력 관리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInSparePartHistoryManagement]
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
	        SPIOH.SparePartIOHistoryNo AS OldSparePartIOHistoryNo,
	        SPIOH.SparePartIOHistoryNo,
	        
	        SPIOH.SparePartIOTypeCode,
	        SPIOTC.SparePartIOTypeName,
	        SPIOTC.IOType,
	        SPIOTC.SparePartIOTypeDesc,
	        
	        SPIOH.CompanyCode,
	        CI.CompanyName,
	        CI.CompanyNameL,
	        
	        SPIOH.WorkCenterCode,
	        WCI.WorkCenterName,
	        WCI.WorkCenterNameL,
	        
	        SPIOH.SPWarehouseCode,
	        SPWI.SPWarehouseName,
	        
	        SPIOH.SPLocationCode,
	        SPLI.SPLocationGroup,
	        SPLI.SPLocationName,
	        
	        SPIOH.SparePartCode,
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
	        SPI.CompatibilityGroup,
	        
	        SPIOH.VendorCode,
	        CII.CustomerName,
	        CII.CustomerNameL,
	        CII.IsCustomer,
	        CII.IsVendor,
	        CII.IsSourcing,
	        CII.BusinessCondition,
	        CII.BusinessType,
	        CII.BusinessNo,
	        CII.ZipCode,
	        CII.AddressText,
	        CII.CeoName,
	        CII.TelNo,
	        CII.FaxNo,
	        CII.ContactName1,
	        CII.ContactTel1,
	        CII.ContactName2,
	        CII.ContactTel2,
	        CII.ContactName3,
	        CII.ContactTel3,
	        CII.OrderToName,
	        CII.OrderToTel,
	        CII.OrderToEmail,
	        CII.CustomerDesc,
	        CII.CIExtText01,
	        CII.CIExtText02,
	        CII.CIExtText03,
	        
	        SPIOH.UnitPrice,
	        SPIOH.ProcessQty,
	        SPSI.CurrentStockQty,
	        SPIOH.HistoryText,
	        
	        '' MachineCode,
	        SPIOH.CreateDateTime,
	        SPIOH.CreateUserID,
	        SPIOH.ChangeDateTime,
	        SPIOH.ChangeUserID,
			SPIOH.CurlingGomaUniqueNo,
			SPIOH.LineCode,
			LI.LineName,
			SPIOH.GRDate
	FROM
	        STB_SparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPIOH.SPLocationCode = SPLI.SPLocationCode
				AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			LEFT OUTER JOIN STB_SparePartInfo SPI WITH(NOLOCK)
				ON SPIOH.SparePartCode = SPI.SparePartCode 
			LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
				ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPIOH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_CustomerInfo CII WITH(NOLOCK)
				ON SPIOH.VendorCode = CII.CustomerCode
			LEFT OUTER JOIN STB_SparePartStockInfo SPSI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
				AND SPIOH.SPLocationCode = SPSI.SPLocationCode
				AND SPIOH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_LineInfo LI
			  ON LI.LineCode = SPIOH.LineCode
				
	WHERE
	        ((@CompanyCode = '*') OR (SPIOH.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseCode = '*') OR (SPIOH.SPWarehouseCode = @SPWarehouseCode)) AND
	        (SPIOTC.IOType = 'I')
	     

END