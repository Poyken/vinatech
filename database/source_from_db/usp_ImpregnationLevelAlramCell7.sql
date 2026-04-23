-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	7호기 함침 수위 알람
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ImpregnationLevelAlramCell7]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	Declare @LineCode VARCHAR(20) = 'ASSYLINE-07'
	       ,@ManagerMailAddressList VARCHAR(MAX)
		   ,@MailSubject VARCHAR(1000) 
		   ,@EmailContents VARCHAR(MAX)
		   ,@SpecOverCnt INT
		   ,@CurrentTime VARCHAR(8) = CONVERT(VARCHAR(8), GETDATE(), 108)
		   ,@LevelMaxValue NUMERIC(20,2) 
		   ,@LevelMinValue NUMERIC(20,2) 

	SELECT COUNT(*)
	  FROM ERPSVR.VINATech.DBO.PLC_셀7_조립
	 WHERE CRT_YMS > DATEADD(MINUTE, -10, GETDATE())
	   AND (ELELVL > 80 OR ELELVL < 20)

	IF @CurrentTime BETWEEN '17:00:00' AND '19:40:00' BEGIN
		PRINT '점검 예외 시간'
	END ELSE BEGIN
		IF @SpecOverCnt > 0 BEGIN
			SELECT @LevelMinValue = MIN(ELELVL)
				  ,@LevelMaxValue = MAX(ELELVL)
			  FROM ERPSVR.VINATech.DBO.PLC_셀7_조립
			 WHERE CRT_YMS > DATEADD(MINUTE, -10, GETDATE())
			   AND (ELELVL > 80 OR ELELVL < 20)

			SELECT @ManagerMailAddressList = COALESCE(@ManagerMailAddressList + ';','') + ManagerEmail
			  FROM STB_LineManagerEmailInfo
			 WHERE LineCode = @LineCode
				
			-- 메일내용 조립
			SET @MailSubject = '셀 7호기 함침수위 스펙오버가 발생하였습니다. (' + @LineCode + ' : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + ')'
			SET @EmailContents = '라인코드 : ' + @LineCode + '<br />'
			SET @EmailContents = @EmailContents + '점검일시 : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + '<br /><br />'
			SET @EmailContents = @EmailContents + '점검값(최소) : ' + CONVERT(VARCHAR(10), @LevelMinValue) + '<br />'
			SET @EmailContents = @EmailContents + '점검값(최대) : ' + CONVERT(VARCHAR(10), @LevelMaxValue) + '<br />'

			-- 메일발송
			EXEC usp_DoAddSystemMail @pProcessUserID = '' 
			                ,@pProcessLanguage = ''
							,@pTargetMailAddress=@ManagerMailAddressList
							,@pMailSubject = @MailSubject
							,@pMailContents = @EmailContents
		END
	END
END
