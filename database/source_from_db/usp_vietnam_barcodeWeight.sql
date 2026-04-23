CREATE PROC [dbo].[usp_vietnam_barcodeWeight] 
@pLotPacking Varchar(30),
@pDefectWeight float,
@pUnitW float,
@pPcs float,
@pRemark nVarchar(1000)=null,
@pOddQty float
AS
BEGIN

	INSERT INTO  STB_VIETNAM_BARCODEWEIGHT (BARCODE, WEIGHT, UnitW,PCS, REMARK,OddQty)
	VALUES (@pLotPacking,@pDefectWeight,@pUnitW,@pPcs,@pRemark,@pOddQty)
	

	SELECT TOP 1 [WEIGHT]
	FROM STB_VIETNAM_BARCODEWEIGHT 
	WHERE BARCODE=@pLotPacking 
	AND  [WEIGHT] > 10 
	ORDER BY CREATEDATETIME DESC 	

END
