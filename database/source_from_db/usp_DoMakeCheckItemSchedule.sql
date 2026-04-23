-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-07-26
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeCheckItemSchedule]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pCheckStandardNo VARCHAR(20),
	@pCheckStartDate DATE,
	@pRepeatCycleCode VARCHAR(10),
	@pCheckDateOption VARCHAR(10),
	@pDayOfTheWeek INT = NULL
AS
    
BEGIN
    Declare @CheckStandardNo VARCHAR(20) = @pCheckStandardNo
	       ,@CheckStartDate DATE = @pCheckStartDate
		   ,@RepeatCycleCode VARCHAR(10) = @pRepeatCycleCode
		   ,@CheckDateOption VARCHAR(10) = @pCheckDateOption
		   ,@DayOfTheWeek INT = @pDayOfTheWeek
		   ,@CheckDate DATE
		   ,@CheckScheduleNo VARCHAR(20)
		   ,@InitDate DATE

	-- 점검일정 테이블 변수
	Declare @Schedule TABLE 
	(
		CheckDate DATE
	)
	-- 10년을 기준으로 조건에 따라 점검스케쥴을 생성한다.
	Declare @CheckCurrentDate DATE
	Declare @CheckEndDate DATE

	-- 일정을 업데이트 할 수 있게 변경하면서, 삭제 로직을 추가함.
	-- 프로시저가 호출된 날짜와 점검시작일자를 비교하여 큰 날짜를 기준으로 이후 일정을 삭제한다.
	-- 2019.09.03 주영진 차장님 요청 By Jackaroe
	IF @CheckStartDate > GETDATE() BEGIN
		SET @InitDate = @CheckStartDate
	END ELSE BEGIN
		SET @InitDate = GETDATE()
	END

	DELETE FROM STB_CheckScheduleInfo
	 WHERE CheckDate >= @InitDate
	   AND CheckStandardNo = @CheckStandardNo

	-- 스케줄 생성 시점도 오늘 날짜와 점검시작일 중 큰 일자를 기준으로 한다.
	SET @CheckCurrentDate = @InitDate

	SELECT @CheckEndDate = DATEADD(year, 10, @CheckStartDate)

	WHILE @CheckEndDate >= @CheckCurrentDate BEGIN
		INSERT INTO @Schedule (CheckDate) VALUES (@CheckCurrentDate)

		IF @RepeatCycleCode = '1' BEGIN
			SET @CheckCurrentDate = DATEADD(day, 1, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '2' BEGIN
			SET @CheckCurrentDate = DATEADD(day, 2, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '3' BEGIN
			SET @CheckCurrentDate = DATEADD(week, 1, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '4' BEGIN
			SET @CheckCurrentDate = DATEADD(week, 2, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '5' BEGIN
			SET @CheckCurrentDate = DATEADD(month, 1, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '6' BEGIN
			SET @CheckCurrentDate = DATEADD(q, 1, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '7' BEGIN
			SET @CheckCurrentDate = DATEADD(q, 2, @CheckCurrentDate)
		END

		IF @RepeatCycleCode = '8' BEGIN
			SET @CheckCurrentDate = DATEADD(year, 1, @CheckCurrentDate)
		END

		IF @RepeatCycleCode <> '1' AND ISNULL(@DayOfTheWeek, 0) <> 0 BEGIN
			-- 반복 주기가 월 이상인 경우 요일을 설정하면, 날짜가 밀리는 현상이 생김.
			-- ex. 2019-08-01 시작으로 매월 목요일로 설정하면, 09-05 -> 10.10 -> 11.14
			-- 반복 주기가 주 이상인 경우 계산된 주차의 일요일로 수정해 줌.
			IF CONVERT(INT, @RepeatCycleCode) >= 3 BEGIN 
				SET @CheckCurrentDate = dbo.fnGetFirstDayOfWeek(@CheckCurrentDate)
			END
			
			WHILE DATEPART(WEEKDAY,@CheckCurrentDate) <> @DayOfTheWeek BEGIN
				SET @CheckCurrentDate = DATEADD(day, 1, @CheckCurrentDate)
			END
		END
	END

	DECLARE cur CURSOR FOR
		SELECT CheckDate
		  FROM @Schedule

	OPEN cur
	FETCH NEXT FROM cur INTO @CheckDate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CheckScheduleInfo',@CheckScheduleNo OUTPUT

		INSERT INTO STB_CheckScheduleInfo (CheckScheduleNo, CheckStandardNo, CheckDate, IsUsed)
			SELECT @CheckScheduleNo, @CheckStandardNo, @CheckDate, 1

		FETCH NEXT FROM cur INTO @CheckDate
	END

END