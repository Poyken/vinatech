-- Procedure: usp_CurlingLine_20191101
-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-02
-- Browsable   : true
-- Group       :  생산현황 > [B751] 일일실적보고 > Grid 2번째 부분
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    :  일일실적현황
--                   2019-09-01  NAIS 실적추가 (kilee)
--                   2019-10-01 전반적으로 모두 수정 (kilee)
-- ==================================================================

--   EXEC [usp_CurlingLine] '','', '2019-10-27 08:30:00'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

CREATE PROC [dbo].[usp_CurlingLine_20191101] 

				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pToDt datetime,
				@pMemo VARCHAR(20) = null,
				@pRouteCode VARCHAR(20) = null

AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    

	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 08:30:00'                                                          -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00' , 121) + ' 08:30:00'                                           
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDt)), 121) + ' 08:30:00'    -- SELECT  CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-01 08:30:00' ), 121) + ' 08:30:00'
	DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'                                                           -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00', 121) + ' 20:30:00'  
	DECLARE @ToDay               VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @pToDt, 121), 9, 2)  		                                              --SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-04-10', 121), 9, 2)	

    DECLARE @DayCnt               VARCHAR(02) = datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, @pToDt)+1, @pToDt))))                     -- 2019.09.03 추가변수 : 해당월의 일수 (31일 or 30일)  -->  SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-05-08')+1,'2019-05-08'))))
	DECLARE @RouteCode           VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END



 --  [주 쿼리부분]  *****************************************************************************************************************************************************  [총합계] + [라인별]

SELECT  
          '총합계'              AS 라인명
		 , ' '                    AS 규격
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
								 SELECT 
								          GG.라인명                                                         AS 라인명
                                        , GG.사이즈                                                          AS 규격  
										, ISNULL(GG.월간계획, 0)                                          AS 월간계획
										, ISNULL(GG.월간계획, 0) / @DayCnt * @ToDay               AS 누계목표 		 
										, ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                                           AS 누계생산         -- 1일부터 현재일까지의 생산량도 추가
										, CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * @ToDay)  *100     END  AS 누계달성율		        -- 누계생산 / 누계목표										 										
	                                    , CASE WHEN ISNULL(GG.월간계획, 0)                * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                               END  AS 누계진도율
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
																			FROM CURLING_PROD                                                              -- 커링일별실적 TABLE
																		WHERE 1=1																					
																			AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 	
																			AND RouteCode LIKE @RouteCode	
																			 --AND 기준년월 = '201910'
																			 --AND RouteCode IN ( 'E-28', 'V-28')
																			-- and 라인코드 = 'ASSYLINE-05'
																		GROUP BY  RouteCode			
																						--, 라인명																 
																						, 라인코드
																						, 월누적수량												
																						, 사이즈	
																						, RouteCode																									
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
																									FROM MEDIUM_PLAN MP
																								WHERE 1=1																																																		 
																									AND 기준년월 = 	REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 	
																									AND MP.공정코드 LIKE  @RouteCode 
																									--   AND 기준년월 = '201910'			
																									--AND 공정코드 = 'E-28'		
																									--AND CompanyCode = 'VNT'
																						) BB		ON AA.라인코드 = BB.LineCode  AND AA.RouteCode = BB.공정코드  AND AA.사이즈 = BB.사이즈
												-- GG END
																)   GG


								LEFT JOIN 	(	

													 SELECT 라인명 AS 라인명
															 , 규격   AS 규격
															 , SUM(주간수량)                      AS 주간수량
															 , SUM(야간수량)                      AS 야간수량 
															 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
														FROM (
			                                                                             

																					-- NAIS 추가부분 (주간실적부분)
																						   SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = SI.InputLineCode ) AS 라인명
																									--, A.InputLineCode AS 라인코드			 
																									, SP.사이즈 AS 규격
																									, (SUM(SI.ProdQty) - SUM(SI.DefectQty))  AS 주간수량
																									, 0 AS 야간수량
																							 FROM STB_SetInfo SI     
																							          LEFT OUTER JOIN STB_ProdRouteHist           PRH	 ON SI.ControlNo = PRH.ControlNo
																									  LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON SI.MaterialCode = SP.PRODCD																							
																							 WHERE 1=1
																								 AND SI.CreateDateTime > @FromDt AND SI.CreateDateTime <= @ChangeTime
																								 --AND SI.CreateDateTime BETWEEN '2019-09-01 08:30:00'and '2019-09-03 20:30:00'																								 																								 
																								 AND SI.InputShiftCode = '1'
																								 AND PRH.RouteCode LIKE  @RouteCode 
																							GROUP BY SI.InputLineCode 
																									   , SP.사이즈		


																					 -- 주간실적부분 End


																					UNION 


																		  
																																						
																					-- NAIS 추가부분 (야간실적)
																						   SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = SI.InputLineCode ) AS 라인명																									
																									, SP.사이즈                                     AS 규격
																								    , 0                                               AS 주간수량
													                                                , (SUM(SI.ProdQty) - SUM(SI.DefectQty))    AS 야간수량
																							 FROM STB_SetInfo SI    
																							          LEFT OUTER JOIN STB_ProdRouteHist           PRH	 ON SI.ControlNo = PRH.ControlNo
																									  LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON SI.MaterialCode = SP.PRODCD																							
																							 WHERE 1=1																								 
																								 AND SI.CreateDateTime > @FromDt AND SI.CreateDateTime <= @ChangeTime                      -- 원본으로 절대삭제금지!!!
																								 --AND SI.CreateDateTime BETWEEN '2019-09-18 08:30:00'and '2019-09-19 20:30:00'			            -- TEST용 : FromDt는 오전8시반, ChangTime는 당일 오후20시반
																								 AND SI.InputShiftCode = '2'
																								 --AND PRH.RouteCode LIKE  'E-24'
																								 AND PRH.RouteCode LIKE  @RouteCode 
																								
																							GROUP BY SI.InputLineCode 
																									   , SP.사이즈		
																				   --- 야간실적부분 End
																			  ) AA
																			  GROUP BY 라인명, 규격

                                         --- 여기까지가 실적부분
											 --) SS	ON  SS.라인명 = GG.라인명 
											 ) SS	ON  SS.라인명 = GG.라인명
											              AND SS.규격 = GG.사이즈											
)  TOTAL
--- 총합계부분 END    ----------------------------------------------------------------------------

UNION ALL


-- 라인부분 START

 SELECT GG.라인명                         AS 라인명
         , GG.사이즈                            AS 규격
	     , ISNULL(GG.월간계획, 0)                           AS 월간계획
		 , (ISNULL(GG.월간계획, 0) /30) * 03                AS 누계목표 		 
		 , ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                                                                                                                                                          AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 , CASE WHEN ISNULL(GG.월간계획, 0) / 30 * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / 30 * 03)  *100           END   AS 누계달성율		   -- 누계생산 / 누계목표										 										
	     , CASE WHEN ISNULL(GG.월간계획, 0)       * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                     END   AS 누계진도율
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
														FROM CURLING_PROD                                                              -- 커링일별실적 TABLE
													WHERE 1=1																					
														AND 기준년월 = '201909'
														AND RouteCode = 'E-28'		
														--and 라인코드 = 'ASSYLINE-05'
													GROUP BY  RouteCode			
																	--, 라인명																 
																	, 라인코드
																	, 월누적수량												
																	, 사이즈																										
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
																				FROM MEDIUM_PLAN MP
																			WHERE 1=1
																				  AND 기준년월 = 	REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 
																				AND MP.공정코드 LIKE @RouteCode	
																				--   AND 기준년월 = '201909'			
																				--AND 공정코드 = 'E-28'		
																				--AND CompanyCode = 'VNT'
																	) BB		ON   AA.라인코드 = BB.LineCode    AND AA.RouteCode = BB.공정코드  AND AA.사이즈 = BB.사이즈
                                      -- GG END
								     )   GG


LEFT JOIN 	(
	
					 SELECT 라인명 AS 라인명
						     , 규격
							 , SUM(주간수량)                      AS 주간수량
							 , SUM(야간수량)                      AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
						FROM (

											
										-- NAIS 추가부분 (주간)
													SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = SI.InputLineCode ) AS 라인명																									
															, SP.사이즈 AS 규격
													        , (SUM(SI.ProdQty) - SUM(SI.DefectQty))             AS 주간수량
															, 0 AS 야간수량
														FROM STB_SetInfo SI     
																LEFT OUTER JOIN STB_ProdRouteHist           PRH	 ON SI.ControlNo = PRH.ControlNo
																LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON SI.MaterialCode = SP.PRODCD																							
														WHERE 1=1		
														AND SI.CreateDateTime > @FromDt AND SI.CreateDateTime <= @ChangeTime                                  -- 지우지말것																							   
														-- AND SI.CreateDateTime > '2019-09-01 08:30:00' AND SI.CreateDateTime <=  '2019-09-03 20:30:00'   	      -- TEST용 : FromDt는 오전8시반, ChangTime는 당일 오후20시반
															AND SI.InputShiftCode = '1'                                                             -- 주간 1														
														AND PRH.RouteCode IN ( 'E-28', 'V-28')
												--AND PRH.RouteCode LIKE  @RouteCode 
													GROUP BY SI.InputLineCode                           
																, SP.사이즈																								

                --  주간 END
                       UNION 				
					   															
										-- NAIS 추가부분 (야간)
										SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = SI.InputLineCode ) AS 라인명																									
												, SP.사이즈 AS 규격
												, 0          AS 주간수량
												, (SUM(SI.ProdQty) - SUM(SI.DefectQty))             AS 야간수량
											FROM STB_SetInfo SI     
													LEFT OUTER JOIN STB_ProdRouteHist           PRH	 ON SI.ControlNo = PRH.ControlNo
													LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON SI.MaterialCode = SP.PRODCD																							
											WHERE 1=1				
												AND SI.CreateDateTime > @ChangeTime AND SI.CreateDateTime <= @ToDt																					 												
												AND PRH.RouteCode LIKE  @RouteCode 
												--AND SI.CreateDateTime > '2019-09-01 08:30:00' AND SI.CreateDateTime <= '2019-09-03 08:30:00'     -- TEST문
												--AND PRH.RouteCode IN ( 'E-28', 'V-28')
												AND SI.InputShiftCode = '2'																						
										GROUP BY SI.InputLineCode 
													, SP.사이즈																										
								--- 야간실적 END


                              ) AA
							  GROUP BY 라인명, 규격
                    ) SS on	 SS.규격 = GG.사이즈           


          --   ) SS	ON  SS.라인명 = GG.라인명 
			       --AND SS.규격 = GG.사이즈                                   -- 계획에 사이즈가 없는경우로 인해서..

-- 라인부분 END       (TOTAL과 LINE은 UNION ALL로)
---ORDER BY GG.라인명 


 END
GO

