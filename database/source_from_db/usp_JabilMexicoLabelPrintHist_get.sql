-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-11-03
-- Description:	Get Jabil Mexico Print Label Hist
-- =============================================
CREATE PROCEDURE usp_JabilMexicoLabelPrintHist_get
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
		JML.JabilPartNumber,
		JML.VinatechPartNumber,
		JML.PONumber,
		JML.Quantity,
		JML.LotCode,
		JML.DateCode,
		JML.CoO,
		JML.MSL,
		JML.LabelQty,
		JML.PrintTime,
		JML.PrintUserID


	from STB_JabilMexicoLabelPrintHist JML WITH(NOLOCK)
	where JML.PrintTime BETWEEN @FromDate AND @ToDate

	ORDER BY JML.PrintTime asc

	-- select * from STB_JabilMexicoLabelPrintHist
END
