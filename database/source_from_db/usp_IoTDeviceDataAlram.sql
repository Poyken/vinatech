-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-06
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	IoT디바이스 데이터 수집 모니터링
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_IoTDeviceDataAlram]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @DeviceID VARCHAR(20) 
	       ,@DeviceClassName NVARCHAR(100)
		   ,@DeviceLocationName NVARCHAR(100)
		   ,@DeviceLocationDetail NVARCHAR(100)
	       ,@DataCount INT
		   ,@SMSMsg NVARCHAR(1000)
		   ,@SMSParams NVARCHAR(1000)

	DECLARE cur1 CURSOR FOR

	SELECT IDI.DeviceID
	      --,IDI.DeviceClassCode
		  ,BC.Description AS DeviceClassName
		  --,IDI.DeviceLocationCode
		  ,BC2.Description AS DeviceLocationName
		  ,BC2.Remark AS DeviceLocationDetail
	  FROM STB_IoTDeviceInfo IDI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'DeviceClassCode'
	   AND BC.ItemCode = IDI.DeviceClassCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON BC2.CodeGroup = 'DeviceLocationCode'
	   AND BC2.ItemCode = IDI.DeviceLocationCode
	 WHERE IDI.IsUsed = CONVERT(BIT, 1)	
	   AND IDI.DeviceID <> 'DHT_04' -- 채민수대리 테스트 관련 대여 상태임. 임시로 모니터링에서 제외 by Jackaroe #2021-05-25
	 ORDER BY IDI.DeviceID ASC

	OPEN cur1

	FETCH NEXT FROM cur1 INTO @DeviceID,@DeviceClassName, @DeviceLocationName, @DeviceLocationDetail

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 최근 30분 데이터를 조회
		SELECT @DataCount = COUNT(*)
		  FROM STB_IoTMeasureHist
		 WHERE DeviceID = @DeviceID
		   AND CreateDateTime > DATEADD(minute, -30, GETDATE())

		-- 결과값이 없으면 SMS 세팅
		IF @DataCount = 0 BEGIN
			SET @SMSMsg = '디바이스 상태를 확인하세요. {#1},{#2},{#3},{#4},{#5}'
			SET @SMSParams = @DeviceID + ',' + @DeviceClassName + ',' + @DeviceLocationName + ',' + @DeviceLocationDetail + ',' + CONVERT(VARCHAR(20), GETDATE(), 121)

			-- IoT 디바이스의 장애 메시지를 SMS에서 Line으로 변경 2020.08.21 By Jackaroe
			exec usp_DoSendLineMessageTest '', '', @SMSMsg, @SMSParams

			--exec usp_DoSendSMS '', '', '01032226697', @SMSMsg, @SMSParams

			--IF @DeviceID = 'DHT_02' BEGIN -- 자재창고이면 자재창고 담당자에게 추가로 전송한다.
			--	SET @SMSMsg = '디바이스 상태를 확인하세요. {#1},{#2},{#3},{#4},{#5}'
			--	SET @SMSParams = @DeviceID + ',' + @DeviceClassName + ',' + @DeviceLocationName + ',' + @DeviceLocationDetail + ',' + CONVERT(VARCHAR(20), GETDATE(), 121)

			--	exec usp_DoSendSMS '', '', '01084160408', @SMSMsg, @SMSParams
			--END
		END

		FETCH NEXT FROM cur1 INTO @DeviceID,@DeviceClassName,@DeviceLocationName,@DeviceLocationDetail
	END

	CLOSE cur1
	DEALLOCATE cur1
END