-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-12-28
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SanminaIndiaLabelPrintHist_get]
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

    -- Insert statements for procedure here
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

    SELECT
        SIL.ID,
		SIL.SupplierName,
        SIL.SanminaPartNumber,
        SIL.PartDesc,
        SIL.MFR,
        SIL.MPN,
        SIL.Quantity,
        SIL.PONumber,
        SIL.LotNo,
        SIL.LotCode,
        SIL.PackingDate,
        SIL.InspEmpID,
        SIL.InspEmpName,
        SIL.CartonBoxNo,
        SIL.PrintTime,
        SIL.PrintUserID


	from STB_SanminaIndiaLabelPrintHist SIL WITH(NOLOCK)
	where SIL.PrintTime BETWEEN @FromDate AND @ToDate

	ORDER BY SIL.PrintTime asc

	-- select * from STB_SanminaIndiaLabelPrintHist
END
