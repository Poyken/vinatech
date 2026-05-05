-- Function: fnGetDates



-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2009-08-17
-- Description: 지정된 일자부터 지정된 일수만큼의 일자 계열을 반환합니다.
-- =============================================
CREATE FUNCTION [dbo].[fnGetDates]
(	
	@pStartDate DATETIME,
	@pEndDate DATETIME
)
RETURNS TABLE
AS
RETURN 
	SELECT @pStartDate + N - 1 AS [Date]
	FROM
			dbo.fnGetNumbers(DATEDIFF(DAY, @pStartDate, @pEndDate) + 1) AS Numbers




GO

