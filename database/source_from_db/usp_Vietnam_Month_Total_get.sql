-- ==================================================================
-- Author      : Mr.Tung
-- Create date : 2020-08

-- POWER-BI 실행문 :   EXEC usp_Vietnam_Month_Total_get  '', 'Korean', '2020-07-01 00:00:00', '', 'VVT' 
-- ==================================================================


CREATE PROC [dbo].[usp_Vietnam_Month_Total_get]
				@pProcessUserID     VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth              DateTime,
				@pSizeCode           VARCHAR(20) = NULL,
				@pCompanyCode    VARCHAR(20) = NULL                                           

AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)	
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	DECLARE @OneDay              VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)	 		

			
			 
	--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       EXEC usp_VVT_Month_Total_get  '', '', '2020-07-15 00:00:00', '', 'VVT' 
	--DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 
	--DECLARE @tmpdate     varchar(10)= convert(varchar(10),CONVERT(datetime,@Month+@ToDay,120),120)
	--DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-25'
	--DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'
	--DECLARE @fullToday     varchar(10) = convert( varchar(10),DATEADD(DAY,1,@tmpdate),120)
	
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

		 
		 	;with ViewBarcode as (
			 select  c.Barcode
			 from 
			 STB_SetInfo c with(nolock) 
			 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
			 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 ),
	RawView as (
	 		select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
			max(b.ProdQty) as ProdQty, sum(a.DefectQty) as DefectQty,  sum(a.RepairQty) as RepairQty ,max(b.ProdDateTime) as ProdDateTime,max(b.CreateDateTime) as CreateDateTime
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
			 --'합계'                   AS 사업장                				
			--	, ''                         AS 사이즈
			 sum("월간생산계획 (PCS)") as  "월간생산계획 (PCS)"
			, sum("누적생산수량 (PCS)") as  "누적생산수량 (PCS)"			
			 ,CONVERT(NUMERIC(20,1), sum("누적생산수량 (PCS)")  ) / CONVERT(NUMERIC(20,5), sum("월간생산계획 (PCS)") ) * 100.0 as "달성율 (%)"
			 --,' '  as Comment
			 --,'VVT' as CompanyCode
			 from datalast	 with(nolock) 
	
 END