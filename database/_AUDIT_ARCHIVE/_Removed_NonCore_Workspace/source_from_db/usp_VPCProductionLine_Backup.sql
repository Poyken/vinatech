-- ==================================================================
-- Author      : Kangs (kilee@vina.co.kr)
-- Create date : 2022-03-10
-- Browsable   : True
-- Group       :  생산현황 > [B602] VPC생산현황
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 
-- 201910.10  LineCode 추가

-- [프로시저 실행문]  :     usp_VPCProductionLine @pProcessUserID='', @pProcessLanguage='',@pMonth='2022-03-10',@pCompanyCode = 'VNT'  , @pRouteCode = 'E-22'
-- =============================================================================================================================

Create PROC [dbo].[usp_VPCProductionLine_Backup] 		
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),			
				@pMonth DateTime,
				@pCompanyCode VARCHAR(20) = 'VNT',                                             -- 사업장코드 kilee 추가 (2019.05.21)				
				@pRouteCode VARCHAR(20) = NULL                                                  -- 2019.05.21 공정코드 추가	
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage  

	DECLARE @Month                VARCHAR(19) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 9), '-', '')                                         -- SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), '2019-09', 121), 0, 9), '-', '')
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @RouteCode          VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END	 

 --  [주 쿼리부분]  *****************************************************************************************************************************************************  [합계부분]  + [라인별로]


 SELECT  RouteCode
		, RouteName
        , 용도
		, LineCode
		 , LineName
		, BaseMonth	
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

				-- 1.  누계부분
					SELECT 
						 '' AS RouteCode
						, '누계' AS RouteName						
						, '' AS LineCode
						, '' AS LineName
						, '' AS 용도
						, BaseMonth	
						, CompanyCode	  
						, NULL AS 합계     	
						, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
						, SUM(Day31) AS Day31, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04
						, SUM(Day05) AS Day05, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09
						, SUM(Day10) AS Day10, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14
						, SUM(Day15) AS Day15, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19
						, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24
						, SUM(Day25) AS Day25
				FROM VPC_Performance A
				WHERE 1=1									  
					AND BaseMonth = @Month
					AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
					AND RouteCode LIKE @RouteCode			
				GROUP BY BaseMonth, A.CompanyCode

				UNION ALL


				-- 1-2. 
				--	SELECT 
				--			'' AS RouteCode
				--		, '' AS RouteName
				--		, '' AS 용도
				--		, BaseMonth	
				--		, CompanyCode	  
				--		, NULL AS 합계     	
				--		, SUM(Day26) AS Day26, SUM(Day27) AS Day27, SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
				--		, SUM(Day31) AS Day31, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04
				--		, SUM(Day05) AS Day05, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09
				--		, SUM(Day10) AS Day10, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14
				--		, SUM(Day15) AS Day15, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19
				--		, SUM(Day20) AS Day20, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24
				--		, SUM(Day25) AS Day25
				--FROM VPC_Performance A
				--WHERE 1=1									  
				--	AND BaseMonth = @Month
				--	AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))  
				--	AND RouteCode LIKE @RouteCode
				--GROUP BY BaseMonth
				--            , A.CompanyCode
				--		 -- , A.LineCode
		
				--UNION ALL

			   -- 2. 라인별현황부분

				   SELECT  RouteCode
						, RouteName
						, LineCode
						, LineName
						, 용도
						, BaseMonth	
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

							-- 2-1. 실적부분
								 SELECT  '일일실적(B)'  AS 용도
										, A.BaseMonth   AS BaseMonth
										, A.RouteCode AS RouteCode
										, A.LineCode   AS LineCode
										, SL.LineName AS LineName
										, (SELECT SR.RouteName FROM STB_RouteInfo  SR WHERE SR.RouteCode = A.RouteCode) AS RouteName							
										, MAX(A.CompanyCode) AS CompanyCode
										, SUM(TotalQty) AS  총합			
										, SUM(Day26) AS Day26, SUM(Day27) AS Day27 , SUM(Day28) AS Day28, SUM(Day29) AS Day29, SUM(Day30) AS Day30
										, SUM(Day31) AS Day31
										, SUM(Day01) AS Day01, SUM(Day02) AS Day02, SUM(Day03) AS Day03, SUM(Day04) AS Day04, SUM(Day05) AS Day05
										, SUM(Day06) AS Day06, SUM(Day07) AS Day07, SUM(Day08) AS Day08, SUM(Day09) AS Day09, SUM(Day10) AS Day10
										, SUM(Day11) AS Day11, SUM(Day12) AS Day12, SUM(Day13) AS Day13, SUM(Day14) AS Day14, SUM(Day15) AS Day15
										, SUM(Day16) AS Day16, SUM(Day17) AS Day17, SUM(Day18) AS Day18, SUM(Day19) AS Day19, SUM(Day20) AS Day20
										, SUM(Day21) AS Day21, SUM(Day22) AS Day22, SUM(Day23) AS Day23, SUM(Day24) AS Day24, SUM(Day25) AS Day25
								FROM VPC_Performance   A  
								-- 계획이 들어간 실적만 표시하기 위해 추가함. 2019.10.28 By Jackaroe
								--INNER JOIN (SELECT BaseMonth,  RouteCode, CompanyCode, LineCode 
								--              FROM MEDIUM_PLAN
								--			 GROUP BY BaseMonth,  공정코드, CompanyCode, LineCode ) B
								--   ON A.BaseMonth = B.BaseMonth
								--  AND A.CompanyCode = B.CompanyCode						 
								--  AND A.RouteCode = B.RouteCode
								--  AND A.LineCode = B.LineCode
								 Left Outer Join STB_LineInfo SL On SL.LineCode = A.LineCode
							  WHERE 1=1																									 				  
								AND A.BaseMonth = @Month	                                                                                                 -- 원본 (삭제금지)	
								AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))   					
								--AND A.BaseMonth = '202203'                                                                                               -- 원본 (삭제금지)						
								--AND A.CompanyCode = 'VNT'
								GROUP BY  A.RouteCode,  A.BaseMonth  
										, A.RouteCode 
										, A.LineCode   
										, SL.LineName 								

				)  AA

				WHERE 1=1		
					AND BaseMonth = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @Month , 121), 0, 8), '-', '') 	
					AND ((@RouteCode = '*') OR (RouteCode = @RouteCode)) 
					AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   

			)  Ordering

ORDER BY			  
			   CASE  WHEN RouteCode = 'E-22' THEN '01'
                 WHEN RouteCode = 'E-24' THEN '02'
                 WHEN RouteCode = 'E-29' THEN '03' 
                 WHEN RouteCode = 'E-33' THEN '04'
                 WHEN RouteCode = 'E-34' THEN '05'
				 WHEN RouteCode = 'E-28' THEN '06'
                    ELSE '99' END
 END