-- Procedure: usp_CurlingLine_Daily_Input
-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-09
-- Browsable   : true
-- Group       : 2019-04-05 오전 08:31 자동실행  (매일 1번 자동실행)
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 매일 아침 8시30분기준으로 전일자 일일실적현황을 자동으로 계산해서 넣어준다.  (오늘이 10일이면 9일 실적을 9일에 자동입력)
--                 2019-04-09 정상실행 
--                 2019-11-14 다시실행하여 정상실행  
--                 2020-03-02 베트남 법인 실적 추가

---[실행문]    EXEC usp_CurlingLine_Daily_Input            
-- ==================================================================
CREATE PROC [dbo].[usp_CurlingLine_Daily_Input]
				@pDate DATE
   			  , @pRouteCode VARCHAR(20) 
AS

BEGIN
	SET NOCOUNT ON;

	Declare @Date                DATE = @pDate
	--Declare @RouteCode VARCHAR(20) = @pRouteCode

	
	DECLARE @RouteCode      VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END

	Declare @ExistRow           INT = 0

	--DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

 --[기존형식]
    DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                                                                             -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10), GetDate(),    121) + ' 08:30:00'                                                                             -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	DECLARE @ToDay      VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                                        -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)
	
	----[원본]
	--DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, -1, @Date), 121) + ' 08:30:00'                                                             -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	--DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10),                        @Date, 121) + ' 08:30:00'                                                             -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	--DECLARE @ToDay      VARCHAR(02) = SUBSTRING(@FromDt, 9, 2)    
	
-- [수동으로 실행시 -> 지우지말것]	
  --DECLARE @FromDt        VARCHAR(19) =  '2019-10-31 08:30:00'            -- 전일                    
  --DECLARE @ToDt           VARCHAR(19) =  '2019-11-01 08:30:00'            -- 금일

	DECLARE @ToDay2         VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @ToDt, 121), 9, 2)                                                                  -- 1일부터 금일까지 일수  (5월 8일이면.. 08일)            --> SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-05-08 08:00:00', 121), 9, 2)
  --DECLARE @DayCnt          VARCHAR(02) = DatePart(dd,dateadd(day,-1,DateAdd(month,1,DateAdd(day,-DatePart(dd, @ToDt)+1, @ToDt))))                    -- 해당월의 일수 (31일 or 30일)  --> SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-05-08')+1,'2019-05-08'))))
	DECLARE @DayCnt          VARCHAR(02) = DatePart(dd,DateAdd(Day,-1,DateAdd(Month,-2,DateAdd(Day,-DatePart(dd, @ToDt)+1, @ToDt))))                  --  해당월의 일수 (31일 or 30일)  -->  SELECT DatePart(DD,DateAdd(Day,-1,DateAdd(Month,-2,DateAdd(Day,-DatePart(DD, '2019-11-15')+1, '2019-11-15')))) 

	DECLARE @ChangeTime   VARCHAR(19) = CONVERT(VARCHAR(10), @ToDt, 121) + ' 20:30:00'                                                                 -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00', 121) + ' 20:30:00'  
	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                                       -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 	

  --DECLARE @BaseYm       VARCHAR(6) = LEFT(@FromDt, 4) + SUBSTRING(@FromDt, 6, 2)                                                                        -- 전일자 두자리           SELECT  LEFT(@FromDt, 4) + SUBSTRING(@FromDt, 6, 2)     
	--DECLARE @BaseYm         VARCHAR(06) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 8), '-', '')	                                  -- SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 8), '-', '')
	DECLARE @BaseYm    VARCHAR(06)
														
		--- 기준년월 (26일부터 ~ 다음달 25일까지)
			SELECT @BaseYm = Replace(CONVERT(VARCHAR(10), BaseMonth, 121), '-', '')
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			  AND  FromDate  <= @OneDay
			  AND  ToDate     >= @OneDay


			--SELECT Replace(CONVERT(VARCHAR(10), BaseMonth, 121), '-', '')
			--FROM STB_AggregationPeriod
  	--		WHERE 1=1									
			--  AND  FromDate  <= '2020-02-25 00:00:00'
			--  AND  ToDate     >= '2020-02-25 00:00:00'


 --  [조회 QUERY]  *****************************************************************************************************************************************

 SELECT GG.LineCode                           AS 라인코드         
         , GG.사이즈                              AS 사이즈
	     , GG.월간계획                           AS 월간계획
		 --, (GG.월간계획/30)                   AS 누계목표 	
		-- , (ISNULL(GG.월간계획, 0) / ISNULL(@DayCnt, 0))             AS 누계목표 		                                                                                       -- 월간계획 / 일수(30일 or 31일)		  

		,  Case When GG.월간계획 = 0 Then 0 		        		          Else (ISNULL(GG.월간계획, 0) / ISNULL(@DayCnt, 0)) End AS 누계목표


		 --, ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )  AS 누계생산                                                                 -- 1일부터 현재일까지의 생산량도 추가
		 , Case when SS.일일총수량 = 0 then 0		        	     ELSE ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )  End AS 누계생산                                                                 -- 1일부터 현재일까지의 생산량도 추가

		-- , CASE WHEN GG.월간계획    = 0 THEN 0 
		--          WHEN SS.일일총수량  = 0 THEN 0					
		--		  WHEN GG.월누적수량 = 0 THEN 0	   ELSE  (    ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )    /   (ISNULL(GG.월간계획, 0 ) / @DayCnt) * 100 )  END   AS 누계달성율

		-- --, (    ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )    /   (ISNULL(GG.월간계획, 0 ) / 30) * 100 )                          AS 누계달성율		   -- 누계생산 / 누계목표
		-- --, (  (  ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )    /   GG.월간계획) * 100)                 AS 누계진도율       -- 누계생산 / 월간계획 		

  --      , CASE WHEN GG.월간계획     = 0 THEN 0 
		--          WHEN SS.일일총수량  = 0 THEN 0	
		--		  WHEN GG.월누적수량 = 0 THEN 0	 ELSE  (  (  ( ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )    /   GG.월간계획) * 100)           END                         AS 누계진도율

		, CASE WHEN SS.주간수량 IS NULL THEN 0 ELSE    SS.주간수량 END             AS 주간수량
		, CASE WHEN SS.야간수량 IS NULL THEN 0 ELSE    SS.야간수량 END             AS 야간수량		
		, GG.특이사항                                                                               AS 특이사항
		, ISNULL(SS.일일총수량, 0)                                                                AS 일일총수량	 
		, CONVERT(VARCHAR(10),  GetDate()-1, 121)                                          AS 기준일자                      -- 금일날짜		
		, GG.공정코드                                                                               AS 공정코드		
		, GG.CompanyCode																		AS   CompanyCode                -- 2020.03.02 추가
  INTO #TEMP_TABLE100                                                                                                                                                                                   -- 주석아님!!
  FROM 
				(  
				 -- GG START						
					SELECT  BB.*
							, AA.월누적수량      AS 월누적수량													
					FROM 
					(
							--SELECT -- 라인명																 
							--		 라인코드   AS 라인코드
							--		 , RouteCode
							--		, 사이즈
							--		, 월누적수량  AS 월누적수량	
							--		, Companycode																  																 
							--FROM CURLING_PROD        -- [커링_일별실적]
							--WHERE 1=1																	
							--	--AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @FromDt , 121), 0, 8), '-', '') 																
							--	AND 기준년월 = '201911'			
												
						SELECT  PL.LineCode           AS 라인코드    --추가												    
								, SUM(CP.월누적수량)  AS 월누적수량
								, CP.RouteCode
								, PL.사이즈
								--, CP.월누적수량  AS 월누적수량
								--, CP.Companycode  AS Companycode
						FROM MEDIUM_PLAN PL                                                                                                                        -- 월별계획 Table
								LEFT OUTER JOIN CURLING_PROD CP ON   CP.사이즈 = PL.사이즈  AND CP.RouteCode = PL.공정코드                   -- 일별실적 Table (사이즈, 공정코드 Join)
						WHERE 1=1											
							--AND PL.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @FromDt , 121), 0, 8), '-', '') 			
                            --AND PL.기준년월 = '202003'
							 AND PL.기준년월 = (                                                                                                      -- 2020.01.13 문제점 해결
														SELECT  Replace(BaseMonth, '-', '')		
														FROM STB_AggregationPeriod
													WHERE 1=1									
														AND  FromDate  <= @OneDay
														AND  ToDate     >= @OneDay
													)

							--AND CP.CompanyCode = 'VNT'
						GROUP BY  PL.사이즈 , CP.RouteCode
									, PL.LineCode		--, CP.Companycode 						  --추가
																								
					) AA
					LEFT OUTER JOIN (
												SELECT LineCode
														, 공정코드
														, 사이즈																			
														, 월간계획																			
														, 특이사항
														, Companycode
													FROM MEDIUM_PLAN
													WHERE 1=1
														--AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @FromDt , 121), 0, 8), '-', '') 																
														--AND 기준년월 = '202003'		
														 AND 기준년월 = (                                                                                                      -- 2020.01.13 문제점 해결
																					SELECT  Replace(BaseMonth, '-', '')		
																					FROM STB_AggregationPeriod
																				WHERE 1=1									
																					AND  FromDate  <= @OneDay
																					AND  ToDate     >= @OneDay
																				)
																								
										) BB		    ON AA.라인코드 = BB.LineCode 
															--AND AA.CompanyCode = BB.CompanyCode 
															AND AA.사이즈 = BB.사이즈 
															AND AA.RouteCode = BB.공정코드							    
				-- GG END
			   ) GG

LEFT JOIN (	--> GG 테이블 기준으로 
                -- SS START
					 SELECT 라인코드                                AS 라인코드
						    ,  CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  ELSE 규격 END AS 규격    				         --- 1030L 문제로 추가
							 , SUM(주간수량)                        AS 주간수량
							 , SUM(야간수량)                        AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량)  AS 일일총수량
							 , 공정코드                               AS 공정코드
						FROM (																						
											 																									
								    SELECT ZZ.규격
											, ZZ.공정코드        AS 공정코드
											, ZZ.라인코드        AS 라인코드
											, SUM(ZZ.주간수량) AS 주간수량
											, SUM(ZZ.야간수량) AS 야간수량
										FROM (								
												SELECT  SP.사이즈                                                                                                    AS 규격																	          
														,  A.RouteCode                                                                                                AS 공정코드
														, A.LineCode																									  AS 라인코드
														, CASE WHEN A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
														, CASE WHEN A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량																			
												FROM                       STB_ProdRouteSummary A                                                                                                
														--LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
														LEFT OUTER JOIN (
																				select RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) AS 사이즈
																				     , ModelCode as ModelCode
																				  from STB_ModelBasicInfo
																				 where modelcode like 'ECVT%'
														)  SP ON A.MaterialCode = SP.ModelCode	


													WHERE 1=1							
														AND A.TIMECODE <> 'E'																																																			   																			
														--AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), '2019-11-13', 121), 0, 11)              
														AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12),@FromDt, 121), 0, 11)                        --  SELECT SUBSTRING(CONVERT(VARCHAR(12), '2019-10-28', 121), 0, 11)    
												GROUP BY A.RouteCode 
															, SP.사이즈		
															, A.ShiftCode	
															, A.LineCode																				
											)  ZZ
										GROUP BY  ZZ.규격
												    , ZZ.공정코드	
												    , ZZ.라인코드						
                              ) AA
							  GROUP BY 라인코드, 규격, 공정코드

             ) SS	ON  SS.라인코드 = GG.LineCode   AND SS.규격 = GG.사이즈  AND SS.공정코드 = GG.공정코드			       

WHERE 1=1
 and CompanyCode in ('VNT','VVT')        -- 추가
ORDER BY GG.LineCode 



-- 주요 INSERT문 ------------------------------------------------------
---- INSERT INTO CURLING_PROD 
 --SELECT  기준일자, 라인코드, 정렬라인명, 일일총수량  
  --FROM #TEMP_TABLE100
  
 -- 전일실적 UPDATE부분 --
   DECLARE @sqlStr VARCHAR(1000)
--DECLARE @ToDay VARCHAR(10) = '08'
  

  -- [ 중요] CURLING_PROD 에 업데이트문
   --SET @sqlStr = ' UPDATE CURLING_PROD SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM CURLING_PROD A  INNER JOIN #TEMP_TABLE100 B  ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 =  ''' + @BaseYm + '''  AND A.RouteCode = ''' + @RouteCode + '''  AND A.CompanyCode = ''VNT''                AND A.LineCode = B.라인코드 '         
	 SET @sqlStr = ' UPDATE CURLING_PROD SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM CURLING_PROD A  INNER JOIN  #TEMP_TABLE100 B  ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 =  ''' + @BaseYm + '''  AND A.RouteCode = ''' + @RouteCode + '''  AND A.CompanyCode = B.[CompanyCode]  AND A.라인코드 = B.라인코드 '      -- 2020.03.02 수정

  --UPDATE CURLING_PROD
  --SET DAY02 = ''
  -- FROM CURLING_PROD A     INNER JOIN #TEMP_TABLE100 B  ON A.[라인코드] = B.[라인코드] AND 기준년월 = '201909'      

   EXECUTE  (@sqlStr)

-- TEMP TABLE삭제
    DELETE FROM  #TEMP_TABLE100      

 END
GO

