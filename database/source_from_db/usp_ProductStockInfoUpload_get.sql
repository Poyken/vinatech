-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-22
-- Browsable : true
-- Group : 생산관리              / 제품관리 > 제품재고정보(import)
-- Description: 제품재고정보입력
-- 2021.01.13  제품재고정보(Lot경과일) 추가

-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfoUpload_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(20) = NULL,
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL
AS

BEGIN

	Declare @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode END
	         , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		     , @MaterialCode      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = ''      THEN '*' ELSE @pMaterialCode END
			 , @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
			 , @ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'
			 , @LastUpdateDate DATE

	SELECT @LastUpdateDate = MAX(CreateDateTime)
	  FROM STB_ProductStockInfoUpload
	 WHERE CompanyCode = 'VVT'
	   AND WorkCenterCode = 'VVT_F1'



					SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode
						  ,PSI.PackingID
						  ,PSI.MaterialWarehouseCode
						  ,MW.MaterialWarehouseName
						  ,PSI.MaterialLocationCode
						  ,ML.MaterialLocationName
						  ,PSI.PaletteNo
						  ,PSI.StockQty
						  ,PSI.ManufacturingUnitPrice
						  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
						  ,PSI.Remark
					  INTO #StockInfoTemp
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
					 WHERE PSI.CompanyCode = 'VNT'
					   AND PSI.WorkCenterCode = 'VNT_F1'
					   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					   AND PSI.CreateDateTime BETWEEN @FromDate AND @ToDate
				UNION ALL
				SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode
						  ,PSI.PackingID
						  ,PSI.MaterialWarehouseCode
						  ,MW.MaterialWarehouseName
						  ,PSI.MaterialLocationCode
						  ,ML.MaterialLocationName
						  ,PSI.PaletteNo
						  ,PSI.StockQty
						  ,PSI.ManufacturingUnitPrice
						  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
						  ,PSI.Remark
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
					 WHERE PSI.CompanyCode = 'VVT'
					   AND PSI.WorkCenterCode = 'VVT_F1'
					   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					   AND PSI.CreateDateTime BETWEEN Convert(CHAR(10), @LastUpdateDate, 121) + ' 00:00:00'
					                              AND Convert(CHAR(10), @LastUpdateDate, 121) + ' 23:59:59'

		SELECT ProductStockNo
			  ,CompanyCode
			  ,CompanyName
			  ,WorkCenterCode
			  ,WorkCenterName
			  ,MaterialCode 
			  ,MaterialName
			  ,Barcode
			  ,PackingID
			  ,MaterialWarehouseCode
			  ,MaterialWarehouseName
			  ,MaterialLocationCode
			  ,MaterialLocationName
			  ,PaletteNo
			  ,StockQty
			  ,ManufacturingUnitPrice
			  ,StockPrice
			  ,CreateDateTime
			  ,CreateUserID
			  ,ChangeDateTime
			  ,ChangeUserID
			  ,Remark
		  FROM #StockInfoTemp
		 WHERE 1=1
		   AND (@CompanyCode = '*' OR CompanyCode = @CompanyCode)
		   AND (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode)
		   AND (@MaterialCode = '*' OR MaterialCode = @MaterialCode)

		DROP TABLE #StockInfoTemp
END
