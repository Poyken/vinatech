-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-02
-- Browsable   : true
-- Group       :  생산현황 > [B752] 중형생산현황 > Grid 두번째
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    :  중형생산현황
-- ==================================================================



-- [프로시저 실행문]  usp_Medium_Production_Line_CEO   @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMonth='2019-09-20', @pCompanyCode = '', @pSizeCode='1030L',  @pRouteCode=default

CREATE PROC [dbo].[usp_Medium_Production_Line_CEO_j] 		
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),				
				@pMonth DateTime,
				@pCompanyCode VARCHAR(20) = NULL,                                             -- 사업장코드 kilee 추가 (2019.05.21)
				@pSizeCode VARCHAR(05) = Null,                                                     --  2019.05.21 사이즈 추가    
				@pRouteCode VARCHAR(20) = NULL                                                  -- 2019.05.21 공정코드 추가	
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage  	
	DECLARE @Month                VARCHAR(19) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 9), '-', '')                                         -- SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), '2019-09', 121), 0, 9), '-', '')
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @SizeCode             VARCHAR(8) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	DECLARE @RouteCode          VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END	 	
		

 --  [주 쿼리부분]  *****************************************************************************************************************************************************  [합계부분]  + [라인별로]

SELECT 사업장
        , 사이즈
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
			SELECT 
			            CASE WHEN A.CompanyCode = 'VNT' THEN '전주본사' 
	                            WHEN A.CompanyCode = 'VVT' THEN '베트남' 
								WHEN A.CompanyCode IS NULL AND A.사이즈 IS NULL THEN '총합계' ELSE '소계' END AS 사업장   
			          , 사이즈
			         , CASE WHEN A.CompanyCode IS NULL THEN NULL ELSE '일일실적(B)' END  AS 용도
					 , MAX(기준년월) AS 기준년월
					 , MAX(A.RouteCode) AS 공정코드
					 , MAX(B.RouteName) AS 공정명					
					, A.CompanyCode		
					, CASE WHEN A.CompanyCode IS NULL THEN NULL ELSE MAX(월누적수량) END AS  총합			
					, SUM(Day26) AS Day26
					, SUM(Day27) AS Day27
					, SUM(Day28) AS Day28
					, SUM(Day29) AS Day29
					, SUM(Day30) AS Day30
					, SUM(Day31) AS Day31
					, SUM(Day01) AS Day01
					, SUM(Day02) AS Day02
					, SUM(Day03) AS Day03
					, SUM(Day04) AS Day04
					, SUM(Day05) AS Day05
					, SUM(Day06) AS Day06
					, SUM(Day07) AS Day07
					, SUM(Day08) AS Day08
					, SUM(Day09) AS Day09
					, SUM(Day10) AS Day10
					, SUM(Day11) AS Day11
					, SUM(Day12) AS Day12
					, SUM(Day13) AS Day13
					, SUM(Day14) AS Day14
					, SUM(Day15) AS Day15
					, SUM(Day16) AS Day16
					, SUM(Day17) AS Day17
					, SUM(Day18) AS Day18
					, SUM(Day19) AS Day19
					, SUM(Day20) AS Day20
					, SUM(Day21) AS Day21
					, SUM(Day22) AS Day22
					, SUM(Day23) AS Day23
					, SUM(Day24) AS Day24
					, SUM(Day25) AS Day25
				FROM MEDIUM_PROD   A     -- 일별실적
			    LEFT OUTER JOIN STB_RouteInfo B
			      ON A.RouteCode = B.RouteCode
			   WHERE 1=1																									 				  
				  AND 기준년월 = @Month
				  AND A.RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')
			   GROUP BY ROLLUP(
					사이즈
				   ,A.CompanyCode
				)
				  UNION  ALL				

				-- 2. 목표   
				SELECT  CASE WHEN A.CompanyCode = 'VNT' THEN '전주본사' 
	                            WHEN A.CompanyCode = 'VVT' THEN '베트남'   ELSE '기타' END AS 사업장   
			          , 사이즈																					
						 , '목표(A)'  AS 용도
						 , 기준년월
						 , A.공정코드
						 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
						 , A.CompanyCode		
						  , A.월간계획    AS  총합				
						, Day26, Day27, Day28, Day29, Day30
						, Day31, Day01, Day02, Day03, Day04
						, Day05, Day06, Day07, Day08, Day09
						, Day10, Day11, Day12, Day13, Day14
						, Day15, Day16, Day17, Day18, Day19
						, Day20, Day21, Day22, Day23, Day24
						, Day25
				FROM MEDIUM_PLAN A
				WHERE 1=1									  
				  AND 기준년월 = @Month	                                                                                                 -- 원본삭제금지

				 UNION  ALL

				 --3. 차이
              	SELECT  CASE WHEN A.CompanyCode = 'VNT' THEN '전주본사' 
	                            WHEN A.CompanyCode = 'VVT' THEN '베트남'   ELSE '기타' END AS 사업장   
			             , A.사이즈																				
						 , '차이(B-A)'  AS 용도
						 , A.기준년월
						 , A.공정코드
						 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
						 , A.CompanyCode			
						  , 0 AS 총합
						 , B.Day26-A.Day26, B.Day27-A.Day27, B.Day28-A.Day28, B.Day29-A.Day29, B.Day30-A.Day30 , B.Day31-A.Day31
						 , B.Day01-A.Day01, B.Day02-A.Day02, B.Day03-A.Day03, B.Day04-A.Day04, B.Day05-A.Day05
						 , B.Day06-A.Day06, B.Day07-A.Day07, B.Day08-A.Day08, B.Day09-A.Day09, B.Day10-A.Day10
						 , B.Day11-A.Day11, B.Day12-A.Day12, B.Day13-A.Day13, B.Day14-A.Day14, B.Day15-A.Day15
						 , B.Day16-A.Day16, B.Day17-A.Day17, B.Day18-A.Day18, B.Day19-A.Day19, B.Day20-A.Day20
						 , B.Day21-A.Day21, B.Day22-A.Day22, B.Day23-A.Day23, B.Day24-A.Day24, B.Day25-A.Day25												 						 						 									
				FROM MEDIUM_PLAN A
				 LEFT OUTER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
																AND A.기준년월 = B.기준년월 
																AND A.공정코드 = B.RouteCode
																AND A.CompanyCode = B.CompanyCode
				WHERE 1=1		
				    AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			

                UNION  ALL

				--- 4. Balance
              	SELECT 
						  CASE WHEN A.CompanyCode = 'VNT' THEN '전주본사' 
	                            WHEN A.CompanyCode = 'VVT' THEN '베트남'   ELSE '기타' END AS 사업장   
			            , A.사이즈																					
						 , 'Balance'  AS 용도
						 , A.기준년월
						 , A.공정코드
						 , (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.공정코드) AS 공정명
						 , A.CompanyCode
    					 , 0 AS 총합
						 , B.Day26-A.Day26  
						 , B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						, B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26  
						, B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   
						, B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						, B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						, B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26 
						, B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26   
						, B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26
						, B.Day25-A.Day25 + B.Day24-A.Day24 + B.Day23-A.Day23 + B.Day22-A.Day22 + B.Day21-A.Day21 + B.Day20-A.Day20 + B.Day19-A.Day19 + B.Day18-A.Day18 + B.Day17-A.Day17 + B.Day16-A.Day16 + B.Day15-A.Day15 + B.Day14-A.Day14 + B.Day13-A.Day13 + B.Day12-A.Day12 + B.Day11-A.Day11 + B.Day10-A.Day10 + B.Day09-A.Day09 + B.Day08-A.Day08 + B.Day07-A.Day07 + B.Day06-A.Day06 + B.Day05-A.Day05 + B.Day04-A.Day04 + B.Day03-A.Day03 + B.Day02-A.Day02 + B.Day01-A.Day01 + B.Day31-A.Day31 + B.Day30-A.Day30 + B.Day29-A.Day29 + B.Day28-A.Day28 + B.Day27-A.Day27 + B.Day26-A.Day26

					
				FROM MEDIUM_PLAN A
				 INNER JOIN  MEDIUM_PROD B ON A.사이즈 = B.사이즈 
				          AND A.기준년월 = B.기준년월 
						  AND A.공정코드 = B.RouteCode
						  AND A.CompanyCode = B.CompanyCode
				WHERE 1=1						
				  AND A.기준년월 = @Month	                                                                                                 -- 원본삭제금지			
)  AA
WHERE 1=1
  AND 사이즈 like @SizeCode  
  AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
  AND 공정코드 IN ('E-28', 'V-28')
ORDER BY 사이즈
        ,CASE WHEN 사업장 = '소계' THEN '힣' ELSE 사업장 END
		,공정코드
		,용도


 END