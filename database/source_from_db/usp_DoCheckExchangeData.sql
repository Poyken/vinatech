CREATE PROC usp_DoCheckExchangeData
AS
BEGIN
	Declare @WeekNumber INT 
	       ,@ExchangeDataCnt INT
		   ,@Today CHAR(10) = CONVERT(CHAR(10), GETDATE(), 121)

	SET @WeekNumber = DATEPART(WEEKDAY, GETDATE())

	SELECT @ExchangeDataCnt = COUNT(*)
	  FROM NEOE.NEOE.MA_EXCHANGE
	 WHERE CD_COMPANY = '1000'
	   AND CURR_SOUR = '001'
	   AND YYMMDD = CONVERT(CHAR(8), GETDATE(), 112)

	IF @WeekNumber NOT IN (1, 7) AND @ExchangeDataCnt = 0 BEGIN
		exec usp_DoSendSMS '', '', '010-3222-6697,010-6276-3560,010-2320-7233,010-6774-1748,010-2912-1830', '환율정보가 등록되지 않았습니다.({#1})', @Today
	END
END