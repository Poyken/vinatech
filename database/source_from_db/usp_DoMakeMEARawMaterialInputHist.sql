CREATE PROC [dbo].[usp_DoMakeMEARawMaterialInputHist] 
	@pBarcode VARCHAR(20)
   ,@pSizeCode VARCHAR(20)
AS
BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@SizeCode VARCHAR(20) = @pSizeCode
		   ,@ProductGroupCode VARCHAR(20)
		   ,@MEARawMaterialInputHistNo VARCHAR(20)
		   
	DECLARE cur CURSOR FOR

	SELECT ProductGroupCode
	  FROM STB_RawMaterialBaiscInfo
	 WHERE SizeCode = @SizeCode


	OPEN cur

	FETCH NEXT FROM cur INTO @ProductGroupCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_RawMaterialInputHist',@MEARawMaterialInputHistNo OUTPUT

		INSERT INTO STB_RawMaterialInputHist (RawMaterialInputHistNo, Barcode, ProductGroupCode, RawMaterialBarcode)
			SELECT @MEARawMaterialInputHistNo, @Barcode, @ProductGroupCode, NULL
	
		FETCH NEXT FROM cur INTO @ProductGroupCode
	END

	CLOSE cur
	DEALLOCATE cur

END