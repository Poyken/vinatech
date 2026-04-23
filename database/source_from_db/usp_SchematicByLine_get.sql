
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : True
-- Group : 생산관리 > 생산현황 > 라인별 도식화 현황판
-- Description: 
-- Modified: 
 
-- EXEC usp_SchematicByLine_get '', '', '', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_SchematicByLine_get]		
							@pCompanyCode VARCHAR(20) = NULL,  			
							@pRouteCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(20) = NULL,				
							@pMaterialCode VARCHAR(30) = NULL
AS
	   DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END	
	   DECLARE	@RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	   DECLARE	@LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	
	   DECLARE	@MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN
	
-- 최종 SELECT문 
   SELECT  XX.ComPanyCode							
			, XX.InputLineCode		
			, XX.LineName											
			, XX.MaterialCode
			, XX.MaterialName   		
			, XX.RouteName
			, SUM(XX.PlanQty)  AS '계획량(ea)'
			, SUM(XX.InputQty) AS '투입량(ea)'
			, SUM(XX.ProdQty)  AS '생산량(ea)'		
	 FROM  (
				-- [1] 권취공정
				SELECT PRH.ComPanyCode
						, Max(SI.MaterialCode)  AS MaterialCode
						, MAX(MM2.MaterialName) AS MaterialName
						, SI.InputLineCode		
						,  LI.LineName
						, '1' AS RouteCode
						, '권취' AS RouteName										
						, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
						, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
						, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty   -- 불량수량 
						,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty     -- 생산수량(투입수량-불량수량)						
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
							--LEFT OUTER JOIN NextProd                 NP	    ON NP.ControlNo = SI.ControlNo
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
					    AND PRH.RouteCode IN ( 'E-22', 'V-22')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   					
					UNION ALL

					-- [2] 커링
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
						    ,  LI.LineName
						    , '2' AS RouteCode
							, '커링' AS RouteName										
							, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty           -- 생산수량)									
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
					   AND PRH.RouteCode IN ( 'E-24', 'V-24')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   						
					UNION ALL

					-- [3] 슬리브
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
							,  LI.LineName
							, '3' AS RouteCode
							, '슬리브' AS RouteName									
						   , ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty         -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty           -- 생산수량)									
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
					   AND PRH.RouteCode IN ( 'E-25', 'V-25')
					Group by PRH.ComPanyCode 
							, SI.InputLineCode
							, LI.LineName		   						
                UNION ALL				
				

				-- [4] 포장
					SELECT PRH.ComPanyCode
							, Max(SI.MaterialCode)  AS MaterialCode
							, MAX(MM2.MaterialName) AS MaterialName
							, SI.InputLineCode		
							,  LI.LineName
							, '4' AS RouteCode
							, '포장' AS RouteName									
							, ISNULL(SUM(Round(DPP.PlanQty, 0) ),0)                                                 AS PlanQty
							, ISNULL(SUM(PRH.ProdQty),0)                                                              AS InputQty    -- 투입수량
							, ISNULL(SUM(DRI.DefectQty), 0)                                                           AS DefectQty   -- 불량수량 
							,  SUM(Round(PRH.ProdQty, 0)) - ISNULL(SUM(Round(DRI.DefectQty, 0)), 0)    AS ProdQty     -- 생산수량																				
					FROM STB_SetInfo SI		
							LEFT OUTER JOIN ( 
														SELECT ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, Max(MaterialCode) as MaterialCode, MachineCode
														FROM STB_ProdRouteHist 
														WHERE 1=1										   														
														   AND JOBDATE BETWEEN '2020-08-26' AND '2020-09-25'
														Group by ControlNo, ComPanyCode,  ProdQty, LineCode, RouteCode, JobDate, MachineCode
													) PRH	                            ON SI.ControlNo = PRH.ControlNo AND SI.MaterialCode = PRH.MaterialCode
							LEFT OUTER JOIN STB_RouteInfo           RI	    ON PRH.RouteCode = RI.RouteCode			  
							LEFT OUTER JOIN STB_MaterialMaster  MM2	    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo              LI	    ON SI.InputLineCode = LI.LineCode							
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
					   AND PRH.RouteCode IN (  'E-28', 'V-28')					
					Group by PRH.ComPanyCode 
								, SI.InputLineCode
								, LI.LineName		   																
	 	 )  XX
		WHERE 1=1
		   --AND XX.JobDate   BETWEEN '2020-08-26' AND '2020-09-25'   -- 추가사항
		 	AND (@RouteCode = '*' OR XX.RouteCode = @RouteCode)
			AND (@LineCode = '*' OR XX.InputLineCode   = @LineCode)	  
			AND (@MaterialCode = '*' OR XX.MaterialCode = @MaterialCode)	   
			AND XX.InputLineCode <> '%'
	   GROUP BY XX.ComPanyCode							
					, XX.InputLineCode		
					,  XX.LineName								
					--, XX.IsHasNextProd		
					, XX.MaterialCode
					, XX.MaterialName   		
					, XX.RouteCode
					, XX.RouteName
					--, XX.JOBDATE
         --ORDER BY  XX.RouteCode, XX.InputLineCode

End