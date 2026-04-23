CREATE PROC [dbo].[usp_ESRInspectionMon]
AS
BEGIN
	Declare @LineName VARCHAR(20)
	       ,@Cnt NUMERIC(20, 3)
		   ,@CheckDateTime VARCHAR(8)
		   ,@IsHoliday BIT
		   ,@LineMessage NVARCHAR(MAX)

	-- 점검일이 휴무인 경우 프로시저를 중지한다. (현재 관리되고 있지 않음.)
	-- 커서 선언 시 계획정지 라인에 대한 고려가 들어가있지 않음. 
	-- 계획정지 라인이 지정되거나 새로운 라인이 추가될 경우 BaseLine 쿼리에 추가하거나 삭제해야 함.
	Declare cur CURSOR FOR
		WITH BaseLine AS
		(
			SELECT CONVERT(INT, RIGHT(LI.LineCode, 2)) AS LINE_NUM
			      ,LI.LineDesc
			      ,0 AS ESR_VALUE
			  FROM STB_LineInfo LI
			 WHERE LI.MonitoringGroup = 'Y'
		)
		SELECT BL.LineDesc AS LineName
			  ,SUM(CONVERT(NUMERIC(20,3), VEI.ESR_VALUE)) AS CNT
			  ,CONVERT(VARCHAR(8), GETDATE(), 108) AS CheckDateTime
		  FROM BaseLine BL
		  LEFT OUTER JOIN ERPSVR.VINATech.DBO.VECS_ESR_INSPECTION VEI
			ON BL.LINE_NUM = VEI.LINE_NUM
		   AND VEI.INSPECTION_DATE > DATEADD(MINUTE, -120, GETDATE())
		 WHERE 1=1
		 GROUP BY BL.LineDesc
		 HAVING SUM(CONVERT(NUMERIC(20,3), VEI.ESR_VALUE)) IS NULL
		 ORDER BY BL.LineDesc

	OPEN cur

	FETCH NEXT FROM cur INTO @LineName, @Cnt, @CheckDateTime

	WHILE @@FETCH_STATUS = 0 BEGIN
		IF @CheckDateTime BETWEEN '13:30:00' AND '14:30:00' 
		       OR @CheckDateTime BETWEEN '19:00:00' AND '20:00:00' 
			   OR @CheckDateTime BETWEEN '01:00:00' AND '02:00:00' 
			   OR @CheckDateTime BETWEEN '08:00:00' AND '09:00:00' 
		BEGIN
			SELECT '점검시간에 휴게시간이 포함되어 있습니다.'
		END ELSE BEGIN
			--INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
			--			SELECT 'yjyu@vina.co.kr', 'ESR 데이터인터페이스를 확인하세요.(' + @LineName + ')', 'ESR 데이터인터페이스를 확인하세요.(점검시간 : ' + @CheckDateTime + ')'
			--FETCH NEXT FROM cur INTO @LineName, @Cnt, @CheckDateTime

			SET @LineMessage = 'ESR 데이터인터페이스를 확인하세요.(' + @LineName + ') (점검시간 : ' + @CheckDateTime + ')'

			-- 라인 메시지 프로시저 호출
			exec usp_DoSendGembaTroubleMessage '', '', @LineMessage     --2020.08.13 Test로 추가
		END

		FETCH NEXT FROM cur INTO @LineName, @Cnt, @CheckDateTime
	END
	CLOSE cur
	DEALLOCATE cur

	-- 첫번째 점검에서 휴게시간에 걸려있었으나 최근 2시간 이내에 측정데이터가 없는 경우

	Declare cur2 CURSOR FOR
		WITH BaseLine AS
		(
			SELECT CONVERT(INT, RIGHT(LI.LineCode, 2)) AS LINE_NUM
			      ,LI.LineDesc
			      ,0 AS ESR_VALUE
			  FROM STB_LineInfo LI
			 WHERE LI.MonitoringGroup = 'Y'
		)
		SELECT BL.LineDesc AS LineName
			  ,SUM(CONVERT(NUMERIC(20,3), VEI.ESR_VALUE)) AS CNT
			  ,CONVERT(VARCHAR(8), GETDATE(), 108) AS CheckDateTime
		  FROM BaseLine BL
		  LEFT OUTER JOIN ERPSVR.VINATech.DBO.VECS_ESR_INSPECTION VEI
			ON BL.LINE_NUM = VEI.LINE_NUM
		   AND VEI.INSPECTION_DATE > DATEADD(HOUR, -2, GETDATE())
		 WHERE 1=1
		 GROUP BY BL.LineDesc
		 HAVING SUM(CONVERT(NUMERIC(20,3), VEI.ESR_VALUE)) IS NULL
		 ORDER BY BL.LineDesc

	OPEN cur2

	FETCH NEXT FROM cur2 INTO @LineName, @Cnt, @CheckDateTime

	WHILE @@FETCH_STATUS = 0 BEGIN
			--INSERT INTO STB_SystemMail (TargetMailAddress, MailSubject, MailContents)
			--			SELECT 'yjyu@vina.co.kr', 'ESR 데이터인터페이스를 확인하세요.(' + @LineName + ')', 'ESR 데이터인터페이스를 확인하세요.(점검시간 : ' + @CheckDateTime + ')'
			--FETCH NEXT FROM cur2 INTO @LineName, @Cnt, @CheckDateTime
			IF @CheckDateTime BETWEEN '13:30:00' AND '14:30:00' 
		       OR @CheckDateTime BETWEEN '19:00:00' AND '20:00:00' 
			   OR @CheckDateTime BETWEEN '01:00:00' AND '02:00:00' 
			   OR @CheckDateTime BETWEEN '08:00:00' AND '09:00:00' BEGIN

			   SET @LineMessage = 'ESR 데이터인터페이스를 확인하세요.(' + @LineName + ') (점검시간 : ' + @CheckDateTime + ')'

				-- 라인 메시지 프로시저 호출
				exec usp_DoSendGembaTroubleMessage '', '', @LineMessage   --2020.08.13 Test로 추가
			END

			FETCH NEXT FROM cur2 INTO @LineName, @Cnt, @CheckDateTime
	END

	CLOSE cur2
	DEALLOCATE cur2
END