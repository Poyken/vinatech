-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-07-22
-- Browsable : true
-- Group : Dates
-- Description:	기준일자
-- =============================================
CREATE PROCEDURE usp_GetDates
		@pFromDate Date,
		@pToDate Date
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate

	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	SELECT DATEADD(day, number, @FromDate) AS Date
	      ,MONTH(DATEADD(day, number, @FromDate)) AS Month
		  ,DAY(DATEADD(day, number, @FromDate)) AS Day
		  ,CASE WHEN CONVERT(CHAR(10), GETDATE(), 121) = CONVERT(CHAR(10), DATEADD(day, number, @FromDate), 121)
		        THEN 'Yes' ELSE 'No' END AS IsToday
	  FROM MASTER.DBO.SPT_VALUES 
	 WHERE TYPE = 'P'
	   AND DATEADD(day, number, @FromDate) <= @ToDate

END
