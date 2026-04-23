

-- =============================================
-- Author:
-- Create date: 
-- Browsable :
-- Group :
-- Description:	
-- Modified: 
-- =============================================

CREATE PROCEDURE [dbo].[usp_InvoiceFinishGoodStockBG_get]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pInvoiceNo NVARCHAR(30) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @InvoiceNo  VARCHAR(30) = CASE WHEN ISNULL(@pInvoiceNo, '') = '' THEN '*' ELSE @pInvoiceNo END

	SELECT
			Customer,
			PN,
			Qty,
			BoxQty,
			Note,
			NoiXuat,
			InvoiceNo,
			PO,
			HH_PN

	FROM InvoiceFinishGoodStockOutBG
	WHERE 1=1		
		AND (@InvoiceNo = '*' OR InvoiceNo = @InvoiceNo)	
	   
END
