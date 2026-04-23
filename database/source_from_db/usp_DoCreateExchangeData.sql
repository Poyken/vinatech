CREATE PROC [dbo].[usp_DoCreateExchangeData]
AS
BEGIN
	Declare @MaxDate CHAR(8)
	       ,@CurrDate CHAR(8)

	;WITH CTE AS (
		SELECT CONVERT(CHAR(8), DATEADD(day, (-1) * number - 1, GETDATE()), 112) AS BaseDate
		  FROM MASTER.DBO.SPT_VALUES 
		 WHERE TYPE = 'P'
		   AND number < 5
	)
	SELECT @MaxDate = MAX(BaseDate)
	  FROM CTE
	 WHERE BaseDate IN (
		SELECT YYMMDD
		  FROM NEOE.NEOE.MA_EXCHANGE
		 WHERE CURR_SOUR = '001'
		   AND YYMMDD >= CONVERT(CHAR(8), DATEADD(day, -5, GETDATE()), 112)
		   AND NO_SEQ = 1
		   AND CD_COMPANY = '1000'
	 )

	DECLARE cur CURSOR FOR

	WITH CTE2 AS (
		SELECT CONVERT(CHAR(8), DATEADD(day, (-1) * number - 1, GETDATE()), 112) AS BaseDate
		  FROM MASTER.DBO.SPT_VALUES 
		 WHERE TYPE = 'P'
		   AND number < 5
	)
	SELECT BaseDate
	  FROM CTE2
	 WHERE BaseDate NOT IN (
		SELECT YYMMDD
		  FROM NEOE.NEOE.MA_EXCHANGE
		 WHERE CURR_SOUR = '001'
		   AND YYMMDD >= CONVERT(CHAR(8), DATEADD(day, -5, GETDATE()), 112)
		   AND NO_SEQ = 1
		   AND CD_COMPANY = '1000'
	 )

	OPEN cur

	FETCH NEXT FROM cur INTO @CurrDate

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO NEOE.NEOE.MA_EXCHANGE (YYMMDD ,CURR_SOUR ,CURR_DEST ,CD_COMPANY ,RATE_BASE
                                          ,RATE_SALE ,RATE_BUY ,ID_INSERT ,DTS_INSERT ,ID_UPDATE
                                          ,DTS_UPDATE ,RATE_3M ,RATE_6M ,RATE_9M ,RATE_12M
                                          ,ST_LINE ,NO_SEQ ,QUOTATION_TIME)
			SELECT @CurrDate ,CURR_SOUR ,CURR_DEST ,CD_COMPANY ,RATE_BASE
                  ,RATE_SALE ,RATE_BUY ,'17120401' ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE()) , NULL
                  ,NULL ,RATE_3M ,RATE_6M ,RATE_9M ,RATE_12M
                  ,ST_LINE ,NO_SEQ ,QUOTATION_TIME
			  FROM NEOE.NEOE.MA_EXCHANGE
			 WHERE CURR_SOUR IN ('001', '002', '003', '004')
			   AND CD_COMPANY = '1000'
			   AND NO_SEQ = 1
			   AND YYMMDD = @MaxDate

		PRINT '@MaxDate : ' + @MaxDate
		PRINT '@CurrDate : ' + @CurrDate
	
		FETCH NEXT FROM cur INTO @CurrDate
	END

	CLOSE cur
	DEALLOCATE cur
END