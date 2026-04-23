-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDataDetailsAgingHN_BI]
	-- Add the parameters for the stored procedure here
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FromDate VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00.000'
	DECLARE @ToDate VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00.000'

			SELECT
				DA.ID,
				DA.LOTNO AS Lot,
				DA.NOITEMS AS [No.],
				DA.RESULT AS [Result],
				DA.CAPUF AS [CAP(uF)],
				DA.LCUA AS [LC(uA)],
				DA.DFPHANTRAM AS [DF(%)],
				DA.ESRM AS [ESR(mΩ)],
				DA.TIMEC AS [time],
				DA.LINES,
				DA.COMPUTER,
				DA.CREATEDATE
			FROM stb_DetailAgaingHN DA WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = DA.LOTNO AND MA.COMPUTER = DA.COMPUTER AND CONVERT(VARCHAR, MA.CREATEDATE, 23) = CONVERT(VARCHAR, DA.CREATEDATE, 23)
			WHERE 1=1 AND
				CONVERT(DATETIME, LEFT(MA.DATES, LEN(MA.DATES) - 3), 103) BETWEEN @FromDate AND @ToDate


END
