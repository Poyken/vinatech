
--        exec   usp_Vietnam_ProductionYearlyIUD_get  '','','VVT','2021-03-01','2021-06-01','','','',''   

CREATE  PROCEDURE [dbo].[usp_Vietnam_ProductionYearlyIUD_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL--,--
	--@pGetFrom26 BIT = 0
AS	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pFromDate)), 120)  +'-26'   + ' 10:30:00'
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pToDate)), 120)  +'-26'   + ' 10:30:00'
	
	--if(@pGetFrom26=1)
	--begin
	--	select @FromDate    = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pMonth)), 120)  +'-26'   + ' 10:30:00'
	--	select @ToDate      = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @pMonth)), 120) +'-26'   + ' 10:30:00'
	--end

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	SET NOCOUNT ON;

declare @count INT=0
select @count = count(*) from STB_VVT_ProductionRecord_VVT with(nolock)  where IsDeleted<>1 and [Year]<>'Total'

if(@count>0) begin

	select @FromDate   = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pFromDate)), 120) 

	;with newtb as (
		select
			Id,
			Size,
			Capa,
			"Year",		
			case when convert(varchar(4),"Year") + (case when Jan>=0 then '-01' end) between @FromDate and @ToDate  then Jan else 0 end as Jan,
			case when convert(varchar(4),"Year") + (case when Feb>=0 then '-02' end) between @FromDate and @ToDate  then Feb else 0 end as Feb,
			case when convert(varchar(4),"Year") + (case when Mar>=0 then '-03' end) between @FromDate and @ToDate  then Mar else 0 end as Mar,
			case when convert(varchar(4),"Year") + (case when Apr>=0 then '-04' end) between @FromDate and @ToDate  then Apr else 0 end as Apr,
			case when convert(varchar(4),"Year") + (case when May>=0 then '-05' end) between @FromDate and @ToDate  then May else 0 end as May,
			case when convert(varchar(4),"Year") + (case when Jun>=0 then '-06' end) between @FromDate and @ToDate  then Jun else 0 end as Jun,
			case when convert(varchar(4),"Year") + (case when Jul>=0 then '-07' end) between @FromDate and @ToDate  then Jul else 0 end as Jul,
			case when convert(varchar(4),"Year") + (case when Aug>=0 then '-08' end) between @FromDate and @ToDate  then Aug else 0 end as Aug,
			case when convert(varchar(4),"Year") + (case when Sep>=0 then '-09' end) between @FromDate and @ToDate  then Sep else 0 end as Sep,
			case when convert(varchar(4),"Year") + (case when Oct>=0 then '-10' end) between @FromDate and @ToDate  then Oct else 0 end as Oct,
			case when convert(varchar(4),"Year") + (case when Nov>=0 then '-11' end) between @FromDate and @ToDate  then Nov else 0 end as Nov,
			case when convert(varchar(4),"Year") + (case when "Dec">=0 then '-12' end) between @FromDate and @ToDate  then "Dec" else 0 end as "Dec",
			ChangeDateTime,
			ChangeUserId,
			IsDeleted
		from STB_VVT_ProductionRecord_VVT with(nolock) where IsDeleted<>1 and [Year]<>'Total'
				and "Year" between DATEPART(year,@FromDate) and DATEPART(year,@ToDate)
	)	
	select 
	*,
	(Jan+Feb+Mar+Apr+May+Jun+Jul+Aug+Sep+Oct+Nov+"Dec") as Total 
	from newtb

end

else 
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
		 		 and b.RouteCode='V-28'
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime
)
,
--AlloyView as (
--select RawView.* --, 
	--(row_number() over (partition by RawView.Barcode order by RawView.RouteCode ASC) )     as Routerank 
		--, (row_number() over (partition by RawView.Barcode order by RawView.ProdDateTime ASC) )  as Timerank 	
		--, prh.ProdDateTime as maxProdDateTime
		--, ( count(prh.RouteCode))  as total
		--  from RawView
		  --join STB_ProdRouteHist  prh with(nolock) on RawView.ControlNo = prh.ControlNo --and RawView.RouteCode = prh.RouteCode
		  --group by Barcode,RawView.RouteCode, FindRouteCode,RawView.ControlNo,RawView.MaterialCode,InputLineCode,
		  --RawView.MachineCode,RawView.WorkerCode,SIExtText07,SIExtInt01,RawView.ProdQty,RawView.DefectQty,RawView.ProdDateTime--, prh.ProdDateTime
--)
DRI as(
		select  
		 RV.Barcode,
		 RV.RouteCode,
		 RV.RouteCode as FindRouteCode,
		 ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		 RV.ProdDateTime, 
		 DATEPART(DAY, ProdDateTime)  as FindDateTime, 

		  		  sum(mli.CurrentQty) as ProdQty,--max(RV.ProdQty) as ProdQty,
		  sum(RV.DefectQty - RV.RepairQty) as DefectQty, 
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
		  --DATEPART(YEAR, ProdDateTime)  as ProdYear,
		  case when ((DATEPART(DAY, ProdDateTime)>25 and DATEPART(HOUR, ProdDateTime) > 10) or
					(DATEPART(DAY, ProdDateTime)>25 and DATEPART(HOUR, ProdDateTime) = 10 and DATEPART(MINUTE, ProdDateTime)>=30)) then DATEPART(YEAR, DATEADD(MONTH,1,ProdDateTime)) 
					else  DATEPART(YEAR, ProdDateTime) end
		   as ProdYear,
		  --DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		  case when ((DATEPART(DAY, ProdDateTime)>25 and DATEPART(HOUR, ProdDateTime) > 10) or
					(DATEPART(DAY, ProdDateTime)>25 and DATEPART(HOUR, ProdDateTime) = 10 and DATEPART(MINUTE, ProdDateTime)>=30)) then DATEPART(MONTH, DATEADD(MONTH,1,ProdDateTime)) 
					else  DATEPART(MONTH, ProdDateTime) end
		   as ProdMonth,
		  DATEPART(DAY, ProdDateTime)  as ProdDay,
		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
		  --substring(MM2.MaterialName,CHARINDEX(' ',MM2.MaterialName)+1,CHARINDEX(' ',MM2.MaterialName)-CHARINDEX(' ',MM2.MaterialName)-1 ) as Size
		   --(RTRIM(LTRIM(SUBSTRING(MM2.MaterialName, CHARINDEX(' ', MM2.MaterialName), 12))) ) AS partno,
		   mbi.MBIExtText05 +'F' as partno,
		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as Size
		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
			  left outer join STB_ModelBasicInfo   mbi with(nolock) on mbi.ModelCode = rv.MaterialCode
		where 
		( 
			(mli.Lotno is not null ) 
			--or -- RV.routecode='V-22' or 
			--(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
			--(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime,mbi.MBIExtText05
		--order by RV.Barcode,RV.RouteCode 
)

,
pivot1 as (
select * from (
	select 
		sum(ProdQty) as ProdQty,
		partno,
		Size,
		convert(varchar(4),ProdYear) as ProdYear,
		ProdMonth
	from DRI
	group by Size,partno,ProdYear,ProdMonth
)  newtab1
PIVOT (sum(ProdQty) for  ProdMonth in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as pivottab
)
, lastdata as (
select
		0 as IsDeleted,
		Size,
		partno as Capa,
		 ProdYear as "Year",
		convert(INT,isnull("1",0) )as "Jan",
		convert(INT,isnull("2",0) )as "Feb",
		convert(INT,isnull("3",0) )as "Mar",
		convert(INT,isnull("4",0) )as "Apr",
		convert(INT,isnull("5",0) )as "May",
		convert(INT,isnull("6",0) )as "Jun",
		convert(INT,isnull("7",0) )as "Jul",
		convert(INT,isnull("8",0) )as "Aug",
		convert(INT,isnull("9",0) )as "Sep",
		convert(INT,isnull("10",0)) as "Oct",
		convert(INT,isnull("11",0)) as "Nov",
		convert(INT,isnull("12",0)) as "Dec",

convert(INT,isnull("1",0) + isnull("2",0) + isnull("3",0) + isnull("4",0) + isnull("5",0) + isnull("6",0) + isnull("7",0) + 
isnull("8",0) + isnull("9",0) + isnull("10",0) + isnull("11",0) + isnull("12",0))  as Total

from pivot1
--union
--select
--		--sum(ProdQty) as ProdQty, convert(INT,
--		0 as IsDeleted,
--		Size,
--		partno as Capa,		
--		'Total' as "Year",
--		convert(INT,sum(isnull("1",0)) ,0) as  "Jan",  
--		convert(INT,sum(isnull("2",0)) ,0) as  "Feb",  
--		convert(INT,sum(isnull("3",0)) ,0) as  "Mar",  
--		convert(INT,sum(isnull("4",0)) ,0) as  "Apr",  
--		convert(INT,sum(isnull("5",0)) ,0) as  "May",  
--		convert(INT,sum(isnull("6",0)) ,0) as  "Jun",  
--		convert(INT,sum(isnull("7",0)) ,0) as  "Jul",  
--		convert(INT,sum(isnull("8",0)) ,0) as  "Aug",  
--		convert(INT,sum(isnull("9",0)) ,0) as  "Sep",  
--		convert(INT,sum(isnull("10",0)),0)  as  "Oct", 
--		convert(INT,sum(isnull("11",0)),0)  as  "Nov", 
--		convert(INT,sum(isnull("12",0)),0)  as  "Dec", 

--		convert(INT,sum(isnull("1",0)) + sum(isnull("2",0)) + sum(isnull("3",0)) + sum(isnull("4",0)) + sum(isnull("5",0)) + sum(isnull("6",0)) + 
--		sum(isnull("7",0)) + sum(isnull("8",0)) + sum(isnull("9",0)) + sum(isnull("10",0)) + sum(isnull("11",0)) + sum(isnull("12",0)))  as Total
--from pivot1
--group by Size,partno
)
select *from lastdata
order by Size,capa,"Year"

end

END

--       exec usp_Vietnam_ProductionYearlyiud_get '','','VVT','2021-01-01','2021-06-01','','','','' 

