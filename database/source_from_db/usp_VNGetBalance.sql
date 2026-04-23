-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-19
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 입고이력 관리
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNGetBalance]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pSparePartCode VARCHAR(20) = NULL

AS
BEGIN

	SET NOCOUNT ON;
    DECLARE @SparePartCode VARCHAR(20) = CASE WHEN ISNULL(@pSparePartCode,'') = '' THEN '*' ELSE @pSparePartCode END
    DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	DECLARE @CNT INT
 
	DECLARE  cursorProduct  CURSOR
	FOR
		SELECT distinct
	        A1.SparePartCode

			FROM STB_VNSparePartInfo A1 
			left join STB_VNSparePartIOHistory A2 ON A1.SparePartCode = A2.SparePartCode
			where A1.IsUsed ='1' and A1.SparePartCode  not in (select SparePartCode from STB_VNSparePartIOHistory where  Attribute1='BALANCE')
			--and A1.SparePartCode='SP153'
	
	
	OPEN cursorProduct 
	FETCH NEXT FROM cursorProduct     -- Đọc dòng đầu tiên
      INTO @SparePartCode

		WHILE @@FETCH_STATUS = 0          --vòng lặp WHILE khi đọc Cursor thành công
		BEGIN
										  --In kết quả hoặc thực hiện bất kỳ truy vấn
									  --nào dựa trên kết quả đọc được
			

			    EXEC SmartFramework.dbo.usp_GetSerialRule 
				@pTableName = 'STB_VNSparePartIOHistory',
				@pIsAutoKey = @IsAutoKey OUTPUT,
				@pIsLoopIUD = @IsLoopIUD OUTPUT,
				@pPrefixData = @PrefixString OUTPUT,
				@pSerialLen = @SerialLen OUTPUT


				EXEC usp_VNDoSparePartInHistory_iud		@pCompanyCode = 'VVT',
															@pWorkCenterCode = 'VVT_F1',
															@pOldSparePartIOHistoryNo = '20200101',
															@pSparePartIOHistoryNo = '20200101',
															@pSPWarehouseCode = 'Kho1',
															@pSparePartCode = @SparePartCode,
															@pSPLocationCode = 'Kho1_ViTriA',
															@pSparePartIOTypeCode = 'GR_NORMAL',
															@pVendorCode = '',
															@pUnitPrice = 0,
															@pProcessQty = 0,
															@pHistoryText = '',
															@pIUD_FLAG = 'INSERT',
															@pProcessUserID = @pProcessUserID,
															@pPrefixString = @PrefixString,
															@pSerialLen = @SerialLen,
															@pCurlingGomaUniqueNo = '',
															@pCodeEmp = '',
															@pAttribute1 = 'BALANCE',
															@pAttribute2 = '',
															@pAttribute3 = '',
															@pAttribute4 = '',
															@pAttribute5 = '',
															@pBasicDate = '',
															@pInvoiceNo=''

				FETCH NEXT FROM cursorProduct -- Đọc dòng tiếp
					  INTO @SparePartCode

		END

		CLOSE cursorProduct              -- Đóng Cursor
		DEALLOCATE cursorProduct         -- Giải phóng tài nguyên

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
			SPIOH.BasicDate,
			SPIOH.CodeEmp,
			ED.Name

			
	FROM
	        STB_VNSparePartIOHistory SPIOH WITH(NOLOCK)
	        LEFT OUTER JOIN STB_SparePartWarehouseInfo SPWI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPWI.SPWarehouseCode
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
			LEFT OUTER JOIN STB_VNSparePartStockInfo SPSI WITH(NOLOCK)
				ON SPIOH.SPWarehouseCode = SPSI.SPWarehouseCode
				AND SPIOH.SPLocationCode = SPSI.SPLocationCode
				AND SPIOH.SparePartCode = SPSI.SparePartCode
			LEFT OUTER JOIN STB_LineInfo LI
			  ON LI.LineCode = SPIOH.LineCode
			LEFT JOIN Stb_EmployeeDepartment ED
			  ON SPIOH.CODEEMP = ED.CODEEMP
				
	WHERE

	        (@pSparePartCode IS NULL OR @pSparePartCode ='' OR (SPIOH.SparePartCode = @pSparePartCode)) 
			AND
	        (SPIOTC.IOType = 'I') AND SPIOH.ATTRIBUTE1='BALANCE'

END