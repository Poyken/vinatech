
-- =============================================
-- Author:	   kilee@vina.co.kr
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 생산관리 > 생산현황 > [B590] 월별생산현황관리
-- Description:	
-- Modified: 
--             2020.05.07 사업장코드 추가 
--             2020.08.27 법인 IT 다른이름으로 프로시저 만들어서 진행할것!

-- 프로시저 실행문 : EXEC usp_VNM_ProdSummary_get '','','2020-08-27 18:00:00'
-- ============================================

Create PROCEDURE [dbo].[usp_VNM_ProdSummary20200827_get]
		@pProcessUserID     VARCHAR(20),
		@pProcessLanguage VARCHAR(20),		
		@pToMonth           DateTime,
		@pRouteCode         VARCHAR(20) = NULL,            -- 2019.05.21 공정코드 추가
		@pSizeCode           VARCHAR(04) = NULL,            -- 2019.05.21 사이즈 추가
		@pCompanyCode     VARCHAR(20) = NULL            -- 2020.05.07 사업장코드 kilee 추가 
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage    				
	DECLARE @ToMonth            VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')          -- 금일 6자리    SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2020-05-17 08:30:00', 121), 1, 7), '-', '')     --> '202005'
	DECLARE @RouteCode          VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	DECLARE @SizeCode             VARCHAR(8)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode    END
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	

	
--if @CompanyCode='VNT'   -- 주석처리!!!!! (NAIS 화면에 영향이 감)   건들지마세요~
--	begin 	

	SELECT MP.기준년월
			, MP.사이즈
			, MP.RouteCode
			, (SELECT A.RouteName FROM STB_RouteInfo A  WHERE A.RouteCode = MP.RouteCode) AS RouteName
			, MP.월누적수량
			, Day01, Day02, Day03, Day04, Day05, Day06, Day07, Day08, Day09, Day10
			, Day11, Day12, Day13, Day14, Day15, Day16, Day17, Day18, Day19, Day20
			, Day21, Day22, Day23, Day24, Day25, Day26, Day27, Day28, Day29, Day30, Day31
			, MP.CompanyCode  AS CompanyCode
			, MP.LineCode 
	FROM MEDIUM_PROD  MP
	WHERE 1=1
		AND MP.기준년월 LIKE @ToMonth + '%'
	-- AND MP.CompanyCode = 'VVT'                                                                        -- 베트남 사업자코드 (원본백업)
		AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode))                     -- 사업장코드 조건추가 (2020.05.07)
		AND ((@RouteCode = '*')     OR (MP.RouteCode = @RouteCode)) 
		AND 사이즈                     Like @SizeCode
	ORDER BY MP.사이즈
--end	











	

----for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       EXEC usp_VNM_ProdSummary_get '','','2020-08-07 18:00:00','','','VVT'
--	DECLARE @tmpdate     varchar(10)= convert(varchar(10),CONVERT(datetime,@ToMonth+'15',120),120)
--	--DECLARE @FromDate varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-25'
--	--DECLARE @ToDate   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'
--	DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @tmpdate)), 120)  +'-26'   + ' 10:29:59'
--	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @tmpdate)), 120)  +'-26'   + ' 10:30:01'

--	if @ProcessUserID='nguyentung' begin
--		raiserror (@ToDate,16,1)
--		return
--	end

--if @CompanyCode='VVT' 
--	begin 	

--	--select @tmpdate, @FromDate, @ToDate
--	--return
		
--		 ; with tung as (
--		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
--		 from 
--		 STB_SetInfo c
--		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
--		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
--		 ----group by c.Barcode,b.RouteCode--,(ProdDateTime)
--		 ----order by a.FindRouteCode 
--		 --union
--		 --select  c.Barcode--, FindRouteCode as RouteCode,a.FindRouteCode,0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
--		 --from 
--		 --STB_SetInfo c
--		 --full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
--		 --where  (a.CompanyCode='VVT'  and a.FindDateTime>'2020-07-01' )
--		 ----group by c.Barcode,a.FindRouteCode--,(FindDateTime)
--		 ----order by a.FindRouteCode 
--	 ),
--	 tungfinished as (
--	  	 select  c.Barcode,count(b.RouteCode) as totalcount
--		 from 
--		 STB_SetInfo c
--		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
--		 where  c.Barcode in (select Barcode from tung)
--		 group by c.Barcode
--	 ),
--	 tungfinished2 as (		
--		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
--		 from 
--		 STB_SetInfo c
--		 left outer join tungfinished on tungfinished.Barcode=c.Barcode
--		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
--		 where  c.Barcode in (select Barcode from tung)
--		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
--	 ),
--	  tung0 as (
--	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
--		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
--		from  STB_SetInfo c
--		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
--		 where c.Barcode in (select Barcode from tung)
--		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
--		 --order by a.FindRouteCode 
--		 union
--		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
--		 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
--		 from  STB_SetInfo c
--		 full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
--		 where   c.Barcode in (select Barcode from tung)
--		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01
--		 --order by a.FindRouteCode 
--	 ),
--	 tung11 as (
--	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
--	 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,
--	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
--	 from tung0
--		group by Barcode,RouteCode,FindRouteCode--,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
--	 --	order by RouteCode
--	),
--	tung1 as (
--	select 
--	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
--	 from tung11
--	 left outer join tungfinished2 
--	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
--	 ),
--	tung22 as (
--	select *
--	from tung1 where RouteCode='V-22'
--	),
--	tung23 as (
--	select *
--	from tung1 where RouteCode='V-23'
--	)
--	,
--	tung24 as (
--	select *
--	from tung1 where RouteCode='V-24'
--	)
--	,
--	tung25 as (
--	select *
--	from tung1 where RouteCode='V-25'
--	)
--	,
--	tung27 as (
--	select *
--	from tung1 where RouteCode='V-27'
--	)
--	,
--	tung28 as (
--	select *
--	from tung1 where RouteCode='V-28'
--	)
--	,
--	tung40 as (
--	select *
--	from tung1 where RouteCode='V-40'
--	),
--	tlast as (
--	select *from tung22 --where  ProdDateTime>'2020-07-01'
--	--union
--	--select tung23.* from tung23--,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
--	--union  																	
--	--select tung40.* from tung40--,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
--	union									 								
--	select tung24.* from tung24,tung22  where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
--	union  									  									
--	select tung25.* from tung25,tung24  where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
--	union  									 									
--	select tung27.* from tung27,tung25  where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
--	union  									 									
--	select tung28.* from tung28,tung27  where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
--	),
--	last2 as (
--	select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
--	CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
--	from tlast
--	--order by ProdDateTime
--	),
--	DRI as (
--	select *, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
--				then     convert(varchar(10),ProdDateTime,120)    
--				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
--				end )    as  FindDateTime 
--	from last2
--	where  ProdDateTime>@FromDate  and ProdDateTime<@ToDate
--	),
--	deptrai as (
--	select
--		   'VVT'   AS 사업장
--		  --,DRI.ControlNo
--	      --,DRI.Barcode
--		  ,DRI.MaterialCode
--		  ,substring(MaterialName,CHARINDEX('(',MaterialName)+1,CHARINDEX(')',MaterialName)-CHARINDEX('(',MaterialName)-1 ) as MaterialName
--		  ,DRI.InputLineCode
--		  ,LI.LineName
--		  ,DRI.RouteCode as RouteCode
--		  ,RI.RouteName
--		  	  ,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
--		  , (case when DATEPART(DAY, FindDateTime)=1 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "1"	
--		  , (case when DATEPART(DAY, FindDateTime)=2 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "2"
--		  , (case when DATEPART(DAY, FindDateTime)=3 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "3"
--		  		  , (case when DATEPART(DAY, FindDateTime)=4 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "4"
--		  , (case when DATEPART(DAY, FindDateTime)=5 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "5"
--		  , (case when DATEPART(DAY, FindDateTime)=6 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "6"
--		  , (case when DATEPART(DAY, FindDateTime)=7 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "7"
--		  , (case when DATEPART(DAY, FindDateTime)=8 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "8"
--		  , (case when DATEPART(DAY, FindDateTime)=9 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "9"
--		  , (case when DATEPART(DAY, FindDateTime)=10 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "10"
--		  		  , (case when DATEPART(DAY, FindDateTime)=11 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "11"
--		  , (case when DATEPART(DAY, FindDateTime)=12 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "12"
--		  , (case when DATEPART(DAY, FindDateTime)=13 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "13"
--		  , (case when DATEPART(DAY, FindDateTime)=14 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "14"
--		  , (case when DATEPART(DAY, FindDateTime)=15 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "15"
--		  , (case when DATEPART(DAY, FindDateTime)=16 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "16"
--		  , (case when DATEPART(DAY, FindDateTime)=17 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "17"
--		  		  , (case when DATEPART(DAY, FindDateTime)=18 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "18"
--		  , (case when DATEPART(DAY, FindDateTime)=19 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "19"
--		  , (case when DATEPART(DAY, FindDateTime)=20 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "20"
--		  , (case when DATEPART(DAY, FindDateTime)=21 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "21"
--		  , (case when DATEPART(DAY, FindDateTime)=22 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "22"
--		  , (case when DATEPART(DAY, FindDateTime)=23 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "23"
--		  , (case when DATEPART(DAY, FindDateTime)=24 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "24"
--		  		  , (case when DATEPART(DAY, FindDateTime)=25 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "25"
--		  , (case when DATEPART(DAY, FindDateTime)=26 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "26"
--		  , (case when DATEPART(DAY, FindDateTime)=27 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "27"
--		  , (case when DATEPART(DAY, FindDateTime)=28 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "28"
--		  , (case when DATEPART(DAY, FindDateTime)=29 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "29"
--		  , (case when DATEPART(DAY, FindDateTime)=30 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "30"
--		  , (case when DATEPART(DAY, FindDateTime)=31 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "31"

--	from DRI 
--			LEFT OUTER JOIN STB_RouteInfo          RI	    ON DRI.FindRouteCode = RI.RouteCode
--			  LEFT OUTER JOIN STB_MaterialMaster   MM2	    ON DRI.MaterialCode = MM2.MaterialCode
--			  LEFT OUTER JOIN STB_LineInfo         LI	    ON DRI.InputLineCode = LI.LineCode			 
--			  LEFT OUTER JOIN STB_MachineMaster    MM	    ON DRI.MachineCode = MM.MachineCode
--			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	    ON DRI.WorkerCode = PWI.WorkerCode
	
--	 group by 	  --DRI.ControlNo
--	      --,DRI.Barcode
--		  DRI.MaterialCode
--		  ,MM2.MaterialName
--		  ,DRI.InputLineCode
--		  ,LI.LineName
--		  ,DRI.RouteCode
--		  ,RI.RouteName		
--		  ,DRI.FindDateTime
--	)
--	select 	 'VVT' as CompanyCode
--		  ,@ToMonth as 기준년월
--		  ,MaterialCode
--		  ,MaterialName as 사이즈
--		  ,InputLineCode as LineCode
--		  ,LineName
--		  ,RouteCode
--		  ,RouteName,	
--		  sum(total) as 월누적수량,
--		   sum("1") as "Day01" ,
--		   sum("2") as "Day02" ,
--		   sum("3") as "Day03" ,
--		   sum("4") as "Day04" ,
--		   sum("5") as "Day05" ,
--		   sum("6") as "Day06" ,
--		   sum("7") as "Day07" ,
--		   sum("8") as "Day08" ,
--		   sum("9") as "Day09" ,
--		  sum("10") as "Day10" ,
--		  sum("11") as "Day11" ,
--		  sum("12") as "Day12" ,
--		  sum("13") as "Day13" ,
--		  sum("14") as "Day14" ,
--		  sum("15") as "Day15" ,
--		  sum("16") as "Day16" ,
--		  sum("17") as "Day17" ,
--		  sum("18") as "Day18" ,
--		  sum("19") as "Day19" ,
--		  sum("20") as "Day20" ,
--		  sum("21") as "Day21" ,
--		  sum("22") as "Day22" ,
--		  sum("23") as "Day23" ,
--		  sum("24") as "Day24" ,
--		  sum("25") as "Day25" ,
--		  sum("26") as "Day26" ,
--		  sum("27") as "Day27" ,
--		  sum("28") as "Day28" ,
--		  sum("29") as "Day29" ,
--		  sum("30") as "Day30" ,
--		  sum("31") as "Day31" 
		  
--		  from deptrai

--		  --where 1=1
--			--AND (@RouteCode = '*' OR RouteCode = @RouteCode)
--			--AND (@SizeCode = '*' OR MaterialName   = @SizeCode)
--		  group by 	 MaterialCode
--		  ,MaterialName
--		  ,InputLineCode
--		  ,LineName
--		  ,RouteCode
--		  ,RouteName		
	
--	end
	

END