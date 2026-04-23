-- =============================================
-- Author:		DinhManh
-- Create date: 2025-11-14
-- Description:	Marking Label Print history in C552 and B718
-- =============================================
CREATE PROCEDURE [dbo].[usp_MarkingLabelPrintHistVVT_iud]  -- select * from STB_MarkingLabelPrintHist
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pMenuCode VARCHAR(10)= NULL,
		@pLotNo1 VARCHAR(50) = NULL,
		@pLotNo2 VARCHAR(50) = NULL,
		@pLotNo3 VARCHAR(50) = NULL,
		@pMarkingLetter NVARCHAR(50) = NULL,
		@pLabelQty VARCHAR(5) = NULL,
		@pTypePrint VARCHAR(30) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO STB_MarkingLabelPrintHist (
		MenuCode,
		LotNo1,
		LotNo2,
		LotNo3,
		MarkingLetter,
		LabelQty,
		TypePrint,
		PrintTime,
		PrintUserID
	
	) VALUES (
		@pMenuCode,
		@pLotNo1,
		@pLotNo2,
		@pLotNo3,
		@pMarkingLetter,
		@pLabelQty,
		@pTypePrint,
		GETDATE(),
		@pProcessUserID
	)




END
