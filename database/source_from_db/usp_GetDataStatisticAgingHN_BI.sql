-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDataStatisticAgingHN_BI]
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
				Mid.ID,
				Mid.IDPARAM,
				Mid.LOTNO AS Lot, 
				Mid.ITEM AS Item,
				Mid.UPPERS AS [Upper],
				Mid.LOWERS AS [Lower],
				Mid.MAXS AS [Max],
				Mid.MINS AS [Min],
				Mid.AVGS AS [AVG],
				Mid.OO AS σ,
				Mid.CPK,
				Mid.COMPUTER,
				Mid.CREATEDATE
			FROM stb_MidlleAgaingHN Mid WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = Mid.LOTNO  --AND CONVERT(VARCHAR, MA.CREATEDATE, 23) = CONVERT(VARCHAR, Mid.CREATEDATE, 23))
			WHERE 1=1 AND
				CONVERT(DATETIME, LEFT(MA.DATES, LEN(MA.DATES) - 3), 103) BETWEEN @FromDate AND @ToDate
				AND MA.COMPUTER = Mid.COMPUTER
				and CONVERT(VARCHAR, MA.CREATEDATE, 23) = CONVERT(VARCHAR, Mid.CREATEDATE, 23)


END

--select * from stb_MidlleAgaingHN
--where Lotno = '7VS100MB6'

--select *,  CONVERT(VARCHAR, CREATEDATE, 23) from stb_MasterAgaingHN
--where LOTNO = '7VS100MB6'

--select * from stb_DetailAgaingHN
--where LOTNO = '7VS100MB6'