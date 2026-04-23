-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	라인별 담당자 정보 조회
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ESRSpecOverAlram]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET XACT_ABORT OFF

	Declare @BaseDate DATE = CASE WHEN CONVERT(VARCHAR(8), GETDATE(), 108) < '08:30:00' 
	                              THEN CONVERT(DATE, DATEADD(day, -1, GETDATE())) 
								  ELSE CONVERT(DATE, GETDATE()) END
	       ,@BaseDateCheckCnt INT
	       ,@CheckSeq INT
	       ,@CheckStartDateTime DATETIME
		   ,@CheckSpecOverCnt INT
		   ,@CheckInspFailCnt INT
		   ,@ManagerMailAddressList VARCHAR(MAX) = NULL
		   ,@MailSubject VARCHAR(500)
		   ,@EmailContents VARCHAR(MAX)
		   ,@LineMessageContents NVARCHAR(MAX)

	-- for cursor
	Declare @LineCode VARCHAR(20)
	       ,@LineNumber INT
		   ,@MaterialCode VARCHAR(20)
		   ,@LSL NUMERIC(20,5)
		   ,@USL NUMERIC(20,5)
		   ,@LineName VARCHAR(50)

	DECLARE cur CURSOR FOR

	-- 최근 3일 이내 라인 ESR측정내역 중 
	SELECT DISTINCT 'ASSYLINE-'+RIGHT('0' + CONVERT(VARCHAR(5), LINE_NUM), 2), LINE_NUM, MaterialCode
	  FROM ERPSVR.VINATech.dbo.VECS_ESR_INSPECTION
	 WHERE INSPECTION_DATE > DATEADD(day, -3, GETDATE())

	OPEN cur

	FETCH NEXT FROM cur INTO @LineCode, @LineNumber, @MaterialCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @MaterialCode

		exec usp_GetMaterialESRSpec @MaterialCode, NULL, @LSL OUTPUT, @USL OUTPUT

		-- 점검기준정보 체크 및 생성
		SELECT @BaseDateCheckCnt = COUNT(*)
		  FROM STB_ESRSpecOverInfo
		 WHERE BaseDate = @BaseDate
		   AND LineCode = @LineCode

		PRINT @LineCode + ' / ' + CONVERT(VARCHAR(10), @BaseDateCheckCnt)

		IF @BaseDateCheckCnt = 0 BEGIN
			INSERT INTO STB_ESRSpecOverInfo (BaseDate, LineCode, Seq, CheckStartDateTime) 
					VALUES (@BaseDate, @LineCode, 1, CONVERT(VARCHAR(10), GETDATE(), 121) + ' 08:30:00' )
		END

		-- 라인 점검 시작시간(MAX) 쿼리
		SELECT TOP 1 @CheckStartDateTime = CheckStartDateTime
		      ,@CheckSeq = Seq
		  FROM STB_ESRSpecOverInfo
		 WHERE BaseDate = @BaseDate
		   AND LineCode = @LineCode
		 ORDER BY Seq DESC

		-- 점검시작일시 이후 스펙오버 건수 체크
		SELECT @CheckSpecOverCnt = COUNT(*)
		  FROM ERPSVR.VINATech.dbo.VECS_ESR_INSPECTION
		 WHERE INSPECTION_DATE > @CheckStartDateTime
		   AND LINE_NUM = @LineNumber
		   AND (CONVERT(NUMERIC(20,5), LEFT(ESR_VALUE, 6)) > @USL OR CONVERT(NUMERIC(20,5), LEFT(ESR_VALUE, 6)) < @LSL)

		-- 측정불능 건 추가 2020.01.31
		SELECT @CheckInspFailCnt = COUNT(*)
		  FROM ERPSVR.VINATech.dbo.VECS_ESR_INSPECTION_LOG
		 WHERE INSPECTION_DATE > @CheckStartDateTime
		   AND LINE_NUM = @LineNumber
		   AND LINE_NUM <> 11

		IF (@CheckSpecOverCnt + @CheckInspFailCnt) < 30 BEGIN
			-- 현재상태 업데이트
			UPDATE STB_ESRSpecOverInfo
			   SET SpecOverCount = @CheckSpecOverCnt + @CheckInspFailCnt
			      ,LastCheckDateTime = GETDATE()
			 WHERE BaseDate = @BaseDate
			   AND LineCode = @LineCode
			   AND Seq = @CheckSeq
		END ELSE BEGIN
			-- 이메일 발송
				-- 라인별 관리자 정보 조립
				SELECT @ManagerMailAddressList = COALESCE(@ManagerMailAddressList + ';','') + ManagerEmail
				  FROM STB_LineManagerEmailInfo
				 WHERE LineCode = @LineCode

				-- 라인명 
				SELECT @LineName = LineName
				  FROM STB_LineInfo LI
				 WHERE LineCode = @LineCode 
				
				-- 메일내용 조립
				SET @MailSubject = 'ESR 스펙오버가 발생하였습니다. (' + @LineName + ' : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + ')'
				SET @EmailContents = '라인코드 : ' + @LineCode + '<br />'
				SET @EmailContents = '라인명 : ' + @LineName + '<br />'
				SET @EmailContents = @EmailContents + '점검시작일시 : ' + CONVERT(VARCHAR(20), @CheckStartDateTime, 121) + '<br />'
				SET @EmailContents = @EmailContents + '점검일시 : ' + CONVERT(VARCHAR(20), GETDATE(), 121) + '<br />'
				SET @EmailContents = @EmailContents + '스펙오버 누적발생건수 : ' + CONVERT(VARCHAR(20), (@CheckSpecOverCnt + @CheckInspFailCnt))

				-- 메일발송
			EXEC usp_DoAddSystemMail @pProcessUserID = '' 
			                ,@pProcessLanguage = ''
							,@pTargetMailAddress=@ManagerMailAddressList
							,@pMailSubject = @MailSubject
							,@pMailContents = @EmailContents

				SET @LineMessageContents = REPLACE(@MailSubject + ' / ' + @EmailContents, '<br />', ', ')
			   
			   EXEC usp_DoSendGembaTroubleMessage '', '', @LineMessageContents

			-- LastCheckDateTime, CheckEndDateTime, SpecOverCount 업데이트
			UPDATE STB_ESRSpecOverInfo
			   SET SpecOverCount = @CheckSpecOverCnt + @CheckInspFailCnt
			      ,LastCheckDateTime = GETDATE()
				  ,CheckEndDateTime = GETDATE()
			 WHERE BaseDate = @BaseDate
			   AND LineCode = @LineCode
			   AND Seq = @CheckSeq

			-- 새로운 체크 기준시간 생성
			INSERT INTO STB_ESRSpecOverInfo (BaseDate, LineCode, Seq, CheckStartDateTime) 
					VALUES (@BaseDate, @LineCode, @CheckSeq + 1, GETDATE())
		END
		
	
		FETCH NEXT FROM cur INTO @LineCode, @LineNumber, @MaterialCode
	END

	CLOSE cur
	DEALLOCATE cur
END
