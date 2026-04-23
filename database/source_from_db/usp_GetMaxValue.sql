CREATE PROC usp_GetMaxValue
	@pDiv VARCHAR(10)
AS
BEGIN
	Declare @len INT = CASE WHEN @pDiv = 'HOUR' THEN 13
	                        WHEN @pDiv = 'DAY' THEN 10
							WHEN @pDiv = 'MONTH' THEN 7
							ELSE 0 END

	IF @len = 0 BEGIN
		SELECT ''
	END ELSE BEGIN
		SELECT LEFT(CONVERT(VARCHAR(19), CreateDateTime, 121), @len)
		      ,MAX(Watt) AS Watt
		  FROM STB_GroupByDateTimeTest
		 GROUP BY LEFT(CONVERT(VARCHAR(19), CreateDateTime, 121), @len)
		 ORDER BY LEFT(CONVERT(VARCHAR(19), CreateDateTime, 121), @len)
	END
END