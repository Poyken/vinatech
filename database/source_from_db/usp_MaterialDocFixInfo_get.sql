-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2020-07-07
-- Description : 입고내역
-- Modified :
-- =============================================
CREATE PROC [dbo].[usp_MaterialDocFixInfo_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pTargetCompanyCode VARCHAR(20)
   ,@pTargetWorkCenterCode VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @TargetCompanyCode VARCHAR(20) = @pTargetCompanyCode
		   ,@TargetWorkCenterCode VARCHAR(20) = @pTargetWorkCenterCode
		   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
		   ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@TargetMaterialWarehouseCode VARCHAR(20)

	SET @TargetMaterialWarehouseCode = CASE @TargetWorkCenterCode WHEN 'VNT_F1' THEN 'ROH_WH'
																  WHEN 'VNT_F2' THEN 'W02'
																  WHEN 'VVT_F1' THEN 'ROH_VN_WH' END

	SELECT MDI.TargetProcessDateTime
		  ,MDI.MaterialDocNo
		  ,MDD.MaterialCode
		  ,MM.MaterialName
		  ,MDD.ProcessFixQty
		  ,MM.MaterialUnit
		  ,MDI.SourceCustomerCode
		  ,CI.CustomerName
		  ,dbo.fnGetERPUnitPrice(MDD.MaterialCode) AS UnitPrice
		  ,dbo.fnGetERPUnitPrice(MDD.MaterialCode) * MDD.ProcessFixQty AS TotalPrice
		  ,dbo.fnGetERPCurrencyType(MDD.MaterialCode) AS CurrencyType
		  ,dbo.fnGetERPConvertPrice(MDD.MaterialCode) * MDD.ProcessFixQty AS ConvertPrice
	  FROM STB_MaterialDocInfo MDI
	  LEFT OUTER JOIN STB_MaterialDocDetail MDD
		ON MDI.MaterialDocNo = MDD.MaterialDocNo
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON MDD.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN STB_CustomerInfo CI
		ON CI.CustomerCode = MDI.SourceCustomerCode
	 WHERE DocStatus = 'FIX'
	   AND MaterialDocType = 'GR'
	   --AND MDI.TargetMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH')
	   AND MDI.TargetMaterialWarehouseCode = @TargetMaterialWarehouseCode
	   AND MDI.TargetCompanyCode = @TargetCompanyCode
	   AND MDI.TargetWorkCenterCode = @TargetWorkCenterCode
	   AND MDI.TargetProcessDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY MDI.TargetProcessDateTime
END