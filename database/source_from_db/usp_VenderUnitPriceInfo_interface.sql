CREATE PROC [dbo].[usp_VenderUnitPriceInfo_interface]
AS
BEGIN
	DELETE FROM STB_VenderUnitPriceInfo

	INSERT INTO STB_VenderUnitPriceInfo (MaterialCode, ChangeDate, CurrencyCode, UnitPrice, CustomerCode)
		SELECT 품목코드, 변경일자, ISNULL(화폐단위, '원'), 단가, 거래처
		  FROM ERPSVR.ERPDB.dbo.업체단가
END