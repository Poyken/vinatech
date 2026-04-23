CREATE PROC usp_DailyWorkCalendar_Interface
AS
BEGIN
	Declare @DayWorkCalendarNo VARCHAR(20)
	Declare @JobDate Date
	Declare @CalendarCode1 VARCHAR(20)
	Declare @CalendarCode2 VARCHAR(20)
	Declare @CalendarName1 VARCHAR(50)
	Declare @CalendarName2 VARCHAR(50)
	Declare @MailContents NVARCHAR(MAX)

	-- 주간근무
	EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_DayWorkCalendar', @DayWorkCalendarNo OUTPUT

	SELECT @JobDate = CONVERT(VARCHAR(10), GETDATE(), 121)
	      ,@CalendarCode1 = 근무조+'Day'
	  FROM erpdb.dbo.생산CALENDAR_3조2교대_REF
	 WHERE ID = (DATEDIFF ( day , '2018-05-01',  CONVERT(DATE,GETDATE()+1)) % 12)
	   AND 근무구분 = '주'

	INSERT INTO STB_DayWorkCalendar (DayWorkCalendarNo, JobDate, CompanyCode, WorkCenterCode, CalendarCode
	                                ,StartDateTime, EndDateTime, CreateDateTime, CreateUserID)
		VALUES (@DayWorkCalendarNo, @JobDate, 'VNT', 'VNT_F1', @CalendarCode1
		       ,CONVERT(VARCHAR(10), @JobDate, 121) + ' 08:30:00', CONVERT(VARCHAR(10), @JobDate, 121) + ' 20:30:00', GETDATE(), 'eai')

	-- 야간근무
    EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_DayWorkCalendar', @DayWorkCalendarNo OUTPUT

	SELECT @JobDate = CONVERT(VARCHAR(10), GETDATE(), 121)
	      ,@CalendarCode2 = 근무조+'Night'
	  FROM erpdb.dbo.생산CALENDAR_3조2교대_REF
	 WHERE ID = (DATEDIFF ( day , '2018-05-01',  CONVERT(DATE,GETDATE()+1)) % 12)
	   AND 근무구분 = '야'

	INSERT INTO STB_DayWorkCalendar (DayWorkCalendarNo, JobDate, CompanyCode, WorkCenterCode, CalendarCode
	                                ,StartDateTime, EndDateTime, CreateDateTime, CreateUserID)
		VALUES (@DayWorkCalendarNo, @JobDate, 'VNT', 'VNT_F1', @CalendarCode2
		       ,CONVERT(VARCHAR(10), @JobDate, 121) + ' 20:30:00', CONVERT(VARCHAR(10), DATEADD(day, 1, @JobDate), 121) + ' 08:30:00', GETDATE(), 'eai')

	---- 메일발송
	--SELECT @CalendarName1 = CalendarName FROM STB_CalendarMaster WHERE CalendarCode = @CalendarCode1
	--SELECT @CalendarName2 = CalendarName FROM STB_CalendarMaster WHERE CalendarCode = @CalendarCode2

	--SET @MailContents = '일일근무카렌더가 정상 입력되었습니다.
	--		작업일 : ' + CONVERT(VARCHAR(10), @JobDate, 121) + '
	--		주간 : ' + @CalendarName1 + '
	--		야간 : ' + @CalendarName2
			

			--INSERT INTO OLDNAISSVR.SmartFactoryV2.dbo.STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
			--	SELECT 'yjyu@vina.co.kr', '일일근무카렌더가 정상 입력되었습니다.(' + CONVERT(VARCHAR(10), @JobDate, 121) + ')', @MailContents
END