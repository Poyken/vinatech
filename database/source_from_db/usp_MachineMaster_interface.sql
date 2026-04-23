CREATE PROC [dbo].[usp_MachineMaster_interface]
AS
BEGIN
	Declare @cnt int
	Declare @MailContents NVARCHAR(MAX)
	
	INSERT STB_MachineMaster (MachineCode, CompanyCode, WorkCenterCode, MachineName, IsProdMachine, MachineTypeCode, IsUsed, IsMonitoring, IsAlarm, CreateDateTime, CreateUserID) 
			select 설비코드, 'VNT', 'VNT_F1', 설비명, 1, 'M000' + 설비구분, 1, 1, 1, GETDATE(), 'eai'
			  from erpdb.dbo.설비자료
			 where 설비코드 NOT IN (SELECT MachineCode FROM STB_MachineMaster)

	SELECT @cnt = COUNT(*)
	  FROM STB_MachineMaster
	 WHERE CreateDateTime > CONVERT(VARCHAR(10), GETDATE(), 121)

	 IF @cnt <> 0 BEGIN
		-- 메일발송
		SET @MailContents = 'ERP 설비정보가 인터페이스 되었습니다.
				인터페이스 기준일 : ' + CONVERT(VARCHAR(10), GETDATE(), 121) + '
				인터페이스 건수 : ' + CONVERT(VARCHAR(10), @cnt)
			

				INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
					SELECT 'yjyu@vina.co.kr', 'ERP 설비정보가 인터페이스 되었습니다.(' + CONVERT(VARCHAR(10), GETDATE(), 121) + ')', @MailContents
	 END
END
