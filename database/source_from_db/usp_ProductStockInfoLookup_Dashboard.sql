-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2021-01-14
-- Browsable : True
-- Group : 제품관리 > 제품재고 조회
--            PowerBI
-- Description: 제품재고정보조회  (최덕렬)
--                  2021.02.25 최덕렬 추가요청
--                  2021.04.25 최덕렬 요청 (베트남 단가, 장기재고 조회오류)

-- 프로시저 실행  : usp_ProductStockInfoLookup_Dashboard  '', '', '',  ''
--						 usp_ProductStockInfoLookup_get  '', '', 'VNT',  ''
--                       usp_ProductStockInfoLookup_get  '', '', 'VVT',  ''
-- ==================================================

CREATE PROCEDURE [dbo].[usp_ProductStockInfoLookup_Dashboard]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						--@pWorkCenterCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(20) = NULL
AS

BEGIN

	Declare @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode END
	         --, @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		     , @MaterialCode      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = ''      THEN '*' ELSE @pMaterialCode END

			   , @FromDate DATETIME = CONVERT(CHAR(10), Getdate(), 121) + ' 00:00:00'
			 , @ToDate DATETIME = CONVERT(CHAR(10), Getdate(), 121) + ' 23:59:59'
			 , @LastUpdateDate DATE
			 , @CompanyName  VARCHAR(20) 


		-- 베트남 최종값 
			SELECT @LastUpdateDate = MAX(CreateDateTime)
			 FROM STB_ProductStockInfoUpload
			WHERE CompanyCode = 'VVT'
			   AND WorkCenterCode = 'VVT_F1'

-- Temp테이블 없이 -----  (2021.04.23)
SELECT  AA.ProductStockNo
			,AA.CompanyCode
			,AA.CompanyName
			,AA.MaterialCode 
			,AA.MaterialName  AS MaterialName
			,AA.Barcode
            ,  AA.Lapse 
	      , AA.Diff
		  , AA.MBISizeW                                                      -- 파이추가  (2021.02.25)
		     ,  (Convert(NUMERIC(10,4), AA.Diff) / 365) AS YEARS  --년수추가 (2021.02.25)
		   
		    ,AA.PackingID
			,AA.MaterialWarehouseCode
			,AA.MaterialWarehouseName
			,AA.MaterialLocationCode
			,AA.MaterialLocationName
			,AA.PaletteNo
			,AA.StockQty
			--,AA.ManufacturingUnitPrice
			,AA.StockPrice
			,AA.CreateDateTime
			,AA.CreateUserID
			,AA.ChangeDateTime
			,AA.ChangeUserID
			,AA.ManufacturingUnitPrice
			, AA.StockPrice
FROM (

  	SELECT A.ProductStockNo
			,A.CompanyCode
			,A.CompanyName
			--,A.WorkCenterCode
			--,A.WorkCenterName
			,A.MaterialCode 
			,A.MaterialName  AS MaterialName
			,A.Barcode
            , Case When Len(A.Day) = 1 then CONCAT(A.Year, A.Month, '0',  A.Day)   
			        When Len(A.Day) = 2  then CONCAT(A.Year, A.Month, A.Day)        Else 0 End as  Lapse 


	      , Case When  LEN(Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, '0',  A.Day)  Else   CONCAT(A.Year, A.Month, A.Day) End)  =  8 Then    DATEDIFF(dd,  Convert(Datetime, Case When Len(A.Day) = 1 then     CONCAT(A.Year, A.Month, 0,  A.Day)  else   CONCAT(A.Year, A.Month, A.Day) End) , Getdate() )   
	          else 0 end as Diff
		    ,A.PackingID
			,A.MaterialWarehouseCode
			,A.MaterialWarehouseName
			,A.MaterialLocationCode
			,A.MaterialLocationName
			,A.PaletteNo
			,A.StockQty
			,A.CreateDateTime
			,A.CreateUserID
			,A.ChangeDateTime
			,A.ChangeUserID
			, A.MBISizeW   -- 파이추가
	             , A.ManufacturingUnitPrice
				 , (A.ManufacturingUnitPrice * A.StockQty) AS StockPrice
FROM (




-- 기존
					SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode
						 -- ,Right(PSI.Barcode, 14) as Barcode
						
						--   2021.01.13 추가사항
						 ,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), SY.Year ), 0 )
								     WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), SY.Year), 0 ) End AS Year
                        
						, CASE   WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2))  , 0) 
								   WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 5, 1)) - 73), 2)) , 0)  ELSE null End  AS Month
                      
					   , CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
								  WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE Null END  AS Day

						  ,PSI.PackingID
						  ,PSI.MaterialWarehouseCode
						  ,MW.MaterialWarehouseName
						  ,PSI.MaterialLocationCode
						  ,ML.MaterialLocationName
						  ,PSI.PaletteNo
						  ,PSI.StockQty
						--  ,PSI.ManufacturingUnitPrice
						--  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
						 -- ,  Right(PSI.Barcode, 10) 
						 , MBI.MBISizeW
						   ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							 -- LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
							 LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SUBSTRING(Right(PSI.Barcode, 14),3, 1)                  --  알파벳 한자리 K


						LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
															 ,MaterialCode, AVG(CostPrice) AS CostPrice 
														 FROM STB_ManufacturingCostAvgByRoute
														GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																,MaterialCode) MCR
													ON MCR.ApplyDate = '2021-05-13'
												   AND MCR.CompanyCode = PSI.CompanyCode
												   AND MCR.WorkCenterCode = PSI.WorkCenterCode
												   AND MCR.CostTypeCode = 'PC'
												   AND MCR.RouteCode = 'E-28'
												   AND MCR.MaterialCode = PSI.MaterialCode

						  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
															 ,MaterialCode, AVG(CostPrice) AS CostPrice 
														 FROM STB_ManufacturingCostAvgByRoute
														GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																,MaterialCode) MCRM
													ON MCRM.ApplyDate = '2021-05-13'
												   AND MCRM.CompanyCode = PSI.CompanyCode
												   AND MCRM.WorkCenterCode = PSI.WorkCenterCode
												   AND MCRM.CostTypeCode = 'PC'
												   AND MCRM.RouteCode = 'E-28'
												   AND MCRM.MaterialCode = MBI.MBIExtText06

					 WHERE 1=1
					 AND  PSI.CompanyCode = 'VNT'
					  AND PSI.WorkCenterCode = 'VNT_F1'
					    AND PSI.Barcode NOT IN ('MVJHP262R750502','MVJIM032R750502','MVJHN313R050501'
														,'MVJIO192R733540','MVJIP042R750503','MVJIQ312R750516','MVJIU012R710503','MVJIU012R710525'
														,'MVJIU012R710527','VJIO172R710503','MVJIP312R710606','MVJIQ042R710601','MVJIM062R710602','MVJIN192R710606'
														,'MVJIP312R710606','MVJIS052R710623','MVJHN313R050501','MVJIU163R050522','MVJIU143R050528','MVJIT233R010609'
														,'MVJIO092R715508','MVJIU182R715504','MVJIL212R715501','MVJIO312R750510','MVJIP012R770506')
					   AND LEN(PSI.Barcode) IN ( '14', '15' )
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
			
               UNION ALL

			   --2. 베트남

			       	SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode
						  ,CI.CompanyName
						  ,PSI.WorkCenterCode
						  ,WCI.WorkCenterName
						  ,PSI.MaterialCode 
						  ,MBI.ModelName  AS MaterialName
						  ,PSI.Barcode
						 -- ,Right(PSI.Barcode, 14) as Barcode
						
						--   2021.01.13 추가사항
						 ,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), SY.Year ), 0 )
								     WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), SY.Year), 0 ) End AS Year
                        
						, CASE   WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2))  , 0) 
								   WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 5, 1)) - 73), 2)) , 0)  ELSE null End  AS Month
                      
					   , CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
								  WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE Null END  AS Day

						  ,PSI.PackingID
						  ,PSI.MaterialWarehouseCode
						  ,MW.MaterialWarehouseName
						  ,PSI.MaterialLocationCode
						  ,ML.MaterialLocationName
						  ,PSI.PaletteNo
						  ,PSI.StockQty
						--  ,PSI.ManufacturingUnitPrice
						--  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
						 -- ,  Right(PSI.Barcode, 10) 
						 , MBI.MBISizeW
						   ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							 -- LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
							 LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SUBSTRING(Right(PSI.Barcode, 14),3, 1)                  --  알파벳 한자리 K


						LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
															 ,MaterialCode, AVG(CostPrice) AS CostPrice 
														 FROM STB_ManufacturingCostAvgByRoute
														GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																,MaterialCode) MCR
													ON MCR.ApplyDate = '2021-05-13'
												   AND MCR.CompanyCode = PSI.CompanyCode
												   AND MCR.WorkCenterCode = PSI.WorkCenterCode
												   AND MCR.CostTypeCode = 'PC'
												   AND MCR.RouteCode = 'V-28'
												   AND MCR.MaterialCode = PSI.MaterialCode

						  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
															 ,MaterialCode, AVG(CostPrice) AS CostPrice 
														 FROM STB_ManufacturingCostAvgByRoute
														GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																,MaterialCode) MCRM
													ON MCRM.ApplyDate = '2021-05-13'
												   AND MCRM.CompanyCode = PSI.CompanyCode
												   AND MCRM.WorkCenterCode = PSI.WorkCenterCode
												   AND MCRM.CostTypeCode = 'PC'
												   AND MCRM.RouteCode = 'V-28'
												   AND MCRM.MaterialCode = MBI.MBIExtText06
					 WHERE 1=1
					  AND  PSI.CompanyCode = 'VVT'
					  AND PSI.WorkCenterCode = 'VVT_F1'
					    AND PSI.Barcode NOT IN ('MVJHP262R750502','MVJIM032R750502','MVJHN313R050501'
														,'MVJIO192R733540','MVJIP042R750503','MVJIQ312R750516','MVJIU012R710503','MVJIU012R710525'
														,'MVJIU012R710527','VJIO172R710503','MVJIP312R710606','MVJIQ042R710601','MVJIM062R710602','MVJIN192R710606'
														,'MVJIP312R710606','MVJIS052R710623','MVJHN313R050501','MVJIU163R050522','MVJIU143R050528','MVJIT233R010609'
														,'MVJIO092R715508','MVJIU182R715504','MVJIL212R715501','MVJIO312R750510','MVJIP012R770506')
					   AND LEN(PSI.Barcode) IN ( '14', '15' )
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					     AND PSI.CreateDateTime BETWEEN Convert(CHAR(10), @LastUpdateDate, 121) + ' 00:00:00'   AND Convert(CHAR(10), @LastUpdateDate, 121) + ' 23:59:59'


		)   A
	WHERE 1=1
	    AND   (@CompanyCode = '*' OR A.CompanyCode = @CompanyCode)


) AA

END
