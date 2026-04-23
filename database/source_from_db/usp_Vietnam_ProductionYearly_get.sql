
--        exec usp_Vietnam_ProductionYearly_get '','','VVT','2021-03-01','2021-05-01','','','',''   

CREATE  PROCEDURE [dbo].[usp_Vietnam_ProductionYearly_get]
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
	
	--select @pMaterialCode = convert(varchar(20),@pToDate,120)
	--raiserror (@pMaterialCode,16,1)
	--return

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
	--EXEC sp_columns STB_VVT_ProductionRecord_VVT

	declare @count INT=0
	select @count = count(*) from STB_VVT_ProductionRecord_VVT with(nolock)  where IsDeleted<>1 and [Year]<>'Total'
	if(@count>0) begin

	--SELECT VendorID, Employee, Orders  
	--FROM   
	--   (SELECT VendorID, Emp1, Emp2, Emp3, Emp4, Emp5  
	--   FROM pvt) p  
	--UNPIVOT  
	--   (Orders FOR Employee IN   
	--      (Emp1, Emp2, Emp3, Emp4, Emp5)  
	--)AS unpvt;  

	select @FromDate   = CONVERT(VARCHAR(10), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pFromDate)), 120) 

	;with newtb as ( 
		select
			Size,
			Capa,
			"Year",		
			 case when ProdMonth='Jan' then  1 
				  when ProdMonth='Feb' then  2 
				  when ProdMonth='Mar' then  3 
				  when ProdMonth='Apr' then  4 
				  when ProdMonth='May' then  5 
				  when ProdMonth='Jun' then  6 
				  when ProdMonth='Jul' then  7 
				  when ProdMonth='Aug' then  8 
				  when ProdMonth='Sep' then  9 
				  when ProdMonth='Oct' then  10  
				  when ProdMonth='Nov' then  11  
				  when ProdMonth='Dec' then  12  
			 else ProdMonth end as ProdMonth,
			 ProdQty
		from 
				(select * from STB_VVT_ProductionRecord_VVT  with(nolock) where IsDeleted<>1 and [Year]<>'Total'
								and "Year" between DATEPART(year,@FromDate) and DATEPART(year,@ToDate)
								 ) p
			UNPIVOT
			(
				ProdQty for ProdMonth in (Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec)
			) as unpvt
	)
	select 	Size,
			Capa,
			"Year",	
			ProdMonth,
			--ProdQty
			case when 
				(case when ProdMonth=1 then convert(varchar(4),"Year")+'-01'
				when ProdMonth=2  then convert(varchar(4),"Year")+'-02'
				when ProdMonth=3  then convert(varchar(4),"Year")+'-03'
				when ProdMonth=4  then convert(varchar(4),"Year")+'-04'
				when ProdMonth=5  then convert(varchar(4),"Year")+'-05'
				when ProdMonth=6  then convert(varchar(4),"Year")+'-06'
				when ProdMonth=7  then convert(varchar(4),"Year")+'-07'
				when ProdMonth=8  then convert(varchar(4),"Year")+'-08'
				when ProdMonth=9  then convert(varchar(4),"Year")+'-09'
				when ProdMonth=10 then convert(varchar(4),"Year")+'-10'
				when ProdMonth=11 then convert(varchar(4),"Year")+'-11'
				when ProdMonth=12 then convert(varchar(4),"Year")+'-12'
				end ) between @FromDate and @ToDate 
			then ProdQty 
			else 0 end  
			as ProdQty
				--convert(datetime,("Year"+'-'+ case when ProdMonth<10 then '0' + convert(varchar(2),ProdMonth) else convert(varchar(2),ProdMonth) end+'-26'),120)
				--	 between @FromDate and @ToDate 
				-- then ProdQty 
				 --else 0 end
	from newtb
	order by Size,capa,"Year";
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

		  sum(mli.CurrentQty) as ProdQty,
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
),
pivot1 as (
--select * from (
	select 
		sum(ProdQty) as ProdQty,
		partno,
		Size,
		convert(varchar(4),ProdYear) as ProdYear,
		ProdMonth
	from DRI
	group by Size,partno,ProdYear,ProdMonth
--)  newtab1
--PIVOT (sum(ProdQty) for  ProdMonth in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) as pivottab
)
, lastdata as (
select
		Size,
		partno as Capa,
		 ProdYear as "Year",
		 ProdQty,
		 ProdMonth
--		convert(INT,isnull("1",0) )as "Jan",
--		convert(INT,isnull("2",0) )as "Feb",
--		convert(INT,isnull("3",0) )as "Mar",
--		convert(INT,isnull("4",0) )as "Apr",
--		convert(INT,isnull("5",0) )as "May",
--		convert(INT,isnull("6",0) )as "Jun",
--		convert(INT,isnull("7",0) )as "Jul",
--		convert(INT,isnull("8",0) )as "Aug",
--		convert(INT,isnull("9",0) )as "Sep",
--		convert(INT,isnull("10",0)) as "Oct",
--		convert(INT,isnull("11",0)) as "Nov",
--		convert(INT,isnull("12",0)) as "Dec",

--convert(INT,isnull("1",0) + isnull("2",0) + isnull("3",0) + isnull("4",0) + isnull("5",0) + isnull("6",0) + isnull("7",0) + 
--isnull("8",0) + isnull("9",0) + isnull("10",0) + isnull("11",0) + isnull("12",0))  as Total

from pivot1
--union
--select
--		--sum(ProdQty) as ProdQty, convert(INT,
--		Size,
--		partno as Capa,		
--		'Total' as "Year",
--		 sum(ProdQty) as ProdQty,
--		 ProdMonth
--		--convert(INT,sum(isnull("1",0)) ,0) as  "Jan",  
--		--convert(INT,sum(isnull("2",0)) ,0) as  "Feb",  
--		--convert(INT,sum(isnull("3",0)) ,0) as  "Mar",  
--		--convert(INT,sum(isnull("4",0)) ,0) as  "Apr",  
--		--convert(INT,sum(isnull("5",0)) ,0) as  "May",  
--		--convert(INT,sum(isnull("6",0)) ,0) as  "Jun",  
--		--convert(INT,sum(isnull("7",0)) ,0) as  "Jul",  
--		--convert(INT,sum(isnull("8",0)) ,0) as  "Aug",  
--		--convert(INT,sum(isnull("9",0)) ,0) as  "Sep",  
--		--convert(INT,sum(isnull("10",0)),0)  as  "Oct", 
--		--convert(INT,sum(isnull("11",0)),0)  as  "Nov", 
--		--convert(INT,sum(isnull("12",0)),0)  as  "Dec", 

--		--convert(INT,sum(isnull("1",0)) + sum(isnull("2",0)) + sum(isnull("3",0)) + sum(isnull("4",0)) + sum(isnull("5",0)) + sum(isnull("6",0)) + 
--		--sum(isnull("7",0)) + sum(isnull("8",0)) + sum(isnull("9",0)) + sum(isnull("10",0)) + sum(isnull("11",0)) + sum(isnull("12",0)))  as Total
--from pivot1
--group by Size,partno,		 	 ProdMonth
)
select *from lastdata
order by Size,capa,"Year"

end

END

--       exec usp_Vietnam_ProductionYearly_get '','','VVT','2020-01-01','2021-06-01','','','','' 


--select*from
--STB_MaterialLotInfo
--where MaterialCode='GAJCFO-002' and CompanyCode='VVT' and MaterialWarehouseCode<>'ROUTE_VN_WH'



--select lotid from
--STB_MaterialDocLotInfo
--where MaterialCode='GAJCFO-002' and  MaterialLocationCode not like 'ROUTE_VN_WH%' and  MaterialLocationCode not like 'ROH_WH_01%'
--and LotAttr10<>'2021-04-27'
--except 
--(select lotid from
--STB_MaterialLotInfo
--where MaterialCode='GAJCFO-002' and CompanyCode='VVT' and MaterialWarehouseCode<>'ROUTE_VN_WH'
--union
--select lotid from
--STB_MaterialLotSnapshot
--where MaterialCode='GAJCFO-002' and CompanyCode='VVT' and MaterialWarehouseCode<>'ROUTE_VN_WH'
--)





--select * from
--STB_MaterialDocLotInfo
--where MaterialCode='SREYPB6' and  MaterialLocationCode not like 'ROUTE_VN_WH%' and  MaterialLocationCode not like 'ROH_WH_01%'
----and LotAttr10>'2021-04-27'
--order by LotAttr10