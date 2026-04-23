-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 제품관리
-- Browsable : true
-- Create date : 2021-04-29
-- Description : 일일 매출 자료 집계 조회
-- Modified :
-- =============================================
CREATE PROC [dbo].[usp_ShipmentHist_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate

	SELECT SH.ShipmentHistNo AS OldShipmentHistNo
		  ,SH.ShipmentHistNo
		  ,SH.ShippmentAreaCode
		  ,CI.CompanyName AS ShipmentAreaName
		  ,SH.ShipmentDate
		  ,SH.ShippingDate
		  ,SH.NationCode
		  ,MCD.NM_SYSDEF AS NationName
		  ,SH.CustomerCode
		  ,CI2.CustomerName
		  ,SH.SalesTypeCode
		  ,BC.Description AS SalesTypeName 
		  ,SH.ShipmentQty
		  ,SH.GIUnitPrice
		  ,SH.FCSalesPrice
		  ,SH.ExchangeRate
		  ,SH.SalesPrice
		  ,SH.TransportTypeCode
		  ,BC2.Description AS TransportTypeName
		  ,SH.ShippingCompanyName
		  ,SH.AirWayBillNo
		  ,SH.MaterialCode
		  ,MM.MaterialName
		  ,SH.CreateDateTime
		  ,SH.CreateUserID
		  ,SH.ChangeDateTime
		  ,SH.ChangeUserID
	  FROM STB_ShipmentHist SH
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = SH.ShippmentAreaCode
	  LEFT OUTER JOIN NEOE.NEOE.MA_CODEDTL MCD
		ON MCD.CD_COMPANY = '1000'
	   AND MCD.CD_FIELD = 'MA_B000065'
	   AND SH.NationCode = MCD.CD_SYSDEF
	  LEFT OUTER JOIN STB_CustomerInfo CI2
		ON CI2.CustomerCode = SH.CustomerCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
		ON BC.CodeGroup = 'SalesTypeCode'
	   AND BC.ItemCode = SH.SalesTypeCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
		ON BC2.CodeGroup = 'TransportTypeCode'
	   AND BC2.ItemCode = SH.TransportTypeCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON MM.MaterialCode = SH.MaterialCode
	 WHERE SH.ShippingDate BETWEEN @FromDate AND @ToDate
END