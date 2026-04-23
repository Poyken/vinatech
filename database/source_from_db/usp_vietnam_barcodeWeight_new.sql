-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_vietnam_barcodeWeight_new
@pLotPacking Varchar(30),
@pDefectWeight float,
@pUnitW float,
@pPcs float,
@pRemark nVarchar(1000)=null,
@pOddQty float,
@pOddQtyTotal varchar(20) = null
AS
BEGIN

	INSERT INTO  STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, UnitW,PCS, REMARK,OddQty,OddQtyTotal)
	VALUES (@pLotPacking,@pDefectWeight,@pUnitW,@pPcs,@pRemark,@pOddQty,@pOddQtyTotal)
	

	SELECT TOP 1 [WEIGHT]
	FROM STB_VIETNAM_BARCODEWEIGHT 
	WHERE BARCODE=@pLotPacking 
	AND  [WEIGHT] > 10 
	ORDER BY CREATEDATETIME DESC 	
END
