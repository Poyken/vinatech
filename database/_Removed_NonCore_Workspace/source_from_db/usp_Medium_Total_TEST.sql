-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
-- ==================================================================

-- [프로시저 실행문]   EXEC [usp_Medium_Total] '' , '' , '2019-04' , '1080'                                            ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  
-- EXEC [usp_Medium_Total] '' , '' , '2019-09-01 00:00:00' , '1840'     
-- EXEC [usp_Medium_Total] '' , '' , '2019-09-01 00:00:00' , ''

CREATE PROC [dbo].[usp_Medium_Total_TEST] 
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				--@pFromDt datetime,
				--@pEndDt datetime
				--@pMonth VARCHAR(07),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = null
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)
	DECLARE @SizeCode             VARCHAR(8) = CASE WHEN @pSizeCode IS NULL THEN '%' ELSE @pSizeCode END

	Declare @RawData TABLE (
		사이즈 VARCHAR(10)
	   ,월누적수량 NUMERIC(20,5)
	   ,계획수량 NUMERIC(20, 5)
	   ,달성률 NUMERIC(20, 5)
	);

	INSERT INTO @RawData

	SELECT                        
		  AA.사이즈
		, AA.월누적수량
		, BB.월간계획
		, CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0
	FROM 
						(
							SELECT 기준년월
								,사이즈
								--, CASE WHEN LineCode = 'ASSYLINE-05' THEN 사이즈 + 'L'  ELSE 사이즈 END AS 사이즈            
								,SUM(월누적수량) AS 월누적수량
							FROM MEDIUM_PROD
							WHERE RouteCode = 'E-28' AND CompanyCode = 'VNT'
							GROUP BY 기준년월, 사이즈
						) AA
						LEFT OUTER JOIN (
														SELECT 기준년월
															,사이즈
															--, CASE WHEN LineCode = 'ASSYLINE-05' THEN 사이즈 + 'L'  ELSE 사이즈 END AS 사이즈
															,SUM(월간계획) AS 월간계획			
														FROM MEDIUM_PLAN
														WHERE 공정코드 = 'E-28' AND CompanyCode = 'VNT'
														GROUP BY 기준년월, 사이즈
													) BB
		ON AA.기준년월 = BB.기준년월
	   AND AA.사이즈 = BB.사이즈 
	WHERE AA.기준년월 = @Month

	SELECT '월간생산계획 (pcs)' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 계획수량 FROM @RawData) AS A
	-- PIVOT (SUM(계획수량) FOR 사이즈 IN ([1030], [1030L], [1325], [2245], [1840], [3562], [3582])) AS PVT
	UNION ALL

	SELECT '누적생산수량 (pcs)' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 월누적수량 FROM @RawData) AS A
	-- PIVOT (SUM(월누적수량) FOR 사이즈 IN ([1030], [1030L], [1325], [2245], [1840], [3562], [3582])) AS PVT
	UNION ALL

	SELECT '달성률 (%)' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 달성률 FROM @RawData) AS A
	-- PIVOT (SUM(달성률) FOR 사이즈 IN ([1030], [1030L], [1325], [2245], [1840], [3562], [3582])) AS PVT

 END

 
