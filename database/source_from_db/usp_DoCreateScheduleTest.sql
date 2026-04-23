CREATE PROC usp_DoCreateScheduleTest @StartDate DATE, @EndDate DATE, @RepeatCycle INT
AS
BEGIN
	Declare @CheckSchedule TABLE (CheckDate DATE NULL);
	Declare @CurrentDate DATE = @StartDate

	WHILE @CurrentDate <= @EndDate BEGIN
		INSERT INTO @CheckSchedule VALUES ( @CurrentDate)

		SET @CurrentDate = DATEADD(day, @RepeatCycle, @CurrentDate)
	END

	SELECT CheckDate FROM @CheckSchedule
END