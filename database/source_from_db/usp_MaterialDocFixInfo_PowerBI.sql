-- =============================================
-- Author : Kangs (kilee@vina.co.kr)
-- Group : 자재관리 > PowerBI
-- Browsable : true
-- Create date : 2020-07-07
-- Description : 입고내역
-- Modified :
-- usp_MaterialDocFixInfo_PowerBI 'VNT','VNT_F1','2020-11-01','2020-11-30'
-- =============================================
CREATE PROC [dbo].[usp_MaterialDocFixInfo_PowerBI]
	--@pProcessUserID VARCHAR(20)
 --  ,@pProcessLanguage VARCHAR(20)
		   @pTargetCompanyCode VARCHAR(20)
		   ,@pTargetWorkCenterCode VARCHAR(20)
		   ,@pFromDate DATE
		   ,@pToDate DATE
AS
BEGIN

	Declare @TargetCompanyCode VARCHAR(20) = @pTargetCompanyCode
			   ,@TargetWorkCenterCode VARCHAR(20) = @pTargetWorkCenterCode
			   ,@FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
			   ,@ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'

	SELECT MDI.TargetProcessDateTime as 입고완료일시
		  ,MDI.MaterialDocNo as 수불문서번호
		  ,MDD.MaterialCode as  품목코드
		  ,MM.MaterialName as 품목명
		  ,MDD.ProcessFixQty as 처리완료수량
		  ,MM.MaterialUnit as 기본단위
		  ,MDI.SourceCustomerCode as  공급업체코드
		  ,CI.CustomerName as 거래선명
		  ,dbo.fnGetERPUnitPrice(MDD.MaterialCode) AS 수주단가
		  ,dbo.fnGetERPUnitPrice(MDD.MaterialCode) * MDD.ProcessFixQty AS 총금액
		  ,dbo.fnGetERPCurrencyType(MDD.MaterialCode) AS 화폐종류
		  ,dbo.fnGetERPConvertPrice(MDD.MaterialCode) * MDD.ProcessFixQty AS 환산금액
		  , MM.ProductGroupCode as ProductGroupCode
		  , SPG.ProductGroupName  AS ProductGroupName           
	  FROM STB_MaterialDocInfo MDI
			  LEFT OUTER JOIN STB_MaterialDocDetail MDD	ON MDI.MaterialDocNo = MDD.MaterialDocNo
			  LEFT OUTER JOIN STB_MaterialMaster MM		ON MDD.MaterialCode = MM.MaterialCode
			  LEFT OUTER JOIN STB_CustomerInfo CI		    ON CI.CustomerCode = MDI.SourceCustomerCode
			  LEFT OUTER JOIN STB_ProductGroup  SPG WITH(NOLOCK) ON  SPG.ProductGroupCode = MM.ProductGroupCode                     
	 WHERE DocStatus = 'FIX'
	   AND MaterialDocType = 'GR'
	   AND MDI.TargetMaterialWarehouseCode IN ('ROH_WH', 'ROH_VN_WH')
	   AND MDI.TargetCompanyCode = @TargetCompanyCode
	   AND MDI.TargetWorkCenterCode = @TargetWorkCenterCode
	   AND MDI.TargetProcessDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY MDI.TargetProcessDateTime

END