-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-08
-- Browsable   : true
-- Group       :  실적일일보고  1일부터~31일까지
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 
-- ==================================================================

--   EXEC [usp_CurlingLine_FULL] '','', '2019-04-07 08:30:00'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

CREATE PROC [dbo].[usp_CurlingLine_FULL] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	--@pFromDt datetime, 
	@pToDt datetime

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 08:30:00'    
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDt)), 121) + ' 08:30:00'
	DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'    	

	-- 지우지말것!!     SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  '2019-04-05 08:30:00' , 121), 0, 8), '-', '')	                     --   SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '')                               --> 오늘날짜 2019-04-05 08:00:00 를  년월로 [201904]
                        

	

SELECT  ''                      AS 정렬라인명                                   -- 숨기는 컬럼
         , '총합계'              AS 라인명
		 , ''                       AS 규격
         , SUM(월간계획)    AS 월간계획
		 , SUM(누계목표)    AS 누계목표
		 , SUM(누계생산)   AS 누계생산
		 , AVG(누계달성율) AS 누계달성율  --(%)
		 , AVG(누계진도율) AS 누계진도율  --(%)
		 ,SUM(주간수량)    AS 주간수량
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
FROM  (

								 SELECT 
								           GG.라인명                                   AS 라인명
										, ISNULL(GG.월간계획, 0)                   AS 월간계획
										, ISNULL(GG.월간계획, 0) / 30             AS 누계목표 		 
										, ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                    AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
	                                    , CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 * 100)  END  AS 누계달성율		   -- 누계생산 / 누계목표										 										
	                                    , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0)        * 100)  END  AS 누계진도율
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
																						, AA.Day31             AS Day31													
																				FROM 
																				(
																						SELECT  라인명																 
																								  , 라인코드
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
																						FROM CURLING_PROD        -- 일별실적
																					WHERE 1=1
																					  -- AND 라인명 = '01호기'
																					   --AND 기준년월 = '201904'
																					   AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 																
																				) AA
																			 LEFT OUTER JOIN (
																											SELECT 라인코드
																													, 라인명
																													, 사이즈
																													, 규격
																													, 월간계획
																													, 라인별칭
																													, 특이사항
																												FROM CURLING_PLAN
																									) BB		ON    AA.라인명 = BB.라인명 AND AA.라인코드 = BB.라인코드
																		   -- GG END
																)   GG


								LEFT JOIN 	(	
													 SELECT 라인명 AS 라인명
															 , 규격
															 , SUM(주간수량)                      AS 주간수량
															 , SUM(야간수량)                      AS 야간수량 
															 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
														FROM (

																			-- 주간 START
																				  SELECT   MAX(라인명)     AS 라인명	
																							, 사이즈             AS 규격					  		
																							, SUM(양품수량)   AS 주간수량		
																							, 0                    AS 야간수량
																					FROM
																					(
			  
																									SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																														WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																														WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '10호기' 
																														WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'    ELSE '드라이룸' END        AS 라인명
																										, 지시번호                                                                                      AS 지시번호 
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
																														, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																														, P.사이즈 													
																											FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																														LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																														INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																														LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																														LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																											WHERE 1=1																																						
																												--AND D.작업일자 BETWEEN '2019-04-05 08:30:00' and '2019-04-06 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
																												AND D.작업일자 > @FromDt AND D.작업일자 <= @ChangeTime
																												AND B.공정코드 = 'E-24'
																											GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																														, GD.PROD_UNIT_PRICE 
																														, GD.CASE_PRICE
																														, TM.라인명		
																														, P.사이즈	
																											---- A		  							  
																										) A								
																								WHERE 1=1							  
																								GROUP BY 품목코드
																											, 품명
																											, 지시번호	 							
																											, 설비명	
																											, 조립라인명
																											, 사이즈
										
																								) ZZ		
																					GROUP BY 사이즈
																								, 라인명
																					 --  주간 END


																					UNION 


																					-- 야간
																				  SELECT   MAX(라인명)    AS 라인명	
																							, 사이즈             AS 규격	
																							, 0                    AS 주간수량				  		
																							, SUM(양품수량)   AS 야간수량		
																					FROM
																					(
																								SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																													WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																													WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '10호기' 
																													WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'    ELSE '드라이룸' END        AS 라인명
																										, 지시번호                                                                                      AS 지시번호 
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
																														, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																														, P.사이즈 													
																											FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																														LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																														LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																														INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																														LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																														LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																											WHERE 1=1																		
																												AND D.작업일자 > @ChangeTime AND D.작업일자 <= @ToDt
																												AND B.공정코드 = 'E-24'
																											GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																														, GD.PROD_UNIT_PRICE 
																														, GD.CASE_PRICE
																														, TM.라인명		
																														, P.사이즈	
																											---- A		  							  
																										) A								
																								WHERE 1=1							  
																								GROUP BY 품목코드
																											, 품명
																											, 지시번호	 							
																											, 설비명	
																											, 조립라인명
																											, 사이즈
										
																								) ZZ		
																					GROUP BY 사이즈
																								, 라인명
																				   --- 야간 END
															  ) AA
															  GROUP BY 라인명, 규격
                             

											 ) SS	ON  SS.라인명 = GG.라인명 AND SS.규격 = GG.사이즈
											-- ) SS	ON  SS.규격 = GG.사이즈
)   K								


------------------ 이 부분부터 라인별로
UNION ALL

 SELECT GG.라인명                         AS 정렬라인명
         , GG.라인별칭                      AS 라인명
         , GG.규격                            AS 규격
	     , ISNULL(GG.월간계획, 0)                      AS 월간계획
		 , ISNULL(GG.월간계획, 0) /30                 AS 누계목표 		 
		 , ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                              AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 --, ((SS.일일총수량+GG.월누적수량) / ISNULL(GG.월간계획, 0) / 30 * 100)                                                                                                                          AS 누계달성율		   -- 누계생산 / 누계목표
		 --, CASE WHEN  (ISNULL(GG.월간계획, 1) * 100)  = 0 THEN 0 ELSE  ISNULL(SS.일일총수량, 1) + ISNULL(GG.월누적수량, 1)  / (ISNULL(GG.월간계획, 1) * 100)      END   AS 누계진도율

		 , CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 * 100)  END  AS 누계달성율		   -- 누계생산 / 누계목표										 										
	     , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0)        * 100)  END  AS 누계진도율
		 , ISNULL(SS.주간수량, 0)     AS 주간수량
		 , ISNULL(SS.야간수량, 0)     AS 야간수량			
			
		, GG.특이사항                                                                                AS 특이사항

		, GG.Day01                                                                                   AS '1일'
		, GG.Day02                                                                                   AS '2일'
		, GG.Day03                                                                                   AS '3일'
		, GG.Day04                                                                                   AS '4일'
		, GG.Day05                                                                                   AS '5일'
		, GG.Day06                                                                                   AS '6일'
		, GG.Day07                                                                                   AS '7일'
		, GG.Day08                                                                                   AS '8일'
		, GG.Day09                                                                                   AS '9일'
		, GG.Day10                                                                                   AS '10일'
  --  INTO #TEMP_TABLE100                                                                                                              --[주석]풀을것
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
												FROM 
												(
														SELECT  라인명																 
														          , 라인코드
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
														FROM CURLING_PROD        -- 일별실적
													WHERE 1=1
													  -- AND 라인명 = '01호기'
													   --AND 기준년월 = '201904'
													   AND 기준년월 =   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 											
												) AA
							                 LEFT OUTER JOIN (
																			SELECT 라인코드
																					, 라인명
																					, 사이즈
																					, 규격
																					, 월간계획
																					, 라인별칭
																					, 특이사항
																				FROM CURLING_PLAN
																	) BB		ON    AA.라인명 = BB.라인명 AND AA.라인코드 = BB.라인코드
                                           -- GG END
								)   GG


LEFT JOIN 	(	
					 SELECT 라인명 AS 라인명
						     , 규격
							 , SUM(주간수량)                      AS 주간수량
							 , SUM(야간수량)                      AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
						FROM (

											-- 주간 START
												  SELECT   MAX(라인명)     AS 라인명	
															, 사이즈             AS 규격					  		
															, SUM(양품수량)   AS 주간수량		
															, 0                    AS 야간수량
													FROM
													(
			  
																SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '10호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'    ELSE '드라이룸' END        AS 라인명
																		, 지시번호                                                                                      AS 지시번호 
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
																						, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																						LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																						LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																			WHERE 1=1																		
																				AND D.작업일자 > @FromDt AND D.작업일자 <= @ChangeTime
																				AND B.공정코드 = 'E-24'
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																						, GD.PROD_UNIT_PRICE 
																						, GD.CASE_PRICE
																						, TM.라인명		
																						, P.사이즈	
																			---- A		  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			, 품명
																			, 지시번호	 							
																			, 설비명	
																			, 조립라인명
																			, 사이즈
										
																) ZZ		
													GROUP BY 사이즈
																, 라인명
                                                     --  주간 END


													UNION 


													-- 야간
												  SELECT   MAX(라인명)    AS 라인명	
															, 사이즈             AS 규격	
															, 0                    AS 주간수량				  		
															, SUM(양품수량)   AS 야간수량		
													FROM
													(
																SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '10호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'    ELSE '드라이룸' END        AS 라인명
																		, 지시번호                                                                                      AS 지시번호 
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
																						, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD	
																						LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																						LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																			WHERE 1=1																		
																				AND D.작업일자 > @ChangeTime AND D.작업일자 <= @ToDt
																				AND B.공정코드 = 'E-24'
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																						, GD.PROD_UNIT_PRICE 
																						, GD.CASE_PRICE
																						, TM.라인명		
																						, P.사이즈	
																			---- A		  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			, 품명
																			, 지시번호	 							
																			, 설비명	
																			, 조립라인명
																			, 사이즈
										
																) ZZ		
													GROUP BY 사이즈
																, 라인명
												   --- 야간 END
                              ) AA
							  GROUP BY 라인명, 규격
                             

             ) SS	ON  SS.라인명 = GG.라인명 AND SS.규격 = GG.사이즈




 END

