-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_DigiKeyLabelInnerPrintHist_iud]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pLotNo varchar(30)= NULL,
		@pLabelType nvarchar(30)= NULL,
		@pPN varchar(50)= NULL,
		@pQty varchar(5)= NULL,
		@pDC varchar(10)= NULL,
		@pLabelQty varchar(5)= NULL,
		@pPONumber nvarchar(50)= NULL,
		@pPOLineNumber nvarchar(50)= NULL,
		@pPackListNumber nvarchar(50)= NULL,
		@pQtyLogisticBox VARCHAR(5)= NULL



AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO  STB_DigiKeyLabelInnerPrintHist(
		LotNo ,
		LabelType,
		PN,
		Qty,
		DC,
		LabelQty,
		PONumber,
		POLineNumber,
		PackListNumber,
		QtyLogisticBoxc,
		CREATEUSERID,
		CREATEDATE
	)
	VALUES
	 (
		@pLotNo ,
		@pLabelType,
		@pPN,
		@pQty,
		@pDC,
		@pLabelQty,
		@pPONumber,
		@pPOLineNumber,
		@pPackListNumber,
		@pQtyLogisticBox,
		@pProcessUserID,
		GETDATE()
	 )

END

--select * from STB_DigiKeyLabelInnerPrintHist