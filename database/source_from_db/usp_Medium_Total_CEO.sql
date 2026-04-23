-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-18
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째
--                   생산현황 > 입고생산현황 > 월생산현황      
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분, Power-BI  
-- ==================================================================

-- [POWER-BI 실행부분]     usp_Medium_Total_CEO '', '', '2020-05-26 00:00:00', '', 'VVT'

CREATE PROC [dbo].[usp_Medium_Total_CEO]
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
	DECLARE @Month				 VARCHAR(8) = CONVERT(VARCHAR(6), @pMonth, 112)                                                                    --  SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  '2020-01-01 00:00:00' , 121), 0, 8), '-', '')
	DECLARE @SizeCode            VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
 -- DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 
	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth-1, 121), 0, 11)                                                     -- 2020.02.27 수정  



if @CompanyCode='VNT' or @CompanyCode='*' 
	begin 
 -- 1. 사이즈별 상세부분
	SELECT  CASE WHEN BB.CompanyCode LIKE '%VNT%' THEN '전주본사' 
	                  WHEN BB.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장                
			 , AA.사이즈                                                                                        AS 사이즈
			, ISNULL(BB.월간계획, 1)                                                                                       AS '월간생산계획 (PCS)'
			, ISNULL(AA.월누적수량, 1)                                                                                    AS '누적생산수량 (PCS)'									
			, CASE WHEN BB.월간계획 = 0 THEN 0 ELSE CONVERT(NUMERIC(20,5), AA.월누적수량) / CONVERT(NUMERIC(20,5), BB.월간계획) * 100.0  END  AS '달성율 (%)'			
			, (SELECT COMMENT FROM PROD_Comment PC  WHERE PC.사이즈 = AA.사이즈 AND PC.CompanyCode = AA.CompanyCode)                      AS Comment
			, AA.CompanyCode                                                                                                                                                      AS CompanyCode
	FROM 
						(	SELECT 기준년월
								    , 사이즈								
								    , SUM(ISNULL(월누적수량,0)) AS 월누적수량
									, CompanyCode
							FROM MEDIUM_PROD
							WHERE 1=1
							   AND RouteCode IN ( 'E-28' , 'V-28')	
								--AND 기준년월 = '20206'			   -----
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
           --AND AA.기준년월 =	'202007'
									
	   AND AA.사이즈  like @SizeCode  
	   AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가
	   

	 UNION ALL

-- 2. 하단 [합계부분]
		SELECT  '합계'                   AS 사업장                				
				, ''                         AS 사이즈
				, SUM(BB.월간계획)     AS '월간생산계획 (PCS)'
				, SUM(AA.월누적수량)  AS '누적생산수량 (PCS)'									
				, CASE WHEN MAX(BB.월간계획) = 0 THEN 0 ELSE CONVERT(NUMERIC(20,5), SUM(AA.월누적수량)) / CONVERT(NUMERIC(20,5), SUM(BB.월간계획)) * 100.0  END  AS '달성율 (%)'			
				, ''                         AS Comment
				, ''                         AS CompanyCode
			FROM 
								(
									SELECT 기준년월 AS 기준년월
											, 사이즈 AS 사이즈
											 , SUM(ISNULL(월누적수량,0)) AS 월누적수량
											, CompanyCode AS CompanyCode
											
									FROM MEDIUM_PROD
									WHERE 1=1
									   AND RouteCode IN ( 'E-28' , 'V-28')	                                              
									   AND 사이즈  like @SizeCode																																																	
									   AND 기준년월 = (
																	SELECT  Replace(BaseMonth, '-', '')		
																	FROM STB_AggregationPeriod
																WHERE 1=1									
																	AND  FromDate  <= @OneDay
																	AND  ToDate     >= @OneDay
										    				)				
										 -- AND 기준년월 = '202007'		 
									   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                           --추가																		
									GROUP BY 기준년월, 사이즈, CompanyCode									
								)  AA

								LEFT OUTER JOIN (
						                  				  SELECT 기준년월 AS 기준년월
																  , 사이즈   AS 사이즈
																  , SUM(ISNULL(월간계획,0)) AS 월간계획																		
															FROM MEDIUM_PLAN
															WHERE 1=1
																   AND 공정코드 IN ('E-28' , 'V-28')              -- 포장공정 실적으로 고정!!	
																   AND 사이즈 like @SizeCode  
																   --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pMonth , 121), 0, 8), '-', '') 	
																   --AND 기준년월 = '202007'
																    AND 기준년월 = (
																							 SELECT  Replace(BaseMonth, '-', '')		
																							 FROM STB_AggregationPeriod
																							WHERE 1=1									
																							   AND  FromDate  <= @OneDay
																							   AND  ToDate     >= @OneDay
										    											)
																   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                           --추가																																				
                                                            GROUP BY 기준년월, 사이즈, CompanyCode
													  ) BB
				ON AA.기준년월 = BB.기준년월
			  AND AA.사이즈 = BB.사이즈 
			WHERE 1=1			 
			   AND AA.기준년월 = (
												SELECT  Replace(BaseMonth, '-', '')		
												FROM STB_AggregationPeriod
											WHERE 1=1									
												AND  FromDate  <= @OneDay
												AND  ToDate     >= @OneDay
										)

              -- AND AA.기준년월 = '202007'
			   AND AA.사이즈   like @SizeCode  			   
			   AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가
	end
			 		
					
					
					








					
					
					




	-- Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode   - Mr.Tung  EA Vietnam 
	-- usp_Medium_Total_CEO '','','2020-07-14', '', 'VVT'
	--   varchar(10)= convert(varchar(10),CONVERT(datetime,@Month+'15',120),120)

	--DECLARE @currentdate varchar(23) = getdate()			
	--  if(DAY(@currentdate)>'25') 
	--	begin 
	--		select @currentdate = convert( varchar(10),DATEADD(MONTH,1, @currentdate),120) 
	--	end 
	--DECLARE @tmpdate    varchar(10) = convert(varchar(10),@currentdate,120)	
	--DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-25'
	--DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'


	
DECLARE @currentdate datetime = DATEADD(DAY,0,getdate()	)

--DECLARE @jodate     varchar(10)= convert(varchar(10),CONVERT(datetime,@Month+@ToDay,120),120)
--DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @jodate),120) + '-25'
--DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @jodate),120) + '-26'
--select @jodate = convert( varchar(10), GETDATE(),120) 
			
	if(DAY(@currentdate)>25) 
		begin 
			select @currentdate = convert( varchar(10),DATEADD(MONTH,1, @currentdate),120) 
		end 
		--	select @ToDay = DAY (@currentdate)
	select @Month = replace(convert( varchar(7),DATEADD(MONTH,0, @currentdate),120),'-','')


	DECLARE @tmpdate    varchar(10) = convert(varchar(10),@currentdate,120)	
	DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-26'
	DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'
	
DECLARE @FromDate   VARCHAR(19) = @jodatefrom + ' 10:30:00'   
DECLARE @ToDate     VARCHAR(19) = @jodateto +' 10:30:00'      


if @CompanyCode='VVT' 
begin 			

	--if (@pProcessUserID='nguyentung')
	--begin
	--     DECLARE @er varchar(100)= '';-- convert(varchar(10),MONTH(@currentdate))+','+','+@currentdate+','+@tmpdate+','+@jodatefrom+','+@jodateto;
		 --raiserror (@er,16,1);
	--end
	
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
				, sum(lv.ProdQty - ISNULL(lv.DefectQty, 0) )  as '누적생산수량 (PCS)'		
		
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
						  -- , /*RIGHT(기준일,2)  AS*/ 기준일
							,sum(수량) as 수량
							--, CompanyCode
							--, LineCode
					  FROM MEDIUM_PLAN  with(nolock)   
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30
																   ,Day31)
							) AS UPT	
							where 기준년월=@Month and 공정코드='V-28' and CompanyCode='VVT'
							group by 기준년월	,사이즈,공정코드
						), 
		PlanPivotView as (
						select 기준년월
							,사이즈
							--, 공정코드
							--, 기준일
							,sum(수량) as  '월간생산계획 (PCS)'
							--, CompanyCode
							--, LineCode
							from PlanDayView with(nolock) 
							group by 기준년월
							,사이즈
							, 공정코드
							--, 기준일
							--, CompanyCode
							--, LineCode
							)
				--)
				,
	AllowMiddle as (
				select 
				'베트남' as 사업장
				,isnull(MiddleLastView.사이즈,PlanPivotView.사이즈) as 사이즈
				--,isnull("월간생산계획 (PCS)",0) as "월간생산계획 (PCS)"
				,( case when"월간생산계획 (PCS)"=0 then "누적생산수량 (PCS)" else isnull("월간생산계획 (PCS)","누적생산수량 (PCS)") end ) as "월간생산계획 (PCS)"	
				, isnull("누적생산수량 (PCS)",0) as "누적생산수량 (PCS)"					
				 ,CASE WHEN (ISNULL("누적생산수량 (PCS)",0)) = 0 OR (ISNULL("월간생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("누적생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("월간생산계획 (PCS)",0)) ) * 100.0  END  		 AS '달성율 (%)'
				 from MiddleLastView  with(nolock) 
				 full join PlanPivotView  with(nolock) on MiddleLastView.사이즈=PlanPivotView.사이즈	
				 ),
	 datalast as (
			 select 
			'베트남' as 사업장
			, 사이즈
			, isnull("월간생산계획 (PCS)","누적생산수량 (PCS)") as "월간생산계획 (PCS)"
			, "누적생산수량 (PCS)"			
			 ,CASE WHEN (ISNULL("누적생산수량 (PCS)",0)) = 0 OR (ISNULL("월간생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("누적생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("월간생산계획 (PCS)",0)) ) * 100.0  END  		 AS '달성율 (%)'
			 from AllowMiddle with(nolock) 
			 )
			 select 
			'베트남' as 사업장
			, 사이즈
			, "월간생산계획 (PCS)"
			, "누적생산수량 (PCS)"			
			 ,CASE WHEN (ISNULL("누적생산수량 (PCS)",0)) = 0 OR (ISNULL("월간생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("누적생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("월간생산계획 (PCS)",0)) ) * 100.0  END  		 AS '달성율 (%)'
			 ,'' as Comment
			 ,'VVT' as CompanyCode
			 from datalast with(nolock) 
	union all
			 select 
			 '합계'                   AS 사업장                				
				, ''                         AS 사이즈
			, sum("월간생산계획 (PCS)") as  "월간생산계획 (PCS)"
			, sum("누적생산수량 (PCS)") as  "누적생산수량 (PCS)"			
			 ,CONVERT(NUMERIC(20,1), sum("누적생산수량 (PCS)")  ) / CONVERT(NUMERIC(20,5), sum("월간생산계획 (PCS)") ) * 100.0 as "달성율 (%)"
			 ,'' as Comment
			 ,'VVT' as CompanyCode
			 from datalast	 with(nolock) 			 		 			 
	end 
	
 END