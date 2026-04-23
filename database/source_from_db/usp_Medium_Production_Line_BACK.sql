-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-02
-- Browsable   : true
-- Group       :  생산현황 > [B752] 중형생산현황
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    :  중형생산현황
-- ==================================================================

--   EXEC [usp_Medium_Production_Line]  '','', '2019-04-01 08:30:00', '2019-04-18 08:30:00'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

CREATE PROC [dbo].[usp_Medium_Production_Line_BACK] 		
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pFromDt datetime,
				@pEndDt datetime

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDt, 121) + ' 08:30:00'                                                                  
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pEndDt)), 121) + ' 08:30:00'
	DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDt, 121) + ' 20:30:00'    
	DECLARE @ToDay               VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @pFromDt, 121), 9, 2)  
	--DECLARE @ToDay               VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate-1(), 121), 9, 2)                                                                       -- 금일(두자리)          SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2)	
	                                                                                                                                                                                                                                                  --SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-04-10', 121), 9, 2)	

	-- 지우지말것!!     SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  '2019-04-05 08:30:00' , 121), 0, 8), '-', '')	                     --   SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '')                               --> 오늘날짜 2019-04-05 08:00:00 를  년월로 [201904]
                        

--SELECT 사이즈 FROM 		ERPSVR.ERPDB.DBO.PRODUCT 
--WHERE 1=1
--GROUP BY 사이즈


 --  [주 쿼리부분]  *****************************************************************************************************************************************************  [합계부분]  + [라인별로]

SELECT 
		   ''                       AS 사이즈
         , SUM(월간계획)    AS 월간계획
		 , SUM(누계목표)    AS 누계목표
		 , SUM(ISNULL(누계생산,0))   AS 누계생산
		 , AVG(누계달성율) AS 누계달성율  --(%)
		 , AVG(누계진도율) AS 누계진도율  --(%)
		 , SUM(주간수량)    AS 주간수량
		 , SUM(야간수량)    AS 야간수량
	  --, SUM(전체수량)    AS 전체수량	
	   , ''                       AS 특이사항

	   , SUM(Day01)         AS Day01
	   , SUM(Day02)         AS Day02
	   , SUM(Day03)         AS Day03
	   , SUM(Day04)         AS Day04
	   , SUM(Day05)         AS Day05
	   , SUM(Day06)         AS Day06
	   , SUM(Day07)         AS Day07
	   , SUM(Day08)         AS Day08
	   , SUM(Day09)         AS Day09
	   , SUM(Day10)         AS Day10
	   , SUM(Day11)         AS Day11
	   , SUM(Day12)         AS Day12
	   , SUM(Day13)         AS Day13
	   , SUM(Day14)         AS Day14
	   , SUM(Day15)         AS Day15
	   , SUM(Day16)         AS Day16
	   , SUM(Day17)         AS Day17
	   , SUM(Day18)         AS Day18
	   , SUM(Day19)         AS Day19
	   , SUM(Day20)         AS Day20	   
	   , SUM(Day21)         AS Day21
	   , SUM(Day22)         AS Day22
	   , SUM(Day23)         AS Day23
	   , SUM(Day24)         AS Day24
	   , SUM(Day25)         AS Day25
	   , SUM(Day26)         AS Day26
	   , SUM(Day27)         AS Day27
	   , SUM(Day28)         AS Day28
	   , SUM(Day29)         AS Day29
	   , SUM(Day30)         AS Day30

FROM  (
             --- 총합계부분 Start
								 SELECT 
								          ISNULL(GG.월간계획, 0)                                          AS 월간계획
										, ISNULL(GG.월간계획, 0) / 30  * @ToDay                            AS 누계목표 		 
										, ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                            AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
										, CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 *@ToDay)  *100         END  AS 누계달성율		   -- 누계생산 / 누계목표										 										
	                                    , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                    END  AS 누계진도율
										, ISNULL(SS.주간수량, 0)                     AS 주간수량
										, ISNULL(SS.야간수량, 0)                     AS 야간수량				
										, SS.주간수량 + SS.야간수량                AS 전체수량

										, GG.Day01                      
										, GG.Day02                      
										, GG.Day03                      
										, GG.Day04                      
										, GG.Day05                      
										, GG.Day06                      
										, GG.Day07                      
										, GG.Day08                      
										, GG.Day09                      
										, GG.Day10     
										, GG.Day11                      
										, GG.Day12                      
										, GG.Day13                      
										, GG.Day14                      
										, GG.Day15                      
										, GG.Day16                      
										, GG.Day17                      
										, GG.Day18                      
										, GG.Day19                      
										, GG.Day20     
										, GG.Day21                      
										, GG.Day22                      
										, GG.Day23                      
										, GG.Day24                      
										, GG.Day25                      
										, GG.Day26                      
										, GG.Day27                      
										, GG.Day28                      
										, GG.Day29                      
										, GG.Day30     

								  FROM 

																(  
																  -- GG START  (현재 19라인)
																			  SELECT  BB.*
																						, AA.월누적수량     AS 월누적수량
													                                    , AA.Day01           AS Day01
																					, AA.Day02            AS Day02
																					, AA.Day03            AS Day03
																					, AA.Day04            AS Day04
																					, AA.Day05            AS Day05
																					, AA.Day06            AS Day06
																					, AA.Day07            AS Day07
																					, AA.Day08            AS Day08
																					, AA.Day09            AS Day09
																					, AA.Day10            AS Day10
																					, AA.Day11            AS Day11
																					, AA.Day12            AS Day12
																					, AA.Day13            AS Day13
																					, AA.Day14            AS Day14
																					, AA.Day15            AS Day15
																					, AA.Day16            AS Day16
																					, AA.Day17            AS Day17
																					, AA.Day18            AS Day18
																					, AA.Day19            AS Day19
																					, AA.Day20            AS Day20
																					, AA.Day21            AS Day21
																					, AA.Day22            AS Day22
																					, AA.Day23            AS Day23
																					, AA.Day24            AS Day24
																					, AA.Day25            AS Day25
																					, AA.Day26            AS Day26
																					, AA.Day27            AS Day27
																					, AA.Day28            AS Day28
																					, AA.Day29            AS Day29
																					, AA.Day30            AS Day30
																					, AA.Day31            AS Day31			  
																	FROM 
																				(
																						SELECT  사이즈
																								  , Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10+Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31  AS 월누적수량																  
																   , Day01 
																								  , Day02
																								  , Day03
																								  , Day04
																								  , Day05
																								  , Day06
																								  , Day07
																								  , Day08
																								  , Day09
																								  , Day10
																								  , Day11 
																								  , Day12
																								  , Day13
																								  , Day14
																								  , Day15
																								  , Day16
																								  , Day17
																								  , Day18
																								  , Day19
																								  , Day20
																								  , Day21 
																								  , Day22
																								  , Day23
																								  , Day24
																								  , Day25
																								  , Day26
																								  , Day27
																								  , Day28
																								  , Day29
																								  , Day30
																                                  , Day31
																						FROM MEDIUM_PROD        -- 일별실적
																					WHERE 1=1																					
																					   AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 																
																				) AA
																			 LEFT OUTER JOIN (
																											SELECT 기준년월
																													, 사이즈																			
																													, 월간계획																			
																													, 특이사항
																												FROM MEDIUM_PLAN
																									  ) BB		ON    AA.사이즈 = BB.사이즈
																		   -- GG END
																)   GG


								LEFT JOIN 	(	
													 SELECT 
															  사이즈
															 , SUM(주간수량)                      AS 주간수량
															 , SUM(야간수량)                      AS 야간수량 
															 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
														FROM (

															-- 일일실적부분 Start
																				  SELECT    사이즈            AS 사이즈					  		
																							, SUM(양품수량)   AS 주간수량		
																							, SUM(양품수량)   AS 야간수량
																					FROM
																					(
			  
																								SELECT 
																										 지시번호                                                                                      AS 지시번호 
																										, A.품목코드                                                                                    AS 품목코드
																										, A.사이즈                                                                                       AS 사이즈								
																										, SUM(투입수량)                                                                               AS 투입수량
																										, SUM(양품수량)                                                                               AS 양품수량													
																										, ISNULL(SUM(금액), 0)                                                                       AS 총합      									       					  								
																								FROM (
																											---- 
																												SELECT A.지시일자
																														, A.지시번호
																														, 투입일자 = B.작업시작시간
																														, 종료일자 = B.작업종료시간
																														, A.품목코드
																														, 품명 = P.PRODNM
																														, 규격 = P.PRODSP
																														, B.공정코드, 공정명 = C.공정명
																														, D.작업자, 작업자명 = (SELECT NAME FROM ERPSVR.ERPDB.DBO.EMPREF WHERE SABUN = D.작업자)
																														, B.순번
																														, B.작업구분
																														, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
																														, ISNULL(D.실적,0)                                              AS 양품수량
																														, SUM(ISNULL(F.수량,0))                                       AS 불량수량
																														, D.작업일자																														
																														, B.설비코드
																														, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  
																														, (GD.PROD_UNIT_PRICE + GD.CASE_PRICE) * ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                                               AS 금액
																														, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 										
																														
																														, P.사이즈 													
																											FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																														LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																														INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																														LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                									  									  																																					                                                                                        
																											WHERE 1=1																																						
																												AND D.작업일자 BETWEEN '2019-04-05 08:30:00' and '2019-04-06 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
																												-- AND D.작업일자 BETWEEN @FromDt AND @ToDt
																												--AND D.작업일자 > @FromDt AND D.작업일자 <= @ChangeTime
																												AND B.공정코드 IN ('E-22', 'E-24', 'E-28')
						                                                                                        AND P.사이즈    IN ('1320', '1325', '1346', '1625', '1840', '1859')
																											GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , B.설비코드
																														, GD.PROD_UNIT_PRICE 
																														, GD.CASE_PRICE																															
																														, P.사이즈	
																											---- A		  							  
																										) A								
																								WHERE 1=1							  
																								GROUP BY 품목코드
																											, 품명
																											, 지시번호	 							
																											, 설비명																												
																											, 사이즈
										
																								) ZZ		
																					GROUP BY 사이즈																								
																					 -- 일일실적부분 End

															  ) AA
															  GROUP BY  사이즈
                             

											 ) SS	ON  SS.사이즈 = GG.사이즈											
)  TOTAL
--- 총합계부분 END

------------------ 이 부분부터 라인별로
UNION ALL




-- 라인부분 START
 SELECT 
           GG.사이즈                            AS 사이즈
	     , ISNULL(GG.월간계획, 0)                           AS 월간계획
		 , (ISNULL(GG.월간계획, 0) /30) * @ToDay                AS 누계목표 		 
		 , ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                                           AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 , CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 * @ToDay)  *100         END   AS 누계달성율		   -- 누계생산 / 누계목표										 										
	     , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                             END  AS 누계진도율
		 , ISNULL(SS.주간수량, 0)     AS 주간수량
		 , ISNULL(SS.야간수량, 0)     AS 야간수량					
		, GG.특이사항                                                                                AS 특이사항
		, GG.Day01                                                                                   AS Day01
		, GG.Day02                                                                                   AS Day02
		, GG.Day03                                                                                   AS Day03
		, GG.Day04                                                                                   AS Day04
		, GG.Day05                                                                                   AS Day05
		, GG.Day06                                                                                   AS Day06
		, GG.Day07                                                                                   AS Day07
		, GG.Day08                                                                                   AS Day08
		, GG.Day09                                                                                   AS Day09
		, GG.Day10                                                                                   AS Day10
		, GG.Day11                                                                                   AS Day11
		, GG.Day12                                                                                   AS Day12
		, GG.Day13                                                                                   AS Day13
		, GG.Day14                                                                                   AS Day14
        , GG.Day15                                                                                   AS Day15
		, GG.Day16                                                                                   AS Day16
		, GG.Day17                                                                                   AS Day17
		, GG.Day18                                                                                   AS Day18
		, GG.Day19                                                                                   AS Day19
		, GG.Day20                                                                                   AS Day20
		, GG.Day21                                                                                   AS Day21
		, GG.Day22                                                                                   AS Day22
		, GG.Day23                                                                                   AS Day23
		, GG.Day24                                                                                   AS Day24
		, GG.Day25                                                                                   AS Day25
		, GG.Day26                                                                                   AS Day26
		, GG.Day27                                                                                   AS Day27
		, GG.Day28                                                                                   AS Day28
		, GG.Day29                                                                                   AS Day29
		, GG.Day30                                                                                   AS Day30
		--, GG.Day31                                                                                   AS Day31
  
  FROM 

								(  
								  -- GG START  (현재 19라인)

											  SELECT  BB.*
														, AA.월누적수량      AS 월누적수량
														    , AA.Day01            AS Day01
															, AA.Day02            AS Day02
															, AA.Day03            AS Day03
															, AA.Day04            AS Day04
															, AA.Day05            AS Day05
															, AA.Day06            AS Day06
															, AA.Day07            AS Day07
															, AA.Day08            AS Day08
															, AA.Day09            AS Day09
															, AA.Day10            AS Day10
															, AA.Day11            AS Day11
															, AA.Day12            AS Day12
															, AA.Day13            AS Day13
															, AA.Day14            AS Day14
															, AA.Day15            AS Day15
															, AA.Day16            AS Day16
															, AA.Day17            AS Day17
															, AA.Day18            AS Day18
															, AA.Day19            AS Day19
															, AA.Day20            AS Day20
															, AA.Day21            AS Day21
															, AA.Day22            AS Day22
															, AA.Day23            AS Day23
															, AA.Day24            AS Day24
															, AA.Day25            AS Day25
															, AA.Day26            AS Day26
															, AA.Day27            AS Day27
															, AA.Day28            AS Day28
															, AA.Day29            AS Day29
															, AA.Day30            AS Day30
															, AA.Day31            AS Day31			  
												FROM 
												(
														SELECT    사이즈
														          ,  Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10+Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31  AS 월누적수량																  
																  , Day01 
																  , Day02
																  , Day03
																  , Day04
																  , Day05
																  , Day06
																  , Day07
																  , Day08
																  , Day09
																  , Day10
																  , Day11 
																  , Day12
																  , Day13
																  , Day14
																  , Day15
																  , Day16
																  , Day17
																  , Day18
																  , Day19
																  , Day20
																  , Day21 
																  , Day22
																  , Day23
																  , Day24
																  , Day25
																  , Day26
																  , Day27
																  , Day28
																  , Day29
																  , Day30
																  , Day31
														FROM MEDIUM_PROD        -- 일별실적
													WHERE 1=1
													  -- AND 라인명 = '01호기'
													   --AND 기준년월 = '201904'
													   AND 기준년월 =   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 											
												) AA
							                 LEFT OUTER JOIN (
																			SELECT 기준년월
																					, 사이즈																			
																					, 월간계획																			
																					, 특이사항
																				FROM MEDIUM_PLAN
																		) BB		ON    AA.사이즈 = BB.사이즈

                                      -- GG END
								)   GG


LEFT JOIN 	(	
					 SELECT  사이즈
							 , SUM(주간수량)                      AS 주간수량
							 , SUM(야간수량)                      AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
						FROM (

											-- 실적 START
												  SELECT   
															 사이즈             AS 사이즈					  		
															, SUM(양품수량)   AS 주간수량		
															, SUM(양품수량)   AS 야간수량
													FROM
													(
			  
																SELECT  
																		 지시번호                                                                                      AS 지시번호 
																		, A.품목코드                                                                                    AS 품목코드
																		, A.사이즈                                                                                       AS 사이즈								
																		, SUM(투입수량)                                                                               AS 투입수량
																		, SUM(양품수량)                                                                               AS 양품수량													
																		, ISNULL(SUM(금액), 0)                                                                       AS 총합      									       					  								
																FROM (
																			---- 
																				SELECT A.지시일자
																						, A.지시번호
																						, 투입일자 = B.작업시작시간
																						, 종료일자 = B.작업종료시간
																						, A.품목코드
																						, 품명 = P.PRODNM
																						, 규격 = P.PRODSP
																						, B.공정코드, 공정명 = C.공정명
																						, D.작업자, 작업자명 = (SELECT NAME FROM ERPSVR.ERPDB.DBO.EMPREF WHERE SABUN = D.작업자)
																						, B.순번
																						, B.작업구분
																						, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
																						, ISNULL(D.실적,0)                                              AS 양품수량
																						, SUM(ISNULL(F.수량,0))                                       AS 불량수량
																						, D.작업일자
																						, D.비고
																						, B.설비코드
																						, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  
																						, (GD.PROD_UNIT_PRICE + GD.CASE_PRICE) * ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                                               AS 금액
																						, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 																																
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																						LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  																						
								  
																			WHERE 1=1																		
																				--AND D.작업일자 > @FromDt AND D.작업일자 <= @ChangeTime
																				--AND D.작업일자 BETWEEN @FromDt AND  @ToDt
																				AND B.공정코드 IN ('E-22', 'E-24', 'E-28')
						                                                        AND P.사이즈 IN ('1320', '1325', '1346', '1625', '1840', '1859')
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																						, GD.PROD_UNIT_PRICE 
																						, GD.CASE_PRICE																						
																						, P.사이즈	
																			---- A		  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			, 품명
																			, 지시번호	 							
																			, 설비명																				
																			, 사이즈
										
																) ZZ		
													GROUP BY 사이즈																
                                                     --  주간 + 야간 END


										
                              ) AA
							  GROUP BY  사이즈
                             
             ) SS	ON  SS.사이즈 = GG.사이즈




 END

