-- ==================================================================
-- Author      : kilee
-- Create date : 2019-12-13
-- Browsable   : true
-- Group       :  Power-BI 모니터링 화면 > 전일 생산목표대비 실적부분
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    :  전일 생산목표대비 실적
--                   2019-12-18 년월추가
--                   2020-01-14 기준년월 수정 : STB_AggregationPeriod 테이블 사용
--                   2020-01-29 피봇테이블이용 쿼리 수정 : 기준년월 부분 수정

-- [프로시저 실행문]  usp_VVT_Day_Total_get  '', '', '2020-07-26', '', 'VNT'    -- 베트남에서 개발한 문제로 VNT로 실행해야 내 Power-BI화면이 적용됨
-- =========================================================================================================
CREATE PROC [dbo].[usp_VVT_Day_Total_get]
				@pProcessUserID     Varchar(20),
				@pProcessLanguage Varchar(20),
				@pMonth              DateTime,
				@pSizeCode           Varchar(20) = null,
				@pCompanyCode    Varchar(20) = null                                           
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month				  VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)	
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                -- 전일자 두자리               SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 	
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')      -- 어제날짜   ex) 20200111   SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	
	DECLARE @OneDay				  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')      -- 오늘날짜   ex) 20200112   SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11), '-', '')  	 	


 -- 2. 피봇테이블 이용한 수정SQL (2020.01.21 적용)  

				 SELECT 	
						   SUM(ISNULL(AA.수량, 0))																																																	  AS '일 생산계획 (PCS)'   
						  , SUM(ISNULL(BB.수량, 0))																																																	  AS '일 생산수량 (PCS)'			
						  , CASE WHEN SUM(ISNULL(AA.수량, 0)) = 0 THEN 100 ELSE   CONVERT(NUMERIC(20,1),  SUM(ISNULL(BB.수량, 0))) / CONVERT(NUMERIC(20,5),  SUM(ISNULL(AA.수량, 0)) ) * 100.0	END  	  AS '달성율 (%)'		  
						  , SUBSTRING(@YesterDay, 0, 5)    + '-' + SUBSTRING(@YesterDay, 5, 2)     + '-' + @ToDay                                                                                                                    AS 일자    		    -- 2020.01.29 추가사항
						  , CASE WHEN SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2) < 27   THEN SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 6, 2) + ' 월'                                                                    -- 26일보다 작은면 이번달, 같거나 크면 다음달 
								   WHEN SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2) >= 27 THEN SUBSTRING(CONVERT(VARCHAR(10), DateAdd(MM,1, GetDate()), 121), 6, 2) + ' 월'  ELSE '' END    AS 월       	      
				FROM 		 
						( 
						 SELECT 기준년월
								,사이즈
								,공정코드 AS 공정코드					
								,수량
								, CompanyCode
								, LineCode
						  FROM MEDIUM_PLAN
								 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																	   ,Day06, Day07, Day08, Day09, Day10
																	   ,Day11, Day12, Day13, Day14, Day15
																	   ,Day16, Day17, Day18, Day19, Day20
																	   ,Day21, Day22, Day23, Day24, Day25
																	   ,Day26, Day27, Day28, Day29, Day30
																	   ,Day31)
								) AS UPT
						WHERE 1=1					   					 
								AND 기준년월 =  (                                                                                                      -- 2020.01.13 문제점 해결
															SELECT  Replace(BaseMonth, '-', '')		
															FROM STB_AggregationPeriod
														WHERE 1=1									
															AND  FromDate  <= @OneDay
															AND  ToDate     >= @OneDay
														)      
								 AND  RIGHT(기준일,2)  = @ToDay					
						  )  AA

						  LEFT OUTER JOIN 
						  ( 
						   SELECT 기준년월
									,사이즈
									, RouteCode AS 공정코드					
								   , RIGHT(기준일,2)  AS 기준일
									,수량
									, CompanyCode
									, LineCode
								  FROM MEDIUM_PROD
								 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																	   ,Day06, Day07, Day08, Day09, Day10
																	   ,Day11, Day12, Day13, Day14, Day15
																	   ,Day16, Day17, Day18, Day19, Day20
																	   ,Day21, Day22, Day23, Day24, Day25
																	   ,Day26, Day27, Day28, Day29, Day30
																	   ,Day31)
								) AS UPT	
							WHERE 1=1					   			
								AND 기준년월 =  (                                                                                                      -- 2020.01.30 수정사항
															SELECT  Replace(BaseMonth, '-', '')		
															FROM STB_AggregationPeriod
														WHERE 1=1									
															AND  FromDate  <= @OneDay
															AND  ToDate     >= @OneDay
														)      
								  AND  RIGHT(기준일,2)  = @ToDay			      

						  )  BB  on AA.기준년월 = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

				WHERE 1=1
				  AND AA.공정코드= 'V-28'                        --- 베트남 포장공정
				  AND AA.CompanyCode = 'VVT'                  ---  베트남만		  
				  AND AA.기준년월 =  (                                                                                                      -- 2020.01.30 수정사항
															SELECT  Replace(BaseMonth, '-', '')		
															FROM STB_AggregationPeriod
														WHERE 1=1									
															AND  FromDate  <= @OneDay
															AND  ToDate     >= @OneDay
														)      		 
				  AND RIGHT(기준일,2) =@ToDay      		 
			   GROUP BY AA.기준년월      


END  