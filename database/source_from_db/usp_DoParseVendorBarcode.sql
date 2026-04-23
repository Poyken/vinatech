
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 자재관리
-- Description:	업체바코드처리
-- Modified:
-- =============================================
CREATE PROCEDURE usp_DoParseVendorBarcode
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pLotID VARCHAR(20),
	@pVendorCode VARCHAR(20),
	@pProductGroupCode VARCHAR(20),
	@pDataType VARCHAR(20),
	@pVendorBarcode VARCHAR(1000)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @LotID VARCHAR(20) = @pLotID
	       ,@VendorCode VARCHAR(20) = @pVendorCode
		   ,@ProductGroupCode VARCHAR(20) = @pProductGroupCode
		   ,@DataType VARCHAR(20) = @pDataType
		   ,@VendorBarcode VARCHAR(1000) = @pVendorBarcode

	Declare @rtnData VARCHAR(20)

	SET @rtnData = dbo.fnGetVendorBarcodeElement(@VendorCode, @ProductGroupCode, @DataType, @VendorBarcode)

	IF @rtnData IS NULL BEGIN
		RAISERROR('바코드 분석을 위한 기준정보가 존재하지 않습니다.', 16, 1)
		RETURN
	END

	UPDATE STB_MaterialDocLotInfo
	   SET LotNo = @rtnData
	 WHERE LotID = @LotID

	 RAISERROR('정상적으로 처리되었습니다.', 16, 1)
END