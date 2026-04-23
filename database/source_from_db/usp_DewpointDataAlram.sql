-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-03-03
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	라인 노점온도 데이터 알람
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_DewpointDataAlram]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @LineCode VARCHAR(20) 
	       ,@LineName NVARCHAR(100)
	       ,@DataCount INT
		   ,@SMSMsg NVARCHAR(1000)
		   ,@SMSParams NVARCHAR(1000)

	DECLARE cur1 CURSOR FOR

	SELECT DD.LineCode
	      ,LI.LineDesc AS LineName
	  FROM STB_DewpointData DD
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LI.LineCode = DD.LineCode
	 --WHERE LI.LineCode NOT IN ('ASSYLINE-15')
	 GROUP BY DD.LineCode, LI.LineDesc
	 ORDER BY DD.LineCode, LI.LineDesc


	OPEN cur1

	FETCH NEXT FROM cur1 INTO @LineCode, @LineName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- 최근 30분 데이터를 조회
		SELECT @DataCount = COUNT(*)
		  FROM STB_DewpointData
		 WHERE LineCode = @LineCode
		   AND CreateDateTime > DATEADD(minute, -30, GETDATE())

		-- 결과값이 없으면 SMS 세팅
		IF @DataCount = 0 BEGIN
			SET @SMSMsg = '{#1} 이후 노점온도 데이터가 존재하지 않습니다. 상태를 확인하세요. {#2}({#3})'
			SET @SMSParams = CONVERT(VARCHAR(20), GETDATE(), 121) + ',' + @LineName + ',' + @LineCode

			-- IoT 디바이스의 장애 메시지를 SMS에서 Line으로 변경 2020.08.21 By Jackaroe
			IF CONVERT(INT, CONVERT(CHAR(2), GETDATE(), 108)) BETWEEN 9 AND 18 BEGIN
				exec usp_DoSendLineMessage '', '', @SMSMsg, @SMSParams
			END ELSE BEGIN
				exec usp_DoSendLineMessageTest '', '', @SMSMsg, @SMSParams
			END

			
		END

		FETCH NEXT FROM cur1 INTO @LineCode, @LineName
	END

	CLOSE cur1
	DEALLOCATE cur1
END