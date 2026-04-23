-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAllDataStatisticAgingHN_BI] -- exec usp_GetAllDataStatisticAgingHN_BI '2025-08-19', '2025-08-19', ''
	-- Add the parameters for the stored procedure here
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL,
			@pMachineNumber NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @FromDate VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00.000'
		DECLARE @ToDate VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00.000'
		DECLARE @MachineNumber NVARCHAR(50) = CASE WHEN ISNULL(@pMachineNumber,'') = '' THEN '%' ELSE @pMachineNumber END

		SELECT
				Mid.ID,
				Mid.IDPARAM,
				MA.SPEC AS [Spec],
				Mid.LOTNO AS Lot, 
				Mid.ITEM AS Item,
				Mid.UPPERS AS [Upper],
				Mid.LOWERS AS [Lower],
				Mid.MAXS AS [Max],
				Mid.MINS AS [Min],
				Mid.AVGS AS [AVG],
				Mid.OO AS σ,
				Mid.CPK,
				Mid.COMPUTER
			FROM stb_MidlleAgaingHN Mid WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = Mid.LOTNO AND Mid.COMPUTER = MA.COMPUTER AND CONVERT(VARCHAR, MA.CREATEDATE, 23) = CONVERT(VARCHAR, Mid.CREATEDATE, 23)
			WHERE 1=1 AND
				CONVERT(DATETIME, LEFT(MA.DATES, LEN(MA.DATES) - 3), 103) BETWEEN @FromDate AND @ToDate  AND
				MA.COMPUTER LIKE @MachineNumber


				--select TOP 100 * from stb_DetailAgaingHN

				--select * from stb_MasterAgaingHN
				
END


-- usp_GetAllDataStatisticAgingHN_BI '2025-08-01', '2025-08-12', 'J250-119'


--exec usp_GetAllDataStatisticAgingHN_BI  '2025-01-01','2025-12-31',''