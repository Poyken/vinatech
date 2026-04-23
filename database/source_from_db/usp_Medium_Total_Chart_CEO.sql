-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
-- ==================================================================

-- [프로시저 실행문]        usp_Medium_Total_Chart_CEO '','','2020-07-02 00:00:00', '', ''

CREATE PROC [dbo].[usp_Medium_Total_Chart_CEO]
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
	DECLARE @SizeCode             VARCHAR(8) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 11)                                                     -- 2020.02.27 수정  


	SELECT  CASE WHEN BB.CompanyCode LIKE '%VNT%' THEN '전주본사' 
	                   WHEN BB.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장                
			 , AA.사이즈                                                                                               AS 사이즈
			, ISNULL(BB.월간계획, 1)                                                                               AS '월간생산계획 (PCS)'
			, ISNULL(AA.월누적수량, 1)                                                                            AS '누적생산수량 (PCS)'									
			, CASE WHEN BB.월간계획 = 0 THEN 0 ELSE CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0  END  AS '달성율 (%)'			
			, (SELECT COMMENT FROM PROD_Comment PC  WHERE PC.사이즈 = AA.사이즈 AND PC.CompanyCode = AA.CompanyCode)                      AS Comment
			, AA.CompanyCode                                                                                                                                                                 AS CompanyCode
	FROM 
						(	SELECT 기준년월
								    , 사이즈								
								    , SUM(ISNULL(월누적수량,0)) AS 월누적수량
									, CompanyCode
							FROM MEDIUM_PROD
							WHERE 1=1
							   AND RouteCode IN ( 'E-28' , 'V-28')	
											  
							GROUP BY 기준년월, 사이즈, CompanyCode
							             --, LINECODE,
						) AA
						LEFT OUTER JOIN (
														SELECT 기준년월
																, 사이즈															
																, SUM(ISNULL(월간계획,0)) AS 월간계획		
																, MAX(특이사항) AS 특이사항
																, CompanyCode
														FROM MEDIUM_PLAN
														WHERE 1=1
														   AND 공정코드 IN ('E-28' , 'V-28')              -- 포장공정 실적으로 고정!!		
														GROUP BY 기준년월, 사이즈,  CompanyCode														       
													) BB

		   ON AA.기준년월 = BB.기준년월	   AND AA.사이즈 = BB.사이즈 
	   AND AA.CompanyCode = BB.CompanyCode
	WHERE 1=1	  
	      AND AA.기준년월 = (
												SELECT  Replace(BaseMonth, '-', '')		
												FROM STB_AggregationPeriod
											WHERE 1=1									
												AND  FromDate  <= @OneDay
												AND  ToDate     >= @OneDay
										)

	   AND AA.사이즈  like @SizeCode  
	   AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가


	-- 1. 사이즈별 상세부분
	--SELECT  CASE WHEN BB.CompanyCode LIKE '%VNT%' THEN '전주본사' 
	--                  WHEN BB.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장                
	--		 , AA.사이즈                                                                                        AS 사이즈
	--		, BB.월간계획                                                                                       AS '월간생산계획 (PCS)'
	--		, AA.월누적수량                                                                                    AS '누적생산수량 (PCS)'									
	--		, CASE WHEN BB.월간계획 = 0 THEN 0 ELSE CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0  END  AS '달성율 (%)'			
	--		, (SELECT  COMMENT FROM PROD_Comment PC  WHERE PC.사이즈 = AA.사이즈 AND PC.CompanyCode = AA.CompanyCode)                     AS Comment
	--		, AA.CompanyCode                                            AS CompanyCode
	--FROM 
	--					(
	--						SELECT 기준년월
	--							    , 사이즈								
	--							    , SUM(월누적수량) AS 월누적수량
	--								, CompanyCode
					
	--						FROM MEDIUM_PROD
	--						WHERE 1=1
	--						   AND RouteCode IN ( 'E-28' , 'V-28')	
	--						   -- AND 사이즈 = '0820' AND 기준년월 = '201910'						  
	--						GROUP BY 기준년월, 사이즈,  CompanyCode
	--						             --, LINECODE,
	--					) AA
	--					LEFT OUTER JOIN (
	--													SELECT 기준년월
	--															, 사이즈															
	--															, SUM(월간계획) AS 월간계획		
	--															, MAX(특이사항) AS 특이사항
	--															, CompanyCode																
	--													FROM MEDIUM_PLAN
	--													WHERE 1=1
	--													   AND 공정코드 IN ('E-28' , 'V-28')              -- 포장공정 실적으로 고정!!		
	--													   --AND 사이즈 = '0820' AND 기준년월 = '201910'
	--													GROUP BY 기준년월, 사이즈, 특이사항,  CompanyCode
	--													             --LINECODE,
	--												) BB
	--	ON AA.기준년월 = BB.기준년월
	--   AND AA.사이즈 = BB.사이즈 
	--   --AND AA.LineCode = BB.LineCode
	--   AND AA.CompanyCode = BB.CompanyCode
	--WHERE 1=1	  
	--   --AND  AA. 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
	--   AND AA.사이즈  like @SizeCode  	   
	--   AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가

	--   --AND  AA. 기준년월 = '202003'

	--     AND AA.기준년월 = (
	--											SELECT  Replace(BaseMonth, '-', '')		
	--											FROM STB_AggregationPeriod
	--										WHERE 1=1									
	--											AND  FromDate  <= @OneDay
	--											AND  ToDate     >= @OneDay
	--									)

	--   --AND AA.사이즈  = '0820'
	----ORDER BY   BB.CompanyCode, AA.사이즈      


	
			 
			 
 END