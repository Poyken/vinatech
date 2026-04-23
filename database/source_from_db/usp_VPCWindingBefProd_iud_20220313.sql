
-- ==============================================================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2022-03-08
-- Browsable : True
-- Group : 
-- Description: 
-- Modified:  전일 VPC 권취실적을 업데이트 해주는 프로시저
-- 2022.03.13 VPC_Performance테이블에 공정코드, 명 추가


-- 프로시저 실행 :  usp_VPCWindingBefProd_iud_20220313 '',''

-- 테이블 조회 :     Select * from VPC_Performance Order by LineCode, RouteCode
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_VPCWindingBefProd_iud_20220313]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;
    
	DECLARE @ProcessLanguage Varchar(20) = @pProcessLanguage
	DECLARE @FromDate DateTime = Convert(Varchar(10), GetDate()-2, 121) + ' 08:30:00'            -- 전일8시반        Select Convert(Varchar(10), GetDate()-1, 121) + ' 08:30:00'  
	DECLARE @ToDate    DateTime = Convert(Varchar(10), GetDate()-1,    121) + ' 08:29:59'            -- 금일8시29분     Select Convert(Varchar(10), GetDate(), 121) + ' 08:29:59'    

	DECLARE @ToDay      Varchar(02) = Substring(Convert(Varchar(10), GetDate()-2, 121), 9, 2)      --테이블에 데이터 입력되는날짜이므로 전일이 맞다!!  / Select Substring(Convert(VARCHAR(10), GetDate()-11, 121), 9, 2) 
	DECLARE @BaseYm    Varchar(06)
	DECLARE @OneDay    Varchar(11) = Substring(Convert(Varchar(10), GetDate()-1, 121), 0, 11)    -- 전일날짜(2022-03-10)   /   SELECT Substring(Convert(VARCHAR(10), GetDate()-1, 121), 0, 11)


	DECLARE @Time  Varchar(20)  = SUBSTRING(CONVERT(NVARCHAR, GetDate(), 121), 12, 5)    --                      Select  SUBSTRING(Convert(NVARCHAR, GETDATE(), 121), 12, 5)
	DECLARE @StandardTime   VARCHAR(200) = '오전 08:30 ~ ' +  @Time

    DECLARE @PlanQty NVARCHAR(MAX)
	DECLARE @ProdQty NVARCHAR(MAX)

	DECLARE @ProdDateTime VARCHAR(20)   = Convert(Varchar(10), GetDate(), 121)               -- 금일 : 2022-03-11    /     SELECT Convert(Varchar(10), GetDate(), 121)

	DECLARE @LineCode Varchar(20) 
	DECLARE @LineName Varchar(30) 
	DECLARE @RouteName Varchar(20) 
	DECLARE @ProdRate Numeric(20,2)
	DECLARE @LineMessage NVARCHAR(MAX)

	DECLARE @msg VARCHAR(MAX) = ''
	DECLARE @msg2 VARCHAR(MAX) = ''



	--- 기준년월 (26일부터 ~ 다음달 25일까지)
			SELECT @BaseYm = Replace(BaseMonth, '-', '') 																		
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			  AND  FromDate  <= @OneDay
			  AND  ToDate     >= @OneDay

/*
		-- 202203
		   SELECT  Replace(BaseMonth, '-', '') 																		
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			  AND  FromDate  <= '2022-03-10'
			  AND  ToDate     >= '2022-03-10'
*/


                              
-- Main 조회문			 
SELECT A2.LineCode
		, Format(Convert(BIGINT, Max(A2.PlanQty)),  'N0')AS PlanQty 
		, Convert(Varchar(10), DateAdd(Day, 1, GetDate()), 121)  As ProdDateTime
		, A2.RouteCode as RouteCode
		, A2.RouteName As RouteName
		, Case When A2.LineCode = 'VPCLINE-01' Then 'VPC 1라인'
				When A2.LineCode = 'VPCLINE-02' Then 'VPC 2라인'
				When A2.LineCode = 'VPCLINE-03' Then 'VPC 3라인'
				When A2.LineCode = 'VPCLINE-04' Then 'VPC 4라인'
				When A2.LineCode = 'VPCLINE-05' Then 'VPC 5라인'
				When A2.LineCode = 'VPCLINE-06' Then 'VPC 6라인' 
				When A2.LineCode = 'VPCLINE-07' Then 'VPC 7라인' 
				When A2.LineCode = 'VPCLINE-08' Then 'VPC 8라인' 
				When A2.LineCode = 'VPCLINE-09' Then 'VPC 9라인'
				When A2.LineCode = 'VPCLINE-10' Then 'VPC 10라인' Else '기타' End As LineName							
		, CONVERT(BIGINT, Sum(IsNull(A2.ProdQty, 0))) AS ProdQty 
		--, Round(Convert(NUMERIC(20,2), (Sum(Isnull(A2.ProdQty, 0)) / Max(IsNull(A2.PlanQty,0)) * 100)), 1) AS ProdRate								
		, Case When Max(A2.PlanQty) = 0 Then 0 Else Round(Convert(NUMERIC(20,2), (Sum(A2.ProdQty) / Max(A2.PlanQty) * 100)), 1) End AS ProdRate		
INTO #Temp20220308
FROM (
			SELECT  B.LineCode
						, IsNull(B.PlanQty, 0) As PlanQty
						--, A.ProdDateTime 
						, B.RouteCode
						, B.RouteName                  
						, A.LineName											
						, IsNull(A.ProdQty, 0) As ProdQty
						--, IsNull(A.DefectQty, 0) As DefectQty
						--, Format(Convert(NUMERIC(20,2), A.ProdQty / B.PlanQty * 100),  'N0') AS ProdRate
			FROM  (
							SELECT Convert(CHAR(10), FIN.ProdDateTime, 121)  AS ProdDateTime 
								, FIN.RouteCode As RouteCode
								, CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END AS RouteName      
								, FIN.LineCode As LineCode
								, FIN.LineName As LineName
								, Convert(BIGINT, Sum(IsNull(FIN.ProdQty,0))) AS ProdQty
								, Convert(BIGINT, Sum(IsNull(FIN.DefectQty,0))) AS DefectQty                              
							FROM (
									SELECT TOP 100000   PRH.RouteCode
											, RI.RouteName
											, PRH.ProdDateTime
											, LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28'  THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime                                          
											, PRH.ProdQty AS InputProdQty
											, IsNull(DRI.DefectQty, 0) AS DefectQty 
											, IsNull(PRH.ProdQty, 0) - IsNull(DRI.DefectQty, 0)  AS ProdQty
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
																			, DRI2.FindRouteCode
																			, Max(PRH2.MachineCode) AS MachineCode
																			, Sum(IsNull(DRI2.DefectQty,0)) AS DefectQty 
																		FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
																		LEFT OUTER JOIN STB_ProdRouteHist PRH2                        ON DRI2.ControlNo = PRH2.ControlNo                     AND DRI2.FindRouteCode = PRH2.RouteCode
																		WHERE 1=1
																			AND RepairType = 'NONE'
																			AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')               
																			AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate																
																			--AND PRH2.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'																
																		GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
																	) DRI                    ON PRH.ControlNo = DRI.ControlNo                  AND PRH.RouteCode = DRI.FindRouteCode                  AND PRH.MachineCode = DRI.MachineCode
											LEFT OUTER JOIN (
															SELECT RouteCode, MIN(MachineCode) AS MachineCode
																FROM STB_ProductMachine
																GROUP BY RouteCode
															) PM                  ON PM.RouteCode = PRH.RouteCode
											LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode										                               
										WHERE 1=1
											AND PRH.CompanyCode = 'VNT'
											AND PRH.WorkCenterCode = 'VNT_F1'
											AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate		
											--AND PRH.ProdDateTime BETWEEN CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'  AND CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:29:59'											
											AND PRH.MaterialCode in ( 'LIVT38-018', 'LIVT38-019', 'LIVT38-020')
											AND PRH.RouteCode in  ('E-22', 'E-24', 'E-28', 'E-29', 'E-30', 'E-33')
										ORDER BY PRH.RouteCode
												, PRH.LineCode
							) FIN
								WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
									AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
									AND FIN.RouteCode in   ('E-22', 'E-24', 'E-28', 'E-29', 'E-30', 'E-33')

								GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
									, RouteCode
									, RouteName
									, LineCode
									, LineName
								HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
								) A
								RIGHT OUTER JOIN STB_ProdLinePlan B  WITH(NOLOCK) ON A.LineCode = B.LineCode  And A.RouteCode = B.RouteCode

						) A2
							GROUP BY A2.LineCode 
							           , A2.RouteCode 
									   , A2.RouteName
                               
-- 메인조회 End                                     
                       

 DECLARE @sqlStr VARCHAR(1000)

          SET @sqlStr = ' UPDATE VPC_Performance  
		                            SET DAY' + @ToDay + ' = IsNull(B.[ProdQty], 0) 
								FROM VPC_Performance A 
								         INNER JOIN  #Temp20220308 B  ON A.[RouteCode] = B.[RouteCode] 
										                                         AND A.BaseMonth =  ''' + @BaseYm + ''' 
																				 AND A.[LineCode] = B.[LineCode] '  

	EXECUTE  (@sqlStr)

    DELETE FROM  #Temp20220308        -- TEMP TABLE삭제

/*
-- 조회용 주석처리
  --  Select * from VPC_Performance Order by LineCode, RouteCode


    UPDATE VPC_Performance
        SET DAY08 = 100					  
     FROM VPC_Performance A  
    WHERE 1=1
       AND   A.[RouteCode] = 'E-22'
       AND BaseMonth = '202203'				    							
	   AND A.LineCode = 'VPC 1라인'
     --AND A.LineCode = B.LineCode
*/

END