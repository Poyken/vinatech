
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 자재관리
-- Description:	업체바코드처리_Dummy
-- Modified:
-- =============================================
CREATE PROCEDURE usp_VendorBarcodeInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT '' AS VendorCode
	      ,'' AS VendorName
	      ,'' AS ProductGroupCode
		  ,'' AS ProductGroupName
		  ,'' AS DataType
		  ,'' AS DataTypeName
		  ,'' AS VendorBarcode
END