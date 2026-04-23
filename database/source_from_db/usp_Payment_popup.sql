
-- =============================================
-- Author:	kilee
-- Create date: 2019-06-17
-- Browsable : true
-- Group :
-- Description: 발주서 지급조건 변경
-- =============================================
-- usp_ItemUnitPrice_popup2

CREATE PROCEDURE [dbo].[usp_Payment_popup] 
@pCustomerCode VARCHAR(20) = NULL, @pMaterialCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;

	Declare @CustomerCode VARCHAR(20) = @pCustomerCode
	Declare @MaterialCode VARCHAR(20) = @pMaterialCode
	
	--SELECT TOP 5 ROW_NUMBER() OVER (ORDER BY 변경일자 DESC) AS SEQ
	--      ,변경일자 AS ChangeDate
	--      ,화폐단위 AS CurrencyType
	--	  ,단가 AS UnitPrice
	--	  ,CASE WHEN 화폐단위 = '원' THEN 단가 ELSE 단가 * dbo.fnGetERPExchangeRate(화폐단위) END AS ConvertPrice
	--  FROM ERPSVR.ERPDB.DBO.업체단가
	-- WHERE 단가구분 = '20'
	--   AND 품목코드 = @MaterialCode
	--   AND 거래처 = (SELECT CIExtText02 FROM STB_CustomerInfo WHERE CustomerCode = @CustomerCode)
 --    ORDER BY 변경일자 DESC

         SELECT ISNULL(Payment, 0) as Payment FROM STB_Order_Report


END

