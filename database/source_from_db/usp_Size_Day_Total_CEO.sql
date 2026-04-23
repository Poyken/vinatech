-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째 [전일생산현황]
--                  Power-BI 대시보드 > 전일실적 Graph 부분
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
--                  2020.02.03  피봇테이블을 이용한  SQL로 변경         ,				`


-- [프로시저 실행문]  :    usp_Size_Day_Total_CEO '','','2020-07-03', '', 'VNT'
-- ==================================================================

CREATE PROC [dbo].[usp_Size_Day_Total_CEO]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = NULL,
				@pCompanyCode VARCHAR(20) = NULL                                           
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
    DECLARE @Month                VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                           -- 전일자 두자리                       SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 		
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth-1, 121), 0, 11)                                                            --    SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                       -- 어제날짜        ex) 20200111      SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	


      -- [1. 전일실적_상세부분] 		
if @CompanyCode='VNT' or  @CompanyCode='*' 
begin


			SELECT CASE WHEN AA.CompanyCode LIKE '%VNT%' THEN '전주본사' 
					         WHEN AA.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장    
					  , AA.사이즈                    AS 사이즈          
					  , SUM(ISNULL(AA.수량,0))   AS  '일 생산계획 (PCS)'  
					  , SUM(ISNULL(BB.수량,0))   AS '일 생산수량 (PCS)'	  
					  , CASE WHEN SUM(ISNULL(AA.수량,0)) = 0 OR SUM(ISNULL(BB.수량,0)) = 0  OR SUM(ISNULL(BB.수량,0)) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(ISNULL(BB.수량,0))  ) / CONVERT(NUMERIC(20,5), SUM(ISNULL(AA.수량,0)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			FROM 		 
					( 
					 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드					
						   , RIGHT(기준일,2)  AS 기준일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30, Day31)
							) AS UPT					
						WHERE 1=1
						AND 기준년월  =  '202008'								
                            AND  RIGHT(기준일,2)  = @ToDay						
					  )  AA
								  LEFT OUTER JOIN 
								  ( 

								   SELECT 기준년월
											,사이즈
											, RouteCode AS 공정코드										
											, RIGHT(기준일, 2)  AS 기준일
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
									  AND 기준년월  = '202008'
										
                            AND  RIGHT(기준일,2)  = @ToDay		
							
					  )  BB  on AA.기준년월 = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

			WHERE 1=1
		    
			   AND AA.기준년월 =  '202008'

	
              AND  RIGHT(AA.기준일,2)  = @ToDay

			  AND AA.공정코드 IN ( 'E-28', 'V-28')
			  
			AND AA.사이즈   like @SizeCode  			   
			AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가
		

			 GROUP BY AA.CompanyCode 
						 , AA.사이즈           
		

UNION ALL


       ---- [2. 전일실적_합계부분] 
			SELECT   '합계'                        AS 사업장
					 ,  ' '                            AS 사이즈          
					 , SUM(ISNULL(AA.수량,0))   AS  '일 생산계획 (PCS)'  
					 , SUM(ISNULL(BB.수량,0))    AS '일 생산수량 (PCS)'	    					 
		            , CASE WHEN SUM(ISNULL(AA.수량,0)) = 0 OR SUM(ISNULL(BB.수량,0)) = 0  OR SUM(ISNULL(BB.수량,0)) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(ISNULL(BB.수량,0))  ) / CONVERT(NUMERIC(20,5), SUM(ISNULL(AA.수량,0)) ) * 100.0  END  		 AS '달성율 (%)'				 		  		  
			FROM 		 
					( 
					 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드
								--	,기준년월 + RIGHT(기준일,2)  AS 기준년월일
						   , RIGHT(기준일,2)  AS 기준일
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
						  AND 기준년월  =  (                                                                                                
													SELECT  Replace(BaseMonth, '-', '')		
													FROM STB_AggregationPeriod
												WHERE 1=1									
													AND  FromDate  <= @OneDay
													AND  ToDate     >= @OneDay
												)      						  							
                            AND  RIGHT(기준일,2)  = @ToDay		
						AND 공정코드  IN ( 'E-28', 'V-28')                                                          -- 추가사항

						
					  )  AA
							 LEFT OUTER JOIN 
									  ( 
									   SELECT 기준년월
												,사이즈
												, RouteCode AS 공정코드											 
												, RIGHT(기준일,2)  AS 기준일
												, 수량
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
										   AND 기준년월  = '202008'

										  --AND 기준년월  =  (                                                                                                
												--	SELECT  Replace(BaseMonth, '-', '')		
												--	FROM STB_AggregationPeriod
												--WHERE 1=1									
												--	AND  FromDate  <= @OneDay
												--	AND  ToDate     >= @OneDay
												--)      							
                            AND  RIGHT(기준일,2)  = @ToDay		
																						
					  )  BB  on AA.기준년월 = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

			WHERE 1=1

			  AND AA.공정코드 IN ( 'E-28', 'V-28')
			     AND AA.기준년월 = '202008'
			   --AND AA.기준년월 = (
						--				 SELECT  Replace(BaseMonth, '-', '')									  
						--				 FROM STB_AggregationPeriod
						--				 WHERE 1=1										   
						--				   AND  FromDate  <= @OneDay
						--				   AND  ToDate     >= @OneDay
						--				)
			AND AA.사이즈  LIKE @SizeCode  			   
			AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           
			AND RIGHT(AA.기준일,2) =@ToDay                                                                                         -- 2020.01.21 추가


end



















-- for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode         합계	 	423145.00000	131189.00000	31.0033203748	VVT 
--  usp_Size_Day_Total_CEO '','','2021-05-11', '', 'VVT'    
--  select     varchar(10)= convert(varchar(10),CONVERT(datetime,@Month+@ToDay,120),120)

	DECLARE @currentdate datetime = getdate() 
	DECLARE @FromDate VARCHAR(19)= CONVERT(VARCHAR(10), DATEADD(DAY, 0,  @currentdate),120) + ' 10:30:00'    	
	DECLARE @ToDate   VARCHAR(19)= CONVERT(VARCHAR(10), DATEADD(DAY,  1,  @currentdate),120) + ' 10:30:00'

  if @CompanyCode='VVT' 
  begin 

		
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
	 ),
RawView as (
	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, sum(a.DefectQty) as DefectQty,  sum(a.RepairQty) as RepairQty ,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime
)
,
LastView as(
		select  
		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		  RV.ProdDateTime, 
		  max(RV.ProdQty) as ProdQty,
		  sum(RV.DefectQty - RV.RepairQty) as DefectQty, 
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		  DATEPART(DAY, ProdDateTime)  as ProdDay,
		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode
		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
		where 
		( 
			(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
		--order by RV.Barcode,RV.RouteCode 
)
,
MiddleLastView as (
			select			
			'베트남' as 사업장
			, '' as 기준년월
			, SizeCode as 사이즈
			, sum(lv.ProdQty) as totalQty		
			, sum(lv.ProdQty - ISNULL(lv.DefectQty, 0) )  as '일 생산수량 (PCS)'		
		
		, sum(lv.DefectQty) as DefectQty
		
			from LastView lv
			where RouteCode = 'V-28'
			group by  			SizeCode
)
,
 PlanDayView as (
						 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드
								--	,기준년월 + RIGHT(기준일,2)  AS 기준년월일
						   , /*RIGHT(기준일,2)  AS*/ 기준일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN with(nolock) 
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30
																   ,Day31)
							) AS UPT	
							where 기준년월=@Month and 공정코드='V-28' and   CompanyCode='VVT'  and 기준일='Day'+@ToDay
			)
			, 
PlanPivotView as (
						select 기준년월
							,사이즈 --,							기준일
							--, 공정코드
							, 기준일
							,sum(수량) as  '일 생산계획 (PCS)'
							--, CompanyCode
							--, LineCode
							from PlanDayView with(nolock) 
							group by 기준년월
							,사이즈
							, 공정코드
							, 기준일
							, CompanyCode
							--, LineCode
		)
		,
AllowMiddle as (
			select 
			'베트남' as 사업장
			,isnull(MiddleLastView.사이즈,PlanPivotView.사이즈) as 사이즈
			,( case when "일 생산계획 (PCS)"=0 then "일 생산수량 (PCS)" else isnull("일 생산계획 (PCS)","일 생산수량 (PCS)") end ) as "일 생산계획 (PCS)"
			,isnull("일 생산수량 (PCS)",0) as "일 생산수량 (PCS)"			
			 ,CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",1)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			 from MiddleLastView  with(nolock) 
			 full join PlanPivotView with(nolock)  on MiddleLastView.사이즈=PlanPivotView.사이즈
			 )
			 ,
datalast as(
			 select 
			'베트남' as 사업장
			 ,사이즈
			 ,isnull("일 생산계획 (PCS)","일 생산수량 (PCS)") as "일 생산계획 (PCS)"
			 ,"일 생산수량 (PCS)"			
			 , CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",1)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			 from AllowMiddle  with(nolock) 
			)			
	select 
			'베트남' as 사업장
			 ,사이즈
			 ,"일 생산계획 (PCS)"
			 ,"일 생산수량 (PCS)"			
			 , CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",1)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			 ,'VVT' as CompanyCode
			 from datalast    
	union all
			select 
			 '합계'                        AS 사업장
			,' ' as 사이즈
			 ,sum("일 생산계획 (PCS)") as "일 생산계획 (PCS)"
			 ,sum("일 생산수량 (PCS)"	) as "일 생산수량 (PCS)"
			 ,CONVERT(NUMERIC(20,1), sum("일 생산수량 (PCS)")  ) / CONVERT(NUMERIC(20,5), case when  sum(isnull("일 생산계획 (PCS)",0))=0 then 1 else  sum(isnull("일 생산계획 (PCS)",0))  end) * 100.0 as "달성율 (%)"
			 ,'VVT' as CompanyCode
			 from datalast 		

			 			 
  end



 END