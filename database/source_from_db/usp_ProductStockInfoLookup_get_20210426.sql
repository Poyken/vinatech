-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2021-01-14
-- Browsable : True
-- Group : 제품관리 > 제품재고 조회
-- Description: 제품재고정보조회  (최덕렬)
--                  2021.02.25 최덕렬 추가요청
--                  2021.04.22 재품재고정보(Import와 동일한 쿼리로 수정)  : 베트남 최종수량문제로..

-- 프로시저 실행  :  usp_ProductStockInfoLookup_get  '', '', 'VNT',  ''
--                        usp_ProductStockInfoLookup_get  '', '', '',  ''
-- ==================================================

Create PROCEDURE [dbo].[usp_ProductStockInfoLookup_get_20210426]
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
			--SELECT @LastUpdateDate = MAX(CreateDateTime)
			-- FROM STB_ProductStockInfoUpload
			--WHERE CompanyCode = 'VVT'
			--   AND WorkCenterCode = 'VVT_F1'

   --   			SELECT MAX(CreateDateTime)
			-- FROM STB_ProductStockInfoUpload
			--WHERE CompanyCode = 'VVT'
			--   AND WorkCenterCode = 'VVT_F1'

SELECT AA.ProductStockNo
		, AA.CompanyCode 
		, AA.CompanyName 
		, AA.MaterialCode 
		, AA.MaterialName  
		, AA.Barcode
        , AA.Lapse 
	    , AA.Diff
		, AA.MBISizeW                                                  -- 파이추가  (2021.02.25)
	   ,  (Convert(NUMERIC(10,4), AA.Diff) / 365) AS YEARS  --년수추가 (2021.02.25)
		, AA.PackingID
		, AA.MaterialWarehouseCode
		, AA.MaterialWarehouseName
		, AA.MaterialLocationCode
		, AA.MaterialLocationName
		, AA.PaletteNo
		, AA.StockQty
		--, AA.StockPrice
		, AA.CreateDateTime
		, AA.CreateUserID
		, AA.ChangeDateTime
		, AA.ChangeUserID
		 , ISnull(AA.ManufacturingUnitPrice, 0) as ManufacturingUnitPrice
		 , (ISNULL(AA.ManufacturingUnitPrice, 0)  * ISNULL(AA.StockQty,0)) AS StockPrice
FROM (

		SELECT ProductStockNo
							  ,CompanyCode
							  ,CompanyName
							  --,WorkCenterCode
							  --,WorkCenterName
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
							  , ISnull(ManufacturingUnitPrice, 0) as ManufacturingUnitPrice
							  , (ISNULL(ManufacturingUnitPrice, 0)  * ISNULL(StockQty,0)) AS StockPrice
							 -- ,StockPrice
							  ,CreateDateTime
							  ,CreateUserID
							  ,ChangeDateTime
							  ,ChangeUserID

						-- 추가
						, Case When Len(Day) = 1 then CONCAT(Year, Month, '0',  Day)   
								When Len(Day) = 2  then CONCAT(Year, Month, Day)        Else 0 End as  Lapse 
						, Case When  LEN(Case When Len(Day) = 1 then     CONCAT(Year, Month, '0',  Day)  Else   CONCAT(Year, Month, Day) End)  =  8 Then    DATEDIFF(dd,  Convert(Datetime, Case When Len(Day) = 1 then     CONCAT(Year, Month, 0,  Day)  else   CONCAT(Year, Month, Day) End) , Getdate() )   
							 else 0 end as Diff
							, MBISizeW
					  FROM  (

		 -- Temp테이블에 Insert부분 (Union)
			   -- 1. 한국본사부분
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
						 -- ,PSI.ManufacturingUnitPrice
						  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
						  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
					--   2021.01.13 추가사항  -- 이 부분이 다름
							,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), SY.Year ), 0 )
										WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), SY.Year), 0 ) End AS Year
							, CASE   WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2))  , 0) 
										WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 5, 1)) - 73), 2)) , 0)  ELSE null End  AS Month
							, CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
										WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE Null END  AS Day
                            , MBI.MBISizeW
						
				--	  INTO #StockInfoTemp2
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
                             
							  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																				,MaterialCode, AVG(CostPrice) AS CostPrice 
																			FROM STB_ManufacturingCostByRoute
																		GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																				,MaterialCode) MCR
																	ON MCR.ApplyDate = (SELECT ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = 1)
																	AND MCR.CompanyCode = PSI.CompanyCode
																	AND MCR.WorkCenterCode = PSI.WorkCenterCode
																	AND MCR.CostTypeCode = 'PC'
																	AND MCR.RouteCode = 'E-28'
																	AND MCR.MaterialCode = PSI.MaterialCode
																	   
							  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																	,MaterialCode, AVG(CostPrice) AS CostPrice 
																FROM STB_ManufacturingCostByRoute
															GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																	,MaterialCode) MCRM	ON MCRM.ApplyDate = (SELECT ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = 1)
																									AND MCRM.CompanyCode = PSI.CompanyCode
																									AND MCRM.WorkCenterCode = PSI.WorkCenterCode
																									AND MCRM.CostTypeCode = 'PC'
																									AND MCRM.RouteCode= 'E-28'
																									AND MCRM.MaterialCode = MBI.MBIExtText06

					 WHERE 1=1
					   AND PSI.CompanyCode = 'VNT'
					   AND PSI.WorkCenterCode = 'VNT_F1'
					   AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					   AND PSI.CreateDateTime BETWEEN @FromDate AND @ToDate

				UNION ALL

		     -- 2. 베트남부분      (VVT)
				SELECT PSI.ProductStockNo
						  ,PSI.CompanyCode as CompanyCode
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
						   -- ,PSI.ManufacturingUnitPrice
						  ,ISNULL(MCR.CostPrice, (MCRM.CostPrice * MBI.MBIExtInt01)) AS ManufacturingUnitPrice
						  ,PSI.StockPrice
						  ,PSI.CreateDateTime
						  ,PSI.CreateUserID
						  ,PSI.ChangeDateTime
						  ,PSI.ChangeUserID
				--   2021.01.13 추가사항 -- 이 부분이 다름
							,  CASE  WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), SY.Year ), 0 )
										WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), SY.Year), 0 ) End AS Year
                        
							, CASE   WHEN LEN(PSI.Barcode) < 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 4, 1)) - 73),2))  , 0) 
										WHEN LEN(PSI.Barcode) = 15 THEN IsNull(Convert(Varchar(20), Right ('0' + CONVERT(VARCHAR(20), ASCII(SubString(PSI.Barcode, 5, 1)) - 73), 2)) , 0)  ELSE null End  AS Month
                      
							, CASE  WHEN LEN(PSI.Barcode) < 15 THEN  ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 5, 2)), 0)
										WHEN LEN(PSI.Barcode) = 15 THEN ISNULL(Convert(Varchar(20), SubString(PSI.Barcode, 6, 2)), 0) ELSE Null END  AS Day
							, MBI.MBISizeW
					  FROM STB_ProductStockInfoUpload PSI
							  LEFT OUTER JOIN STB_CompanyInfo CI	         ON PSI.CompanyCode = CI.CompanyCode
							  LEFT OUTER JOIN STB_WorkCenterInfo WCI	     ON PSI.WorkCenterCode = WCI.WorkCenterCode
							  LEFT OUTER JOIN VW_ModelBasicInfo MBI	     ON PSI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_MaterialWarehouse MW	 ON PSI.MaterialWarehouseCode = MW.MaterialWarehouseName
							  LEFT OUTER JOIN STB_MaterialLocation ML	     ON PSI.MaterialLocationCode = ML.MaterialLocationCode
							  LEFT OUTER JOIN STB_YearInfo SY	                 ON SY.YearCode =  SubString(PSI.Barcode, 3, 1)
							 -- 단가때문에 추가부분 Start
							 	LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																				,MaterialCode, AVG(CostPrice) AS CostPrice 
																			FROM STB_ManufacturingCostByRoute
																		GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																				,MaterialCode) MCR
																	ON MCR.ApplyDate = (SELECT ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = 1)
																	AND MCR.CompanyCode = PSI.CompanyCode
																	AND MCR.WorkCenterCode = PSI.WorkCenterCode
																	AND MCR.CostTypeCode = 'PC'
																	AND MCR.RouteCode = 'V-28'
																	AND MCR.MaterialCode = PSI.MaterialCode

							  LEFT OUTER JOIN (SELECT ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																	,MaterialCode, AVG(CostPrice) AS CostPrice 
																FROM STB_ManufacturingCostByRoute
															GROUP BY ApplyDate, CompanyCode, WorkCenterCode, CostTypeCode, RouteCode
																	,MaterialCode) MCRM
														ON MCRM.ApplyDate = (SELECT ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = 1)
														AND MCRM.CompanyCode = PSI.CompanyCode
														AND MCRM.WorkCenterCode = PSI.WorkCenterCode
														AND MCRM.CostTypeCode = 'PC'
														AND MCRM.RouteCode  = 'V-28'
														AND MCRM.MaterialCode = MBI.MBIExtText06
                               -- 단가때문에 추가부분 End
					 WHERE 1=1
					   AND  PSI.CompanyCode = 'VVT'
					  AND PSI.WorkCenterCode = 'VVT_F1'
					  AND (@MaterialCode = '*' OR PSI.MaterialCode = @MaterialCode)
					   AND PSI.MaterialCode IN (SELECT MaterialCode FROM STB_MaterialMaster)
					  AND PSI.CreateDateTime BETWEEN Convert(CHAR(10), '2021-04-22 10:30:05', 121) + ' 00:00:00'   AND Convert(CHAR(10), '2021-04-22 10:30:05', 121) + ' 23:59:59'

) A

					 WHERE 1=1
					   AND (@CompanyCode = '*' OR CompanyCode = @CompanyCode)
				  --   AND (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode)               -- 작업장은 제외
					   AND (@MaterialCode = '*' OR MaterialCode = @MaterialCode)
				   -- 재품재고정보(Import)와 차이점 Start
					   AND Barcode  NOT IN ( 'MVJHP262R750502','MVJIM032R750502','MVJHN313R050501','MVJIO192R733540','MVJIP042R750503'
					                                   ,'MVJIQ312R750516','MVJIU012R710503','MVJIU012R710525','MVJIU012R710527','VJIO172R710503'
													   ,'MVJIP312R710606','MVJIQ042R710601','MVJIM062R710602','MVJIN192R710606','MVJIP312R710606'
													   ,'MVJIS052R710623','MVJHN313R050501','MVJIU163R050522','MVJIU143R050528','MVJIT233R010609'
													   ,'MVJIO092R715508','MVJIU182R715504','MVJIL212R715501','MVJIO312R750510','MVJIP012R770506'  )
						AND LEN(Barcode) IN ( '14', '15' )
				   -- 재품재고정보(Import)와 차이점 End
				   ) AA
---- [최종SQL] ----------------------------------------------------------------------
--SELECT AA.ProductStockNo
--		, AA.CompanyCode 
--		, AA.CompanyName 
--		, AA.MaterialCode 
--		, AA.MaterialName  
--		, AA.Barcode
--        , AA.Lapse 
--	    , AA.Diff
--		, AA.MBISizeW                                                  -- 파이추가  (2021.02.25)
--	   ,  (Convert(NUMERIC(10,4), AA.Diff) / 365) AS YEARS  --년수추가 (2021.02.25)
--		, AA.PackingID
--		, AA.MaterialWarehouseCode
--		, AA.MaterialWarehouseName
--		, AA.MaterialLocationCode
--		, AA.MaterialLocationName
--		, AA.PaletteNo
--		, AA.StockQty
--		--, AA.StockPrice
--		, AA.CreateDateTime
--		, AA.CreateUserID
--		, AA.ChangeDateTime
--		, AA.ChangeUserID
--		 , ISnull(AA.ManufacturingUnitPrice, 0) as ManufacturingUnitPrice
--		 , (ISNULL(AA.ManufacturingUnitPrice, 0)  * ISNULL(AA.StockQty,0)) AS StockPrice
--FROM (
--					SELECT ProductStockNo
--							  ,CompanyCode
--							  ,CompanyName
--							  --,WorkCenterCode
--							  --,WorkCenterName
--							  ,MaterialCode 
--							  ,MaterialName
--							  ,Barcode
--							  ,PackingID
--							  ,MaterialWarehouseCode
--							  ,MaterialWarehouseName
--							  ,MaterialLocationCode
--							  ,MaterialLocationName
--							  ,PaletteNo
--							  ,StockQty
--							  , ISnull(ManufacturingUnitPrice, 0) as ManufacturingUnitPrice
--							  , (ISNULL(ManufacturingUnitPrice, 0)  * ISNULL(StockQty,0)) AS StockPrice
--							 -- ,StockPrice
--							  ,CreateDateTime
--							  ,CreateUserID
--							  ,ChangeDateTime
--							  ,ChangeUserID

--						-- 추가
--						, Case When Len(Day) = 1 then CONCAT(Year, Month, '0',  Day)   
--								When Len(Day) = 2  then CONCAT(Year, Month, Day)        Else 0 End as  Lapse 
--						, Case When  LEN(Case When Len(Day) = 1 then     CONCAT(Year, Month, '0',  Day)  Else   CONCAT(Year, Month, Day) End)  =  8 Then    DATEDIFF(dd,  Convert(Datetime, Case When Len(Day) = 1 then     CONCAT(Year, Month, 0,  Day)  else   CONCAT(Year, Month, Day) End) , Getdate() )   
--							 else 0 end as Diff
--							, MBISizeW
--					  FROM #StockInfoTemp2
--					 WHERE 1=1
--					   AND (@CompanyCode = '*' OR CompanyCode = @CompanyCode)
--				  --   AND (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode)               -- 작업장은 제외
--					   AND (@MaterialCode = '*' OR MaterialCode = @MaterialCode)
--				   -- 재품재고정보(Import)와 차이점 Start
--					   AND Barcode  NOT IN ( 'MVJHP262R750502','MVJIM032R750502','MVJHN313R050501','MVJIO192R733540','MVJIP042R750503'
--					                                   ,'MVJIQ312R750516','MVJIU012R710503','MVJIU012R710525','MVJIU012R710527','VJIO172R710503'
--													   ,'MVJIP312R710606','MVJIQ042R710601','MVJIM062R710602','MVJIN192R710606','MVJIP312R710606'
--													   ,'MVJIS052R710623','MVJHN313R050501','MVJIU163R050522','MVJIU143R050528','MVJIT233R010609'
--													   ,'MVJIO092R715508','MVJIU182R715504','MVJIL212R715501','MVJIO312R750510','MVJIP012R770506'  )
--						AND LEN(Barcode) IN ( '14', '15' )
--				   -- 재품재고정보(Import)와 차이점 End

--				)  AA

--		   ---

		
		
END