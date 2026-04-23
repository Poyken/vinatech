-- ==================================================================
-- Author      : 
-- Create date : 2020-01-14
-- Browsable   : true
-- Group       :  
--                  
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 
-- ==================================================================
-- 실행문 : usp_VVTProdQty ''


CREATE PROC [dbo].[usp_VVTProdQty] 
                 @pProdBaseDate DATETIME
AS

BEGIN

		Declare @ProdBaseDate VARCHAR(6) = CONVERT(VARCHAR(6), @pProdBaseDate, 112)
		Declare @ToMonth VARCHAR(6) = @ProdBaseDate
		Declare @RowCount     INT
		Declare @OneDay        VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)	 		

		
		--SELECT @RowCount = COUNT(*) FROM MEDIUM_PROD WHERE 기준년월 = @ProdBaseDate
		---- select top 1000 * from MEDIUM_PROD where 기준년월='202007' 

		--IF @RowCount <> 0 
				
		--BEGIN 
		--	SELECT A.기준년월
		--		  ,A.사이즈
		--		  ,A.RouteCode AS 공정코드
		--		  ,CASE WHEN RI.RouteName = '권취' THEN 'WINDING' 
		--				WHEN RI.RouteName = '커링' THEN 'CURLING'
		--				ELSE RI.RouteName END AS 공정명
		--		  ,CONVERT(SMALLDATETIME, 기준년월+REPLACE(BaseYmd, 'Day', ''), 112) AS 작업일자
		--		  ,ProdQty AS 실적수량
		--	  FROM (
		--		SELECT 기준년월, 사이즈, RouteCode, BaseYmd, CompanyCode
		--			  ,ProdQty
		--		  FROM MEDIUM_PROD
		--		 UNPIVOT
		--		 (
		--			ProdQty
		--			For BaseYmd IN (
		--							Day01, Day02, Day03, Day04, Day05
		--						   ,Day06, Day07, Day08, Day09, Day10
		--						   ,Day11, Day12, Day13, Day14, Day15
		--						   ,Day16, Day17, Day18, Day19, Day20
		--						   ,Day21, Day22, Day23, Day24, Day25
		--						   ,Day26, Day27, Day28, Day29, Day30
		--						   ,Day31
		--						   )
		--		 ) VVTProdQtyData
		--	) A
		--	LEFT OUTER JOIN STB_RouteInfo RI ON A.RouteCode = RI.RouteCode
		--	WHERE A.기준년월 = @ProdBaseDate
		--	  AND A.CompanyCode = 'VVT'
		--	  AND A.기준년월+REPLACE(A.BaseYmd, 'Day', '') <= CONVERT(VARCHAR(8), dbo.fnGetLastDayOfMonth(@pProdBaseDate), 112)
		--	ORDER BY A.사이즈, A.RouteCode, CONVERT(SMALLDATETIME, A.기준년월+REPLACE(A.BaseYmd, 'Day', ''), 112)
		--END ELSE 
		
		--BEGIN
		--	SELECT @ProdBaseDate AS 기준년월
		--		  ,A.사이즈
		--		  ,A.RouteCode AS 공정코드
		--		  ,CASE WHEN RI.RouteName = '권취' THEN 'WINDING' 
		--				WHEN RI.RouteName = '커링' THEN 'CURLING'
		--				ELSE RI.RouteName END AS 공정명
		--		  ,CONVERT(SMALLDATETIME, @ProdBaseDate+REPLACE(BaseYmd, 'Day', ''), 112) AS 작업일자
		--		  ,0 AS 실적수량
		--	  FROM (
		--		SELECT 기준년월, 사이즈, RouteCode, BaseYmd, CompanyCode
		--			  ,ProdQty
		--		  FROM MEDIUM_PROD
		--		 UNPIVOT
		--		 (
		--			ProdQty
		--			For BaseYmd IN (
		--							Day01, Day02, Day03, Day04, Day05
		--						   ,Day06, Day07, Day08, Day09, Day10
		--						   ,Day11, Day12, Day13, Day14, Day15
		--						   ,Day16, Day17, Day18, Day19, Day20
		--						   ,Day21, Day22, Day23, Day24, Day25
		--						   ,Day26, Day27, Day28, Day29, Day30
		--						   ,Day31
		--						   )
		--		 ) VVTProdQtyData
		--	) A
		--	LEFT OUTER JOIN STB_RouteInfo RI ON A.RouteCode = RI.RouteCode
		--	WHERE 1=1
		--	 -- AND A.기준년월 = '202001'

		--	     AND 기준년월 = (
		--									SELECT Replace(BaseMonth, '-', '')
		--									FROM STB_AggregationPeriod
		--								WHERE 1=1									
		--									AND  FromDate  <= @OneDay
		--									AND  ToDate     >= @OneDay
		--							  )

		--	  AND A.CompanyCode = 'VVT'
		--	  AND @ProdBaseDate+REPLACE(BaseYmd, 'Day', '') <= CONVERT(VARCHAR(8), dbo.fnGetLastDayOfMonth(@pProdBaseDate), 112)
		--	ORDER BY A.사이즈, A.RouteCode, CONVERT(SMALLDATETIME, A.기준년월+REPLACE(A.BaseYmd, 'Day', ''), 112)
		--END






		
--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       EXEC usp_VVTProdQty '2020-07-15'
	DECLARE @tmpdate    varchar(10)= convert(varchar(10),CONVERT(datetime,@ToMonth+'15',120),120)
	DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-25'
	DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'

--if @CompanyCode='VVT' 
	--begin 	
			
	;with data1 as (
		select CompanyCode,substring(MaterialName,CHARINDEX('(',MaterialName)+1,CHARINDEX(')',MaterialName)-CHARINDEX('(',MaterialName)-1 ) as MaterialName,
		LineCode,RouteCode,JobDate,sum(outputqty) as outputqty,sum(defectqty) as defectqty
		 from	STB_ProdRouteSummary k1 join STB_MaterialMaster k2 on k1.MaterialCode=k2.MaterialCode
		  where JobDate>'2020-06-25' and JobDate<'2020-07-26' and companycode='VVT'  and routecode in ('V-22','V-24','V-28')
		 group by CompanyCode,MaterialName,LineCode,RouteCode,JobDate
		 --order by JobDate,MaterialName
		 )--,
	--data2 as (
		select '202007' as "기준년월"
		--,CompanyCode
		,MaterialName as "사이즈"
		--,LineCode
		,RouteCode as "공정코드"
		,(select RouteName from [SmartFactoryV2].[dbo].[STB_RouteInfo] where RouteCode=data1.RouteCode) as "공정명"
		,JobDate as "작업일자"
		,sum(outputqty) as 실적수량
		--,sum(defectqty) as defectqty
		 from	data1 
		  --where JobDate>@jodatefrom and JobDate<@jodateto and companycode='VVT' 
		 group by CompanyCode,MaterialName,LineCode,RouteCode,JobDate
		 --order by JobDate
		--),
    
	--end
		

END