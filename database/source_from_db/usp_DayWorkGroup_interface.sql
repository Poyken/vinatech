
CREATE PROC [dbo].[usp_DayWorkGroup_interface] @pCompanyCode VARCHAR(20), @pWorkCenterCode VARCHAR(20)
AS
BEGIN 
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
		   ,@WorkGroupCode VARCHAR(1)
		   ,@JobDate DATE = GETDATE()

	-- 근무조 정보 삭제
	DELETE FROM STB_DayWorkGroup 
	 WHERE CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND JobDate = @JobDate

	-- 근무조 정보 입력
	INSERT INTO STB_DayWorkGroup (CompanyCode, WorkCenterCode, JobDate, WorkerCode, WorkGroupCode
	                             ,WorkGroupName
								 )
			SELECT 'VNT', 'VNT_F1', @JobDate, 사원번호, CASE 근무조 WHEN 'X' THEN 'A'
			                                                         WHEN 'Y' THEN 'B'
																	 WHEN 'Z' THEN 'C'
																	 WHEN 'A' THEN 'D'
																	 END
			      ,CASE 근무조 WHEN 'X' THEN 'ACE'
			                   WHEN 'Y' THEN 'BEST'
							   WHEN 'Z' THEN 'CORE'
							   WHEN 'A' THEN '주간고정'
							   END
			  FROM ERPDB.DBO.근무조
			 WHERE 근무조 IN ('X', 'Y', 'Z','A')

	-- 주,야,휴 정보 업데이트
	SELECT @WorkGroupCode = LEFT(CalendarCode, 1)
	  FROM STB_DayWorkCalendar
	 WHERE JobDate = @JobDate
	   AND CalendarCode LIKE '%Day'

	UPDATE STB_DayWorkGroup
	   SET ShiftCode = 1
	 WHERE WorkGroupCode IN (@WorkGroupCode, 'D')
	   AND CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND JobDate = @JobDate

	SELECT @WorkGroupCode = LEFT(CalendarCode, 1)
	  FROM STB_DayWorkCalendar
	 WHERE JobDate = @JobDate
	   AND CalendarCode LIKE '%Night'

	UPDATE STB_DayWorkGroup
	   SET ShiftCode = 2
	 WHERE WorkGroupCode = @WorkGroupCode
	   AND CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND JobDate = @JobDate

	UPDATE STB_DayWorkGroup
	   SET ShiftCode = 3
	 WHERE CompanyCode = @CompanyCode
	   AND WorkCenterCode = @WorkCenterCode
	   AND JobDate = @JobDate
	   AND ShiftCode IS NULL
	   AND WorkGroupCode <> 'D'


END