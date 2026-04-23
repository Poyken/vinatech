-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-08-11
-- Description : 폐기물 무게 조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_WasteWeight_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20),
	@pDefectGroupCode VARCHAR(20)
AS
BEGIN
	Declare @LineCode VARCHAR(20)
		   ,@Barcode VARCHAR(20) = @pBarcode
		   ,@DefectGroupCode VARCHAR(20) = CASE WHEN @pDefectGroupCode > 'E-25' THEN 'E-25' ELSE @pDefectGroupCode END
		   ,@WasteWeight NUMERIC(10, 2)
		   ,@Volt NUMERIC(4,1)
		   ,@Farad NUMERIC(6,1)
		   ,@Size VARCHAR(10)
		   ,@RouteCode VARCHAR(20)
		   ,@TotalWastePrice NUMERIC(10, 2)
		   ,@WasteQty INT

	  SELECT @LineCode = InputLineCode
	   FROM STB_SetInfo
	  WHERE Barcode = @Barcode

	SELECT TOP 1 @WasteWeight = WasteWeight
	  FROM STB_WasteWeight
	 WHERE LineCode LIKE ISNULL(@LineCode, '') + '%'
	 ORDER BY CreateDateTime DESC

	 SELECT @Volt = CONVERT(NUMERIC(4,1), MBIExtText04)
	       ,@Farad = CONVERT(NUMERIC(6,1), MBIExtText05)
		   ,@Size = RIGHT('0' + CONVERT(VARCHAR(2), CONVERT(INT, MBISizeW)), 2) 
		          + CONVERT(VARCHAR(2), CONVERT(INT, MBISizeH))
	   FROM STB_ModelBasicInfo
	  WHERE ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)

	  SELECT TOP 1 @TotalWastePrice = (ProcessUnitPriceKG * (@WasteWeight / 1000))
	        ,@WasteQty = CONVERT(INT, (ProcessUnitPriceKG / ProcessUnitPriceEA) * (@WasteWeight / 1000))
	    FROM STB_WasteUnitPrice
	   WHERE LineCode = CASE WHEN LEFT(ISNULL(@LineCode, 'ASSY'), 4) = 'ASSY' THEN 'ASSY' ELSE 'DRYROOM' END
	     AND Volt = @Volt
		 AND Farad = @Farad
		 AND Size LIKE @Size + '%'
		 AND RouteCode = @DefectGroupCode

	  SELECT @Barcode AS Barcode
	        ,@DefectGroupCode AS RouteCode
			,@WasteWeight AS WasteWeight
			,@TotalWastePrice AS DefectPrice
			,@WasteQty AS DefectQty
			,'Report' AS CommandType
END