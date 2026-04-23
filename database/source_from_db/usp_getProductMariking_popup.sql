-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-26
-- Description:	Lấy ra chữ marking đã lưu của các lot nhà máy hà nam
-- =============================================
CREATE PROCEDURE usp_getProductMariking_popup 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Barcode VARCHAR(20) = @pBarcode
		
		select MarkingCode ,MarkingName ,Qty from STB_CreateMarkingLetterAndQtyForBarcode where barcode=@Barcode
END
