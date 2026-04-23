
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-03
-- Description:	근무 상세정보 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoWorkCalendar_IUD]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pDayWorkCalendarNo VARCHAR(20),
	@pCalendarCode VARCHAR(10),
	@pJobDate DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE	@ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE	@DayWorkCalendarNo VARCHAR(20) = @pDayWorkCalendarNo
	DECLARE	@CalendarCode VARCHAR(20) = @pCalendarCode
	DECLARE @JobDate DATETIME = @pJobDate
	DECLARE @SeqNo VARCHAR(4)
	DECLARE @tbDayWorkCalendarDetail TABLE (IDX INT IDENTITY, ShiftCode VARCHAR(1), TimeCode VARCHAR(2), StartTime DATETIME, EndTime DATETIME, IsWork BIT, RestType BIT)
	DECLARE @InitNum INT = 1
	DECLARE @rowCnt INT
	
	DECLARE @ShiftCode VARCHAR(1)
	DECLARE @TimeCode VARCHAR(2)
	DECLARE @StartTime DATETIME
	DECLARE @EndTime DATETIME
	DECLARE @IsWork BIT
	DECLARE @RestType BIT
	
	DECLARE @MinStartDateTime DATETIME
	DECLARE @MaxEndDateTime DATETIME
			
	--디테일 지우고 다시 넣기
	DELETE FROM STB_DayWorkCalendarDetail WHERE DayWorkCalendarNo = @DayWorkCalendarNo

	
	
	INSERT @tbDayWorkCalendarDetail
	SELECT
			CD.ShiftCode,
			CD.TimeCode,
			CD.StartTime,
			CD.EndTime,
			CD.IsWork,
			CD.RestType
	FROM
			STB_CalendarDetail CD 
			LEFT OUTER JOIN STB_CalendarMaster CM 
				ON CM.CalendarCode = CD.CalendarCode
	WHERE
			CD.CalendarCode = @CalendarCode AND
			CM.IsUsed = 1
			
	SET @rowCnt = (SELECT COUNT(*) FROM @tbDayWorkCalendarDetail)
	
	WHILE @InitNum <= @rowCnt BEGIN
	
		SELECT
				@ShiftCode = ShiftCode,
				@TimeCode = TimeCode,
				@StartTime = StartTime,
				@EndTime = EndTime,
				@IsWork = IsWork,
				@RestType = RestType, 
				@SeqNo = SmartFramework.dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL((SELECT MAX(SeqNo) FROM STB_DayWorkCalendarDetail WHERE DayWorkCalendarNo = @DayWorkCalendarNo),0)) + 1,4)
		FROM
				@tbDayWorkCalendarDetail
		WHERE
				IDX = @InitNum
		
		INSERT INTO STB_DayWorkCalendarDetail
		(
			DayWorkCalendarNo,
			SeqNo,
			ShiftCode,
			TimeCode,
			StartDateTime,
			EndDateTime,
			IsWork,
			RestType
		)
		VALUES
		(
			@DayWorkCalendarNo,
			@SeqNo,
			@ShiftCode,
			@TimeCode,
			--CONVERT(TIME,@StartTime),
			--CONVERT(TIME,@EndTime),
			CONVERT(DATETIME,CONVERT(VARCHAR(10),@JobDate,120) + ' ' + CONVERT(VARCHAR, @StartTime, 108)),
			CONVERT(DATETIME,CONVERT(VARCHAR(10),@JobDate,120) + ' ' + CONVERT(VARCHAR, @EndTime, 108)),
			@IsWork,
			@RestType
		)
				
		SET @InitNum = @InitNum + 1
		
	END	
	
	
	
	SELECT
			@MinStartDateTime = MIN(CONVERT(TIME,DWCD.StartDateTime)),
			@MaxEndDateTime = MAX(CONVERT(TIME,DWCD.EndDateTime))
	FROM
			STB_DayWorkCalendarDetail DWCD
	WHERE
			DWCD.DayWorkCalendarNo = @DayWorkCalendarNo
			
	SET @MinStartDateTime = CONVERT(DATETIME,CONVERT(VARCHAR(10),@JobDate,120) + ' ' + CONVERT(VARCHAR,@MinStartDateTime,108))
	SET @MaxEndDateTime = CONVERT(DATETIME,CONVERT(VARCHAR(10),@JobDate,120) + ' ' + CONVERT(VARCHAR,@MaxEndDateTime,108))
	
	UPDATE STB_DayWorkCalendar
	SET
			StartDateTime = @MinStartDateTime,
			EndDateTime = @MaxEndDateTime
	WHERE
			DayWorkCalendarNo = @DayWorkCalendarNo
	
	
	
END

