
-- =============================================
-- Author:	   kilee@vina.co.kr
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B590] 월별생산현황관리
-- Description:	
-- Modified: 
--              2020.05.07 사업장코드 추가 
--              2020.08.27 법인 IT 소스는 다른 프로시저(usp_VNM_ProdSummary20200827_get) 백업!

-- 프로시저 실행문 : EXEC usp_VNM_ProdSummary_get '','','2020-08-27 18:00:00'
-- =======================================================================

CREATE PROCEDURE [dbo].[usp_VNM_ProdSummary_get]
		@pProcessUserID     VARCHAR(20),
		@pProcessLanguage VARCHAR(20),		
		@pToMonth           DateTime,
		@pRouteCode         VARCHAR(20) = NULL,            -- 2019.05.21 공정코드 추가
		@pSizeCode           VARCHAR(04) = NULL,            -- 2019.05.21 사이즈 추가
		@pCompanyCode     VARCHAR(20) = NULL            -- 2020.05.07 사업장코드 kilee 추가 
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage    				
	DECLARE @ToMonth            VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')          -- 금일 6자리    SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2020-05-17 08:30:00', 121), 1, 7), '-', '')     --> '202005'
	DECLARE @RouteCode          VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @SizeCode             VARCHAR(8)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode    END
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
		

	SELECT MP.기준년월
			, MP.사이즈
			, MP.RouteCode
			, (SELECT A.RouteName FROM STB_RouteInfo A  WHERE A.RouteCode = MP.RouteCode) AS RouteName
			, MP.월누적수량
			, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10
			, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, Day20
			, Day21, Day22, Day23, Day24, Day25, Day26, Day27, Day28, Day29, Day30, Day31
			, MP.CompanyCode  AS CompanyCode
			, MP.LineCode 
	FROM MEDIUM_PROD  MP
	WHERE 1=1
	   AND MP.기준년월 LIKE @ToMonth + '%'
	-- AND MP.CompanyCode = 'VVT'                                                                        -- 베트남 사업자코드 (원본백업)
	   AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode))                     -- 사업장코드 조건추가 (2020.05.07)
	   AND ((@RouteCode = '*')     OR (MP.RouteCode = @RouteCode)) 
	   AND 사이즈                     Like @SizeCode
	ORDER BY MP.사이즈

END