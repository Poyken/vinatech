CREATE PROC [dbo].[usp_ExchangeInfo_interface]
AS
BEGIN
	DELETE FROM STB_ExchangeInfo WHERE CurrencyDate >= CONVERT(DATE, DATEADD(day, -5, GETDATE()), 121)

	INSERT INTO STB_ExchangeInfo (CurrencyCode, CurrencyDate, ExchangeRateAmount)
		SELECT 코드, 일자, 금액
		  FROM ERPSVR.ERPDB.dbo.환율
		 WHERE 일자 >= CONVERT(DATE, DATEADD(day, -5, GETDATE()), 121)
END