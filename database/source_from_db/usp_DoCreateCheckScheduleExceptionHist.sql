CREATE PROC usp_DoCreateCheckScheduleExceptionHist
AS
BEGIN
	INSERT INTO STB_CheckScheduleExceptionHist (LineCode, CheckScheduleExceptionDate, CreateUserID)
		SELECT LineCode, GETDATE(), 'eai'
		  FROM STB_LineInfo
		 WHERE IsCheckScheduleMonitoring = CONVERT(BIT, 0)
END