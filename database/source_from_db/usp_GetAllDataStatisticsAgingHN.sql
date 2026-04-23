-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_GetAllDataStatisticsAgingHN
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

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
				Mid.COMPUTER,
				Mid.CREATEDATE
			FROM stb_MidlleAgaingHN Mid WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = Mid.LOTNO
END
