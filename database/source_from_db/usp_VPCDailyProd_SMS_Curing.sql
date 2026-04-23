
-- ================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-25 
-- Browsable : True
-- Group : VPC 커링실적 자동문자메세지 발송 > 하루에 2번 문자발송!! (오전오후8시반)
-- Description: 
-- Modified:  권취 시간별 문자메세지
--               2020.3.3일 수정보완하여 전직원에게 발송시작 
--               2022.03.10 합계수량 추가 (정갑수)
--               2022.03.13 계획테이블 변경 ( STB_ProdLinePlan  -> STB_VPCLinePlan )
--               2022.03.24 임시테이블 삭제

-- 프로시저 실행 :              usp_VPCDailyProd_SMS_Curing  '', ''
-- ================================================================================
CREATE PROCEDURE [dbo].[usp_VPCDailyProd_SMS_Curing]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @FromDate DateTime = CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'                               -- select CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  
	DECLARE @ToDate    DateTime = CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59'         -- select CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59'    
	DECLARE @Time  VARCHAR(20)  = SUBSTRING(CONVERT(NVARCHAR, GETDATE(), 121), 12, 5)                -- Select  SUBSTRING(CONVERT(NVARCHAR, GETDATE(), 121), 12, 5)
	DECLARE @StandardTime   VARCHAR(200) = '오전 08:30 ~ ' +  @Time

    DECLARE @PlanQty NVARCHAR(MAX)
	DECLARE @ProdQty NVARCHAR(MAX)
	DECLARE @ProdDateTime VARCHAR(20)   = CONVERT(VARCHAR(10), GETDATE(), 121)                                  -- SELECT CONVERT(VARCHAR(10), GETDATE(), 121)

	DECLARE @LineCode VARCHAR(20) 
	DECLARE @LineName VARCHAR(20) 
	DECLARE @RouteName VARCHAR(20) 
	DECLARE @ProdRate Numeric(20,2)
	DECLARE @LineMessage NVARCHAR(MAX)

	DECLARE @msg VARCHAR(MAX) = ''
	DECLARE @msg2 VARCHAR(MAX) = ''

-- 1. 권취공정
   -- SMS를 위한 메세지 조립
  --SELECT  @msg = @msg + '[권취] : ' + A.LineName + '(' + convert(varchar(20), PlanQty) + ' / ' + convert(varchar(20), ProdQty) + ' / ' + convert(varchar(20), ProdRate) + '% ' + ')<br>'
 -- SELECT @msg = @msg + Z.LineName + ' (' + Convert(Varchar(20), PlanQty) + ' / ' + Convert(Varchar(20), ProdQty) + ' / ' + Convert(Varchar(20), ProdRate) + '% ' + ')<br>'

  SELECT @msg = @msg + ZA.LineName + ' (' + Convert(Varchar(20), PlanQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdRate) + '% ' + ')<br>'
  FROM  (  

  		 --1. 권취누계추가   							

				SELECT '권취합계 ' As LineCode
				--, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0')AS PlanQty 
				, Format(Convert(BIGINT, 139000),  'N0')AS PlanQty                                         -- 고정값 세팅
				, Convert(Varchar(10), DateAdd(Day, 1, GetDate()), 121)  As ProdDateTime
				, '권취' As RouteName
				, '[권취합계]' As LineName
				, Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0')AS ProdQty 
				--, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Sum(A2.PlanQty) * 100)), 1) AS ProdRate
				, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / 139000.00 * 100)), 1) AS ProdRate                  -- 고정값 세팅
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
													--, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) + IPQ.ProdQty  AS ProdQty
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
																				AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
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
													AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
													--AND PRH.MaterialCode = 'LIVT38-018'
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
								RIGHT OUTER JOIN STB_VPCLinePlan B  WITH(NOLOCK) ON A.LineCode = B.LineCode     -- 권취테이블 : STB_VPCLinePlan
																									
									
									) A2														
																		
  		-- 2. 커링누계 추가 
  								UNION ALL

										   SELECT '커링합계 ' As LineCode
												  --, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0')AS PlanQty 
													, Format(Convert(BIGINT, 217000),  'N0')AS PlanQty                                         -- 고정값 세팅
													, Convert(Varchar(10), DateAdd(Day, 1, GetDate()), 121)  As ProdDateTime
													, '조립(커링)' As RouteName
													, '[커링합계]' As LineName
													, Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0')AS ProdQty 
													--, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Sum(A2.PlanQty) * 100)), 1) AS ProdRate
													, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / 217000.00 * 100)), 1) AS ProdRate                  -- 고정값 세팅
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
																							--, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) + IPQ.ProdQty  AS ProdQty
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
																														AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
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
																							AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
																							--AND PRH.MaterialCode = 'LIVT38-018'
																							AND SubString(PRH.MaterialCode, 1, 6) = 'LIVT38' 
																							--AND PRH.RouteCode = 'E-24'    --커링은 제외되어야 함!!!
																						--ORDER BY PRH.RouteCode, PRH.LineCode
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
																		RIGHT OUTER JOIN STB_VPCLinePlan_Two B  WITH(NOLOCK) ON A.LineCode = B.LineCode  
																		
																		
																				
																			) A2														
	) ZA
			-- 커링누계 End
			--UNION ALL


			-- 3. 라인별(커링)조회부분
   

    SELECT @msg2 = @msg2 + ZB.LineName + ' (' + Convert(Varchar(20), PlanQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdQty) + '개 ' + ' | ' + Convert(Varchar(20), ProdRate) + '% ' + ')<br>'
     FROM  (  

				SELECT A2.LineCode
						, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0')AS PlanQty 
						, Convert(Varchar(10), DateAdd(Day, 1, GetDate()), 121)  As ProdDateTime
						, IsNull(Max(A2.RouteName), '조립(커링)') As RouteName
						, Case When A2.LineCode = 'VPCLINE-01' Then 'VPC 1라인'
								When A2.LineCode = 'VPCLINE-02' Then 'VPC 2라인'
								When A2.LineCode = 'VPCLINE-03' Then 'VPC 3라인'
								When A2.LineCode = 'VPCLINE-04' Then 'VPC 4라인'
								When A2.LineCode = 'VPCLINE-05' Then 'VPC 5라인'
								When A2.LineCode = 'VPCLINE-06' Then 'VPC 6라인' 
								When A2.LineCode = 'VPCLINE-07' Then 'VPC 7라인' 
								When A2.LineCode = 'VPCLINE-08' Then 'VPC 8라인' 
								When A2.LineCode = 'VPCLINE-09' Then 'VPC 9라인' Else '기타' End As LineName
						 , Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0') AS ProdQty 
						--, SUM(A2.DefectQty) AS DefectQty
						, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Max(A2.PlanQty) * 100)), 1) AS ProdRate
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
																, Convert(BIGINT, Sum(FIN.ProdQty)) AS ProdQty
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
																										AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
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
																			AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
																			--AND PRH.MaterialCode = 'LIVT38-018'
																			AND SubString(PRH.MaterialCode, 1, 6) = 'LIVT38' 
																			--AND PRH.RouteCode = 'E-24'
																		--ORDER BY PRH.RouteCode, PRH.LineCode
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

														RIGHT OUTER JOIN STB_VPCLinePlan_Two B  WITH(NOLOCK) ON A.LineCode = B.LineCode  And A.LineName = B.LineName
														
													) A2
														GROUP BY A2.LineCode															                           
												-- 커링 라인별 조회부분


			) ZB    -- 메세지 조립위한 테이블

         
		 -- 주석처리부분 (프로시저실행시 출력부분)  
         --   Select  '[권취 실적]' + '<br>' + @msg + '<br>' 

		

			SET @LineMessage = '금일 VPC 생산실적 공유드립니다.' + '<br>'
	                    + ' [기준일] : ' + ISNULL(@ProdDateTime,'') + '<br>'
						+ ' [기준시간] : ' + ISNULL(@StandardTime,'') + '<br>'						
						+ '<br>'
						+  '[생산실적]' + ' ( ' + '목표수량' + ' | ' + '생산수량' + ' | ' + '진행률(%) )' + '<br>'
			            +	@msg + '<br>' 												
					     --+  '[조립(커링)실적]' + ' ( ' + '목표수량' + ' / ' + '생산수량' + ' / ' + '진척률(%) )' + '<br>'
					     + @msg2 
						 +  '※ 라인별 실적은 조립(커링)의 실적입니다.' + '<br>'                           -- 전달사항 부분

              Select  @LineMessage    --주석부분

-- 1. 테스트용 (나만)	
       --Exec usp_DoSendSMS '', '', '010-2320-7233,', @LineMessage , ''     
	   --Exec usp_DoSendSMS '', '', '010-2320-7233, 010-2912-1830', @LineMessage , '' 

-- 2. 전직원 정규직 발송 (2022-03-24 변경)   
--Exec usp_DoSendSMS '', '', 
--'010-4654-3727,010-4652-7649,010-3707-6551,010-5305-5305,010-9433-1324,010-9223-1754,010-8257-2990,010-9935-5313,010-7268-1995,010-4108-1002,010-2935-1748
--,010-4557-7870,010-9437-2487,010-4404-3836,010-5886-5340,010-2019-1363,010-4412-1356,010-3629-6109,010-4465-1833,010-2834-4213,010-3676-1914,010-2000-3125
--,010-3584-8450,010-6405-2254,010-7930-3727,010-3948-7605,010-4278-1425,010-9641-9994,010-3099-1130,010-5630-8986,010-5632-5754,010-5476-9346,010-9476-1663
--,010-9138-4083,010-8536-6875,010-2417-6436,010-4580-7949,010-9476-1285,010-9547-0308,010-7577-5042,010-9088-1368,010-4034-6550,010-6395-9188,010-5038-2960
--,010-3519-9282,010-8770-8608,010-3876-6391,010-5580-9695,010-8445-0786,010-3222-6697,010-7460-5995,010-8550-1291,010-2080-1826,010-2706-0652,010-3701-4951
--,010-7465-1204,010-9200-8922,010-8760-1002,010-2079-4421,010-8075-1014,010-4277-0875,010-5106-4632,010-4660-4184,010-3511-5703,010-6276-3560,010-2769-9699
--,010-3659-9042,010-4191-6484,010-2273-8889,010-9116-5235,010-2719-4222,010-4804-0584,010-3684-2983,010-8416-0408,010-9211-4721,010-8703-0570,010-4629-0763
--,010-9092-3044,010-5613-2567,010-9515-9113,010-5270-4002,010-6613-2224,010-2320-7233,010-5548-0911,010-9092-4354,010-7466-3290,010-9436-0930,010-2043-4306
--,010-4214-5342,010-7612-7123,010-5613-0679,010-8848-8231,010-7687-1601,010-6439-6622,010-2378-5681,010-2875-1676,010-2901-2070,010-9263-9714,010-3296-7815
--,010-9975-7717,010-9442-2061,010-2060-1714,010-9206-4584,010-9212-1990,010-5630-0663,010-5192-2111,010-4378-8253,010-9174-5291,010-9458-2880,010-7585-8684
--,010-6415-9644,010-5317-2528,010-8694-2027,010-2205-5828,010-2474-7006,010-9846-8885,010-2196-1049,010-6774-1748,010-4886-6444,010-4169-1257,010-2972-0351
--,010-2912-1830,010-6210-3421,010-3302-9512,010-7221-1981,010-9116-4381,010-6797-4483,010-7645-9110,010-9981-4353,010-5582-9187,010-9241-2224,010-8468-3974
--,010-4134-7351,010-4826-4216,010-2263-8890,010-2204-2080,010-4232-2766,010-6757-6702,010-3906-3248,010-7655-3650,010-2235-0225,010-8761-3449,010-4814-1963
--,010-8299-9625,010-4998-8628,010-2637-5199,010-8344-4181,010-9655-7682,010-4190-1070,010-2629-2296'
--, @LineMessage , ''         
   






-- 4. 전직원 모두발송 (223명)
--Exec usp_DoSendSMS '', '', 
--'010-4652-7649,010-3707-6551,010-5305-5305,010-5617-0713,010-9433-1324,010-9223-1754,010-8257-2990,010-9935-5313,010-7268-1995,010-4108-1002
--,010-2935-1748,010-4557-7870,010-9437-2487,010-4404-3836,010-5886-5340,010-2019-1363,010-4412-1356,010-3629-6109,010-4465-1833,010-2834-4213
--,010-3676-1914,010-2000-3125,010-3584-8450,010-2647-8415,010-6405-2254,010-7930-3727,010-3948-7605,010-4278-1425,010-9641-9994,010-3099-1130
--,010-5630-8986,010-5632-5754,010-4949-6234,010-5476-9346,010-9476-1663,010-9138-4083,010-6637-7780,010-2417-6436,010-4580-7949,010-9476-1285
--,010-9547-0308,010-7577-5042,010-9088-1368,010-4034-6550,010-6395-9188,010-5038-2960,010-3519-9282,010-8770-8608,010-3876-6391,010-5580-9695
--,010-8445-0786,010-3222-6697,010-7460-5995,010-8550-1291,010-2080-1826,010-2706-0652,010-3701-4951,010-7465-1204,010-9200-8922,010-8760-1002
--,010-2079-4421,010-8075-1014,010-4277-0875,010-5106-4632,010-3511-5703,010-6276-3560,010-2769-9699,010-3659-9042,010-9116-5235,010-2719-4222
--,010-4804-0584,010-3684-2983,010-8416-0408,010-9211-4721,010-8703-0570,010-4629-0763,010-6613-2224,010-2320-7233,010-5548-0911,010-9092-4354
--,010-7466-3290,010-9436-0930,010-2043-4306,010-4214-5342,010-7612-7123,010-5613-0679,010-5577-0597,010-8848-8231,010-7687-1601,010-6439-6622
--,010-2378-5681,010-2875-1676,010-2901-2070,010-9263-9714,010-3296-7815,010-6632-1314,010-4199-5255,010-3381-1476,010-4583-7438,010-3168-9475
--,010-9975-7717,010-9442-2061,010-2060-1714,010-9206-4584,010-9212-1990,010-4221-2512,010-2205-5828,010-8806-5451,010-9846-8885,010-2196-1049
--,010-5192-2111,010-4378-8253,010-9458-2880,010-7585-8684,010-2040-2359,010-8694-2027,010-6774-1748,010-4886-6444,010-7120-1365,010-4169-1257
--,010-9200-8922,010-9092-3044,010-9515-9113,010-5270-4002,010-6210-3421,010-3302-9512,010-6761-7274,010-5038-3260,010-5643-6686,010-6652-1643
--,010-4654-3727,010-5630-0663,010-5317-2528,010-9949-4600,010-2972-0351,010-2912-1830,010-4392-6239,010-5404-1951,010-9565-0402,010-9435-4517
--,010-2397-0491,010-3162-7799,010-9543-5623,010-5014-6484,010-7246-3012,010-9755-9129,010-7254-0958,010-9852-2510,010-3943-8928,010-2776-1573
--,010-3652-3121,010-7442-7010,010-5493-3048,010-3946-8709,010-4322-0829,010-7929-8950,010-4784-6770,010-4323-2566,010-5250-2415,010-6797-4483
--,010-6401-0422,010-4659-6679,010-7645-9110,010-9981-4353,010-5582-9187,010-9241-2224,010-8468-3974,010-4134-7351,010-4826-4216,010-7935-9225
--,010-7454-8778,010-9477-7214,010-2263-8890,010-2204-2080,010-5063-2694,010-2841-9179,010-5892-0142,010-6201-2088,010-7182-2400,010-4594-1930
--,010-5825-0301,010-2038-1571,010-4232-2766,010-8576-3362,010-9024-8242,010-7316-1759,010-8800-9924,010-6659-3461,010-7788-3139,010-2619-9720
--,010-8990-0901,010-8449-6677,010-4691-8681,010-6757-6702,010-3906-3248,010-7655-3650,010-2235-0225,010-8761-3449,010-5332-3725,010-9448-2389
--,010-8705-4580,010-9287-8641,010-9208-0240,010-5648-9032,010-8910-6376,010-8576-9406,010-7105-6658,010-6664-7042,010-7925-8166,010-8299-9625
--,010-4998-8628,010-2327-8231,010-9267-9472,010-8619-4611,010-4230-4947,010-8828-7219,010-8782-0764,010-4540-8269,010-2806-2140,010-6415-9644
--,010-2273-8889,010-2474-7006,010-9174-5291'
--, @LineMessage , ''                 

END


