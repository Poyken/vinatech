-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_PACBoxLabelPrintHist_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLot varchar(30)= NULL,
		@pLabelQty varchar(2)= NULL,
		@pTypeBox nvarchar(20)= NULL,
		@pPN varchar(50)= NULL,
		@pDC varchar(10)= NULL,
		@pQty varchar(5)= NULL,
		@pReel varchar(30)= NULL,
		@pMPN varchar(20)= NULL,
		@pVNBarcode varchar(100)= NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO  STB_PACBoxLabalPrintHist(
		LotNo ,
		LabelQty,
		LabelType,
		PN,
		DC,
		Qty,
		Reel,
		MPN,
		VN,
		CREATEUSERID,
		CREATEDATE
	)
	VALUES
	 (
		@pLot ,
		@pLabelQty,
		@pTypeBox,
		@pPN,
		@pDC,
		@pQty,
		@pReel,
		@pMPN,
		@pVNBarcode,
		@pProcessUserID,
		GETDATE()
	 )

END
