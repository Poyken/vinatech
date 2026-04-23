-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : True
-- Group       : 생산현황 > [B606] 입고생산현황 종합보고 > 첫번째 전일계획대비 생산량의 Graph
-- Description : DB명 : [SmartFactoryV2]
-- Modified    :   

-- [프로시저 실행문]     usp_Size_Day_Chart_CEO 'kilee','Korean','2020-03-01 00:00:00', '', ''
-- ==================================================================

CREATE PROC [dbo].[usp_Size_Day_Chart_CEO]
				@pProcessUserID		VARCHAR(20),
				@pProcessLanguage   VARCHAR(20),
				@pMonth				DateTime,
				@pSizeCode				VARCHAR(20) = NULL,
				@pCompanyCode      VARCHAR(20) = NULL                                           

AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
  DECLARE @Month				  VARCHAR(6) = CONVERT(VARCHAR(7), @pMonth, 112)                                                                                     -- SELECT CONVERT(VARCHAR(7), '2020-02-01 00:00:00', 112)  
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                            -- 전일자 두자리                SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 	
	--DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                           -- 오늘날짜   ex) 2020-01-12  SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 11)                                                             
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                        -- 어제날짜   ex) 20200111    SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	




---- 1. [전일실적-상세부분]   (원본백업)

--		SELECT CASE WHEN A.CompanyCode LIKE '%VNT%' THEN '전주본사' 
--						 WHEN A.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장    
--				,  A.사이즈                                                                                       AS  사이즈
--				, SUM(A.Day03)                                                                                  AS '일 생산계획 (PCS)'
--				, SUM(B.Day03)                                                                                  AS '일 생산수량 (PCS)'
--				, CASE WHEN SUM(A.Day03) = 0 THEN 0 ELSE CONVERT(NUMERIC(20,1), SUM(B.Day03)) / CONVERT(NUMERIC(20,5), SUM(A.Day03) ) * 100.0  END   AS '달성율 (%)'
--		FROM MEDIUM_PLAN A
--			   LEFT OUTER JOIN MEDIUM_PROD B  ON A.사이즈 = B.사이즈 AND A.CompanyCode = B.CompanyCode AND A.LineCode = B.LineCode  AND A.공정코드 = B.RouteCode	AND A.기준년월 = B.기준년월
--		WHERE 1=1				
--			AND A.공정코드 IN ('E-28', 'V-28')					  

--			--AND A.기준년월 = '202002'			
--			--AND A.공정코드 IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')			
--			--AND A.사이즈 = '0813'

--			--AND A.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
--			--AND A.기준년월 = (SELECT BaseMonth  FROM #TEMP_TABLE_200 )
--			--AND A.기준년월 = (
--			--                          SELECT  Replace(BaseMonth, '-', '')		
--			--						 FROM STB_AggregationPeriod
--			--						WHERE 1=1									   
--			--						   AND  FromDate  <= @OneDay
--			--						   AND  ToDate     >= @OneDay
--			--                        )

--			--AND A.사이즈   like @SizeCode  			   
--			AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))                                           --추가
--			--AND A.CompanyCode = 'VVT'
			 
--		GROUP BY  A.사이즈, A.CompanyCode
--		ORDER BY  A.사이즈, A.CompanyCode

--		-- 여기서는 합계부분 제외임 - 헷갈리지말것!!



-- 2020.01.20 수정본

		-- [전일실적_상세부분] 		
			SELECT  CASE WHEN AA.CompanyCode LIKE '%VNT%' THEN '전주본사' 
							  WHEN AA.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END																																			  AS 사업장    
					 , AA.사이즈																																																								  AS 사이즈          
					 , SUM(AA.수량)																																																							  AS '일 생산계획 (PCS)'  
					 , SUM(BB.수량)																																																						      AS '일 생산수량 (PCS)'	  
					 , CASE WHEN SUM(AA.수량) = 0 or SUM(BB.수량) = 0  or SUM(BB.수량) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(BB.수량)) / CONVERT(NUMERIC(20,5), SUM(AA.수량) ) * 100.0  END  AS '달성율 (%)'		  				   
			FROM 		 
					( 
					 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드
							,기준년월 + RIGHT(기준일,2)  AS 기준년월일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30, Day31)
							) AS UPT
					WHERE 1=1
						   --AND 기준년월  =  (                                                                                                
									--				SELECT  Replace(BaseMonth, '-', '')		
									--				FROM STB_AggregationPeriod
									--			WHERE 1=1									
									--				AND  FromDate  <= @OneDay
									--				AND  ToDate     >= @OneDay
									--			)      
									AND  기준년월 = '202006'

						  --AND 기준년월 + RIGHT(기준일,2)  = '20200326'
							--AND 기준년월 + RIGHT(기준일,2)  = @YesterDay							
                            AND  RIGHT(기준일,2)  = @ToDay						

					  )  AA
							  LEFT OUTER JOIN 
							  ( 
							   SELECT 기준년월
										,사이즈
										, RouteCode AS 공정코드
										,기준년월 + RIGHT(기준일,2)  AS 기준년월일
										, RIGHT(기준일, 2)  AS 기준일
										,수량
										, CompanyCode
										, LineCode
									  FROM MEDIUM_PROD
									 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																		   ,Day06, Day07, Day08, Day09, Day10
																		   ,Day11, Day12, Day13, Day14, Day15
																		   ,Day16, Day17, Day18, Day19, Day20
																		   ,Day21, Day22, Day23, Day24, Day25
																		   ,Day26, Day27, Day28, Day29, Day30 ,Day31)
									) AS UPT			
								WHERE 1=1
										  --AND 기준년월  =  (                                                                                                
												--	SELECT  Replace(BaseMonth, '-', '')		
												--	FROM STB_AggregationPeriod
												--WHERE 1=1									
												--	AND  FromDate  <= @OneDay
												--	AND  ToDate     >= @OneDay
												--)      

												AND  기준년월 = '202006'
						  --AND 기준년월 + RIGHT(기준일,2)  = '20200326'
							--AND 기준년월 + RIGHT(기준일,2)  = @YesterDay							
                            AND  RIGHT(기준일,2)  = @ToDay		
																		
					  )  BB  on AA.기준년월 = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

		WHERE 1=1
		      --AND AA.기준년월일 = '20200120'
			  --AND AA.기준년월일 = @YesterDay
			   AND AA.기준년월 = '202006'
											

            --     AND AA.기준년월 =  (                                                                                                      -- 2020.01.30 수정사항
												--	SELECT  Replace(BaseMonth, '-', '')		
												--	FROM STB_AggregationPeriod
												--WHERE 1=1									
												--	AND  FromDate  <= @OneDay
												--	AND  ToDate     >= @OneDay
												--)      

              AND  RIGHT(기준일,2)  = @ToDay

			  AND AA.공정코드 IN ( 'E-28', 'V-28')
			  
			AND AA.사이즈   like @SizeCode  			   
			AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가
		 -- AND AA.CompanyCode = 'VVT'

	GROUP BY AA.CompanyCode 
				, AA.사이즈           
   ORDER BY  AA.CompanyCode 
			    , AA.사이즈     

			 
 END