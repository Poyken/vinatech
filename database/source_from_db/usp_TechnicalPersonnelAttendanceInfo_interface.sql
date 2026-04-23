CREATE PROC usp_TechnicalPersonnelAttendanceInfo_interface 
	@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate

	SELECT 'exec InputWorktimeForExcel ''' + CONVERT(VARCHAR(19), AttendanceDateTime, 121) + ''',''' + CONVERT(VARCHAR(19), LeavingDateTime, 121) + ''',''' + EI.EmployeeName + ''''
	  FROM STB_TechnicalPersonnelAttendanceInfo TPAI
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI
		ON TPAI.WorkerCode = EI.EmployeeNo
	 WHERE AttendanceDate BETWEEN @FromDate AND @ToDate
	 ORDER BY TPAI.WorkerCode, TPAI.AttendanceDate
END
