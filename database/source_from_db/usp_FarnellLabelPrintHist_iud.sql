-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_FarnellLabelPrintHist_iud
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCustomerPO VARCHAR(50),
		@pPackingListNumber VARCHAR(50),
		@pCustomerPartNumber VARCHAR(50),
		@pSupplierPartNumber VARCHAR(50),
		@pQuantity VARCHAR(10),
		@pDateCodes VARCHAR(10),
		@pLotCodes VARCHAR(50),
		@pSerialNumber VARCHAR(50),
		@pProdLabelQty VARCHAR(10),
		@pLogLabelQty VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @LabelType VARCHAR(50) = NULL
	SET @LabelType = CASE WHEN CAST(@pProdLabelQty AS INT) > 0 THEN 'Product Label - INNER'
						ELSE 'Logistic Label - OUTER' 
						END


    INSERT INTO STB_FarnellLabelPrintHist (
		LabelType ,
		CustomerPO ,
		PackingListNumber ,
		CustomerPartNumber ,
		SupplierPartNumber ,
		Quantity ,
		DateCodes ,
		LotCodes ,
		SerialNumber,
		ProdLabelQty ,
		LogLabelQty ,
		PrintTime ,
		PrintUserID
	) 
	VALUES 
		(
			@LabelType,
			@pCustomerPO ,
			@pPackingListNumber ,
			@pCustomerPartNumber ,
			@pSupplierPartNumber ,
			@pQuantity ,
			@pDateCodes ,
			@pLotCodes ,
			@pSerialNumber,
			@pProdLabelQty ,
			@pLogLabelQty ,
			GETDATE() ,
			@pProcessUserID
		)
END
