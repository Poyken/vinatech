-- =============================================
-- Author: kilee@awoo.co.kr
-- Create date: 2020-06-23
-- Browsable : true
-- Group : 생산관리 > 생산현황
-- Description:	[B630] WIP정보
-- Modified: 

-- EXEC [usp_WipInfo_get] 'kilee', 'Korean','VNT', 'VNT_F1', 'ASSYLINE-11', '', 'VJKO203R025608'
-- =============================================

CREATE PROCEDURE [dbo].[usp_WipInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(200) = NULL,
						@pPONo VARCHAR(20) = NULL,
						@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	-- 화면에서 검색조건이 넘어오지 않을 경우 테이블 풀스캔을 방지하기 위해 수정함. 2019.09.18 By Jackaroe
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END

	DECLARE @PONo VARCHAR(20) = CASE WHEN ISNULL(@pPONo,'') = '' THEN '*' ELSE @pPONo END
	DECLARE @Barcode VARCHAR(50) = ISNULL(@pBarcode, '')
	            ,@ControlNo VARCHAR(20)

	

SELECT  
          BB.LotID AS LotId
        , SUM(BB.AA)  AS 권취
        , SUM(BB.BB)   AS 고무전
		, SUM(BB.CC)   AS 커링
		, SUM(BB.DD)   AS 슬리빙
		, SUM(BB.EE)   AS 에이징
		, SUM(BB.FF)   AS 외관
		, SUM(BB.GG)   AS 제품검사
		, SUM(BB.HH)   AS 포장
FROM

		       --[기본 공정틀]   
			  (
			        	SELECT	
							   0 AS AA							
							  , 0 AS BB								
							  , 0 AS CC
							  , 0 AS DD
							  , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH
							   , SBD.RouteCode	  as RouteCode
						  From STB_BasicRoutingInfo SBR
								  Left Outer Join STB_BasicRoutingDetail SBD ON SBR.BasicRoutingCode = SBD.BasicRoutingCode
						Where 1=1
						   And SBR.BasicRoutingCode = 'WipRouting' 
						   And SBD.CompanyCode = 'VNT'					 			       
			)  AA
			
LEFT OUTER JOIN (
					      
						  -- [권취공정]
						   SELECT	
								ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS AA							
							  , 0 AS BB								
							  , 0 AS CC									    
							  , 0 AS DD
							  , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH							  	
							  , PRH.RouteCode AS RouteCode
							  , SI.Barcode AS LotId

							  , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode							  
							FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-22'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode												 
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						   --AND SI.Barcode = 'VJKO093R015602'
				 
				 -- [고무전공정]
				 UNION ALL

					  SELECT	
					            0 AS AA								
							  , ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS BB							
							  , 0 AS CC									  							    
							  , 0 AS DD
							  , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH	
							   , PRH.RouteCode AS RouteCode	
							   , SI.Barcode AS LotId		
							    , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode							  
							FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-23'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode													      
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						   --AND SI.Barcode = 'VJKO093R015602'
				
				 -- [3. 커링] 
				 UNION ALL
				
					  SELECT	
								 0  AS AA								
                               , 0  AS BB								
							   , ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS CC							     
							   , 0 AS DD
							  , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH
							    , PRH.RouteCode AS RouteCode
								, SI.Barcode AS LotId
								 , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode							  
						  FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-24'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode												      
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						   --AND SI.Barcode = 'VJKO093R015602'


                  -- [슬리빙] 
				 UNION ALL
				
					  SELECT	
								 0  AS AA								
                               , 0  AS BB								
							   , 0  AS CC							     
							   , ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS DD
							  , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH
							    , PRH.RouteCode AS RouteCode
								, SI.Barcode AS LotId
								 , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode
							  
						  FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-25'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode													       
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						   --AND SI.Barcode = 'VJKO093R015602'

				    -- [에이징] 
				 UNION ALL
				
					  SELECT	
								 0  AS AA								
                               , 0  AS BB								
							   , 0  AS CC							     
							   , 0 AS DD
							  , ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS EE
							   , 0 AS FF
							    , 0 AS GG
								, 0 AS HH
							    , PRH.RouteCode AS RouteCode
								, SI.Barcode AS LotId
								 , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode
							  
						  FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-26'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode														
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						  -- AND SI.Barcode = 'VJKO093R015602'

				-- [외관] 
				 UNION ALL
				
					  SELECT	
								 0  AS AA								
                               , 0  AS BB								
							   , 0  AS CC							     
							   , 0 AS DD
							   , 0 AS EE
							   , ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS FF
							    , 0 AS GG
								, 0 AS HH
							    , PRH.RouteCode AS RouteCode
								, SI.Barcode AS LotId
								 , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode
							 
						  FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-27'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode													  
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						  -- AND SI.Barcode = 'VJKO093R015602'
                   	
					-- [제품검사] 				
					    UNION ALL 

							SELECT	
									  0 AS AA								
									, 0 AS BB								
									, 0 AS CC							     
									, 0 AS DD
									, 0 AS EE
									, 0 AS FF
									, ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS GG
									, 0 AS HH
									, 'E-99' AS RouteCode
									, SI.Barcode        AS LotId
									 , PRH.CompanyCode AS CompanyCode
							  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode							  
								FROM (
											SELECT CompanyCode 
														,WorkCenterCode
														,PONo
														,ControlNo
														,LineCode
														,RouteCode
														,ProdQty
												FROM STB_ProdRouteHist
												WHERE RouteCode = 'E-27'								 
										) PRH														
									LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode								    
									LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
									LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
									LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
									LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
									LEFT OUTER JOIN (
																SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
																	FROM STB_DefectRepairInfo
																	WHERE 1=1				   
																	AND RepairType NOT IN ('MISSING')
																	GROUP BY ControlNo, FindLineCode, FindRouteCode
															) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
									  LEFT OUTER JOIN (
																 SELECT MaterialQcNo
																 FROM STB_MaterialQcInfo WHERE InspectionDocType = 'OQC' AND DecisionResult = 'Pass' --and MaterialQcNo = 'VJKO093R015602'
															   ) QC ON QC.MaterialQcNo = SI.Barcode
			  
							WHERE 1=1
								AND  PRH.CompanyCode    =  'VNT'			
								AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
								--AND SI.Barcode = 'VJKO093R015602'

			     -- [포장 : E-28]
				 UNION ALL
				
					  SELECT	
								 0  AS AA								
                               , 0  AS BB								
							   , 0  AS CC							     
							   , 0 AS DD
							   , 0 AS EE
							   , 0 AS FF
							    , 0 AS GG
								, ISNULL(PRH.ProdQty, 0) - ISNULL(DQI.DefectQty, 0) AS HH
							    , PRH.RouteCode AS RouteCode
								, SI.Barcode AS LotId
								, PRH.CompanyCode AS CompanyCode
								  , SI.MaterialCode      AS MaterialCode
							  , MM.MaterialName AS MaterialName
							  , SI.InputLineCode    AS LineCode	
						  FROM (
										SELECT CompanyCode 
												  ,WorkCenterCode
												  ,PONo
												  ,ControlNo
												  ,LineCode
												  ,RouteCode
												  ,ProdQty
										  FROM STB_ProdRouteHist
										  WHERE RouteCode = 'E-28'								 
									) PRH						
								LEFT OUTER JOIN STB_RouteInfo RI                          WITH(NOLOCK)	ON RI.RouteCode = PRH.RouteCode						
								
								LEFT OUTER JOIN STB_RouteInfo NRI                     WITH(NOLOCK)	ON NRI.RouteCode = PRH.RouteCode
								LEFT OUTER JOIN STB_SetInfo SI                           WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
								LEFT OUTER JOIN STB_MaterialMaster MM               WITH(NOLOCK)	ON MM.MaterialCode = SI.MaterialCode
								LEFT OUTER JOIN STB_LineInfo LI                          WITH(NOLOCK)	ON LI.LineCode = PRH.LineCode	
								LEFT OUTER JOIN (
															SELECT ControlNo, FindLineCode, FindRouteCode, SUM(DefectQty) AS DefectQty
															  FROM STB_DefectRepairInfo
															 WHERE 1=1				   
															   AND RepairType NOT IN ('MISSING')
															 GROUP BY ControlNo, FindLineCode, FindRouteCode
														) DQI ON PRH.ControlNo = DQI.ControlNo AND PRH.LineCode = DQI.FindLineCode AND PRH.RouteCode = DQI.FindRouteCode
						WHERE 1=1
						   AND  PRH.CompanyCode    =  'VNT'			
						   AND SI.IsProdFinish <> 1                                                                              -- 2020.06.02 추가
						  -- AND SI.Barcode = 'VJKO093R015602'
						 
						 
			) BB  ON AA.RouteCode = BB.RouteCode
WHERE 1=1
AND BB.LotID = @Barcode
Group By BB.LotID

END