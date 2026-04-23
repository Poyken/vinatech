-- =============================================
-- Author:	
-- Create date: 
-- Browsable : true
-- Group : 급여명세 인터페이스 
-- Description:  
-- =============================================


CREATE PROC [dbo].[usp_DoCreateEmployeeWorkTime]
					@pProcessUserID VARCHAR(20)
				   ,@pProcessLanguage VARCHAR(20)
				   ,@pBaseMonth DATE = NULL
AS

BEGIN

	 Declare @BaseMonth CHAR(6)
			   ,@NO_EMP VARCHAR(20) 
			   ,@ProcessingCount INT
			   ,@PayrollCreationHist VARCHAR(20)


	IF @pBaseMonth IS NULL BEGIN
		SELECT @BaseMonth = CONVERT(CHAR(6) 
								   , CASE WHEN CONVERT(INT, RIGHT(CONVERT(CHAR(8), GETDATE(), 112), 2)) <= 5 
									    	 THEN DATEADD(Month, -1, GETDATE())
										 ELSE GETDATE() END
								   ,112)

	END 
	
	ELSE 
	
	BEGIN
		SET @BaseMonth = CONVERT(CHAR(6), @pBaseMonth, 112)
	END

	--일괄 처리 전 기존 데이터 삭제
	DELETE FROM STB_WorkTimeInfo WHERE YM = @BaseMonth

	-- Cursor부분
	DECLARE cur CURSOR FOR

	SELECT NO_EMP
	  FROM NEOE.NEOE.MA_EMP
     WHERE CD_COMPANY = '1000'
	   AND (ISDATE(DT_RETIRE) = 0 OR DT_RETIRE > @BaseMonth+'01')
	 ORDER BY NO_EMP

	OPEN cur

	FETCH NEXT FROM cur INTO @NO_EMP

	WHILE @@FETCH_STATUS = 0

	BEGIN
		PRINT '@NO_EMP : ' + @NO_EMP
		exec NEOE.NEOE.VinatechWorkTime @P_CD_COMPANY=N'1000'
		                               ,@P_MULTI_BIZAREA=N''
									   ,@P_MULTI_DEPT=N''
									   ,@P_MULTI_SERIES=N''
									   ,@P_MULTI_CC=N''
									   ,@P_YM=@BaseMonth
									   ,@P_NO_SEQ=2
									   ,@P_CD_EMP=N''
									   ,@P_MULTI_TP_EMP=N''
									   ,@P_TP_PAY=N'001'
									   ,@P_CD_INCOM=N''
									   ,@P_TP_SUM=N'001'
									   ,@P_TP_REPORT=N'100'
									   ,@P_STATUS=N'N'
									   ,@P_MULTI_EMP=@NO_EMP
									   ,@P_AM_TOTPAY=N'Y'
									   ,@P_TP_SUM_INFO=N''
									   ,@P_TP_TIME=N'Y'
	
		FETCH NEXT FROM cur INTO @NO_EMP
	END

	CLOSE cur
	DEALLOCATE cur
END