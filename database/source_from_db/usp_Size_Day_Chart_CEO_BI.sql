-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       : Power-BI 화면으로 구상중인데 현재는 사용안함.
-- Description : DB명 : [SmartFactoryV2]
-- Modified    :   
-- ==================================================================

-- [프로시저 실행문]       [usp_Size_Day_Chart_CEO_BI] '','','2019-10-30 00:00:00', '', 'VVT'

CREATE PROC [dbo].[usp_Size_Day_Chart_CEO_BI]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = null,
				@pCompanyCode VARCHAR(20) = NULL                                           

AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)
	--DECLARE @SizeCode             VARCHAR(8) = CASE WHEN @pSizeCode IS NULL THEN '%' WHEN @pSizeCode = '' THEN '%'  ELSE @pSizeCode END
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
    
	DECLARE @ToDay                VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                           -- 전일자 두자리                        SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 	
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                            -- 오늘날짜        ex) 2020-01-12    SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                       -- 어제날짜        ex) 20200111      SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	

-- 1. [전일실적-상세부분]


SELECT AA.사업장 AS 사업장
        , AA.파이            AS 파이
		, SUM(AA.생산계획) AS '일 생산계획 (PCS)'
		, SUM(AA.생산수량) AS '일 생산수량 (PCS)'
		, AVG(AA.달성율)            AS  '달성율 (%)'

FROM (
			SELECT CASE WHEN A.CompanyCode LIKE '%VNT%' THEN '전주본사' 
							 WHEN A.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장    
					--,  A.사이즈                                                                                       AS  사이즈
					, SUBSTRING(A.사이즈, 1, 2)                                                                   AS 파이 
					, SUM(A.Day01)                                                                                  AS 생산계획 --'일 생산계획 (PCS)'
					, SUM(B.Day01)                                                                                  AS 생산수량 --'일 생산수량 (PCS)'
					, CASE WHEN SUM(A.Day01) = 0 THEN 100.0 ELSE CONVERT(NUMERIC(20,1), SUM(B.Day01)) / CONVERT(NUMERIC(20,5), SUM(A.Day01) ) * 100.0  END   AS 달성율
			FROM MEDIUM_PLAN A
				   LEFT OUTER JOIN MEDIUM_PROD B  ON A.사이즈 = B.사이즈 AND A.CompanyCode = B.CompanyCode AND A.LineCode = B.LineCode  AND A.공정코드 = B.RouteCode	AND A.기준년월 = B.기준년월
			WHERE 1=1				
				AND A.공정코드 IN ('E-28', 'V-28')					  

				--AND A.기준년월 = '202001'			

			    AND A.기준년월 =  (                                                                                                      -- 2020.01.30 수정사항
													SELECT  Replace(BaseMonth, '-', '')		
													FROM STB_AggregationPeriod
												WHERE 1=1									
													AND  FromDate  <= @OneDay
													AND  ToDate     >= @OneDay
									)      


				--AND A.공정코드 IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = 'Route-28')			
				--AND A.사이즈 = '0813'
				--AND A.CompanyCode = 'VVT'

				--AND A.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
				AND A.사이즈   like @SizeCode  			   
				AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode))                                           --추가
			 
			GROUP BY  A.사이즈, A.CompanyCode
			--ORDER BY  A.사이즈, A.CompanyCode
		    -- 합계부분 제외

		 )  AA
		
GROUP BY AA.파이,  AA.사업장
ORDER BY AA.파이
			 
 END