-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B602] 사이즈별 생산현황 > Grid 첫번째
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 
--                     2019-11-23 사이즈별 생산현황 Total부분               
-- ==================================================================

-- [프로시저 실행문]   
-- Exec usp_Medium_Total @pProcessUserID='kilee2',@pProcessLanguage='Korean',@pMonth='2020-09-09 00:00:00',@pSizeCode=default,@pCompanyCode='VVT',@pRouteCode=default
-- Exec usp_Medium_Total @pProcessUserID='kilee2',@pProcessLanguage='Korean',@pMonth='2020-09-09 00:00:00',@pSizeCode=default,@pCompanyCode='VVT',@pRouteCode='V-28'


CREATE PROC [dbo].[usp_Medium_Total] 
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = NULL,
				@pCompanyCode VARCHAR(20) = NULL,                                             -- 사업장코드 kilee 추가 (2019.09.26)
				@pRouteCode VARCHAR(20) = NULL                                                 -- 공정코드 추가 kilee 추가 (2019.11.23)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month               VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)                                  -- Select CONVERT(VARCHAR(6), '2020-09-09 00:00:00', 112)  
	--DECLARE @Month               VARCHAR(7) = REPLACE(CONVERT(VARCHAR(7), @pMonth, 112), '-', '')                -- Select REPLACE(CONVERT(VARCHAR(7), '2020-09-09 00:00:00', 112), '-', '')  
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN @pSizeCode IS NULL THEN '%' ELSE @pSizeCode END
	DECLARE @RouteCode           VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END             -- 공정코드 추가 kilee 추가 (2019.11.23)       


	SELECT   CASE WHEN AA.ComPanyCode = 'VNT' THEN '전주본사'
	                   WHEN AA.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장                    
			,  AA.사이즈      AS 사이즈			
			, (SELECT SR.RouteName FROM STB_RouteInfo SR WHERE  SR.RouteCode = AA.RouteCode) AS 공정명
			, BB.월간계획    AS '월간생산계획 (PCS)'
			, AA.월누적수량 AS '누적생산수량 (PCS)'						
			, CASE WHEN BB.월간계획 = 0 THEN 0 ELSE 	CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0  END  AS '달성율 (%)'
			, BB.특이사항                                                                                                                                                               AS 특이사항

			--, BB.기준년월
			--, BB.LineCode
	FROM 
			(
							SELECT 기준년월
								    , 사이즈								
								    , SUM(월누적수량) AS 월누적수량
									, RouteCode        AS  RouteCode                                         -- 추가
									, CompanyCode    
									, LineCode
							FROM MEDIUM_PROD
							WHERE 1=1							   
							   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
							   AND RouteCode  LIKE @RouteCode	                                                     -- 추가
							   AND 기준년월      = @Month
							GROUP BY 기준년월, 사이즈, RouteCode, CompanyCode,  LineCode 
			) AA
						LEFT OUTER JOIN (
														SELECT 기준년월
																, 사이즈															
																, SUM(월간계획) AS 월간계획		
																, 특이사항	
																, 공정코드
																, CompanyCode
																, LineCode
														FROM MEDIUM_PLAN
														WHERE 1=1													
														  AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))   
														  AND 공정코드  LIKE @RouteCode	                                                     -- 추가
														  AND 기준년월      = @Month
														GROUP BY 기준년월, 사이즈, 특이사항, 공정코드, CompanyCode, LineCode
													) BB		
		ON AA.기준년월 = BB.기준년월  AND AA.사이즈 = BB.사이즈 AND AA.RouteCode = BB.공정코드  AND AA.CompanyCode = BB.CompanyCode  AND AA.LineCode = BB.LineCode

	WHERE 1=1		
		AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))   
		AND AA.기준년월      = @Month
		AND AA.RouteCode  LIKE @RouteCode	                                                     -- 추가
		AND AA.사이즈        LIKE   @SizeCode                                                     -- 추가

	ORDER BY       AA.사이즈            
			 
			 

 END