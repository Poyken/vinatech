
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 생산관리 > [B155] 중형생산목표 > 중형생산일일계획 조회SQL
-- Description:	
-- Modified: 
--  2019.05.07 화면의 기준년월 데이터타입 DateTime으로 변경
-- =============================================
-- EXEC [usp_Medium_Plan_get] '','','2021-07-01','VVT','',''

CREATE PROCEDURE [dbo].[usp_Medium_Plan_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	--@pToMonth VARCHAR(06)
	@pToMonth Datetime,
	@pCompanyCode VARCHAR(20) = NULL,                                             -- kilee 추가 (2019.05.21)
	@pRouteCode VARCHAR(20) = NULL,                                                 -- 2019.05.21 추가
	@pSizeCode VARCHAR(05) = Null                                                     -- 2019.05.21 추가
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage    				
	DECLARE @ToMonth             VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')                                   -- 금일 6자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2019-05-17 08:30:00', 121), 1, 7), '-', '')     --> '201905'
	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @SizeCode    VARCHAR(8)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode    END

--  EXEC  [usp_Medium_Plan_get]  '', '', '2019-05-21 00:00:01'


--SELECT *
SELECT CompanyCode 
         , Case When CompanyCode = 'VNT' THEN '비나텍'
		         When CompanyCode = 'VVT' THEN '비나텍(베트남)' ELSE '기타' END AS CompanyName
         , 기준년월
         , 사이즈
		 , 공정코드
		 , (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = MP.공정코드)  AS 공정명
		 --, 월간계획
		 --, (Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10+Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31) AS 월간계획
		 , Case When MP.월간계획 = NULL or MP.월간계획 = 0 or MP.월간계획 = '' THEN (Day01+Day02+Day03+Day04+Day05+Day06+Day07+Day08+Day09+Day10+Day11+Day12+Day13+Day14+Day15+Day16+Day17+Day18+Day19+Day20+Day21+Day22+Day23+Day24+Day25+Day26+Day27+Day28+Day29+Day30+Day31) 
		                  ELSE 월간계획                                                               END 월간계획
		 , Day26,	Day27, Day28, Day29, Day30, Day31, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, Day20, Day21, Day22, Day23, Day24, Day25
		 , 특이사항
		 , LineCode 
		 , MP.Target_Defect_Price                   -- 2020.03.17 추가 (kilee)
		 , MP.PlanQty AS PlanQty
FROM MEDIUM_PLAN MP
WHERE 1=1
   AND 기준년월 LIKE @ToMonth + '%'
  --AND 기준년월 = '201909'
   AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode)) 
   AND ((@RouteCode = '*')     OR (MP.공정코드 = @RouteCode)) 
   AND 사이즈 LIKE @SizeCode
ORDER BY 사이즈, LineCode


END

