-- 베트남 재고 정보
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-25
-- Browsable : true
-- Group : 인터페이스
-- Source Table: SmartFactoryV2.dbo.STB_ProductStockInfoUpload
-- Target Table: NEOE.NEOE.MM_Z_VINA_OHSLINVD
-- Description:	베트남 재고 정보 인터페이스
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_VietnamStockInfo_itf]
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20) -- 베트남법인 재고 입력 프로시저이므로 베트남법인의 회사코드인 TESTV를 입력함.
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode
	       ,@LastUpdateDate DATETIME

	SELECT @LastUpdateDate = MAX(CreateDateTime)
	  FROM STB_ProductStockInfoUpload
	 WHERE CompanyCode = 'VVT'
	   AND WorkCenterCode = 'VVT_F1'

	DELETE FROM NEOE.NEOE.MM_Z_VINA_OHSLINVD WHERE CD_COMPANY = @IUCompanyCode AND DT_IO = CONVERT(CHAR(8), GETDATE(), 112)

	INSERT INTO NEOE.NEOE.MM_Z_VINA_OHSLINVD (CD_COMPANY, CD_ITEM, DT_IO, QT_INV, DTS_INSERT)
		SELECT @IUCompanyCode
	   		  ,PSI.MaterialCode 
	   		  ,CONVERT(CHAR(8), GETDATE(), 112)
			  ,ISNULL(SUM(PSI.StockQty), 0)
	   		  ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE())
		   FROM STB_ProductStockInfoUpload PSI
	   			LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
	   			LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
	   			LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
	   			LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
	   			LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
	   			LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
		   WHERE PSI.CompanyCode = 'VVT'
		   AND PSI.WorkCenterCode = 'VVT_F1'
		   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
		   AND PSI.CreateDateTime BETWEEN Convert(CHAR(10), @LastUpdateDate, 121) + ' 00:00:00'
	   								  AND Convert(CHAR(10), @LastUpdateDate, 121) + ' 23:59:59'
		   GROUP BY PSI.MaterialCode
END