-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_FarnellLabelPrintHist_get
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

    SELECT
		LabelType,
		CustomerPO, 
		PackingListNumber,
		CustomerPartNumber,
		SupplierPartNumber,
		LotCodes,
		Quantity AS BoxQty,
		DateCodes,
		SerialNumber,
		CASE 
			WHEN ProdLabelQty > 0 THEN ProdLabelQty
			ELSE LogLabelQty
		END AS LabelQty,
		PrintTime,
		PrintUserID


	from STB_FarnellLabelPrintHist FL WITH(NOLOCK)
	where FL.PrintTime BETWEEN @FromDate AND @ToDate

	ORDER BY FL.PrintTime asc

	-- select * from STB_FarnellLabelPrintHist

END
