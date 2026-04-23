-- 제품재고정보이력조회
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-09
-- Browsable : true
-- Group : 제품관리 / PowerBI화면
-- Description:	일자별 제품재고현황 조회
-- 2021.03.07 SQL수정

-- Modified: 베트남 법인에서 재고수량을 일자별로 신규입력하는 부분을 해결하기 위해 UNION ALL 로 베트남 재고의 최근 데이터를 붙여줌.

-- 프로시저 실행 : usp_ProductStockInfo_Dashboard '', '', NULL, NULL, NULL, NULL, NULL, NULL
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfo_Dashboard]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
	       ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) =  CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	       ,@MaterialCode VARCHAR(20) =  CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	       ,@MaterialWarehouseCode VARCHAR(20) =  CASE WHEN ISNULL(@pMaterialWarehouseCode, '') = '' THEN '*' ELSE @pMaterialWarehouseCode END
		   ,@LastUpdateDate DATE

		IF @FromDate = '1900-01-01' OR @FromDate IS NULL  BEGIN
			SET @FromDate = GETDATE()
		END

		IF @ToDate = '1900-01-01' OR @ToDate IS NULL  BEGIN
			SET @ToDate = GETDATE()
		END

		SELECT @LastUpdateDate = MAX(CreateDateTime)
		  FROM STB_ProductStockInfoUpload
		 WHERE CompanyCode = 'VVT'
		   AND WorkCenterCode = 'VVT_F1'


		-- 1. 한국본사
		SELECT PSI.ProductStockNo
			  ,PSI.CompanyCode
			  ,CI.CompanyName
			  ,PSI.WorkCenterCode
			  ,WCI.WorkCenterName
			  ,PSI.MaterialCode
			  ,MBI.ModelName AS MaterialName
			  ,MBI.MBIExtText03 AS ProdType
			  ,MBI.MBIExtText04 AS Volt
			  ,MBI.MBIExtText05 AS Farad
			  ,MBI.MBISizeH AS ProdLength
			  ,MBI.MBISizeW AS ProdWidth
			  ,RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) 	+ CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) AS SizeD
			  ,PSI.Barcode
			  ,PSI.PackingID
			  ,PSI.MaterialWarehouseCode
			  ,MW.MaterialWarehouseName
			  ,PSI.MaterialLocationCode
			  ,ML.MaterialLocationName
			  ,PSI.PaletteNo
			  ,PSI.StockQty
			  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
			  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) * PSI.StockQty AS StockPrice
			  ,PSI.CreateDateTime
			  ,PSI.CreateUserID
			  ,PSI.ChangeDateTime
			  ,PSI.ChangeUserID
		  FROM STB_ProductStockInfo PSI
		  LEFT OUTER JOIN STB_CompanyInfo CI			ON PSI.CompanyCode = CI.CompanyCode
		  LEFT OUTER JOIN STB_WorkCenterInfo WCI			ON PSI.WorkCenterCode = WCI.WorkCenterCode
		  LEFT OUTER JOIN VW_ModelBasicInfo MBI			ON PSI.MaterialCode = MBI.ModelCode
		  LEFT OUTER JOIN STB_MaterialWarehouse MW			ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseCode
		  LEFT OUTER JOIN STB_MaterialLocation ML			ON PSI.MaterialLocationCode = ML.MaterialLocationCode
		  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
											 ,MaterialCode, AVG(CostPrice) AS CostPrice 
										 FROM STB_ManufacturingCostAvgByRoute
										GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
												,MaterialCode) MCR
						ON MCR.ApplyDate = '2021-05-13'
					   AND MCR.CompanyCode = PSI.CompanyCode
					   AND MCR.WorkCenterCode = PSI.WorkCenterCode
					   AND MCR.CostTypeCode = 'PC'
					   AND MCR.RouteCode IN ('E-28')
					   AND MCR.MaterialCode = PSI.MaterialCode
		  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode    ,MaterialCode, AVG(CostPrice) AS CostPrice 
						     FROM STB_ManufacturingCostAvgByRoute
							GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode ,MaterialCode
									) MCRM
		    ON MCRM.ApplyDate = '2021-05-13'
			AND MCRM.CompanyCode = PSI.CompanyCode
			AND MCRM.WorkCenterCode = PSI.WorkCenterCode
			AND MCRM.CostTypeCode = 'PC'
			AND MCRM.RouteCode IN ('E-28')
			AND MCRM.MaterialCode = MBI.MBIExtText06
		  WHERE PSI.BaseDate BETWEEN @FromDate AND @ToDate
			AND PSI.CompanyCode = 'VNT'
			AND PSI.WorkCenterCode IN ('VNT_F1', 'VNT_F4')
			AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
			AND (@MaterialWarehouseCode = '*' OR PSI.MaterialWarehouseCode = @MaterialWarehouseCode)
			AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
		 UNION ALL

		 --2. 베트남

		 SELECT PSI.ProductStockNo
			  ,PSI.CompanyCode
			  ,CI.CompanyName
			  ,PSI.WorkCenterCode
			  ,WCI.WorkCenterName
			  ,PSI.MaterialCode
			  ,MBI.ModelName AS MaterialName
			  ,MBI.MBIExtText03 AS ProdType
			  ,MBI.MBIExtText04 AS Volt
			  ,MBI.MBIExtText05 AS Farad
			  ,MBI.MBISizeH AS ProdLength
			  ,MBI.MBISizeW AS ProdWidth
			  ,RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2)	+ CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) AS SizeD
			  ,PSI.Barcode
			  ,PSI.PackingID
			  ,PSI.MaterialWarehouseCode
			  ,MW.MaterialWarehouseName
			  ,PSI.MaterialLocationCode
			  ,ML.MaterialLocationName
			  ,PSI.PaletteNo
			  ,PSI.StockQty
			  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
			  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) * PSI.StockQty AS StockPrice
			  ,PSI.CreateDateTime
			  ,PSI.CreateUserID
			  ,PSI.ChangeDateTime
			  ,PSI.ChangeUserID
		  FROM STB_ProductStockInfoUpload PSI
		  LEFT OUTER JOIN STB_CompanyInfo CI			ON PSI.CompanyCode = CI.CompanyCode
		  LEFT OUTER JOIN STB_WorkCenterInfo WCI			ON PSI.WorkCenterCode = WCI.WorkCenterCode
		  LEFT OUTER JOIN VW_ModelBasicInfo MBI			ON PSI.MaterialCode = MBI.ModelCode
		  LEFT OUTER JOIN STB_MaterialWarehouse MW			ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseCode
		  LEFT OUTER JOIN STB_MaterialLocation ML			ON PSI.MaterialLocationCode = ML.MaterialLocationCode
		  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode  ,MaterialCode, AVG(CostPrice) AS CostPrice 
									 FROM STB_ManufacturingCostAvgByRoute
									GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
											,MaterialCode) MCR
										ON MCR.ApplyDate = '2021-05-13'
									   AND MCR.CompanyCode = PSI.CompanyCode
									   AND MCR.WorkCenterCode = PSI.WorkCenterCode
									   AND MCR.CostTypeCode = 'PC'
									   AND MCR.RouteCode IN ('V-28')
									   AND MCR.MaterialCode = PSI.MaterialCode
		  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode       ,MaterialCode, AVG(CostPrice) AS CostPrice 
									 FROM STB_ManufacturingCostAvgByRoute
									GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
											,MaterialCode) MCRM		    
								    ON MCRM.ApplyDate = '2021-05-13'
								   AND MCRM.CompanyCode = PSI.CompanyCode
								   AND MCRM.WorkCenterCode = PSI.WorkCenterCode
								   AND MCRM.CostTypeCode = 'PC'
								   AND MCRM.RouteCode IN ('V-28')
								   AND MCRM.MaterialCode = MBI.MBIExtText06
		 WHERE 1=1
		   AND PSI.CreateDateTime BETWEEN Convert(CHAR(10), @LastUpdateDate, 121) + ' 00:00:00'
					                  AND Convert(CHAR(10), @LastUpdateDate, 121) + ' 23:59:59'
		   AND PSI.CompanyCode = 'VVT'
		   AND PSI.WorkCenterCode IN ('VVT_F1')

END