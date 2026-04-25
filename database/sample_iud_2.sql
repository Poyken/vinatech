-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-16
-- Description:	Print History of BloomBox Label
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_BloomBoxLabelPrintHist_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLotID VARCHAR(50) = NULL,
		@pMaterialCode VARCHAR(50) = NULL,
		@pMaterialName NVARCHAR(100) = NULL,
		@pPackingID VARCHAR(50) = NULL,
		@pLabelQty INT,
		@pLotQty INT,
		@pCurrentQty NUMERIC(20, 10),
		@pLotNo VARCHAR(50) = NULL,
		@pPartNo VARCHAR(50) = NULL,
		@pMarkingLetter VARCHAR(50) = NULL,
		@pSN VARCHAR(10) = NULL,
		@pDC VARCHAR(10) = NULL,
		@pStockAttrib1 NVARCHAR(100) = NULL,
		@pSalesPONo VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO 
		 STB_VN_BloomBoxLabelPrintHist (
			LotID,
			MaterialCode,
			MaterialName,
			PackingID,
			LabelQty,
			LotQty,
			CurrentQty,
			LotNo,
			PartNo,
			MarkingLetter,
			SN,
			DC,
			SalesPONo,
			StockAttrib1,
			PrintTime,
			PrintUserID
			)
		VALUES
			(
			@pLotID,
			@pMaterialCode,
			@pMaterialName,
			@pPackingID,
			@pLabelQty,
			@pLotQty,
			@pCurrentQty,
			@pLotNo,
			@pPartNo,
			@pMarkingLetter,
			@pSN,
			@pDC,
			@pSalesPONo,
			@pStockAttrib1,
			GETDATE(),
			@pProcessUserID
			)
END
