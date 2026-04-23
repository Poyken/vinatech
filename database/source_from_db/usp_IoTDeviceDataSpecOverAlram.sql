-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 20200406
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	온/습도 상하한 체크 및 SMS 발송
-- Modified: 삼성 심사 테스트를 위한 조건 변경 (1시간 안쪽으로 1번이라도 스펙오버일 경우 발송)
-- =============================================
CREATE PROC [dbo].[usp_IoTDeviceDataSpecOverAlram]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @DeviceID VARCHAR(20) 
	       ,@DeviceClassName NVARCHAR(100)
		   ,@DeviceLocationName NVARCHAR(100)
		   ,@DeviceLocationDetail NVARCHAR(100)
		   ,@CheckResult INT
		   ,@TempLSL NUMERIC(10,2)
		   ,@TempUSL NUMERIC(10,2)
		   ,@HumiLSL NUMERIC(10,2)
		   ,@HumiUSL NUMERIC(10,2)
		   ,@SMSMsg NVARCHAR(1000)
		   ,@SMSParams NVARCHAR(1000)
		   ,@MailTitle NVARCHAR(MAX)
		   ,@ToAddress VARCHAR(MAX)
		   ,@MailContents NVARCHAR(MAX)
		   ,@MaxTempValue NUMERIC(20,2)
		   ,@MaxHumiValue NUMERIC(20,2)

	DECLARE cur1 CURSOR FOR

	SELECT IDI.DeviceID
		  ,BC.Description AS DeviceClassName
		  ,BC2.Description AS DeviceLocationName
		  ,BC2.Remark AS DeviceLocationDetail
		  ,IDI.TempLSL
		  ,IDI.TempUSL
		  ,IDI.HumiLSL
		  ,IDI.HumiUSL
	  FROM STB_IoTDeviceInfo IDI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'DeviceClassCode'
	   AND BC.ItemCode = IDI.DeviceClassCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'DeviceLocationCode'
	   AND BC2.ItemCode = IDI.DeviceLocationCode
	 WHERE IDI.IsUsed = CONVERT(BIT, 1)	 
	 ORDER BY IDI.DeviceID ASC

	OPEN cur1

	FETCH NEXT FROM cur1 INTO @DeviceID,@DeviceClassName, @DeviceLocationName, @DeviceLocationDetail
	                         ,@TempLSL, @TempUSL, @HumiLSL, @HumiUSL

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @DeviceID = 'SHT_test_01' BEGIN
			SET @ToAddress = 'mschae@vina.co.kr;wskang@vina.co.kr;kbnam@vina.co.kr;yjyu@vina.co.kr'
		END

		IF @DeviceID IN ('DHT_04', 'DHT_06') BEGIN
			SET @ToAddress = 'mschae@vina.co.kr;hjjo@vina.co.kr;jskim@vina.co.kr;sspark@vina.co.kr;drchoi@vina.co.kr;yjyu@vina.co.kr'
		END

		IF @DeviceID = 'SHT_02' BEGIN
			SET @ToAddress = 'bgkoo@vina.co.kr;gaoyan@vina.co.kr;ecrkim@vina.co.kr;yjyu@vina.co.kr'
		END

		IF @DeviceID = 'DHT_03' BEGIN
			SET @ToAddress = 'ehchoi@vina.co.kr;mskim@vina.co.kr;yjyu@vina.co.kr'
		END

		IF @DeviceID = 'DHT_07' BEGIN
			SET @ToAddress = 'twkim@vina.co.kr;ucjo@vina.co.kr;yjyu@vina.co.kr'
		END

		-- 온도 상하한 체크
		SELECT @CheckResult = COUNT(*)
		      ,@MaxTempValue = MAX(MeasureValue)
		  FROM STB_IoTMeasureHist
		 WHERE DeviceID = @DeviceID
		   AND MeasureItemCode = 'Temperature'
		   AND (CASE WHEN MeasureItemCode = 'Temperature' AND DeviceID = 'SHT_02' THEN  MeasureValue - 1.72 
			         WHEN MeasureItemCode = 'Temperature' AND DeviceID = 'DHT_02' THEN  MeasureValue - 2.9 
		             ELSE MeasureValue END < @TempLSL 
					OR CASE WHEN MeasureItemCode = 'Temperature' AND DeviceID = 'SHT_02' THEN  MeasureValue - 1.72 
						    WHEN MeasureItemCode = 'Temperature' AND DeviceID = 'DHT_02' THEN  MeasureValue - 2.9 
						    ELSE MeasureValue END > @TempUSL)
					   AND CreateDateTime > DATEADD(hour, -1, GETDATE())

		-- 결과값 10개 이상이면 메일 세팅
		IF @CheckResult > 10 BEGIN
			SET @MailTitle = @DeviceLocationDetail + '의 온도가 상/하한을 초과하였습니다.'

			SET @MailContents = '최근 한 시간 온도 데이터 모니터링 결과 온도 상/하한 초과가 10건 이상 발생하였습니다.<br />'
			SET @MailContents = @MailContents + '상태 점검 및 조치 부탁드립니다.<br /><br />'
			SET @MailContents = @MailContents + '점검일시 : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + '<br />'
			SET @MailContents = @MailContents + '점검구간 중 온도 최대값  : ' + CONVERT(VARCHAR(30), @MaxTempValue)

			exec usp_DoAddSystemMail '', '', @ToAddress, @MailTitle, @MailContents

			-- 라인 메시지 추가 발송
			exec usp_DoSendGembaTroubleMessage '', '', @MailTitle
		END

		-- 습도 상하한 체크
		SELECT @CheckResult = COUNT(*)
		      ,@MaxHumiValue = MAX(MeasureValue)
		  FROM STB_IoTMeasureHist
		 WHERE DeviceID = @DeviceID
		   AND MeasureItemCode = 'Humidity'
		   AND (CASE WHEN MeasureItemCode = 'Humidity' AND DeviceID = 'SHT_02' THEN  MeasureValue - 9.25
			         WHEN MeasureItemCode = 'Humidity' AND DeviceID = 'DHT_02' THEN  MeasureValue - 12.7 - 2.9
		             ELSE MeasureValue END < @HumiLSL 
					 OR CASE WHEN MeasureItemCode = 'Humidity' AND DeviceID = 'SHT_02' THEN  MeasureValue - 9.25
							 WHEN MeasureItemCode = 'Humidity' AND DeviceID = 'DHT_02' THEN  MeasureValue - 12.7 - 2.9
							 ELSE MeasureValue END > @HumiUSL)
		   AND CreateDateTime > DATEADD(hour, -1, GETDATE())

		-- 결과값 10개 이상이면 메일 세팅
		IF @CheckResult > 10 BEGIN
			SET @MailTitle = @DeviceLocationDetail + '의 습도가 상/하한을 초과하였습니다.'

			SET @MailContents = '최근 한 시간 습도 데이터 모니터링 결과 습도 상/하한 초과가 10건 이상 발생하였습니다.<br />'
			SET @MailContents = @MailContents + '상태 점검 및 조치 부탁드립니다.<br /><br />'
			SET @MailContents = @MailContents + '점검일시 : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + '<br />'
			SET @MailContents = @MailContents + '점검구간 중 습도 최대값  : ' + CONVERT(VARCHAR(30), @MaxHumiValue)

			exec usp_DoAddSystemMail '', '', @ToAddress, @MailTitle, @MailContents

			-- 라인 메시지 추가 발송
			exec usp_DoSendGembaTroubleMessage '', '', @MailTitle
		END
	
		FETCH NEXT FROM cur1 INTO @DeviceID,@DeviceClassName,@DeviceLocationName,@DeviceLocationDetail
		                         ,@TempLSL, @TempUSL, @HumiLSL, @HumiUSL
	END

	CLOSE cur1
	DEALLOCATE cur1
END