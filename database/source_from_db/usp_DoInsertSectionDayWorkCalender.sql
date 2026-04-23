-- =============================================
-- Author:		Ji Hyang Mi(hmji@awoo.co.kr)
-- Create date: 2017-11-20
-- Browsable : true
-- Group : 일일근무카렌더
-- Description:	구간 일일근무 등록하면 실행함수 입니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoInsertSectionDayWorkCalender]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pCalendarCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage 
	DECLARE @FromDate DATE = CASE WHEN ISNULL(@pFromDate,'') = '' THEN GETDATE() ELSE @pFromDate END
	DECLARE @ToDate DATE = CASE WHEN ISNULL(@pToDate,'') = '' THEN GETDATE() ELSE @pToDate END
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '' ELSE @pLineCode END
	DECLARE @CalendarCode VARCHAR(20) = CASE WHEN ISNULL(@pCalendarCode,'') = '' THEN '' ELSE @pCalendarCode END

	DECLARE @DayWorkCalendarNo VARCHAR(20)
	DECLARE @COUNT INT
	DECLARE @ROW INT
	DECLARE @JobDate DATETIME

	SELECT 
			@COUNT = COUNT(*),
			@ROW = 1,
			@JobDate = @FromDate
	FROM
			master..spt_values MSV WITH(NOLOCK)	
	WHERE
			MSV.type = 'P' AND
			number <= DATEDIFF(D,@FromDate,@ToDate)

	WHILE @ROW <= @COUNT BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayWorkCalendar', @DayWorkCalendarNo OUTPUT

		IF EXISTS (
						SELECT	1
						FROM
								STB_DayWorkCalendar WC
						WHERE
								WC.JobDate = @JobDate AND
								WC.CompanyCode = @CompanyCode AND
								WC.WorkCenterCode = @WorkCenterCode AND
								WC.LineCode = @LineCode
					) BEGIN
				SET @JobDate = @JobDate + 1
				SET @ROW = @ROW +1
				CONTINUE
		END

		INSERT INTO STB_DayWorkCalendar
		(
			DayWorkCalendarNo,
			JobDate,
			CompanyCode,
			WorkCenterCode,
			LineCode,
			CalendarCode,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@DayWorkCalendarNo,
			@JobDate,
			@CompanyCode,
			@WorkCenterCode,
			@LineCode,
			@CalendarCode,
			GETDATE(),
			@ProcessUserID
		)
		
		EXEC usp_DoWorkCalendar_IUD @pProcessLanguage = @ProcessLanguage,
														@pProcessUserID = @ProcessUserID,
														@pDayWorkCalendarNo = @DayWorkCalendarNo,
														@pCalendarCode = @CalendarCode,
														@pJobDate = @JobDate 

		SET @JobDate = @JobDate + 1
		SET @ROW = @ROW +1

	END	-- while


END