-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 입고이력 관리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNGetInSparePartHistoryManagement]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
    @pCompanyCode VARCHAR(20) = NULL,
    @pSPWarehouseCode VARCHAR(20) = NULL,
	@pFromdate Date,
	@pToDate Date,
	--@pFromDate DATE = NULL,
	--@pToDate DATE= NULL,	
	@pSparePartCode nvarchar(50) = NULL,
	@pVendorCode nvarchar(50) = NULL,
	@pInvoiceNo nvarchar(200) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL


	-- select * from STB_VNSparePartStockInfo
AS
BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @SPWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pSPWarehouseCode,'') = '' THEN '*' ELSE @pSPWarehouseCode END

	;with table1 as
	(
		--select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		--from 
		--(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
		--	  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
		--	  sum(CurrentStockQty) as CurrentStockQty
		-- from STB_VNSparePartStockInfo 
		 
		-- group by SparePartCode,SPWarehouseCode) aa
		-- group by SparePartCode

		--------------------------------------------------------- Ha them 07/05/24
		select SparePartCode,sum(CurrentStockQtyKho1) as CurrentStockQtyKho1, sum(CurrentStockQtyKho2) as CurrentStockQtyKho2, sum(CurrentStockQty) as CurrentStockQty
		from 
		(select SparePartCode,case when SPWarehouseCode='Kho1' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho1,
			  case when SPWarehouseCode='Kho2' then sum(CurrentStockQty) else 0 end as CurrentStockQtyKho2,
			  sum(CurrentStockQty) as CurrentStockQty
		 from STB_VNSparePartStockInfo_TEST where WorkCenterCode =@pWorkCenterCode
		 
		 group by SparePartCode,SPWarehouseCode) aa
		 group by SparePartCode
		 ---------------------------------------------------------------

	)
    
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
			TSP.TYPECODE,
			TSP.TYPENAME,
	        SPI.SparePartImage,
	        SPI.BasicUnitPrice,
	        SPI.BasicDeliveryDay,
	        SPI.BasicUnit,
	        SPI.SafeQty,
	        SPI.LastDeliveryVendor,
	        SPI.CompatibilityGroup,
			SPI.Position,
	        
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
	      --  SPSI.CurrentStockQty,
			--sum(CurrentStockQty) as CurrentStockQty,
			t1.CurrentStockQtyKho1,
			t1.CurrentStockQtyKho2,
			t1.CurrentStockQty,
	        SPIOH.HistoryText,
	        
	        '' MachineCode,
	        SPIOH.CreateDateTime,
	        SPIOH.CreateUserID,
	        SPIOH.ChangeDateTime,
	        SPIOH.ChangeUserID,
			SPIOH.CurlingGomaUniqueNo,
			SPIOH.LineCode,
			LI.LineName,
			dbo.fnGetLocalTime(SPIOH.BasicDate,@pUtcOffset) AS BasicDate,
			--convert(varchar, SPIOH.BasicDate, 111) as BasicDate, 
			--SPIOH.BasicDate,
			SPIOH.CodeEmp,
			ED.Name,
			ED.PartName,
			SPIOH.InvoiceNo,
			SPIOH.Attribute2,
			SPI.PositionBG

			
	FROM
	        STB_VNSparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode  and SPIOH.WorkCenterCode =SPWI.WorkCenterCode
			LEFT OUTER JOIN STB_SparePartLocationInfo SPLI WITH(NOLOCK)
				ON SPIOH.SPLocationCode = SPLI.SPLocationCode
				AND SPIOH.SPWarehouseCode = SPLI.SPWarehouseCode
			LEFT OUTER JOIN STB_VNSparePartInfo SPI WITH(NOLOCK)
				ON SPIOH.SparePartCode = SPI.SparePartCode 
			LEFT OUTER JOIN STB_SparePartIOTypeCode SPIOTC WITH(NOLOCK)
				ON SPIOH.SparePartIOTypeCode = SPIOTC.SparePartIOTypeCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON SPIOH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON SPIOH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_CustomerInfo CII WITH(NOLOCK)
				ON SPIOH.VendorCode = CII.CustomerCode
			--LEFT OUTER JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK)
				--ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
				--AND SPIOH.SPLocationCode = SPSI.SPLocationCode
				--ON SPIOH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_LineInfo LI
			  ON LI.LineCode = SPIOH.LineCode
			LEFT JOIN Stb_EmployeeDepartment ED
			  ON SPIOH.CODEEMP = ED.CODEEMP
			LEFT JOIN STB_TYPESPAREPART TSP
				ON SPI.TypeCode = TSP.TYPECODE	
			left join table1 t1 on  SPIOH.SparePartCode = t1.SparePartCode
	WHERE
	        ((@CompanyCode = '*') OR (SPIOH.CompanyCode = @CompanyCode)) AND
	        ((@WorkCenterCode = '*') OR (SPIOH.WorkCenterCode = @WorkCenterCode)) AND
	        ((@SPWarehouseCode = '*') OR (SPIOH.SPWarehouseCode = @SPWarehouseCode)) AND
	        (SPIOTC.IOType = 'I') AND SPIOH.Attribute1 IS NULL 
	     	AND SPIOH.BasicDate between @pFromDate and @pToDate
			AND (@pSparePartCode is null or SPIOH.SparePartCode = @pSparePartCode)
			and (@pVendorCode is null or SPIOH.VendorCode =@pVendorCode)
			and (@pInvoiceNo is null or @pInvoiceNo='' or spioh.InvoiceNo like '%'+@pInvoiceNo+'%')
	
END

