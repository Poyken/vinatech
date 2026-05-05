
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : True
-- Group : 생산관리 > 생산현황 > 라인별 도식화 현황판
-- Description: 
-- Modified: 
 
--프로시저 실행  usp_LotTrackingInfo_Mornitorning_20200825_get 'VNT', '', 'ASSYLINE-05', ''
--                    usp_LotTrackingInfo_Mornitorning_20200825_get '', '', '', ''
-- =============================================
Create PROCEDURE [dbo].[usp_LotTrackingInfo_Mornitorning_20200915_get]					
							@pCompanyCode VARCHAR(20) = NULL,  			
							@pRouteCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(20) = NULL,				
							@pMaterialCode VARCHAR(30) = NULL
AS

	   DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	-- DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	-- DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	   DECLARE	@RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	   DECLARE	@LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	
	   DECLARE	@MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	;WITH NextProd AS
	(
		SELECT
				SI.ControlNo,
				MAX(PRH.RouteCode) AS AftRouteCode,
				SUM(PRH.ProdQty)     AS AftProdQty					
		FROM
									    STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)	   ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	   ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode								
        WHERE 1=1		   
		   And SI.IsProdFinish <> '1'
		   And InputJobDate is not Null
		   And InputLineCode is not Null
		   --And SI.InputLineCode Like 'ASSYLINE%'
		   --And prh.CompanyCode = ''
		GROUP BY
				SI.ControlNo
	)


	--- 최종 SELECT문   ---

	SELECT  XX.ComPanyCode							
			, XX.InputLineCode		
			,  XX.LineName								
			, XX.IsHasNextProd		
			, XX.MaterialCode
			, XX.MaterialName   		
			, XX.RouteName
			, SUM(XX.PlanQty)  AS '계획량(ea)'
			, SUM(XX.InputQty) AS '투입량(ea)'
			, SUM(XX.ProdQty)  AS '생산량(ea)'
			, SUM(XX.CheckQty) AS '진행율(%)'
			, XX.JobDate AS JobDate

	 FROM  (
				-- [1] 권취공정
				SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
							,  LI.LineName
							, '1' AS RouteCode
							, '권취' AS RouteName			
							, CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd		   
							, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty   -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty     -- 생산수량(투입수량-불량수량)
							, 0 AS CheckQty						
							, PRH.JobDate  AS JobDate
					FROM STB_SetInfo SI		
							LEFT OUTER JOIN ( 
														SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
														FROM STB_ProdRouteHist 
														WHERE 1=1										   
														--And ComPanyCode = 'VNT'			
														AND JOBDATE BETWEEN '2020-08-26' AND '2020-09-25'											
														Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
													) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
							LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
							LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
							LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
							LEFT OUTER JOIN ( 
														SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
														FROM STB_DefectRepairInfo 
														WHERE RepairType = 'NONE'
														GROUP BY ControlNo, FindRouteCode
													) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

							LEFT OUTER JOIN (
													SELECT ProdNo, COUNT(*) AS MeasureCount
														FROM STB_CommInspDocHistory CIDH
														LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
														INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
														GROUP BY ProdNo
													) MC                                                   ON SI.ControlNo = MC.ProdNo    
						LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	         ON DPP.DayPlanNo = SI.DayPlanNo              
					WHERE 1=1	   
					AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                 	   
					AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
					AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
					AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)	   
					AND SI.InputLineCode <> '%'
					AND PRH.RouteCode IN ( 'E-22', 'V-22')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   
					, PRH.JobDate

					UNION ALL


					-- [2] 커링
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
						    ,  LI.LineName
						    , '2' AS RouteCode
							, '커링' AS RouteName			
							, CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd		   
							, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty           -- 생산수량)		
							, 0 AS CheckQty							
							, PRH.JobDate  AS JobDate
					FROM STB_SetInfo SI		
							LEFT OUTER JOIN ( 
														SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
														FROM STB_ProdRouteHist 
														WHERE 1=1										   
														--And ComPanyCode = 'VNT'
														AND JOBDATE BETWEEN '2020-08-26' AND '2020-09-25'
														Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
													) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
							LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
							LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
							LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
							LEFT OUTER JOIN ( 
														SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
														FROM STB_DefectRepairInfo 
														WHERE RepairType = 'NONE'
														GROUP BY ControlNo, FindRouteCode
													) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

							LEFT OUTER JOIN (
													SELECT ProdNo, COUNT(*) AS MeasureCount
														FROM STB_CommInspDocHistory CIDH
														LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
														INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
														GROUP BY ProdNo
													) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
						LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	         ON DPP.DayPlanNo = SI.DayPlanNo              
					WHERE 1=1	   
					AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                 	   
					AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
					AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
					AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)	   
					AND SI.InputLineCode <> '%'
					AND PRH.RouteCode IN ( 'E-24', 'V-24')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   
							, PRH.JobDate
					UNION ALL


					-- [3] 슬리브
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
						,  LI.LineName
						, '3' AS RouteCode
						, '슬리브' AS RouteName			
						, CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd		   
								, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty           -- 생산수량)		
							, 0 AS CheckQty						
							, PRH.JobDate  AS JobDate
					FROM STB_SetInfo SI		
							LEFT OUTER JOIN ( 
														SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
														FROM STB_ProdRouteHist 
														WHERE 1=1										   
														--And ComPanyCode = 'VNT'
														AND JOBDATE BETWEEN '2020-08-26' AND '2020-09-25'
														Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
													) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
							LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
							LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
							LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
							LEFT OUTER JOIN ( 
														SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
														FROM STB_DefectRepairInfo 
														WHERE RepairType = 'NONE'
														GROUP BY ControlNo, FindRouteCode
													) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

							LEFT OUTER JOIN (
													SELECT ProdNo, COUNT(*) AS MeasureCount
														FROM STB_CommInspDocHistory CIDH
														LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
														INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
														GROUP BY ProdNo
													) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
						LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	         ON DPP.DayPlanNo = SI.DayPlanNo              
					WHERE 1=1	   
					AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                 	   
					AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
					AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
					AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)	   
					AND SI.InputLineCode <> '%'
					AND PRH.RouteCode IN ( 'E-25', 'V-25')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   
							, PRH.JobDate
                UNION ALL				
				

				-- [4] 포장
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
						,  LI.LineName
						, '4' AS RouteCode
						, '포장' AS RouteName			
						, CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd		   
							, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty   -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty     -- 생산수량													
							, Case When SUM(PRH.ProdQty)= 0 Then 0 
									When SUM(MP.PlanQty) = 0 Then 0  								
									Else (SUM(MP.PlanQty) / SUM(PRH.ProdQty)) End AS CheckQty
							, PRH.JobDate  AS JobDate

					FROM STB_SetInfo SI		
							LEFT OUTER JOIN ( 
														SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
														FROM STB_ProdRouteHist 
														WHERE 1=1										   
														--And ComPanyCode = 'VNT'
														AND JOBDATE BETWEEN '2020-08-26' AND '2020-09-25'
														Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
													) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
							LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
							LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
							LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
							LEFT OUTER JOIN ( 
														SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
														FROM STB_DefectRepairInfo 
														WHERE RepairType = 'NONE'
														GROUP BY ControlNo, FindRouteCode
													) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

							LEFT OUTER JOIN (
													SELECT ProdNo, COUNT(*) AS MeasureCount
														FROM STB_CommInspDocHistory CIDH
														LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
														INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
														GROUP BY ProdNo
													) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
						LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	         ON DPP.DayPlanNo = SI.DayPlanNo              

						LEFT Outer Join MEDIUM_PLAN MP  WITH(NOLOCK)	         ON MP.LineCode = SI.InputLineCode	         
					WHERE 1=1	   					
					AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
					AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
					AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)	   
					AND SI.InputLineCode <> '%'
					AND PRH.RouteCode IN (  'E-28', 'V-28')

					AND MP.기준년월 = '202009'
					Group by PRH.ComPanyCode 
								, SI.InputLineCode
								, LI.LineName		   								
								, PRH.JobDate
    --                  UNION ALL				
				
				---- [5] 전체공정
				--	SELECT PRH.ComPanyCode
				--			, Max(SI.MaterialCode)  AS MaterialCode
				--			, MAX(MM2.MaterialName) AS MaterialName
				--			, SI.InputLineCode		
				--		,  LI.LineName
				--		, '공정합계' AS RouteCode
				--		, '공정합계' AS RouteName			
				--		, CONVERT(BIT,CASE WHEN ISNULL(SUM(NP.AftProdQty),0) > 0 THEN 1	ELSE 0 	END) AS IsHasNextProd		   
				--			, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
				--			, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
				--			, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
				--			,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty           -- 생산수량)			
				--			--, Case When SUM(PRH.ProdQty) = 0 Then 0 
				--			--	  When SUM(Round(DPP.PlanQty, 0) )   = 0 Then 0 
				--			--	   Else Round((SUM(PRH.ProdQty)    /  SUM(DPP.PlanQty)  * 100), 1)  End       AS '진행율(%)'   
				--	FROM STB_SetInfo SI		
				--			LEFT OUTER JOIN ( 
				--										SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
				--										FROM STB_ProdRouteHist 
				--										WHERE 1=1										   
				--										--And ComPanyCode = 'VNT'
				--										Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
				--									) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
				--			LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
				--			LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
				--			LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode
				--			LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
				--			LEFT OUTER JOIN ( 
				--										SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
				--										FROM STB_DefectRepairInfo 
				--										WHERE RepairType = 'NONE'
				--										GROUP BY ControlNo, FindRouteCode
				--									) DRI	                                              ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

				--			LEFT OUTER JOIN (
				--									SELECT ProdNo, COUNT(*) AS MeasureCount
				--										FROM STB_CommInspDocHistory CIDH
				--										LEFT OUTER JOIN STB_CommInspDocItem CIDI					ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
				--										INNER JOIN STB_CommInspMeasureHist CIMH					ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
				--										GROUP BY ProdNo
				--									) MC                                                   ON SI.ControlNo = MC.ProdNo     -- #0406
				--		LEFT OUTER JOIN STB_DayProdPlan  DPP  WITH(NOLOCK)	         ON DPP.DayPlanNo = SI.DayPlanNo              
				--	WHERE 1=1	   
				--	AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                 	   
				--	AND (@RouteCode = '*' OR PRH.RouteCode = @RouteCode)
				--	AND (@LineCode = '*' OR PRH.LineCode   = @LineCode)	  
				--	AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)	   
				--	AND SI.InputLineCode <> '%'
				--	AND PRH.RouteCode IN ('E-22', 'E-24', 'E-25', 'E-28', 'V-22', 'V-24', 'V-25', 'V-28')
				--	Group by PRH.ComPanyCode 
				--			, SI.InputLineCode
				--			, LI.LineName		   
	 	 )  XX
		WHERE 1=1
		   AND XX.JobDate   BETWEEN '2020-08-26' AND '2020-09-25'   -- 추가사항

		 
	   GROUP BY XX.ComPanyCode							
					, XX.InputLineCode		
					,  XX.LineName								
					, XX.IsHasNextProd		
					, XX.MaterialCode
					, XX.MaterialName   		
					, XX.RouteCode
					, XX.RouteName
					, XX.JOBDATE
         ORDER BY  XX.RouteCode, XX.InputLineCode

End