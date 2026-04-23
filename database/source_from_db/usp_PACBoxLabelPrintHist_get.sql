-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PACBoxLabelPrintHist_get]
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
		PAC.LotNo ,
		PAC.LabelQty,
		PAC.LabelType,
		PAC.PN,
		PAC.DC,
		PAC.Qty,
		PAC.Reel,
		PAC.MPN,
		PAC.VN,
		PAC.CREATEUSERID,
		PAC.CREATEDATE

	from STB_PACBoxLabalPrintHist PAC WITH(NOLOCK)
	where PAC.CREATEDATE BETWEEN @FromDate AND @ToDate

	ORDER BY PAC.CREATEDATE asc


END
