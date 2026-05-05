-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-22
-- Browsable : true
-- Group : 생산관리
-- Description: 제품재고정보입력
-- 2021.01.13  제품재고정보(Lot경과일) 추가

-- [usp_ProductStockInfoUpload_get_20210113] '','','VNT','VNT_F1','ECVT30-220'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfoUpload_get_20210113]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(20) = NULL
AS

BEGIN

	Declare @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode END
	         , @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		     , @MaterialCode      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = ''      THEN '*' ELSE @pMaterialCode END


SELECT  A.ProductStockNo
          ,A.CompanyCode
		  ,A.CompanyName
          ,A.WorkCenterCode
		  ,A.WorkCenterName
          ,A.MaterialCode
		  ,A.ModelName AS MaterialName
          ,A.Barcode

		-- 일수계산 추가 (최덕렬)

      ,   Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) as  StartDate
      ,  GETDATE()                                                 AS EndDate
       ,   DATEDIFF(dd,  Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) , Getdate() )   as Diff


          ,A.PackingID
          ,A.MaterialWarehouseCode
		  ,A.MaterialWarehouseName
          ,A.MaterialLocationCode
		  ,A.MaterialLocationName
          ,A.PaletteNo
          ,A.StockQty
          ,A.ManufacturingUnitPrice
          ,A.StockPrice
          ,A.CreateDateTime
          ,A.CreateUserID
          ,A.ChangeDateTime
          ,A.ChangeUserID

FROM     (
					SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName 
						  ,PSI.Barcode

							-- 일수계산 추가 (최덕렬)
						,    ISNULL(Convert(Varchar(20), (select SY.Year    from STB_YearInfo SY  where SY.YearCode =  SubString(PSI.Barcode, 3, 1))) , 0)					   AS Year
                        
						,  ISNULL(Convert(Varchar(20), (select SM.Month from STB_MonthInfo SM where SM.MonthCode =  SubString(PSI.Barcode, 4, 1)) ), 0) 		     AS Month
                      
					   ,  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)  AS Day

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
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
					 WHERE 1=1
					   -- AND (@CompanyCode = '*' OR PSI.CompanyCode = @CompanyCode)
					   --AND (@WorkCenterCode = '*' OR PSI.WorkCenterCode = @WorkCenterCode)
					   --AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					  --  AND  PSI.Barcode = 'VVKT253R010501'      -- 2019.10.18                2021.01.13
					   AND LEN(PSI.Barcode)   IN ('14', '15')
	   )  A


END