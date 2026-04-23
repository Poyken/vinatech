-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-10-23
-- Browsable : true
-- Group : 생산관리
-- Description: 제품재고정보이력조회
-- =============================================
CREATE PROCEDURE usp_ProductStockInfoUploadHist_get
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
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@MaterialCode      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = ''      THEN '*' ELSE @pMaterialCode END
		   ,@FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
		   ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'

	SELECT PSIUP.ProductStockNo
          ,CASE WHEN PSIUP.ActionType = 'I' THEN '입력'
		        WHEN PSIUP.ActionType = 'UB' THEN '수정전'
				WHEN PSIUP.ActionType = 'UA' THEN '수정후'
				WHEN PSIUP.ActionType = 'D' THEN '삭제' END AS ActionType
          ,PSIUP.CompanyCode
		  ,CI.CompanyName
          ,PSIUP.WorkCenterCode
		  ,WI.WorkCenterName
          ,PSIUP.MaterialCode
		  ,MBI.ModelName AS MaterialName
          ,PSIUP.Barcode
          ,PSIUP.PackingID
          ,PSIUP.MaterialWarehouseCode
		  ,MW.MaterialWarehouseName
          ,PSIUP.MaterialLocationCode
		  ,ML.MaterialLocationName
          ,PSIUP.PaletteNo
          ,PSIUP.StockQty
          ,PSIUP.ManufacturingUnitPrice
          ,PSIUP.StockPrice
          ,PSIUP.Remark
          ,PSIUP.CreateDateTime
          ,PSIUP.CreateUserID
          ,PSIUP.ChangeDateTime
          ,PSIUP.ChangeUserID
	  FROM STB_ProductStockInfoUploadHist PSIUP
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = PSIUP.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WI
	    ON WI.WorkCenterCode = PSIUP.WorkCenterCode
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI
	    ON MBI.ModelCode = PSIUP.MaterialCode
	  LEFT OUTER JOIN STB_MaterialWarehouse MW
	    ON MW.MaterialWarehouseCode = PSIUP.MaterialWarehouseCode
	  LEFT OUTER JOIN STB_MaterialLocation ML
	    ON ML.MaterialLocationCode = PSIUP.MaterialLocationCode
	 WHERE 1=1
	   AND PSIUP.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR PSIUP.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR PSIUP.WorkCenterCode = @WorkCenterCode)
	   AND (@MaterialCode = '*' OR PSIUP.MaterialCode = @MaterialCode)
END