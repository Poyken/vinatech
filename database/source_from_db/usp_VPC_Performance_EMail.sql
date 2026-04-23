
-- ==============================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-02
-- Browsable : True
-- Group : E-Mail > 금일!!!  VPC 실적을 전직원에게 메일로 발송
-- Description: 
-- Modified:  데이터 E-Mail로 자동 발송

-- 프로시저 실행 :  usp_VPC_Performance_EMail '', ''
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_VPC_Performance_EMail]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;
    
	DECLARE @htmlText NVARCHAR(MAX) = '<table border=1><thead><tr><th>라인명</th><th>목표수량</th><th>8:30~13:30</th><th>13:30~20:30</th><th>금일 합계</th><th>진척률</th></tr></thead><tbody>'

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
                              
							 
							  --CONVERT(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 										  
										 -- , LineCode
							select         LineName 
										  , CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName
										  , Format(CONVERT(BIGINT, Max(FIN.PlanQty)),  'N0') AS PlanQty   -- Max
										  --, Format(CONVERT(BIGINT, SUM(FIN.ProdQty)),  'N0')  AS ProdQty
										  --, Format(CONVERT(NUMERIC(20,2), SUM(FIN.ProdQty) / Max(FIN.PlanQty) * 100),  'N0') AS ProdRate   --Max
										  --, SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) < CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' THEN ProdQty ELSE 0 END)  AS PreDayProdQty
										  , Format(SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121)+ ' 13:30:00' THEN CONVERT(INT, ProdQty)  ELSE 0 END),  'N0')  AS FirstProdQty
										  , Format(SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 13:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' THEN CONVERT(INT, ProdQty) ELSE 0 END),  'N0')  AS SecondProdQty
										  , Format(SUM(CASE WHEN CONVERT(VARCHAR(19), ProdDateTime, 121) BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00' AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 20:30:00' THEN CONVERT(INT, ProdQty) ELSE 0 END),  'N0')  AS TotalProdQty
										  , Format(CONVERT(NUMERIC(20,2), SUM(FIN.ProdQty) / Max(FIN.PlanQty) * 100),  'N0') + '(%)'AS ProdRate
									FROM (
												SELECT TOP 100000   PRH.RouteCode
														, RI.RouteName
														, PRH.ProdDateTime
														, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
														--, DPP.PlanQty as PlanQty
														, Case When  SI.InputLineCode = 'VPCLINE-01' Then '24000'
															    When  SI.InputLineCode = 'VPCLINE-02' Then '13000'
															    When  SI.InputLineCode = 'VPCLINE-03' Then '24000'
															    When  SI.InputLineCode = 'VPCLINE-04' Then '24000'
															    When  SI.InputLineCode = 'VPCLINE-05' Then '24000'
															    When  SI.InputLineCode = 'VPCLINE-06' Then '15000'
															    When  SI.InputLineCode = 'VPCLINE-07' Then '15000' Else 0  End AS PlanQty
														, PRH.ProdQty AS InputProdQty
														, ISNULL(DRI.DefectQty, 0) AS DefectQty 
														, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty														
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
																					   AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59' 																				
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
														AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59' 										
														AND PRH.MaterialCode = 'LIVT38-018'
														AND PRH.RouteCode = 'E-22'
													ORDER BY PRH.RouteCode
																, PRH.LineCode
								) FIN
									WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
									  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
									  AND FIN.RouteCode = 'E-22'

									GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
											, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
											, LineCode
											, LineName
									HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
                                     
                                 )


SELECT @htmlText = @htmlText + '<tr><td>' + LineName 
										-- + '</td><td>' + RouteName 
										 + '</td><td>' + CONVERT(VARCHAR(20), PlanQty) 
										 + '</td><td>' + CONVERT(VARCHAR(20), FirstProdQty) 
										 + '</td><td>' + CONVERT(VARCHAR(20), SecondProdQty) 
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