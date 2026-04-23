-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_InvoiceFinishGoodBG_get_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCustomer NVARCHAR(50)= NULL,
		@pPN NVARCHAR(50) = NULL,
		@pQty int = NULL,
		@pBoxQty int = NULL,
		@pNote NVARCHAR(MAX)= NULL,
		@pNoiXuat nvarchar(50)= NULL,
		@pInvoiceNo nvarchar(50)= NULL,
		@pPO NVARCHAR(50) = NULL,
		@pHH_PN NVARCHAR(50) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO  InvoiceFinishGoodStockOutBG(
		Customer ,
		PN,
		Qty,
		BoxQty,
		Note,
		NoiXuat,
		InvoiceNo,
		PO,
		HH_PN
	)
	VALUES
	 (
		@pCustomer ,
		@pPN,
		@pQty,
		@pBoxQty,
		@pNote,
		@pNoiXuat,
		@pInvoiceNo,
		@pPO,
		@pHH_PN
	 )

END
