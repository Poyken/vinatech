-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-22
-- Browsable : true
-- Group : 생산관리              / 제품관리 > 제품재고정보(import)
-- Description: 제품재고정보입력
-- 2021.01.13  제품재고정보(Lot경과일) 추가

-- [usp_ProductStockInfoUpload_get] '','','VNT','VNT_F1',''
-- [usp_ProductStockInfoUpload_get] '','','', '','','2021-03-05','2021-03-07'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductStockInfoUpload_get_20210308_kilee]
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
			 , @FromDate CHAR(19) = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
			 , @ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'


--  	SELECT A.ProductStockNo
--			,A.CompanyCode
--			,A.CompanyName
--			,A.WorkCenterCode
--			,A.WorkCenterName
--			,A.MaterialCode 
--			,A.MaterialName  AS MaterialName
--			,A.Barcode
--            , Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, '0',  A.Day)         else          CONCAT(A.Year, A.Month, A.Day) End as  Lapse
--			--, CONCAT(A.Year, A.Month, A.Day) End as  Lapse

--       --,  Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) as  StartDate
--      --,  GETDATE()                                                         as EndDate
--      -- , DATEDIFF(dd,  Convert(Datetime, CONCAT(A.Year, A.Month, A.Day)) , Getdate() )   as Diff
--	 , Case When     LEN(Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, '0',  A.Day)         else          CONCAT(A.Year, A.Month, A.Day) End)   =    8 then             DATEDIFF(dd,  Convert(Datetime, Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, 0,  A.Day)  else   CONCAT(A.Year, A.Month, A.Day) End) , Getdate() )   
--	          else 0 end as diff
--		,A.PackingID
--			,A.MaterialWarehouseCode
--			,A.MaterialWarehouseName
--			,A.MaterialLocationCode
--			,A.MaterialLocationName
--			,A.PaletteNo
--			,A.StockQty
--			,A.ManufacturingUnitPrice
--			,A.StockPrice
--			,A.CreateDateTime
--			,A.CreateUserID
--			,A.ChangeDateTime
--			,A.ChangeUserID

--FROM (


-- 기존
					SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode

						  -- 2021.01.13 추가사항
						--   ,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN  IsNull(Convert(Varchar(10), SY.Year ), 0 )
						--		     WHEN LEN(PSI.Barcode) = 15 THEN  IsNull(Convert(Varchar(10), SY.Year), 0 ) End AS Year

						---- ,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), (select SY.Year    from STB_YearInfo SY  where SY.YearCode =  SubString(PSI.Barcode, 3, 1))) , 0)
						----		        WHEN LEN(PSI.Barcode) = 15 THEN  ISNULL(Convert(Varchar(20), (select SY.Year    from STB_YearInfo SY  where SY.YearCode =  SubString(PSI.Barcode, 4, 1))), 0)  ELSE 01 END  AS Year
                        
						--, CASE   WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), (select SM.Month from STB_MonthInfo SM where SM.MonthCode =  SubString(PSI.Barcode, 4, 1)) ), 0) 
						--		   WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), (select SM.Month from STB_MonthInfo SM where SM.MonthCode =  SubString(PSI.Barcode, 5, 1)) ), 0)  ELSE 01 END  AS Month
                      
					 --  , CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
						--		  WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE 01 END  AS Day

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
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
					 WHERE (@CompanyCode = '*' OR PSI.CompanyCode = @CompanyCode)
					   AND (@WorkCenterCode = '*' OR PSI.WorkCenterCode = @WorkCenterCode)
					   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					   AND PSI.CreateDateTime BETWEEN @FromDate AND @ToDate
--)   A


END