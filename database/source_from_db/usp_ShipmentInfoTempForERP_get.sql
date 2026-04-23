-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-12-02
-- Browsable : true
-- Group : 제품관리
-- Description: 
-- =============================================
CREATE PROCEDURE usp_ShipmentInfoTempForERP_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT ShipmentInfoNo
		  ,MaterialWarehouseName
		  ,ShipmentNo
		  ,ShipmentSerNo
		  ,ShipmentDate
		  ,ShipmentClassName
		  ,CustomerName
		  ,MaterialCode
		  ,MaterialName
		  ,MaterialSpec
		  ,MaterialSize
		  ,MaterialQty
		  ,MaterialUnitCode
		  ,MaterialUnitPrice
		  ,MaterialTotPrice
		  ,CurrencyCode
		  ,CurrencyRate
		  ,ConvertPrice
		  ,StockUnitPrice
		  ,StockTotPrice
		  ,Margin
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_ShipmentInfoTempForERP
END