-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-09-19
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_MediumTotal_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMonth DATE 
AS
BEGIN
	Declare @Month VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)
	Declare @RawData TABLE (
		사이즈 VARCHAR(10)
	   ,월누적수량 BIGINT
	   ,계획수량 BIGINT
	   ,달성률 NUMERIC(20, 2)
	);

	INSERT INTO @RawData
	SELECT                        
		  BB.사이즈
		, AA.월누적수량
		, BB.월간계획
		, CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0
	FROM 
	(
		SELECT 기준년월
			,사이즈             
			,SUM(월누적수량) AS 월누적수량
		FROM MEDIUM_PROD
		GROUP BY 기준년월, 사이즈
	) AA
	LEFT OUTER JOIN (
		SELECT 기준년월
			,사이즈
			,SUM(월간계획) AS 월간계획
		FROM MEDIUM_PLAN
		GROUP BY 기준년월, 사이즈
	) BB
		ON AA.기준년월 = BB.기준년월
	   AND AA.사이즈 = BB.사이즈 
	WHERE AA.기준년월 = @Month

	SELECT '월간생산계획' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 계획수량 FROM @RawData) AS A
	 PIVOT (SUM(계획수량) FOR 사이즈 IN ([1030], [1325], [2245], [1840], [3562], [3582])) AS PVT
	UNION ALL
	SELECT '누적생산수량' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 월누적수량 FROM @RawData) AS A
	 PIVOT (SUM(월누적수량) FOR 사이즈 IN ([1030], [1325], [2245], [1840], [3562], [3582])) AS PVT
	UNION ALL
	SELECT '달성률' AS 구분, *, '' AS 특이사항
	  FROM (SELECT 사이즈, 달성률 FROM @RawData) AS A
	 PIVOT (SUM(달성률) FOR 사이즈 IN ([1030], [1325], [2245], [1840], [3562], [3582])) AS PVT

END