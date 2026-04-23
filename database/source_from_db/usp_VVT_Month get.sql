-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째
--                   생산현황 > 입고생산현황 > 월생산현황      
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
-- ==================================================================

-- [프로시저 실행문]       EXEC "usp_VVT_Month get"   '', ''

CREATE PROC [dbo].[usp_VVT_Month get]
				
				@pSizeCode VARCHAR(20) = null,
				@pCompanyCode VARCHAR(20) = NULL                                           

AS

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    -- DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	--DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month VARCHAR(6) = CONVERT(VARCHAR(6), getdate(), 112)	
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 	




		SELECT 
				  SUM(BB.월간계획)                                                                                                                                                                            AS '월간생산계획 (PCS)'
				, SUM(AA.월누적수량)																																										   AS '누적생산수량 (PCS)'									
				, CASE WHEN MAX(BB.월간계획) = 0 THEN 0 ELSE CONVERT(NUMERIC(20,5), SUM(AA.월누적수량)) / CONVERT(NUMERIC(20,5), SUM(BB.월간계획)) * 100.0  END   AS '달성율 (%)'						
			FROM 
								(
									SELECT MAX(기준년월)        AS 기준년월
											, MAX(사이즈)           AS 사이즈
											, SUM(월누적수량)      AS 월누적수량
											, MAX(CompanyCode) AS CompanyCode											
									FROM MEDIUM_PROD
									WHERE 1=1
									   AND RouteCode IN ( 'E-28' , 'V-28')	
									   AND 사이즈  like @SizeCode  
									   --AND 기준년월 = '202001'	
									   --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 		     -- 원본백업 (26일부터 다음달 25일까지의 문제로)									   
									    AND 기준년월 = (
																 SELECT  Replace(BaseMonth, '-', '')		
																 FROM STB_AggregationPeriod
																WHERE 1=1									
																   AND  FromDate  <= @OneDay
																   AND  ToDate     >= @OneDay
										    				)
									   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                          -- 추가																		
									--GROUP BY 기준년월, 사이즈
								)  AA
								LEFT OUTER JOIN (
						                  				  SELECT MAX(기준년월) AS 기준년월
																, MAX(사이즈)   AS 사이즈
																, SUM(월간계획) AS 월간계획																		
															FROM MEDIUM_PLAN
															WHERE 1=1
																   AND 공정코드 IN ('E-28' , 'V-28')              -- 포장공정 실적으로 고정!!	
																   AND 사이즈 like @SizeCode  
																-- AND 기준년월 = '202001'	
																-- AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 																			
																   AND 기준년월 = (
																								SELECT  Replace(BaseMonth, '-', '')		
																								FROM STB_AggregationPeriod
																							WHERE 1=1									
																								AND  FromDate  <= @OneDay
																								AND  ToDate     >= @OneDay
										    											  )
																   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                 -- 추가																																				
													  ) BB
				ON AA.기준년월 = BB.기준년월 AND AA.사이즈 = BB.사이즈 
			WHERE 1=1
			   --AND AA.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
			   --AND AA.기준년월 = '202001'
			    AND AA.기준년월 = (
											SELECT  Replace(BaseMonth, '-', '')		
											FROM STB_AggregationPeriod
										  WHERE 1=1									
											AND  FromDate  <= @OneDay
											AND  ToDate     >= @OneDay
									      )
			   AND AA.사이즈   like @SizeCode  			   
			   AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가			 	
					
						 
 END