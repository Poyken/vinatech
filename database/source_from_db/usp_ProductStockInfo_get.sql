-- 제품재고정보이력조회
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-09
-- Browsable : true
-- Group : 제품관리
-- Description:	일자별 제품재고현황 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBaseDate DATE = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pMaterialWarehouseCode VARCHAR(20) = NULL,
	@pIsShowDetail BIT = NULL
AS
BEGIN
	DECLARE @BaseDate DATE = @pBaseDate
	       ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) =  CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
	       ,@MaterialCode VARCHAR(20) =  CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	       ,@MaterialWarehouseCode VARCHAR(20) =  CASE WHEN ISNULL(@pMaterialWarehouseCode, '') = '' THEN '*' ELSE @pMaterialWarehouseCode END
	       ,@IsShowDetail BIT = CASE WHEN @pIsShowDetail IS NULL THEN CONVERT(BIT, 0) ELSE @pIsShowDetail END

	IF @IsShowDetail = CONVERT(BIT, 1) BEGIN
		SELECT PSI.ProductStockNo
			  ,PSI.CompanyCode
			  ,CI.CompanyName
			  ,PSI.WorkCenterCode
			  ,WCI.WorkCenterName
			  ,PSI.MaterialCode
			  ,MBI.ModelName AS MaterialName
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
		  FROM STB_ProductStockInfo PSI
		  LEFT OUTER JOIN STB_CompanyInfo CI
			ON PSI.CompanyCode = CI.CompanyCode
		  LEFT OUTER JOIN STB_WorkCenterInfo WCI
			ON PSI.WorkCenterCode = WCI.WorkCenterCode
		  LEFT OUTER JOIN VW_ModelBasicInfo MBI
			ON PSI.MaterialCode = MBI.ModelCode
		  LEFT OUTER JOIN STB_MaterialWarehouse MW
			ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseCode
		  LEFT OUTER JOIN STB_MaterialLocation ML
			ON PSI.MaterialLocationCode = ML.MaterialLocationCode
		 WHERE PSI.BaseDate = @BaseDate
		   AND (@CompanyCode = '*' OR PSI.CompanyCode = @CompanyCode)
		   AND (@WorkCenterCode = '*' OR PSI.WorkCenterCode = @WorkCenterCode)
		   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
		   AND (@MaterialWarehouseCode = '*' OR PSI.MaterialWarehouseCode = @MaterialWarehouseCode)
	END ELSE BEGIN
		SELECT '' AS ProductStockNo
			  ,PSI.CompanyCode
			  ,CI.CompanyName
			  ,PSI.WorkCenterCode
			  ,WCI.WorkCenterName
			  ,PSI.MaterialCode
			  ,MBI.ModelName AS MaterialName
			  ,'' AS Barcode
			  ,'' AS PackingID
			  ,'' AS MaterialWarehouseCode
			  ,'' AS MaterialWarehouseName
			  ,'' AS MaterialLocationCode
			  ,'' AS MaterialLocationName
			  ,NULL AS PaletteNo
			  ,SUM(PSI.StockQty) AS StockQty
			  ,SUM(PSI.ManufacturingUnitPrice) AS ManufacturingUnitPrice
			  ,SUM(PSI.StockPrice) AS StockPrice
			  ,'' AS CreateDateTime
			  ,'' AS CreateUserID
			  ,'' AS ChangeDateTime
			  ,'' AS ChangeUserID
		  FROM STB_ProductStockInfo PSI
		  LEFT OUTER JOIN STB_CompanyInfo CI
			ON PSI.CompanyCode = CI.CompanyCode
		  LEFT OUTER JOIN STB_WorkCenterInfo WCI
			ON PSI.WorkCenterCode = WCI.WorkCenterCode
		  LEFT OUTER JOIN VW_ModelBasicInfo MBI
			ON PSI.MaterialCode = MBI.ModelCode
		  LEFT OUTER JOIN STB_MaterialWarehouse MW
			ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
		  LEFT OUTER JOIN STB_MaterialLocation ML
			ON PSI.MaterialLocationCode = ML.MaterialLocationCode
		 WHERE PSI.BaseDate = @BaseDate
		   AND (@CompanyCode = '*' OR PSI.CompanyCode = @CompanyCode)
		   AND (@WorkCenterCode = '*' OR PSI.WorkCenterCode = @WorkCenterCode)
		   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
		   AND (@MaterialWarehouseCode = '*' OR PSI.MaterialWarehouseCode = @MaterialWarehouseCode)
		 GROUP BY PSI.CompanyCode
			     ,CI.CompanyName
			     ,PSI.WorkCenterCode
			     ,WCI.WorkCenterName
			     ,PSI.MaterialCode
			     ,MBI.ModelName
	END
END