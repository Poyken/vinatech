-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMidlleAgingHN_get] -- exec usp_GetMidlleAgingHN_get '35VHV100MC8', 'MAY05', '08/08/2025 15:38:30 PM'
			@pLotNo VARCHAR(50) = NULL,
			@pCOMPUTER VARCHAR(50) = NULL
			--@pCREATEDATE DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 --   DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	--DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'
	--DECLARE @LotNo VARCHAR(50) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END



			SELECT DISTINCT
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
				Mid.COMPUTER
			FROM stb_MidlleAgaingHN Mid WITH(NOLOCK) 
			--LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = Mid.LOTNO AND MA.COMPUTER = Mid.COMPUTER AND CONVERT(VARCHAR, Mid.CREATEDATE, 23) = CONVERT(VARCHAR, MA.CREATEDATE, 23)
			WHERE 
				Mid.LOTNO = @pLotNo
				AND Mid.COMPUTER = @pCOMPUTER
				--AND CONVERT(VARCHAR, Mid.CREATEDATE, 120) = CONVERT(VARCHAR, DATEADD(hour, 2, @pCREATEDATE), 120)
				--AND Mid.CREATEDATE =  @pCREATEDATE


END
