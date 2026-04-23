
-- ==============================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-02
-- Browsable : True
-- Group : E-Mail > 금일!!!  VPC 실적을 전직원에게 메일로 발송  - 3월3일 새로반영
-- Description: 
-- Modified:  데이터 E-Mail로 자동 발송
-- 이전 프로시저명 : usp_VPC_Performance_EMai

-- 프로시저 실행 :  usp_VPCDailyProd_Mail '', ''
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_VPCDailyProd_Mail]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;
    
	DECLARE @htmlText NVARCHAR(MAX) = '<table border=1><thead><tr><th>라인명</th><th>목표수량</th><th>8:30~13:30</th><th>13:30~20:30</th><th>20:30~08:30</th><th>금일 합계</th><th>성과율</th></tr></thead><tbody>'

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @FromDate DateTime = CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'                               -- select CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  
	DECLARE @ToDate    DateTime = CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59'         -- select CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59'    

	DECLARE @Time  VARCHAR(20)  = SUBSTRING(CONVERT(NVARCHAR, GetDate(), 121), 12, 5)                -- Select  SUBSTRING(CONVERT(NVARCHAR, GETDATE(), 121), 12, 5)
	DECLARE @StandardTime   VARCHAR(200) = '오전 08:30 ~ ' +  @Time

    DECLARE @PlanQty NVARCHAR(MAX)
	DECLARE @ProdQty NVARCHAR(MAX)

	DECLARE @ProdDateTime VARCHAR(20)   = CONVERT(VARCHAR(10), GetDate(), 121)                                  -- SELECT CONVERT(VARCHAR(10), GETDATE(), 121)

	DECLARE @LineCode VARCHAR(20) 
	DECLARE @LineName VARCHAR(30) 
	DECLARE @RouteName VARCHAR(20) 
	DECLARE @ProdRate Numeric(20,2)
	DECLARE @LineMessage NVARCHAR(MAX)

	DECLARE @msg VARCHAR(MAX) = ''
	DECLARE @msg2 VARCHAR(MAX) = ''

	-- 메일발송에 필요함수
	DECLARE @MailSubject NVARCHAR(MAX)
	DECLARE @EmailBody   NVARCHAR(MAX)	
	
	-- 메일발송 대상자부분 (수신, 참조자) 
-- DECLARE @ToAddress VARCHAR(MAX) = 'v.all@vina.co.kr;'             -- 전직원

	--DECLARE @ToAddress VARCHAR(MAX) = 'v.manufacturing@vina.co.kr;'             -- 생산
	--DECLARE @CcAddress VARCHAR(MAX) = 'oqc@vina.co.kr;v.planning@vina.co.kr;'    -- 품질 + 기획실
 
    -- 테스트 용도
	DECLARE @ToAddress VARCHAR(MAX) = 'nicekangil@naver.com;'     -- Kangs 메일
	DECLARE @CcAddress VARCHAR(MAX) = 'kilee@vina.co.kr;'



;WITH SampleData AS (
                              
							 
						SELECT A2.LineCode
								, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0')AS PlanQty 
								, Convert(Varchar(10), DateAdd(Day, 1, GetDate()), 121)  As ProdDateTime
								, IsNull(Max(A2.RouteName), '권취') As RouteName
								, Case When A2.LineCode = 'VPCLINE-01' Then 'VPC 1라인'
										When A2.LineCode = 'VPCLINE-02' Then 'VPC 2라인'
										When A2.LineCode = 'VPCLINE-03' Then 'VPC 3라인'
										When A2.LineCode = 'VPCLINE-04' Then 'VPC 4라인'
										When A2.LineCode = 'VPCLINE-05' Then 'VPC 5라인'
										When A2.LineCode = 'VPCLINE-06' Then 'VPC 6라인' 
										When A2.LineCode = 'VPCLINE-07' Then 'VPC 7라인' 
										When A2.LineCode = 'VPCLINE-08' Then 'VPC 8라인' 
										When A2.LineCode = 'VPCLINE-09' Then 'VPC 9라인' Else '기타' End As LineName
								, Format(SUM(Isnull(A2.FirstProdQty,0)),  'N0') AS FirstProdQty
								, Format(SUM(Isnull(A2.SecondProdQty,0)),  'N0') AS SecondProdQty
								, Format(SUM(Isnull(A2.ThirdProdQty,0)),  'N0') AS ThirdProdQty
								, Format(SUM(Isnull(A2.TotalProdQty,0)),  'N0') AS TotalProdQty
								, Format(CONVERT(BIGINT, Sum(A2.ProdQty)),  'N0') AS ProdQty 
								--, SUM(A2.DefectQty) AS DefectQty
								, Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Max(A2.PlanQty) * 100)), 1) AS ProdRate
						FROM (

						-- 1.
									SELECT  B.LineCode
												, IsNull(B.PlanQty, 0) As PlanQty
												--, A.ProdDateTime 
												, A.RouteName                  
												, A.LineName
											, A.FirstProdQty
											, A.SecondProdQty
											, A.ThirdProdQty
											, A.TotalProdQty
												, IsNull(A.ProdQty, 0) As ProdQty
												--, IsNull(A.DefectQty, 0) As DefectQty
												--, Format(Convert(NUMERIC(20,2), A.ProdQty / B.PlanQty * 100),  'N0') AS ProdRate
									FROM  (
											SELECT Convert(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 
												, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName      
												, FIN.LineCode As LineCode
												, FIN.LineName As LineName
											--, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121)+ ' 13:30:00' THEN CONVERT(INT, ProdQty)  ELSE 0 END)  AS FirstProdQty
											--, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 13:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' THEN CONVERT(INT, ProdQty) ELSE 0 END)  AS SecondProdQty
											--, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' AND CONVERT(VARCHAR(10), GetDate() + 1, 121) + ' 08:29:59' THEN CONVERT(INT, ProdQty) ELSE 0 END)  AS ThirdProdQty
											--, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate() + 1, 121) + ' 08:29:59' THEN CONVERT(INT, ProdQty) ELSE 0 END)  AS TotalProdQty
											, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121)+ ' 13:30:00'  THEN CONVERT(INT, Isnull(ProdQty,0))  ELSE 0 END)  AS FirstProdQty
											, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 13:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' THEN CONVERT(INT, Isnull(ProdQty,0)) ELSE 0 END)  AS SecondProdQty
											, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59' THEN CONVERT(INT, Isnull(ProdQty,0)) ELSE 0 END)  AS ThirdProdQty
											, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate()+1, 121) +' 08:29:59' THEN CONVERT(INT, Isnull(ProdQty,0)) ELSE 0 END)  AS TotalProdQty
												, Convert(BIGINT, Sum(Isnull(FIN.ProdQty,0))) AS ProdQty
												, Convert(BIGINT, Sum(Isnull(FIN.DefectQty,0))) AS DefectQty                              
											FROM (
													SELECT TOP 100000   PRH.RouteCode
															, RI.RouteName
															, PRH.ProdDateTime
															, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28'    THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime                                          
															, PRH.ProdQty AS InputProdQty
															, ISNULL(DRI.DefectQty, 0) AS DefectQty 
															, ISNULL(PRH.ProdQty, 0) - ISNULL(DRI.DefectQty, 0)  AS ProdQty
															, SI.InputLineCode AS LineCode
															, LI.LineName As LineName                                           
														FROM STB_SetInfo SI WITH(NOLOCK) 
															LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo                                                                                                                                                   
															LEFT OUTER JOIN STB_ProdRouteHist  PRH   WITH(NOLOCK)   ON SI.ControlNo = PRH.ControlNo
															LEFT OUTER JOIN STB_RouteInfo      RI   WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
															LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
															LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
															LEFT OUTER JOIN STB_LineInfo       LI   WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode                 
															LEFT OUTER JOIN ( SELECT DRI2.ControlNo
																					,DRI2.FindRouteCode
																					,MAX(PRH2.MachineCode) AS MachineCode
																					,SUM(DRI2.DefectQty) AS DefectQty 
																				FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																				LEFT OUTER JOIN STB_ProdRouteHist PRH2                        ON DRI2.ControlNo = PRH2.ControlNo                     AND DRI2.FindRouteCode = PRH2.RouteCode
																				WHERE RepairType = 'NONE'
																				   AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')               
																				   AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
																	             --AND PRH2.ProdDateTime BETWEEN '2022-03-02 08:30:00'  AND '2022-03-03 08:29:59'
																				GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
																			) DRI                    ON PRH.ControlNo = DRI.ControlNo                  AND PRH.RouteCode = DRI.FindRouteCode                  AND PRH.MachineCode = DRI.MachineCode
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
													        --AND PRH.ProdDateTime BETWEEN '2022-03-02 08:30:00'  AND '2022-03-03 08:29:59'
															AND PRH.MaterialCode = 'LIVT38-018'
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
														RIGHT OUTER JOIN STB_ProdLinePlan B  WITH(NOLOCK) ON A.LineCode = B.LineCode  

														UNION ALL


														---2.
															Select DPP.LineCode
																, MAX(PLP.PlanQty) AS PlanQty
																--,Convert(Char(10), IPQ.CreateDateTime, 121)
																, RI.RouteName
																, LI.LineName
														, 0 AS FirstProdQty
														, 0 AS SecondProdQty
														, 0 AS ThirdProdQty
														, 0 AS TotalProdQty
																, SUM(IPQ.ProdQty) As ProdQty
																--, 0
																--, 0
															From STB_InterimProdQtyInfo IPQ
																	LEFT OUTER JOIN STB_SetInfo SI         ON IPQ.ControlNo = SI.ControlNo
																	LEFT OUTER JOIN STB_DayProdPlan DPP   ON DPP.DayPlanNo = SI.DayPlanNo
																	LEFT OUTER JOIN STB_LineInfo LI         ON LI.LineCode = DPP.LineCode
																	LEFT OUTER JOIN STB_ProdLinePlan PLP   ON PLP.LineCode = DPP.LineCode
																	LEFT OUTER JOIN STB_RouteInfo RI           ON RI.RouteCode = IPQ.RouteCode
															WHERE IPQ.CreateDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate()+1, 121) + ' 08:29:59'
															GROUP BY DPP.LineCode, Convert(Char(10), IPQ.CreateDateTime, 121), RI.RouteName, LI.LineName


															) A2
														GROUP BY A2.LineCode
                               
                        -- 메인조회 End
                                     
                                 )


SELECT @htmlText = @htmlText + '<tr><td>' + LineName 
										-- + '</td><td>' + RouteName 
										 + '</td><td>' + CONVERT(VARCHAR(20), PlanQty) 
										 + '</td><td>' + CONVERT(VARCHAR(20), FirstProdQty) 
										 + '</td><td>' + CONVERT(VARCHAR(20), SecondProdQty) 
										  + '</td><td>' + CONVERT(VARCHAR(20), ThirdProdQty) 
										 + '</td><td>' + CONVERT(VARCHAR(20), TotalProdQty) 								
										 + '</td><td>' + CONVERT(VARCHAR(20), ProdRate) 								
										 + '</td></tr>'
FROM SampleData

      SET @htmlText = @htmlText + '</tbody></table>'

--SELECT @htmlText

    -- 메일 Seting부분
   SET @MailSubject = '금일 VPC 권취실적 공유드립니다.' + ' (' + CONVERT(CHAR(5), GETDATE(), 101)   + ') '          -- 제목
   SET @EmailBody = @htmlText			-- 내용 (html형태)


   SELECT @htmlText   -- 주석처리 (실행시 조회용도)

 -- E-Mail 발송 프로시저 호출 : 새로 만듦
	 EXEC usp_DoAddVPCProdReportMail @pProcessUserID = @pProcessUserID                       
											   , @pProcessLanguage = @pProcessLanguage
											   , @pToMailAddress= @ToAddress
											   , @pCcMailAddress= @CcAddress
											   , @pMailSubject = @MailSubject
											   , @pMailContents = @EmailBody

END