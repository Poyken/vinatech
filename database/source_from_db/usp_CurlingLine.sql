-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-02
-- Browsable   : true
-- Group       :  생산현황 > [B601] 일일실적보고 > Grid 2번째 부분
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    :  [B601] 일일실적보고
--                   2019-09-01  NAIS 실적추가 (kilee)
--                   2019-10-01 전반적으로 모두 수정 (kilee)
--                   2019-11-14 라인, 공정코드 추가 (kilee)
--                   2019-11-16 정상작동 (kilee)
--                   2020-03-02 베트남 법인 추가
-- ==================================================================
--   EXEC [usp_CurlingLine] '','', '2019-11-15 08:30:00', '' ,'E-28', 'VNT'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  
--   EXEC [usp_CurlingLine] '','', '2020-03-02 08:30:00', '' ,'V-28', 'VVT'                                                    ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

CREATE PROC [dbo].[usp_CurlingLine] 

				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pToDt datetime,
				@pMemo VARCHAR(20) = null,
				@pRouteCode VARCHAR(20) = NULL,
				@pCompanyCode VARCHAR(20) = NULL                    -- 추가
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    

	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 08:30:00'                                                          -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00' , 121) + ' 08:30:00'                                           
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDt)), 121) + ' 08:30:00'    -- SELECT  CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-01 08:30:00' ), 121) + ' 08:30:00'
	DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'                                                           -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00', 121) + ' 20:30:00'  
	DECLARE @ToDay               VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), @pToDt, 121), 9, 2)  		                                             --  SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-11-14', 121), 9, 2)	

    --DECLARE @DayCnt              VARCHAR(02) = datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, @pToDt)+1, @pToDt))))                     -- 2019.09.03 추가변수 : 해당월의 일수 (31일 or 30일)  -->  SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-11-14')+1,'2019-11-14'))))
	DECLARE @DayCnt              VARCHAR(02) = DatePart(dd,DateAdd(Day,-1,DateAdd(Month,-2,DateAdd(Day,-DatePart(dd, @pToDt)+1, @pToDt)))) 
	DECLARE @RouteCode         VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode                     END

  -- [주 쿼리부분]  *****************************************************************************************************************************************************  [총합계] + [라인별]

SELECT  '총합계'            AS 라인코드     
         , ' '                 AS 라인번호
         , ' '                   AS 라인명
		 , ''                    AS 공정코드
		 , ' '                   AS 규격
         , SUM(월간계획)    AS 월간계획
		 , SUM(누계목표)    AS 누계목표
		 , SUM(ISNULL(누계생산,0))   AS 누계생산
		 , AVG(누계달성율)            AS 누계달성율  --(%)
		 , AVG(누계진도율)            AS 누계진도율  --(%)
		 , SUM(주간수량)    AS 주간수량
		 , SUM(야간수량)    AS 야간수량
	  --, SUM(전체수량)    AS 전체수량	
	   , ''                       AS 특이사항
	   , SUM(Day26)         AS Day26
	   , SUM(Day27)         AS Day27
	   , SUM(Day28)         AS Day28
	   , SUM(Day29)         AS Day29
	   , SUM(Day30)         AS Day30
	   , SUM(Day31)         AS Day31
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
FROM  (

             --- 총합계부분 Start
								 SELECT GG.LineCode                                                     AS 라인코드
								        ,  GG.라인명                                                        AS 라인명
                                        , GG.사이즈                                                         AS 규격  
										, ISNULL(GG.월간계획, 0)                                         AS 월간계획

										, ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay + 6)       AS 누계목표 		 
									--  , ISNULL(GG.월간계획, 0) /           31 * (14 + 6)             AS 누계목표 		 

										, ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)      AS 누계생산         -- 1일부터 현재일까지의 생산량도 추가

										, CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay + 6 ))  * 100  END  AS 누계달성율		        -- 누계생산 / 누계목표										 										
									 -- , CASE WHEN ISNULL(GG.월간계획, 0) / 14  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 31 * (14 + 6 ))  *100  END                           AS 누계달성율		        -- 누계생산 / 누계목표										 										

	                                    , CASE WHEN ISNULL(GG.월간계획, 0)                * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                                    END  AS 누계진도율
										, ISNULL(SS.주간수량, 0)                     AS 주간수량
										, ISNULL(SS.야간수량, 0)                     AS 야간수량				
										, SS.주간수량 + SS.야간수량                AS 전체수량

										, GG.Day26, GG.Day27, GG.Day28, GG.Day29, GG.Day30, GG.Day31
										, GG.Day01, GG.Day02, GG.Day03, GG.Day04, GG.Day05                      
										, GG.Day06, GG.Day07, GG.Day08, GG.Day09, GG.Day10     
										, GG.Day11, GG.Day12, GG.Day13, GG.Day14, GG.Day15                      
										, GG.Day16, GG.Day17, GG.Day18, GG.Day19, GG.Day20     
										, GG.Day21, GG.Day22, GG.Day23, GG.Day24, GG.Day25                      										       
								  FROM 
										(  
														  -- GG START  
																SELECT  BB.*
																		, AA.월누적수량     AS 월누적수량													                                
																		, AA.Day26            AS Day26	
																		, AA.Day27            AS Day27
																		, AA.Day28            AS Day28
																		, AA.Day29            AS Day29
																		, AA.Day30            AS Day30
																		, AA.Day31            AS Day31
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
																FROM 
																	(
																			SELECT  --라인명																 
																						 라인코드
																						, 월누적수량
																						, 사이즈
																						, RouteCode
																						, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29)AS Day29, SUM(Day30)AS Day30, SUM(Day31) AS Day31
																						, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04)AS Day04, SUM(Day05)AS Day05, SUM(Day06) AS Day06
																						, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09, SUM(Day10)AS Day10, SUM(Day11)AS Day11, SUM(Day12) AS Day12
																						, SUM(Day13) AS Day13, SUM(Day14) AS Day14, SUM(Day15) AS Day15, SUM(Day16)AS Day16, SUM(Day17)AS Day17, SUM(Day18) AS Day18
																						, SUM(Day19) AS Day19, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22)AS Day22, SUM(Day23)AS Day23, SUM(Day24) AS Day24, SUM(Day25) AS Day25																																														  
																						, CompanyCode
																			FROM CURLING_PROD                                                              -- 커링일별실적 TABLE
																		WHERE 1=1																					

																			--AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 	
																			--AND 기준년월 = '201912'	
																			--AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가
																			--AND RouteCode LIKE @RouteCode	
																																					
																			 AND 기준년월 = '202003'
																			-- AND RouteCode = 'E-28'																			 																		 																			
																			--AND CompanyCode = 'VNT'
																		    

																		GROUP BY  RouteCode			
																						--, 라인명																 
																						, 라인코드
																						, 월누적수량												
																						, 사이즈	
																						, RouteCode	
																						, CompanyCode																								
																		-- SELECT * FROM CURLING_PROD WHERE 기준년월 = '201909'   and 라인코드 = 'ASSYLINE-05'  ORDER BY RouteCode 
																	)  AA
																	LEFT OUTER JOIN (
																								SELECT LineCode
																										, (SELECT LineName FROM STB_LineInfo SL WHERE SL.LineCode = MP.LineCode)   AS 라인명
																										, 사이즈	                                                                                        
																										, 월간계획
																										--, 라인별칭
																										, 특이사항
																										, 공정코드
																										, CompanyCode
																									FROM MEDIUM_PLAN MP
																								WHERE 1=1			
																									
																								   --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 																									   
																								   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가
																								   AND 공정코드 LIKE @RouteCode	
																																					
																									AND 기준년월 = '202003'			
																									--AND 공정코드 = 'E-28'		
																									--AND CompanyCode = 'VNT'

																						) BB		ON AA.라인코드 = BB.LineCode  AND AA.RouteCode = BB.공정코드  AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode
									 -- GG END
								 )   GG

				LEFT JOIN 	(	
				                     -- [SS] START
									SELECT   라인코드                               AS 라인코드													
												, CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  
														WHEN 라인코드 LIKE '%ASSYLINE-09%' AND 규격 = '1030' THEN 규격 + 'L'  
														 WHEN 라인코드 LIKE '%ASSYLINE-11%' AND 규격 = '1840' THEN 규격 + '-수동'  
														 WHEN 라인코드 LIKE '%ASSYLINE-13%' AND 규격 = '1840' THEN 규격 + '-자동'  							   
									                                                                                                      ELSE 규격 END     AS 규격  
												, SUM(주간수량)                        AS 주간수량
												, SUM(야간수량)                        AS 야간수량 
												, SUM(주간수량) + SUM(야간수량) AS 일일총수량
												, 공정코드 AS 공정코드
										FROM (																																	 																									
													SELECT ZZ.규격
															, ZZ.공정코드  AS 공정코드
															, ZZ.라인코드  AS 라인코드
															, SUM(ZZ.주간수량) AS 주간수량
															, SUM(ZZ.야간수량) AS 야간수량
															

														FROM (	
														          -- ZZ START							
																	SELECT  SP.사이즈                                                                                                    AS 규격																	          
																			,  A.RouteCode                                                                                                AS 공정코드
																			, A.LineCode																									  AS 라인코드
																			, CASE WHEN A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
																			, CASE WHEN A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량																			
																	FROM STB_ProdRouteSummary A                                                                                                
																			LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
																		WHERE 1=1							
																			AND A.TIMECODE <> 'E'			
																			AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12),@FromDt, 121), 0, 11)                        --  SELECT SUBSTRING(CONVERT(VARCHAR(12), '2019-10-28', 121), 0, 11)    
																			AND A.RouteCode  LIKE @RouteCode																				
																			AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))                                                --추가
																																																																			   																			
																			--AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), '2019-11-14', 121), 0, 11)              
																			--AND A.RouteCode = 'E-28'
																			--AND A.CompanyCode = 'VNT'

																	GROUP BY A.RouteCode 
																				, SP.사이즈		
																				, A.ShiftCode	
																				, A.LineCode	
																	-- ZZ END																						
															    )  ZZ
														GROUP BY  ZZ.규격
																,  ZZ.공정코드	
																, ZZ.라인코드																								
												) AA
												GROUP BY 라인코드, 규격, 공정코드
                                       -- SS END
             ) SS	ON  SS.라인코드 = GG.LineCode   AND SS.규격 = GG.사이즈 
			        AND SS.공정코드 = GG.공정코드
 
WHERE 1=1
   --AND GG.CompanyCode = 'VNT'

   AND ((@CompanyCode = '*') OR (GG.CompanyCode = @CompanyCode))    
   --AND GG.공정코드 LIKE @RouteCode
   --AND GG.공정코드 = 'E-28'


)  TOTAL

--- 총합계부분 END    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

UNION ALL


-- 라인부분 START

 SELECT GG.LineCode                          AS 라인코드       
         , CASE WHEN GG.LineCode IN ('ASSYLINE-10', 'ASSYLINE-11', 'ASSYLINE-12', 'ASSYLINE-13', 'ASSYLINE-14' )  THEN 99 ELSE RIGHT(GG.LineCode,2) END              AS 라인번호          
         , GG.라인명                            AS 라인명
		 , GG.공정코드							AS 공정코드
         , GG.사이즈                            AS 규격
	     , ISNULL(GG.월간계획, 0)                           AS 월간계획
		 --, (ISNULL(GG.월간계획, 0) /30) * 03                AS 누계목표 				 
		 , ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay + 6)               AS 누계목표 		 		  

		 , ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                          AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 --, CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 * 03)  *100           END   AS 누계달성율		   -- 누계생산 / 누계목표										 										
	  --   , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                     END   AS 누계진도율

		 , CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay + 6 ))  *100  END  AS 누계달성율		        -- 누계생산 / 누계목표										 										
	     , CASE WHEN ISNULL(GG.월간계획, 0)                * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                                    END  AS 누계진도율

		 , ISNULL(SS.주간수량, 0)     AS 주간수량
		 , ISNULL(SS.야간수량, 0)     AS 야간수량					
		, GG.특이사항                                                                                AS 특이사항	
		, GG.Day26                                                                                   AS Day26
		, GG.Day27                                                                                   AS Day27
		, GG.Day28                                                                                   AS Day28
		, GG.Day29                                                                                   AS Day29
		, GG.Day30                                                                                   AS Day30
		, GG.Day31                                                                                   AS Day31
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
  FROM 

								(  
								-- GG START  
											SELECT  BB.*
													, AA.월누적수량     AS 월누적수량													                                
													, AA.Day26           AS Day26	
													, AA.Day27           AS Day27
													, AA.Day28           AS Day28
													, AA.Day29           AS Day29
													, AA.Day30           AS Day30
													, AA.Day31           AS Day31
													, AA.Day01           AS Day01
													, AA.Day02           AS Day02
													, AA.Day03           AS Day03
													, AA.Day04           AS Day04
													, AA.Day05           AS Day05
													, AA.Day06           AS Day06
													, AA.Day07           AS Day07
													, AA.Day08           AS Day08
													, AA.Day09           AS Day09
													, AA.Day10           AS Day10
													, AA.Day11           AS Day11
													, AA.Day12           AS Day12
													, AA.Day13           AS Day13
													, AA.Day14           AS Day14
													, AA.Day15           AS Day15
													, AA.Day16           AS Day16
													, AA.Day17           AS Day17
													, AA.Day18           AS Day18
													, AA.Day19           AS Day19
													, AA.Day20           AS Day20
													, AA.Day21           AS Day21
													, AA.Day22           AS Day22
													, AA.Day23           AS Day23
													, AA.Day24           AS Day24
													, AA.Day25           AS Day25																							  
											FROM 
												(
														SELECT  --라인명															     		 													 
																	 라인코드
																	, 월누적수량
																	, 사이즈																								  
																	, RouteCode
																	, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29)AS Day29, SUM(Day30)AS Day30, SUM(Day31) AS Day31
																	, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04)AS Day04, SUM(Day05)AS Day05, SUM(Day06) AS Day06
																	, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09, SUM(Day10)AS Day10, SUM(Day11)AS Day11, SUM(Day12) AS Day12
																	, SUM(Day13) AS Day13, SUM(Day14) AS Day14, SUM(Day15) AS Day15, SUM(Day16)AS Day16, SUM(Day17)AS Day17, SUM(Day18) AS Day18
																	, SUM(Day19) AS Day19, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22)AS Day22, SUM(Day23)AS Day23, SUM(Day24) AS Day24, SUM(Day25) AS Day25																	
																	, CompanyCode
														FROM CURLING_PROD                                                              -- 커링일별실적 TABLE
													WHERE 1=1																					
														 AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 																				
														AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가
														AND RouteCode LIKE @RouteCode	
																																					
														--AND 기준년월 = '201912'			
														--AND RouteCode = 'E-22'		
														--AND CompanyCode = 'VNT'	

													GROUP BY  RouteCode			
																	--, 라인명																 
																	, 라인코드
																	, 월누적수량												
																	, 사이즈		
																	, CompanyCode																								
													-- SELECT * FROM CURLING_PROD WHERE 기준년월 = '201909'   and 라인코드 = 'ASSYLINE-05'  ORDER BY RouteCode 
												)  AA
												LEFT OUTER JOIN (
																			SELECT LineCode
																					, (SELECT LineName FROM STB_LineInfo SL WHERE SL.LineCode = MP.LineCode)   AS 라인명
																					, 사이즈	                                                                                        
																					, 월간계획
																					--, 라인별칭
																					, 특이사항
																					, 공정코드
																					, CompanyCode
																				FROM MEDIUM_PLAN MP
																			WHERE 1=1
																			 --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 																				
																			   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가
																			   AND 공정코드 LIKE @RouteCode	
																																					
																			AND 기준년월 = '202003'			
																			--AND 공정코드 = 'E-22'		
																			--AND CompanyCode = 'VNT'																				  

																	) BB		ON   AA.라인코드 = BB.LineCode  AND AA.RouteCode = BB.공정코드  AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode
                                      -- GG END
								     )   GG


LEFT JOIN 	(
	             -- [SS START] --
                  SELECT 라인코드                                 AS 라인코드
				       --  ,  CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  
						     --      WHEN 라인코드 LIKE '%ASSYLINE-09%' THEN 규격 + 'L'  
								   --WHEN 라인코드 LIKE '%ASSYLINE-13%' THEN 규격 + '-자동'  
								   --WHEN 라인코드 LIKE '%ASSYLINE-11%' THEN 규격 + '-수동'      ELSE 규격 END    AS 규격   	


							, CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  
					                 WHEN 라인코드 LIKE '%ASSYLINE-09%' AND 규격 = '1030' THEN 규격 + 'L'  
									 WHEN 라인코드 LIKE '%ASSYLINE-11%' AND 규격 = '1840' THEN 규격 + '-수동'  
									 WHEN 라인코드 LIKE '%ASSYLINE-13%' AND 규격 = '1840' THEN 규격 + '-자동'  							   
									                                                                                                      ELSE 규격 END     AS 규격  

						-- 규격                                      AS 규격
						, SUM(주간수량)                        AS 주간수량
						, SUM(야간수량)                        AS 야간수량 
						, SUM(주간수량) + SUM(야간수량) AS 일일총수량
						, 공정코드 AS 공정코드
				FROM (																						
											 														
											
							SELECT ZZ.규격
									, ZZ.공정코드
									, ZZ.라인코드        AS 라인코드
									, SUM(ZZ.주간수량) AS 주간수량
									, SUM(ZZ.야간수량) AS 야간수량
								FROM (								
										SELECT  SP.사이즈                                                                                                    AS 규격																	          
												,  A.RouteCode                                                                                                AS 공정코드
												, A.LineCode																									  AS 라인코드
												, CASE WHEN A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
												, CASE WHEN A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량																			
										FROM STB_ProdRouteSummary A                                                                                                
												LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
											WHERE 1=1							
												AND A.TIMECODE <> 'E'																																																			   																			
												AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12),@FromDt, 121), 0, 11)                        --  SELECT SUBSTRING(CONVERT(VARCHAR(12), '2019-10-28', 121), 0, 11)    
												AND A.RouteCode  LIKE @RouteCode																																				
												AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))                                                --추가

												--AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), '2019-11-14', 121), 0, 11)              												
												--AND A.RouteCode = 'E-28'
												--AND A.ComPanyCode = 'VNT'

										GROUP BY A.RouteCode 
													, SP.사이즈		
													, A.ShiftCode	
													, A.LineCode																				
									)  ZZ
								GROUP BY  ZZ.규격
										,  ZZ.공정코드	
										, ZZ.라인코드						
						) AA
						GROUP BY 라인코드, 규격, 공정코드


         ) SS	ON  SS.라인코드 = GG.LineCode   AND SS.규격 = GG.사이즈  		 
			        AND SS.공정코드 = GG.공정코드

			       
WHERE 1=1
   --AND GG.CompanyCode = 'VNT'
    --AND GG.공정코드 = 'E-28'

-- 라인부분 END       (TOTAL과 LINE은 UNION ALL로)

   AND GG.LineCode IS NOT NULL
ORDER BY 라인번호 ASC

 END