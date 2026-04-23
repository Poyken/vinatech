-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-02
-- Browsable   : true
-- Group       :  생산현황 > [B602] 사이즈별생산현황
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    :  사이즈별 생산현황 Grid 두번째 - 생산현황_상세정보
-- 201910.10  LineCode 추가
-- ==================================================================

-- [프로시저 실행문]  :      Exec usp_Medium_Production_Line @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMonth='2019-11-18',@pCompanyCode = VNT, @pSizeCode=default

CREATE PROC [dbo].[usp_Medium_Production_Line] 		
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),			
				@pMonth DateTime,
				@pCompanyCode VARCHAR(20) = NULL,                                             -- 사업장코드 kilee 추가 (2019.05.21)
				@pSizeCode VARCHAR(20) = Null,                                                     --  2019.05.21 사이즈 추가    
				@pRouteCode VARCHAR(20) = NULL                                                  -- 2019.05.21 공정코드 추가
	

AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage  
	--DECLARE @Month             VARCHAR(19) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 9, 2)                                                               --  SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-04', 121), 9, 2)
	
	--DECLARE @Month               VARCHAR(19) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 9, 2)                                                               --  SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-04', 121), 9, 2)
	DECLARE @Month                VARCHAR(19) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 9), '-', '')                                         -- SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), '2019-09', 121), 0, 9), '-', '')

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	DECLARE @RouteCode          VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END	 
	--DECLARE @FromDt             VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDt, 121) + ' 08:30:00'                                                                  
	--DECLARE @ToDt                VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pEndDt)), 121) + ' 08:30:00'
	--DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDt, 121) + ' 20:30:00'    
	--DECLARE @ToDay              VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @pFromDt, 121), 9, 2)  
	--DECLARE @ToDay              VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate-1(), 121), 9, 2)                                                                       -- 금일(두자리)          SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2)	
	                                                                                                                                                                                                                                                  --SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-04-10', 121), 9, 2)	

	-- 지우지말것!!     SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  '2019-04-05 08:30:00' , 121), 0, 8), '-', '')	                     --   SELECT   REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '')                               --> 오늘날짜 2019-04-05 08:00:00 를  년월로 [201904]
                        

--SELECT 사이즈 FROM 		ERPSVR.ERPDB.DBO.PRODUCT 
--WHERE 1=1
--GROUP BY 사이즈


 --  [주 쿼리부분]  *****************************************************************************************************************************************************  [합계부분]  + [라인별로]


 -- 일자별 계획수량과 일자별 실적수량을  UNION ALL로 추가함 주영진 차장님 요청 2019.09.27 By Jackaroe
 SELECT 사이즈      
       -- , '' AS 라인코드
		, 공정코드
		, 공정명
        , 용도
		, 기준년월	
		, CompanyCode	  
		, 합계      
		, Day26, Day27, Day28, Day29, Day30
		, Day31
		, Day01, Day02, Day03, Day04, Day05
		, Day06, Day07, Day08, Day09, Day10
		, Day11, Day12, Day13, Day14, Day15
		, Day16, Day17, Day18, Day19, Day20
		, Day21, Day22, Day23, Day24, Day25
  FROM (
		 SELECT 
				  '계획합계' AS 사이즈
				--  , '' AS 라인코드
				--, A.LineCode AS 라인코드
				, '' AS 공정코드
				, '' AS 공정명
				, '' AS 용도
				, 기준년월	
				, CompanyCode	  
				, NULL AS 합계     	
				, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
				, SUM(Day31) AS Day31, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04
				, SUM(Day05) AS Day05, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09
				, SUM(Day10) AS Day10, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14
				, SUM(Day15) AS Day15, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19
				, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24
				, SUM(Day25) AS Day25
		FROM MEDIUM_PLAN A
		WHERE 1=1									  
			AND 기준년월 = @Month
			AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
			--AND 공정코드 IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')
			AND 공정코드 LIKE @RouteCode

			AND 사이즈 like @SizeCode
		GROUP BY 기준년월, A.CompanyCode
		UNION ALL

		 SELECT 
				  '실적합계' AS 사이즈
				 -- , '' AS 라인코드				
				, '' AS 공정코드
				, '' AS 공정명
				, '' AS 용도
				, 기준년월	
				, CompanyCode	  
				, NULL AS 합계     	
				, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
				, SUM(Day31) AS Day31, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04
				, SUM(Day05) AS Day05, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09
				, SUM(Day10) AS Day10, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14
				, SUM(Day15) AS Day15, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19
				, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24
				, SUM(Day25) AS Day25
		FROM MEDIUM_PROD A
		WHERE 1=1									  
			AND 기준년월 = @Month
			AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))  
			--AND RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28') 

			AND RouteCode LIKE @RouteCode

			AND 사이즈 like @SizeCode
		GROUP BY 기준년월, A.CompanyCode--, A.LineCode
		

		UNION ALL

---------------------------------- 세부현황부분

		   SELECT 사이즈
		      --  , 라인코드
				, 공정코드
				, 공정명
				, 용도
				, 기준년월	
				, CompanyCode	  
				, CASE WHEN 총합 = 0 THEN NULL ELSE 총합 END 합계      
				, Day26, Day27, Day28, Day29, Day30
				, Day31
				, Day01, Day02, Day03, Day04, Day05
				, Day06, Day07, Day08, Day09, Day10
				, Day11, Day12, Day13, Day14, Day15
				, Day16, Day17, Day18, Day19, Day20
				, Day21, Day22, Day23, Day24, Day25
		FROM (

					-- 1. 일일실적


					-- 기존거
					--SELECT  사이즈
					--		 , '일일실적(B)'  AS 용도
					--		 , 기준년월
					--		 --, A.LineCode   AS 라인코드
					--		 , A.RouteCode AS 공정코드
					--		 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.RouteCode) AS 공정명							
					--		 , A.CompanyCode		
					--		, 월누적수량 AS  총합			
					--		, Day26, Day27, Day28, Day29, Day30
					--		, Day31
					--		, Day01, Day02, Day03, Day04, Day05
					--		, Day06, Day07, Day08, Day09, Day10
					--		, Day11, Day12, Day13, Day14, Day15
					--		, Day16, Day17, Day18, Day19, Day20
					--		, Day21, Day22, Day23, Day24, Day25
					--	FROM MEDIUM_PROD   A   
					--   WHERE 1=1																									 				  
					--	  AND 기준년월 = @Month	                                                                                                 -- 원본 (삭제금지)
					--	 -- AND  기준년월 = '201909'                                                                                                 -- TEST용                          
					--	--  AND 사이즈 = '1320'                                                                                                        -- TEST용
					--	 AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   



						 SELECT  A.사이즈 AS 사이즈
								, '일일실적(B)'  AS 용도
								, MAX(A.기준년월)   AS 기준년월
								--, A.LineCode   AS 라인코드
								, MAX(A.RouteCode) AS 공정코드
								, (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.RouteCode) AS 공정명							
								, MAX(A.CompanyCode) AS CompanyCode
								, SUM(월누적수량) AS  총합			
								, SUM(Day26) AS Day26, SUM(Day27) AS Day27 , SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
								, SUM(Day31) AS Day31
								, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04, SUM(Day05) AS Day05
								, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09, SUM(Day10) AS Day10
								, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14, SUM(Day15) AS Day15
								, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19, SUM(Day20) AS Day20
								, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24, SUM(Day25) AS Day25
						FROM MEDIUM_PROD   A  
						-- 계획이 들어간 실적만 표시하기 위해 추가함. 2019.10.28 By Jackaroe
						INNER JOIN (SELECT 기준년월, 사이즈, 공정코드, CompanyCode, LineCode 
						              FROM MEDIUM_PLAN
									 GROUP BY 기준년월, 사이즈, 공정코드, CompanyCode, LineCode ) B
						   ON A.기준년월 = B.기준년월
						  AND A.CompanyCode = B.CompanyCode
						  AND A.사이즈 = B.사이즈
						  AND A.RouteCode = B.공정코드
						  AND A.LineCode = B.LineCode
					  WHERE 1=1																									 				  
						AND A.기준년월 = @Month	                                                                                                 -- 원본 (삭제금지)
						--AND  기준년월 = '201910'                                                                                                 -- TEST용                          
						--AND 사이즈 = '1840'                                                                                                        -- TEST용
						AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   
						GROUP BY  A.사이즈,  A.RouteCode
						--, A.LineCode


						  UNION  ALL				

						-- 2. 목표   
									--SELECT 
									--		 사이즈																						
									--		 , '목표(A)'  AS 용도
									--		 , 기준년월
									--		-- , A.LineCode AS 라인코드
									--		 , A.공정코드
									--		 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
									--		 , A.CompanyCode		
									--		  , A.월간계획    AS  총합				
									--		, Day26, Day27, Day28, Day29, Day30
									--		, Day31, Day01, Day02, Day03, Day04
									--		, Day05, Day06, Day07, Day08, Day09
									--		, Day10, Day11, Day12, Day13, Day14
									--		, Day15, Day16, Day17, Day18, Day19
									--		, Day20, Day21, Day22, Day23, Day24
									--		, Day25
									--FROM MEDIUM_PLAN A
									--WHERE 1=1									  
									--  AND 기준년월 = @Month	                                                                                                 -- 원본삭제금지
									--  --AND 기준년월 = '201909'
									--  --AND CompanyCode = 'VVT'
									-- -- AND 사이즈 = '1320'
									-- AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   


					 SELECT  A.사이즈 AS 사이즈
								, '목표(A)'  AS 용도
								, MAX(A.기준년월)   AS 기준년월
								--, A.LineCode   AS 라인코드
								, MAX(A.공정코드) AS 공정코드
								, (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명							
								, MAX(A.CompanyCode) AS CompanyCode
								, SUM(월간계획) AS  총합			
								, SUM(Day26) AS Day26, SUM(Day27) AS Day27 , SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
								, SUM(Day31) AS Day31
								, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04, SUM(Day05) AS Day05
								, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09, SUM(Day10) AS Day10
								, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14, SUM(Day15) AS Day15
								, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19, SUM(Day20) AS Day20
								, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24, SUM(Day25) AS Day25
						FROM MEDIUM_PLAN A
						WHERE 1=1									  
						  AND 기준년월 = @Month	                                                                                                 -- 원본삭제금지
						  --AND 기준년월 = '201909'
						  --AND CompanyCode = 'VVT'
						 -- AND 사이즈 = '1320'
						 AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
						 GROUP BY  A.사이즈,  A.공정코드



						 UNION  ALL

						 --3. 차이

						-- -- 기존거
      --        			SELECT 
						--		  A.사이즈																						
						--		 , '차이(B-A)'  AS 용도
						--		 , A.기준년월
						--		--  , A.LineCode AS 라인코드
						--		 , A.공정코드
						--		 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
						--		 , A.CompanyCode			
						--		  , 0 AS 총합
						--		 , B.Day26-A.Day26, B.Day27-A.Day27, B.Day28-A.Day28, B.Day29-A.Day29, B.Day30-A.Day30 , B.Day31-A.Day31
						--		 , B.Day01-A.Day01, B.Day02-A.Day02, B.Day03-A.Day03, B.Day04-A.Day04, B.Day05-A.Day05
						--		 , B.Day06-A.Day06, B.Day07-A.Day07, B.Day08-A.Day08, B.Day09-A.Day09, B.Day10-A.Day10
						--		 , B.Day11-A.Day11, B.Day12-A.Day12, B.Day13-A.Day13, B.Day14-A.Day14, B.Day15-A.Day15
						--		 , B.Day16-A.Day16, B.Day17-A.Day17, B.Day18-A.Day18, B.Day19-A.Day19, B.Day20-A.Day20
						--		 , B.Day21-A.Day21, B.Day22-A.Day22, B.Day23-A.Day23, B.Day24-A.Day24, B.Day25-A.Day25												 						 						 										
						--FROM MEDIUM_PLAN A
						-- LEFT OUTER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
						--												AND A.기준년월 = B.기준년월 
						--												AND A.공정코드 = B.RouteCode
						--												AND A.CompanyCode = B.CompanyCode
						--												AND A.LineCode =B.LineCode
						--WHERE 1=1		
						--	AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			
						-- -- AND A.기준년월 = '201909'															
						-- -- AND A.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 		
						----	AND A.사이즈 = '1320'
						----	AND A.CompanyCode = 'VVT'
						--AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   
						

						SELECT 
								  A.사이즈																						
								 , '차이(B-A)'  AS 용도
								 , MAX(A.기준년월) AS 기준년월
								--  , A.LineCode AS 라인코드
								, MAX(A.공정코드) AS 공정코드
								 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
								, MAX(A.CompanyCode) AS CompanyCode
								  , 0 AS 총합
								 , SUM(B.Day26)-SUM(A.Day26) AS Day26
								 , SUM(B.Day27)-SUM(A.Day27) AS Day27								 
								 , SUM(B.Day28)-SUM(A.Day28) AS Day28
								 , SUM(B.Day29)-SUM(A.Day29) AS Day29
								 , SUM(B.Day30)-SUM(A.Day30) AS Day30
								 , SUM(B.Day31)-SUM(A.Day31) AS Day31
								 , SUM(B.Day01)-SUM(A.Day01) AS Day01
								 , SUM(B.Day02)-SUM(A.Day02) AS Day02
								 , SUM(B.Day03)-SUM(A.Day03) AS Day03
								 , SUM(B.Day04)-SUM(A.Day04) AS Day04
								 , SUM(B.Day05)-SUM(A.Day05) AS Day05
								 , SUM(B.Day06)-SUM(A.Day06) AS Day06
								 , SUM(B.Day07)-SUM(A.Day07) AS Day07
								 , SUM(B.Day08)-SUM(A.Day08) AS Day08
								 , SUM(B.Day09)-SUM(A.Day09) AS Day09
								 , SUM(B.Day10)-SUM(A.Day10) AS Day10
								 , SUM(B.Day11)-SUM(A.Day11) AS Day11
								 , SUM(B.Day12)-SUM(A.Day12) AS Day12
								 , SUM(B.Day13)-SUM(A.Day13) AS Day13
								 , SUM(B.Day14)-SUM(A.Day14) AS Day14
								 , SUM(B.Day15)-SUM(A.Day15) AS Day15
								 , SUM(B.Day16)-SUM(A.Day16) AS Day16
								 , SUM(B.Day17)-SUM(A.Day17) AS Day17
								 , SUM(B.Day18)-SUM(A.Day18) AS Day18
								 , SUM(B.Day19)-SUM(A.Day19) AS Day19
								 , SUM(B.Day20)-SUM(A.Day20) AS Day20
								 , SUM(B.Day21)-SUM(A.Day21) AS Day21
								 , SUM(B.Day22)-SUM(A.Day22) AS Day22
								 , SUM(B.Day23)-SUM(A.Day23) AS Day23
								 , SUM(B.Day24)-SUM(A.Day24) AS Day24
								 , SUM(B.Day25)-SUM(A.Day25) AS Day25								 						 						 										
						FROM MEDIUM_PLAN A
						 LEFT OUTER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
																		AND A.기준년월 = B.기준년월 
																		AND A.공정코드 = B.RouteCode
																		AND A.CompanyCode = B.CompanyCode
																		-- group by 에서는 제외되더라도 테이블 간의 관계에서는 키가 됨. 2019.10.28 By Jackaroe
																		AND A.LineCode =B.LineCode 
						WHERE 1=1		
							AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			
						 -- AND A.기준년월 = '201909'															
						 -- AND A.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 		
						--	AND A.사이즈 = '1320'
						--	AND A.CompanyCode = 'VVT'
						AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   
						GROUP BY  A.사이즈,  A.공정코드





						UNION  ALL

						--- 4. Balance
      --        			SELECT 
						--		  A.사이즈																						
						--		, 'Balance'                                                                                              AS 용도
						--		, A.기준년월
						--		--, A.LineCode AS 라인코드
						--		, A.공정코드
						--		, (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
						--		, A.CompanyCode
    		--					, 0 AS 총합
						--		, B.Day26-A.Day26  
						--		, B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						--	, B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26  
						--	, B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   
						--	, B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						--	, B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						--	, B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						--	, B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   
						--	, B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						--	, B.Day25-A.Day25 + B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
								
						--FROM MEDIUM_PLAN A
						-- INNER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
						--		  AND A.기준년월 = B.기준년월 
						--		  AND A.공정코드 = B.RouteCode
						--		  AND A.CompanyCode = B.CompanyCode
						--		  AND A.LineCode =B.LineCode
						--WHERE 1=1						
						--  AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			
						-- --AND A.기준년월  = '201909'
						--  --  AND A.사이즈 = '1320'		
						-- --AND A.CompanyCode = 'VVT'
						-- AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   

						--- 4-2. Balance 
              			SELECT 
								  A.사이즈	AS 사이즈																					
								, 'Balance'                                                                                              AS 용도
								, MAX(A.기준년월) AS 기준년월
								--, A.LineCode AS 라인코드
								, A.공정코드
								, (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
								, MAX(A.CompanyCode) AS CompanyCode
    							, 0 AS 총합
								 ,SUM(B.Day26-A.Day26  )
								 ,SUM(B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 )
								 ,SUM(B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26  )
								 ,SUM(B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   )
								 ,SUM(B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 )
								 ,SUM(B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 )
								 ,SUM(B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 )
								 ,SUM(B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   )
								 ,SUM(B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								 ,SUM(B.Day25-A.Day25 + B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26)
								
						FROM MEDIUM_PLAN A
						 INNER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
								  AND A.기준년월 = B.기준년월 
								  AND A.공정코드 = B.RouteCode
								  AND A.CompanyCode = B.CompanyCode
								  AND A.LineCode =B.LineCode
						WHERE 1=1						
						   AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			
						 --AND A.기준년월  = '201909'
						  --  AND A.사이즈 = '1320'		
						 --AND A.CompanyCode = 'VVT'
						 AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   

						GROUP BY A.사이즈, A.CompanyCode, A.공정코드





		)  AA
		WHERE 1=1
		  AND 사이즈 like @SizeCode
		  AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
		  AND ((@RouteCode = '*') OR (공정코드 = @RouteCode)) 
		  AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   

 )  Ordering

--AND 기준년월 = '201905'
--AND 사이즈 = '1320'
--ORDER BY 사이즈, 용도, 공정코드, 
ORDER BY CASE WHEN 사이즈 = '계획합계' THEN '0'
              WHEN 사이즈 = '실적합계' THEN '00'
			  WHEN 사이즈 = '일별달성률' THEN '000'
			  ELSE 사이즈 END
        ,공정코드
		,용도


 END