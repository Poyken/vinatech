-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_PACPrintLablePrintHist_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLabelQty varchar(2)= NULL,
		@pPO varchar(50) = NULL,
		@pCustomer_PN nvarchar(50)= NULL,
		@pSupplierPN varchar(50)= NULL,
		@pUnitQty varchar(50)= NULL,
		@pDC varchar(50)= NULL,
		@pLot varchar(50)= NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO  STB_PACLabelPrintHistV1(
		LabelQty ,
		PO,
		CustomerPN,
		SupplierPN,
		UnitQty,
		DC,
		LotNo,
		CREATEUSERID,
		CREATEDATE
	)
	VALUES
	 (
		@pLabelQty ,
		@pPO,
		@pCustomer_PN,
		@pSupplierPN,
		@pUnitQty,
		@pDC,
		@pLot,
		@pProcessUserID,
		GETDATE()
	 )

END

--select * from STB_PACLabelPrintHistV1