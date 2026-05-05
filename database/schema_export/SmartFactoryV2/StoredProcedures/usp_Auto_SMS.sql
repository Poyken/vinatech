-- Procedure: usp_Auto_SMS

-- =======================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-08-10
-- Browsable : True
-- Group : SMS 문자메세지 발송> 매일 오전 8시반에 [VPC전일실적]을 정규직 직원에게 발송!!!!
-- Description: 
--                  2022.03.13 계획테이블 변경 ( STB_ProdLinePlan  -> STB_VPCLinePlan)
--                  2022.03.24 임시테이블 제외
--                  2022.03.25 커링실적으로 변경  (백업 프로시저 -> usp_VPCBeforeDailyTotalProd_SMS_Winding)
--                  2022.04.01 계획수량 변경 (155,000) 
--                  2022.04.18 권취 8라인 추가로 권취 계획수량변경 (178,000)
-- Modified:  

-- 프로시저 실행 :                    usp_Auto_SMS  '',''
-- ==============================================================================

CREATE PROCEDURE [dbo].[usp_Auto_SMS]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @FromDate DateTime = CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  --전일
	DECLARE @ToDate    DateTime = CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'   --금일 
    
	DECLARE @YesterDate VARCHAR(20)   = CONVERT(VARCHAR(10), GETDATE()-1, 121)                      --  전일 : SELECT CONVERT(VARCHAR(10), GETDATE()-1, 121)
	DECLARE @ProdDate VARCHAR(20)   = CONVERT(VARCHAR(10), GETDATE(), 121)                           -- 금일 : SELECT CONVERT(VARCHAR(10), GETDATE(), 121)	

	DECLARE @Time  VARCHAR(20)  = SUBSTRING(CONVERT(NVARCHAR, GETDATE(), 121), 12, 5)                -- Select  SUBSTRING(CONVERT(NVARCHAR, GETDATE()-1, 121), 12, 5)
	DECLARE @StandardTime   VARCHAR(200) = @YesterDate + ' 오전 08:30 ~ ' + @ProdDate + ' 오전 08:29'

    DECLARE @PlanQty NVARCHAR(MAX)
	DECLARE @ProdQty NVARCHAR(MAX)

	DECLARE @LineCode VARCHAR(20) 
	DECLARE @LineName VARCHAR(20) 
	DECLARE @RouteName VARCHAR(20) 
	DECLARE @ProdRate Numeric(20,2)
	DECLARE @LineMessage NVARCHAR(MAX)

	DECLARE @msg VARCHAR(MAX) = ''
	DECLARE @msg2 VARCHAR(MAX) = ''

	-- 권취, 커링 생산목표
	Declare @WindingTargetQty BIGINT
	Declare @CurlingTargetQty BIGINT

	SELECT @WindingTargetQty = SUM(PlanQty)
	  FROM STB_VPCLinePlan

	SELECT @CurlingTargetQty = SUM(PlanQty)
	  FROM STB_VPCLinePlan_two

/*
-- 1. 권취공정
    -- 1-1. SMS를 위한 메세지 조립
  SELECT @msg = @msg + ZA.LineName + ' (' + Convert(Varchar(20), PlanQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdRate) + '% ' + ')<br>'
   FROM  (  
                  
                --  [1] 권취누계  									
					SELECT 'VPC권취합계 ' As LineCode
							, Format(Convert(BIGINT, @WindingTargetQty),  'N0')AS PlanQty
							, Convert(Varchar(10), DateAdd(Day, -1, GetDate()), 121)  As ProdDateTime
							, '권취' As RouteName
							, '[권취합계]' As LineName
							, Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0') AS ProdQty 
							, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / CONVERT(NUMERIC(20,2), @WindingTargetQty) * 100)), 1) AS ProdRate										
					 FROM (
										SELECT  B.LineCode
													, IsNull(B.PlanQty, 0) As PlanQty
													, A.RouteName						
													, A.LineName
													, IsNull(A.ProdQty, 0) As ProdQty
										FROM  (
															SELECT Convert(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 
																		, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName		
																		, FIN.LineCode As LineCode
																		, FIN.LineName As LineName
																		, Convert(BIGINT, Sum(FIN.ProdQty))  AS ProdQty
																		, Convert(BIGINT, Sum(FIN.DefectQty)) AS DefectQty										
																FROM (

																			SELECT TOP 100000   PRH.RouteCode
																					, RI.RouteName
																					, PRH.ProdDateTime
																					, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime														
																					, PRH.ProdQty AS InputProdQty
																					, ISNULL(DRI.DefectQty, 0) AS DefectQty 
																					, ISNULL(PRH.ProdQty, 0) - ISNULL(DRI.DefectQty, 0)  AS ProdQty
																					, SI.InputLineCode AS LineCode
																					, LI.LineName As LineName														 
																				FROM STB_SetInfo SI WITH(NOLOCK) 
																						LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo																					   																											
																						LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
																						LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
																						LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
																						LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
																						LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
																						LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																													,DRI2.FindRouteCode
																													,MAX(PRH2.MachineCode) AS MachineCode
																													,SUM(DRI2.DefectQty) AS DefectQty 
																												FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																												LEFT OUTER JOIN STB_ProdRouteHist PRH2								ON DRI2.ControlNo = PRH2.ControlNo							AND DRI2.FindRouteCode = PRH2.RouteCode
																												WHERE RepairType = 'NONE'
																												AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')					
																												AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																												GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
																											) DRI 						 ON PRH.ControlNo = DRI.ControlNo						AND PRH.RouteCode = DRI.FindRouteCode						AND PRH.MachineCode = DRI.MachineCode
																					LEFT OUTER JOIN (
																											SELECT RouteCode, MIN(MachineCode) AS MachineCode
																												FROM STB_ProductMachine
																												GROUP BY RouteCode
																											) PM                  ON PM.RouteCode = PRH.RouteCode
																					LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode
																					LEFT OUTER JOIN (
																											Select RouteCode
																													, ControlNo
																													, Sum(ProdQty)  As ProdQty
																											From STB_InterimProdQtyInfo
																											Where RouteCode = 'E-22'
																											Group by RouteCode, ControlNo
																											) IPQ  On SI.ControlNo = IPQ.ControlNo 														
																				WHERE 1=1
																					AND PRH.CompanyCode = 'VNT'
																					AND PRH.WorkCenterCode = 'VNT_F1'
																					AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																					AND SubString(PRH.MaterialCode, 1, 6) = 'LIVT38' 
																					AND PRH.RouteCode = 'E-22'
																				ORDER BY PRH.RouteCode
																							, PRH.LineCode
															) FIN
																WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
																	AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
																	AND FIN.RouteCode = 'E-22'

																GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
																		, RouteName
																		, LineCode
																		, LineName
																HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
																) A																		                                                                    												
																	RIGHT OUTER JOIN STB_VPCLinePlan B  WITH(NOLOCK) ON A.LineCode = B.LineCode  																																																						
															) A2														
				  -- [1] 권취누계 End
                           
   	             --  [2] 커링누계 Start  									
				        UNION ALL

							               SELECT 'VPC조립합계 ' As LineCode
													, Format(Convert(BIGINT, @CurlingTargetQty),  'N0')AS PlanQty
													, Convert(Varchar(10), DateAdd(Day, -1, GetDate()), 121)  As ProdDateTime
													, '조립(커링)' As RouteName
													, '[조립합계]' As LineName
													, Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0') AS ProdQty 
													, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / CONVERT(NUMERIC(20,2), @CurlingTargetQty) * 100)), 1) AS ProdRate											
													FROM (
																SELECT  --B.LineCode
																		 IsNull(B.PlanQty, 0) As PlanQty
																		--, A.RouteName						
																		--, A.LineName
																		, IsNull(A.ProdQty, 0) As ProdQty
																FROM  (
																						SELECT Convert(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 
																								, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName		
																								, FIN.LineCode As LineCode
																								--, FIN.LineName As LineName
																								, Convert(BIGINT, Sum(FIN.ProdQty))  AS ProdQty
																								, Convert(BIGINT, Sum(FIN.DefectQty)) AS DefectQty										
																						FROM (

																									SELECT TOP 100000   PRH.RouteCode
																											, RI.RouteName
																											, PRH.ProdDateTime
																											, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime														
																											, PRH.ProdQty AS InputProdQty
																											, ISNULL(DRI.DefectQty, 0) AS DefectQty 
																											, ISNULL(PRH.ProdQty, 0) - ISNULL(DRI.DefectQty, 0)  AS ProdQty
																											, SI.InputLineCode AS LineCode
																											, LI.LineName As LineName														 
																										FROM STB_SetInfo SI WITH(NOLOCK) 
																												LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo																					   																											
																												LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
																												LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
																												LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
																												LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
																												LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
																												LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																																			,DRI2.FindRouteCode
																																			,MAX(PRH2.MachineCode) AS MachineCode
																																			,SUM(DRI2.DefectQty) AS DefectQty 
																																		FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																																		LEFT OUTER JOIN STB_ProdRouteHist PRH2								ON DRI2.ControlNo = PRH2.ControlNo							AND DRI2.FindRouteCode = PRH2.RouteCode
																																		WHERE RepairType = 'NONE'
																																		AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')					
																																		AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																																		GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
																																	) DRI 						 ON PRH.ControlNo = DRI.ControlNo						AND PRH.RouteCode = DRI.FindRouteCode						AND PRH.MachineCode = DRI.MachineCode
																											LEFT OUTER JOIN (
																																	SELECT RouteCode, MIN(MachineCode) AS MachineCode
																																		FROM STB_ProductMachine
																																		GROUP BY RouteCode
																																	) PM                  ON PM.RouteCode = PRH.RouteCode
																											LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode																																						
																										WHERE 1=1
																										   AND PRH.CompanyCode = 'VNT'
																										   AND PRH.WorkCenterCode = 'VNT_F1'
																										   AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																										   AND SubString(PRH.MaterialCode, 1, 6) = 'LIVT38' 																										   
																										ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END
																					) FIN
																						WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
																							AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
																							AND FIN.RouteCode = 'E-24'

																						GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
																								, RouteName
																								, LineCode
																								, LineName
																						HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
																						) A																		                                                                    												
																						   --RIGHT OUTER JOIN STB_VPCLinePlan_Two B  WITH(NOLOCK) ON A.LineCode = B.LineCode  																																																						
																						      LEFT OUTER JOIN STB_VPCLinePlan_Two B  WITH(NOLOCK) ON A.LineCode = B.LineCode  																																																						
																					) A2														
					-- [2] 커링누계 End

                 ) ZA

    
		
	SELECT @msg2 = @msg2 + ZB.LineName + ' (' + Convert(Varchar(20), PlanQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdRate) + '% ' + ')<br>'
     FROM  (  

	     -- [3] 커링 라인별 집계		
				SELECT A2.LineCode
						, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0') As PlanQty 
						, Convert(Varchar(10), DateAdd(Day, -1, GetDate()), 121)  As ProdDateTime
						, IsNull(Max(A2.RouteName), '조립(커링)') As RouteName
						, Case When A2.LineCode = 'VPCLINE-01' Then 'VPC 1라인'
								When A2.LineCode = 'VPCLINE-02' Then 'VPC 2라인'
								When A2.LineCode = 'VPCLINE-03' Then 'VPC 3라인'
								When A2.LineCode = 'VPCLINE-04' Then 'VPC 4라인'
								When A2.LineCode = 'VPCLINE-05' Then 'VPC 5라인'
								When A2.LineCode = 'VPCLINE-06' Then 'VPC 6라인' 
								When A2.LineCode = 'VPCLINE-07' Then 'VPC 7라인' 
								When A2.LineCode = 'VPCLINE-08' Then 'VPC 8라인' 
								When A2.LineCode = 'VPCLINE-09' Then 'VPC 9라인' 
								When A2.LineCode = 'VPCLINE-10' Then 'VPC10라인' Else '기타' End As LineName
						 , Format(Convert(BIGINT, Sum(A2.ProdQty)),  'N0') As ProdQty 						
						 , Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Max(A2.PlanQty) * 100)), 1) As ProdRate
				FROM (
								SELECT  B.LineCode
										, IsNull(B.PlanQty, 0) As PlanQty
										, A.RouteName						
										, A.LineName
										, IsNull(A.ProdQty, 0) As ProdQty
								FROM  (
														SELECT Convert(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 
																, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName		
																--, FIN.LineCode As LineCode   -- 원본백업
																, Case When MachineName = 'VPC#1 조립기' Then 'VPCLINE-01'
																		When MachineName = 'VPC#2 조립기' Then 'VPCLINE-02'
																		When MachineName = 'VPC#3 조립기' Then 'VPCLINE-03'
																		When MachineName = 'VPC#4 조립기' Then 'VPCLINE-04'
																		When MachineName = 'VPC#5 조립기' Then 'VPCLINE-05'
																		When MachineName = 'VPC#6 조립기' Then 'VPCLINE-06'
																		When MachineName = 'VPC#7 조립기' Then 'VPCLINE-07'
																		When MachineName = 'VPC#8 조립기' Then 'VPCLINE-08' 
																		When MachineName = 'VPC#9 조립기' Then 'VPCLINE-09' 
																		When MachineName = 'VPC#10 조립기' Then 'VPCLINE-10' Else 'VPCLINE-기타' End As LineCode  -- 설비기준 라인변경 (2022.03.29)
																, FIN.LineName As LineName
																, Convert(BIGINT, Sum(FIN.ProdQty))  AS ProdQty
																, Convert(BIGINT, Sum(FIN.DefectQty)) AS DefectQty										
														FROM (

																	SELECT TOP 100000   PRH.RouteCode
																			, RI.RouteName
																			, PRH.ProdDateTime
																			, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime														
																			, PRH.ProdQty AS InputProdQty
																			, ISNULL(DRI.DefectQty, 0) AS DefectQty 
																			--, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) + IPQ.ProdQty  AS ProdQty
																			, ISNULL(PRH.ProdQty, 0) - ISNULL(DRI.DefectQty, 0)  AS ProdQty
																			, SI.InputLineCode AS LineCode
																			, LI.LineName As LineName		
																			, PRH.MachineCode As MachineCode   -- (2022.03.29) 추가
														                    , (Select SMM.MachineName From STB_MachineMaster SMM Where SMM.MachineCode = PRH.MachineCode) As MachineName	 -- (2022.03.29) 추가												 
																		FROM STB_SetInfo SI WITH(NOLOCK) 
																				LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo																					   																											
																				LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
																				LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
																				LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
																				LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
																				LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
																				LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																											,DRI2.FindRouteCode
																											,MAX(PRH2.MachineCode) AS MachineCode
																											,SUM(DRI2.DefectQty) AS DefectQty 
																										FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																										LEFT OUTER JOIN STB_ProdRouteHist PRH2								ON DRI2.ControlNo = PRH2.ControlNo							AND DRI2.FindRouteCode = PRH2.RouteCode
																										WHERE RepairType = 'NONE'
																										AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')					
																										AND PRH2.ProdDateTime BETWEEN Convert(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																										GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
																									) DRI 						 ON PRH.ControlNo = DRI.ControlNo						AND PRH.RouteCode = DRI.FindRouteCode						AND PRH.MachineCode = DRI.MachineCode
																			LEFT OUTER JOIN (
																									SELECT RouteCode, MIN(MachineCode) AS MachineCode
																										FROM STB_ProductMachine
																										GROUP BY RouteCode
																									) PM                  ON PM.RouteCode = PRH.RouteCode
																			LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode																																
																		WHERE 1=1
																			AND PRH.CompanyCode = 'VNT'
																			AND PRH.WorkCenterCode = 'VNT_F1'
																			AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'
																			--AND PRH.MaterialCode = 'LIVT38-018'
																			AND SubString(PRH.MaterialCode, 1, 6) = 'LIVT38' 
																			--AND PRH.RouteCode = 'E-24'
																		ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END
													) FIN
														WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
															AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
															AND FIN.RouteCode = 'E-24'

														GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
																, RouteName
																, LineCode
																, LineName
																, MachineName   -- (2022.03.29) 2022.03.29 추가
														HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
														) A																									
														   RIGHT OUTER JOIN STB_VPCLinePlan_Two B  WITH(NOLOCK) ON A.LineCode = B.LineCode       													
												) A2
												GROUP BY A2.LineCode															                           
											-- [3]. 라인별조회 End

			) ZB    -- @msg2 조립위한 테이블


         
		 -- 주석처리부분   
         --   select  '[생산 실적]' + '<br>' + @msg + '<br>'                         -- 찍어보기 위한 용도
--			      + '[슬리브실적]' + '<br>' + @msg2 + '<br>' 
		
*/
			SET @LineMessage = '당신을 축제에 초대합니다.' + '<br>'
			            + 'https://url.kr/jnb6ui'  + '<br>'
	                    + ' [일시] : 8월 26일~28일 (3일간)'  + '<br>'
						+ ' [장소] : 대전컨벤션센터(DCC) 제2전시장 '  + '<br>'							
					

              Select  @LineMessage    --주석부분						          	
	
-- 1. 테스트용 (나만)	
   Exec usp_DoSendSMS '', '', '010-3844-1998, 010-4225-0556, 01023207233', @LineMessage , ''    

    

	
END


/*

select * from STB_SystemSms
where 1=1
and systemsmsno >= '1217'
order by systemsmsno desc

*/
GO

