
CREATE PROCEDURE [dbo].[usp_bomreport_get_TEST]          --- exec  [usp_bomreport_get_TEST] '','','2023-01-01','2023-03-31'
	@pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
    @pFromDate Date = NULL,
    @pToDate Date = NULL
AS
BEGIN

--select '' as tung
--return;

declare

	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = 'VVT',  
	--@pMonth DATETIME = '2022-09-01',

	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL


	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	--DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pFromDate)), 120)  +'-01'   + ' 10:30:00'
	--DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 1, CONVERT(smalldatetime, @pToDate)), 120)  +'-01'   + ' 10:30:00'
	
	DECLARE @FromDate    VARCHAR(19)  =  CONVERT(VARCHAR(10),  @pFromDate )               +  ' 10:00:00'  
	DECLARE @ToDate      VARCHAR(19)  =  CONVERT(VARCHAR(10),  dateadd(day,1,@pToDate) )  +  ' 10:00:00'  
	


;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode=@CompanyCode  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
	 ),
RawView as (
	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,--InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, sum(isnull(a.DefectQty,0)) as DefectQty,  sum(isnull(a.RepairQty,0)) as RepairQty ,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,b.CreateDateTime
		 --,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
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
		 ControlNo,RV.MaterialCode,		
		 --RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 
		 MM2.MaterialName,
		 --li.LineName, pwi.WorkerName,mm.MachineName,
		 RV.ProdDateTime, 

		 DATEPART(DAY, ProdDateTime)  as FindDateTime, 

		  max(isnull(RV.ProdQty,0)) as ProdQty,
		  sum(isnull(RV.DefectQty,0) - isnull(RV.RepairQty,0) ) as DefectQty, 
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate--,  
		--  DATEPART(YEAR, ProdDateTime)  as ProdYear,
		--  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		--  DATEPART(DAY, ProdDateTime)  as ProdDay,
		--  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		--  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		--  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
		--  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode
		----, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
		from RawView RV 
		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			--  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			--  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	
		where 
		( 
			(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,--RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,	 RV.ProdDateTime --	, li.LineName, pwi.WorkerName,mm.MachineName		 
		--order by RV.Barcode,RV.RouteCode 
)
, NG_SX as
(select * from
(	select
		  -- 'VVT'   AS 사업장
		  --,DRI.ControlNo
	      --,DRI.Barcode
		  --,
		  DRI.MaterialCode as materialco
		  ,MaterialName as materialna
		 -- ,InputLineCode
		--  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		   --,DRI.RouteCode as RouteCode1
		 -- ,RouteName
		 -- , sum(DRI.ProdQty) ProdQty
		 -- ,sum(DRI.ProdQty - (DRI.DefectQty))  as GoodQty
		
		  ,sum(isnull(DRI.DefectQty,0)) as DefectQty
		  
	from DRI  WITH(NOLOCK)  
			--LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
			--  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
			--  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)     ON InputLineCode = LI.LineCode			 
			--  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)     ON DRI.MachineCode = MM.MachineCode
			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)    ON DRI.WorkerCode = PWI.WorkerCode
     --where 1=1
	   --AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   --AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode   = @MaterialCode)
	  -- and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   --and MaterialCode='LIVT38-018'
	 group by 	  --DRI.ControlNo 
	      --,DRI.Barcode 
		  DRI.MaterialCode 
		  ,MaterialName 
		 -- ,InputLineCode 
		--  ,LI.LineName 
		  ,DRI.RouteCode 
		 -- ,RouteName		
		  --,DRI.FindDateTime 
		)tb11
	 pivot (		   
 sum(DefectQty)
		  for routecode in ([V-22],[V-23],[V-24],[V-25],[V-26],[V-27],[V-29],[V-30],[V-31],[V-32],
[V-33],[V-34],[V-35],[V-99],[MV-01],[MV-02],[MV-03],[MV-04])
		  ) newtb
) 
,fg1 as(
select coalesce(si.MaterialCode,lc.BefMaterialCode,fg.MaterialCode) MaterialCode, sum(PackQty) fgqty
from STB_VN_FINISHGOODS          fg  with(nolock)
left outer join STB_SetInfo      si with(nolock) on fg.LotNo=si.Barcode
left outer join STB_LotChangeMaterialHistory lc with(nolock) on fg.LotNo=lc.OldBarcode
where fg.CreateDate between @FromDate and @ToDate
and fg.Flag=1
and PackQty is not null
group by coalesce(si.MaterialCode,lc.BefMaterialCode,fg.MaterialCode)
) 
,data1 as (
select   isnull(materialco,MaterialCode)MaterialCode 
, materialna as materialnam
,isnull(fgqty,1) fgqty 
,(  isnull("V-22",0)+	isnull("V-23",0)+	isnull("V-24",0)+	isnull("V-25",0)+	isnull("V-26",0)+	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg22
,(	isnull("V-23",0)+	isnull("V-24",0)+	isnull("V-25",0)+	isnull("V-26",0)+	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg23
,(	isnull("V-23",0)+	isnull("V-24",0)+	isnull("V-25",0)+	isnull("V-26",0)+	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg24
,(	isnull("V-25",0)+	isnull("V-26",0)+	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg25
,(	isnull("V-26",0)+	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg26
,(	isnull("V-27",0)+	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg27
,(	isnull("V-29",0)+	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg29
,(	isnull("V-30",0)+	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg30
,(	isnull("V-31",0)+	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg31
,(	isnull("V-32",0)+	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg32
,(	isnull("V-33",0)+	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg33
,(	isnull("V-34",0)+	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg34
,(	isnull("V-35",0)+	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg35
,(	isnull("V-99",0)+	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNg99
,(	isnull("MV-01",0)+	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNgmv01
,(	isnull("MV-02",0)+	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNgmv02
,(	isnull("MV-03",0)+	isnull("MV-04",0)) as TongNgmv03 
,(	isnull("MV-04",0)) as TongNgmv04
 from  NG_SX   
 full  outer  join  fg1   on NG_SX.materialco=fg1.MaterialCode 
 )

,
deptrai as (
	select
		  --'VVT'   AS 사업장
		  --,DRI.ControlNo
	      --,DRI.Barcode
		  --,
		  DRI.MaterialCode as materialco
		  ,MaterialName as materialna
		 -- ,InputLineCode
		--  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RouteName
		  , sum(DRI.ProdQty) ProdQty
		  	  ,sum(DRI.ProdQty - (DRI.DefectQty))  as GoodQty
		
		  ,sum(DRI.DefectQty) as DefectQty
		  
	from DRI  WITH(NOLOCK)  
			--LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
			--  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
			--  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)     ON InputLineCode = LI.LineCode			 
			--  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)     ON DRI.MachineCode = MM.MachineCode
			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)    ON DRI.WorkerCode = PWI.WorkerCode
     --where 1=1
	   --AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   --AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode   = @MaterialCode)
	  -- and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   --and MaterialCode='LIVT38-018'
	 group by 	  --DRI.ControlNo 
	      --,DRI.Barcode 
		  DRI.MaterialCode 
		  ,MaterialName 
		 -- ,InputLineCode 
		--  ,LI.LineName 
		  ,DRI.RouteCode 
		  ,RouteName		
		  --,DRI.FindDateTime 
	) 

, b11 as (
	select  b1.MaterialCode,	max(b1.BomVersion)BomVersion,ChildMaterialCode, mm.ProductGroupCode
	from STB_BomDetail b1  with(nolock) 
	join STB_BomHeader bh  with(nolock) on b1.MaterialCode=bh.MaterialCode and b1.BomVersion=bh.BomVersion
	join STB_MaterialMaster mm  with(nolock) on b1.ChildMaterialCode=mm.MaterialCode
	where 
	isnull(bh.IsUsed,convert(bit,0))<>convert(bit,0) and
	b1.BomVersion='99' 
	 --(b1.BomVersion='99' and len(rtrim(ltrim(b1.BomVersion)))='99' and b1.BomVersion='99' )
	 group by b1.MaterialCode,	ChildMaterialCode, mm.ProductGroupCode,mm.MaterialName
	 --having  mm.ProductGroupCode in ('SLITTING-ROLL','COATING-ROLL','JELLY-ROLL','BINDER','SLEEVE','SURFACTANT','FOIL','A.C','CARBON','HC-EDLC','HC-VPC') 
)


--	,
--	b11 as (
--select  b1.MaterialCode,	max(b1.BomVersion)BomVersion,ChildMaterialCode, mm.ProductGroupCode
--from STB_BomDetail b1 
--join STB_BomHeader bh on b1.MaterialCode=bh.MaterialCode and b1.BomVersion=bh.BomVersion
--join STB_MaterialMaster mm on b1.ChildMaterialCode=mm.MaterialCode
--where (select count(*) from b10 where )=0
--)


,bom as
(  
	select 
	case when materialcode='GCMTAW-001' then 'GCTN00-003' else materialcode end as
	materialcode, 

	MaterialCode1, 

	MaterialName,

	--(select count(distinct m1.ProductGroupCode+b0.ChildMaterialCode) 
	--from STB_BomDetail b0 
	--join STB_MaterialMaster m1 on b0.ChildMaterialCode=m1.MaterialCode 
	--where b0.materialcode=tb123.materialcode1 and m1.ProductGroupCode=tb123.ProductGroupCode
	--and b0.UsedQty<=2
	--) as totalissue, 

	case when 
	(MaterialName like '%슬리브%' or MaterialName like '%sleeve%')
	and (MaterialName like '%5R4%' or MaterialName like '%6R0%' or MaterialName like '%7R5%' or MaterialName like '%8R1%'
	or MaterialName like '%9R0%' or MaterialName like '%10R0%' or MaterialName like '%11R0%' or MaterialName like '%12R0%'
	 or MaterialName like '%13R0%')
	then 'MD-SLEEVE' else ProductGroupCode end as
	ProductGroupCode, 

	max(usedqty) as usedqty, 

	--case when ProductGroupCode in ('BINDER','JELLY-ROLL','SLITTING-ROLL','COATING-ROLL','SURFACTANT','FOIL','A.C','CARBON') then ProductGroupCode + right(convert(varchar(10),row_number() over ( order by ProductGroupCode,childmaterialcode)),1) else ProductGroupCode end as ProductGroupCode,
	ChildMaterialCode 

	from (
	select  
	distinct 
	b1.materialcode,
	b1.CreateDateTime,--b1.ChildMaterialCode,--mm.MaterialName,
	 mm.ProductGroupCode,
	 mm.MaterialName, --count(mm.ProductGroupCode) as totalissue,
	coalesce(
	b6.usedqty*
	b5.usedqty*
	b4.usedqty*
	b3.usedqty*
	b2.usedqty*
	b1.usedqty*1000000,
	b5.usedqty*
	b4.usedqty*
	b3.usedqty*
	b2.usedqty*
	b1.usedqty*1000000,
	b4.usedqty*
	b3.usedqty*
	b2.usedqty*
	b1.usedqty*1000000,

	b3.usedqty*
	b2.usedqty*
	b1.usedqty*1000000,
	b2.usedqty*
	b1.usedqty*1000000,
	b1.usedqty*1000000
) as usedqty,

case when mm.ProductGroupCode in ('BINDER','SURFACTANT','CARBON','A.C','FOIL') then
substring(coalesce(
b6.MaterialCode,
b5.MaterialCode,
b4.MaterialCode,
b3.MaterialCode,
b2.MaterialCode,
b1.MaterialCode
),3,1) else '' end as MaterialCode1,

coalesce(
b6.ChildMaterialCode,
b5.ChildMaterialCode,
b4.ChildMaterialCode,
b3.ChildMaterialCode,
b2.ChildMaterialCode,
b1.ChildMaterialCode
) as ChildMaterialCode

from STB_BomDetail b1  with(nolock) 

left outer join STB_BomDetail b2  with(nolock) on b2.MaterialCode=b1.ChildMaterialCode and b2.MaterialCode<>b2.ChildMaterialCode  and  (b2.BomVersion='99' )

left outer join STB_BomDetail b3  with(nolock) on b3.MaterialCode=b2.ChildMaterialCode and b3.MaterialCode<>b3.ChildMaterialCode  and  (b3.BomVersion='99' )

left outer join STB_BomDetail b4  with(nolock) on b4.MaterialCode=b3.ChildMaterialCode and b4.MaterialCode<>b4.ChildMaterialCode  and  (b4.BomVersion='99' )

left outer join STB_BomDetail b5  with(nolock) on b5.MaterialCode=b4.ChildMaterialCode and b5.MaterialCode<>b5.ChildMaterialCode  and  (b5.BomVersion='99' )

left outer join STB_BomDetail b6  with(nolock) on b6.MaterialCode=b5.ChildMaterialCode and b6.MaterialCode<>b6.ChildMaterialCode  and  (b6.BomVersion='99' )

left outer join STB_MaterialMaster mm on coalesce(
b6.ChildMaterialCode,
b5.ChildMaterialCode,
b4.ChildMaterialCode,
b3.ChildMaterialCode,
b2.ChildMaterialCode,
b1.ChildMaterialCode
)=mm.MaterialCode and b1.MaterialCode<>b1.ChildMaterialCode and  (b1.BomVersion='99' )

 join  b11 on (coalesce(
b6.MaterialCode,
b5.MaterialCode,
b4.MaterialCode,
b3.MaterialCode,
b2.MaterialCode,
b1.MaterialCode
))=b11.MaterialCode and (coalesce(
b6.BomVersion,
b5.BomVersion,
b4.BomVersion,
b3.BomVersion,
b2.BomVersion,
b1.BomVersion
))=b11.BomVersion

where (b11.BomVersion='99' ) and 

--isnull(b11.IsUsed,convert(bit,0))<>convert(bit,0) and
coalesce( 
b6.usedqty*
b5.usedqty*
b4.usedqty*
b3.usedqty*
b2.usedqty*
b1.usedqty*1000000,

b5.usedqty*
b4.usedqty*
b3.usedqty*
b2.usedqty*
b1.usedqty*1000000,

b4.usedqty*
b3.usedqty*
b2.usedqty*
b1.usedqty*1000000,

b3.usedqty*
b2.usedqty*
b1.usedqty*1000000,

b2.usedqty*
b1.usedqty*1000000,

b1.usedqty*1000000
)<=2*1000000  

--and mm.MaterialCode in ( 
--select  distinct materialcode  from STB_MaterialLotInfo  with(nolock) 
--where CreateDateTime>'2022-01-01' and MaterialWarehouseCode='ROUTE_VN_WH'  
--) 
--and b1.MaterialCode like 'ED%' 
--and b1.ChildMaterialCode not like 'SLV_%'
 ) tb123 
 --where  ProductGroupCode is not null and ProductGroupCode<>'' 
 group by materialcode, MaterialCode1, 
ProductGroupCode, 
ChildMaterialCode  ,MaterialName
--having ProductGroupCode<>'BINDER' 
) 

,bom1 as (
select *
, case when ProductGroupCode in (
'A.C',
'BINDER',
'CARBON',
'FOIL',
'COATING-ROLL',
'SLITTING-ROLL',
'JELLY-ROLL',
'SEPARATOR',
'SURFACTANT',
'TERMINAL',
'PI-TAPE',
'ATL-TERMINAL'
) then 'V-22' 

-- when ProductGroupCode in (
--'RUBBER-PAD'
--) then 'V-23' 

 when ProductGroupCode in (
'CASE',
'RUBBER-PAD',
'WASHER',
'TERMINAL-PLATE',
'ELECTROLYTE'
) then 'V-24' 

 when ProductGroupCode in (
 'BOTTOM-PLATE',
'SLEEVE'
) then 'V-25' 

 when ProductGroupCode in (
'HC-EDLC',
'MD-CHIP',
'MD-PCB ',
'MD-WIRE','MD-HARNESS'
) then 'MV-01' 

 when ProductGroupCode in (
 'MD-SLEEVE'
) then 'MV-03' 

end as routeexpress,
case when ProductGroupCode<>'MD-SLEEVE' then 'MV-01' else 'MV-03' end as routemodule
from bom
)

--, materialOut as (
--	 select 
--	''사업장, '' MaterialCode, mdi.materialdoctypecode MaterialName1, '' RouteCode, '' RouteName,0 ProdQty,0 total,0 DefectQty,
--	MWIOH.SourceMaterialWarehouseCode matcode, 
--	MWIOH.TargetMaterialWarehouseCode, mm.MaterialName, '' ProductGroupCode,0 usedqty,MLI.MaterialCode ChildMaterialCode,
--	'' routeexpress,'' routemodule, MM.MaterialUnit, '' Ma_Lieu_DAU_KY,''  Ma_BTP_DAU_KY,''  Donvi_DAU_KY,0  Ton_DAU_KY,
--case when MWIOH.TargetMaterialWarehouseCode='ROUTE_VN_WH' then	sum(MLI.CurrentQty) end  Xuat_trong_ky,
--case when MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH' and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' 
--or   mdi.materialdoctypecode in ('GR_RETURN_MATERIAL') 
--then	sum(MLI.CurrentQty) end   Tra_lai_trong_ky,
--	0  Tong_TRONG_KY,0  Good_TRONG_KY,0  Defect_TRONG_KY,0  Ton_CUOI_KY
--	  FROM STB_MaterialWarehouseInOutHist MWIOH with(nolock)  
--	   LEFT OUTER JOIN  STB_MaterialLotInfo  MLI  with(nolock) on MWIOH.LotID=MLI.LotID 
--	   LEFT OUTER JOIN  STB_MaterialdocLotInfo  MDLI  with(nolock) on MDLI.LotID=MLI.LotID 
--	   left join STB_MaterialDocInfo mdi WITH(NOLOCK) ON  MDLI.MaterialDocNo = mdi.MaterialDocNo
--		 LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)   ON MM.MaterialCode = MDLI.MaterialCode   
--		 where (
--		           MWIOH.SourceMaterialWarehouseCode='ROH_VN_WH'   and MWIOH.TargetMaterialWarehouseCode<>'HOLDING_VN_WH' 
--				or MWIOH.SourceMaterialWarehouseCode='ROUTE_VN_WH' and MWIOH.TargetMaterialWarehouseCode='ROH_VN_WH' 
--		  )
--		  and MWIOH.CreateDateTime between @FromDate and @ToDate
--		 group by mdi.materialdoctypecode,MWIOH.SourceMaterialWarehouseCode,MWIOH.TargetMaterialWarehouseCode,MLI.MaterialCode,MM.MaterialUnit,mm.MaterialName 
--)
--, materialOut1 as (
--	 select 
--	''사업장, '' MaterialCode,  max(MaterialName1)MaterialName1, '' RouteCode, '' RouteName,0 ProdQty,0 total,0 DefectQty,
--	 max(matcode) matcode, 
--	max(TargetMaterialWarehouseCode) as TargetMaterialWarehouseCode, max(MaterialName) MaterialName, '' ProductGroupCode,0 usedqty, ChildMaterialCode,
--	'' routeexpress,'' routemodule, max(MaterialUnit) MaterialUnit, '' Ma_Lieu_DAU_KY,''  Ma_BTP_DAU_KY,''  Donvi_DAU_KY,0  Ton_DAU_KY,
--max(Xuat_trong_ky)  Xuat_trong_ky,
--max(Tra_lai_trong_ky)   Tra_lai_trong_ky,
--	0  Tong_TRONG_KY,0  Good_TRONG_KY,0  Defect_TRONG_KY,0  Ton_CUOI_KY
--	  FROM materialOut 
--		 group by ChildMaterialCode
--)

, lastqty as (
select isnull(deptrai.MaterialCo,bom1.MaterialCode) MaterialCot,deptrai.* ,bom1.*,replace(MaterialUnit,'KP','EA') as MaterialUnit  --isnull(b1.MaterialUnit,mm.MaterialUnit)MaterialUnit
--,''   Ma_Lieu_DAU_KY
--,''   Ma_BTP_DAU_KY
--,''  Donvi_DAU_KY
--,0 as Ton_DAU_KY
,0 Xuat_trong_ky
,0 Tra_lai_trong_ky
,(ProdQty)*bom1.usedqty/1000000   as Tong_TRONG_KY 
,(GoodQty)*bom1.usedqty/1000000     as Good_TRONG_KY 
,(DefectQty)*bom1.usedqty/1000000 as Defect_TRONG_KY 
,0 as Ton_CUOI_KY 
from deptrai 
left outer join bom1 on deptrai.MaterialCo=bom1.MaterialCode and (deptrai.RouteCode=bom1.routeexpress or deptrai.RouteCode=bom1.routemodule)
left outer join STB_MaterialMaster mm  with(nolock) on bom1.ChildMaterialCode=mm.MaterialCode
)

select *,
Ton_DAU_KY_723*usedqty/1000000 as NVL_tondauky_723,
Ton_Cuoi_KY_723*usedqty/1000000 as NVL_toncuoiky_723,
isnull(NG_Trong_KY_726,0)*usedqty/1000000 as NVL_NG_Trong_KY_726,

usedqty/1000000 as BOM_KY_THUAT--,


,case when Ton_DAU_KY_723 is null  then isnull( fgqty+(case 
when RouteCode='V-22' then TongNg22 
when RouteCode='V-23' then TongNg23
when RouteCode='V-24' then TongNg24
when RouteCode='V-25' then TongNg25
when RouteCode='V-26' then TongNg26
when RouteCode='V-27' then TongNg27
when RouteCode='V-29' then TongNg29
when RouteCode='V-30' then TongNg30
when RouteCode='V-31' then TongNg31
when RouteCode='V-32' then TongNg32
when RouteCode='V-33' then TongNg33
when RouteCode='V-34' then TongNg34
when RouteCode='V-35' then TongNg35
when RouteCode='V-99' then TongNg99
when RouteCode='MV-01' then TongNgmv01
when RouteCode='MV-02' then TongNgmv02
when RouteCode='MV-03' then TongNgmv03
when RouteCode='MV-04' then TongNgmv04
else 0 end) ,Tong_TRONG_KY) 

else ( 
isnull( fgqty+(case 
when RouteCode='V-22' then TongNg22 
when RouteCode='V-23' then TongNg23
when RouteCode='V-24' then TongNg24
when RouteCode='V-25' then TongNg25
when RouteCode='V-26' then TongNg26
when RouteCode='V-27' then TongNg27
when RouteCode='V-29' then TongNg29
when RouteCode='V-30' then TongNg30
when RouteCode='V-31' then TongNg31
when RouteCode='V-32' then TongNg32
when RouteCode='V-33' then TongNg33
when RouteCode='V-34' then TongNg34
when RouteCode='V-35' then TongNg35
when RouteCode='V-99' then TongNg99
when RouteCode='MV-01' then TongNgmv01
when RouteCode='MV-02' then TongNgmv02
when RouteCode='MV-03' then TongNgmv03
when RouteCode='MV-04' then TongNgmv04
else 0 end) ,Tong_TRONG_KY) 
+ 
(Ton_DAU_KY_723 - isnull(Ton_Cuoi_KY_723,0))
+
isnull( NG_Trong_KY_726 ,0) 
) end
/
case when Ton_DAU_KY_723 is null  then isnull(fgqty,case when Good_TRONG_KY=0 or Good_TRONG_KY is null then 1 else Good_TRONG_KY end) else
(
 isnull(fgqty,case when Good_TRONG_KY=0 or Good_TRONG_KY is null then 1 else Good_TRONG_KY end) 
+
(case when (Ton_DAU_KY_723 - isnull(Ton_Cuoi_KY_723,0))=-1 then 0 else Ton_DAU_KY_723 - isnull(Ton_Cuoi_KY_723,0) end)
)
end *usedqty/1000000
as DINHMUC

,(case 
when RouteCode='V-22' then TongNg22 
when RouteCode='V-23' then TongNg23
when RouteCode='V-24' then TongNg24
when RouteCode='V-25' then TongNg25
when RouteCode='V-26' then TongNg26
when RouteCode='V-27' then TongNg27
when RouteCode='V-29' then TongNg29
when RouteCode='V-30' then TongNg30
when RouteCode='V-31' then TongNg31
when RouteCode='V-32' then TongNg32
when RouteCode='V-33' then TongNg33
when RouteCode='V-34' then TongNg34
when RouteCode='V-35' then TongNg35
when RouteCode='V-99' then TongNg99
when RouteCode='MV-01' then TongNgmv01
when RouteCode='MV-02' then TongNgmv02
when RouteCode='MV-03' then TongNgmv03
when RouteCode='MV-04' then TongNgmv04
else 0 end)/isnull(fgqty,1)*100 as PercentHaoHut_X100

,(case 
when RouteCode='V-22' then TongNg22 
when RouteCode='V-23' then TongNg23
when RouteCode='V-24' then TongNg24
when RouteCode='V-25' then TongNg25
when RouteCode='V-26' then TongNg26
when RouteCode='V-27' then TongNg27
when RouteCode='V-29' then TongNg29
when RouteCode='V-30' then TongNg30
when RouteCode='V-31' then TongNg31
when RouteCode='V-32' then TongNg32
when RouteCode='V-33' then TongNg33
when RouteCode='V-34' then TongNg34
when RouteCode='V-35' then TongNg35
when RouteCode='V-99' then TongNg99
when RouteCode='MV-01' then TongNgmv01
when RouteCode='MV-01' then TongNgmv02
when RouteCode='MV-01' then TongNgmv03
when RouteCode='MV-01' then TongNgmv04
else 0 end)/isnull(fgqty,1)*usedqty/1000000  as TiLeHaoHut_BOM


from lastqty
full outer join (
SELECT --Modelname Modelname_DAU_KY_723, 
 top 1 Modelcode Modelcode_DAU_KY_723, CodeBtp Ma_BTP_DAU_KY_723, RouteCode RouteCode_DAU_KY_723, 
CODENAME Ma_HAI_QUAN_723, FirstQty AS Ton_DAU_KY_723, UNIT_DAU_KY_723,Ton_Cuoi_KY_723,UNIT_CUOI_KY_723, Ma_HAI_QUAN_726, 
 --PRODUCTIONNAME_726, 
 NG_Trong_KY_726 AS NG_TRong_KY_726, UNIT_726 --, Model as PHE_NVL_598, ISNULL(NGweight598,0)NGweight, UNIT as UNIT_598
FROM (
select  top 1 tb1.*,vic.CODENAME,vic.QTY as FirstQty,Ton_Cuoi_KY_723,UNIT_CUOI_KY_723,vic.UNIT_DAU_KY_723 ,vsa.CODENAME AS Ma_HAI_QUAN_726,
--vsa.PRODUCTIONNAME PRODUCTIONNAME_726,
vsa.QTY as NG_TRong_KY_726,vsa.UNIT_726--,vpe.Model,	vpe.NGweight,	vpe.UNIT

from (
  select  top 1  [Modelname], replace([Modelcode],'.','')[Modelcode],CodeBtp,RouteCode 
  from stb_Vietnam_MapCode with(nolock) 
  unpivot(
   CodeBtp for RouteCode in ( [V-22], [V-23], [V-24], [V-25], [V-26], [V-27], [V-28] , [V-29], [V-30], [V-33], [V-34], [MV-01], [MV-03], [MV-04], [MV-05])
  )tb2 
  )tb1 
  full outer join (select top 1 CODENAME,sum(QTY)QTY,max((UNIT))UNIT_DAU_KY_723 
					from STB_VN_ITEM_CHECK  with(nolock) 
					where CreateDateTime between convert(varchar(7),dateadd(month,-1,convert(date,@FromDate,120)),120)+'-25'
										 and     substring(@FromDate,1,7)+'-05'
						 and qty is not null
					group by CODENAME
					) 
					vic on tb1.Modelcode=vic.CODENAME or tb1.CodeBtp=vic.CODENAME --723

  full outer join (select  top 1 CODENAME Ma_Cuoiky_723,sum(QTY)Ton_Cuoi_KY_723,max((UNIT)) UNIT_CUOI_KY_723
					from STB_VN_ITEM_CHECK  with(nolock) 
					where CreateDateTime between substring(@FromDate,1,7)+'-25'
										 and     convert(varchar(7),dateadd(month,1,convert(date,@FromDate,120)),120)+'-05'
						 and qty is not null
					group by CODENAME
					) 
					vic1plus on tb1.Modelcode=vic1plus.Ma_Cuoiky_723 or tb1.CodeBtp=vic1plus.Ma_Cuoiky_723
					or vic.CODENAME=vic1plus.Ma_Cuoiky_723 and tb1.Modelcode is null and tb1.CodeBtp is null--723

  full outer join (select  top 1 (case when CODEPRODUTION is not null and CODEPRODUTION<>''  then CODEPRODUTION else CODENAME end)CODENAME,
					 --(case when PRODUCTIONNAME is not null and PRODUCTIONNAME<>''  then PRODUCTIONNAME else INPUT end)PRODUCTIONNAME,
					--  isnull(PRODUCTIONNAME,INPUT)PRODUCTIONNAME,
					 sum(qty)QTY,max(UNIT)UNIT_726 
					  from STB_VN_SCRAP_AFTERPRODUCTIONS  with(nolock) 
						 where CreateDateTime between @FromDate and @ToDate 
						 and qty is not null
						   group by (case when CODEPRODUTION is not null and CODEPRODUTION<>''  then CODEPRODUTION else CODENAME end)--,
					  --(case when PRODUCTIONNAME is not null and PRODUCTIONNAME<>''  then PRODUCTIONNAME else INPUT end)
					)
					vsa on vsa.CODENAME=vic.CODENAME or vsa.CODENAME=tb1.CodeBtp or vsa.CODENAME=tb1.Modelcode --726
					 
 ) TBNEW
)TBStage on lastqty.MaterialCot=TBStage.Modelcode_DAU_KY_723 and lastqty.RouteCode=TBStage.RouteCode_DAU_KY_723
       or lastqty.MaterialCot=TBStage.Modelcode_DAU_KY_723 and lastqty.routeexpress=TBStage.RouteCode_DAU_KY_723
	   or lastqty.RouteCode is null and lastqty.routeexpress is null and TBStage.RouteCode_DAU_KY_723 is null and (lastqty.MaterialCot=TBStage.Modelcode_DAU_KY_723 )   --or lastqty.materialcode=TBStage.Modelcode_DAU_KY_723)

 full outer join ( 
		select  top 1 MaLotCapThu, MaLotNguyenLieu as MaLieu_NG_598 
			, sum(Weights) as NG_trongky_598,max(UNIT)UNIT_598 
					  from STB_VN_PRODUCTION_ERROR  with(nolock) 
						 where CreateDateTime between @FromDate and @ToDate 
						  and Weights is not null
						   group by MaLotCapThu,MaLotNguyenLieu 
		)  vpe on    lastqty.MaterialCot=vpe.MaLotCapThu and   lastqty.ChildMaterialCode=vpe.MaLieu_NG_598 --598 


 -- where (modelcode is not null or CodeBtp is not null or vic.CODENAME is not null or vsa.CODENAME is not null )
 -- isnull(vic.CreateDateTime,vsa.CreateDateTime)>'2023-03-01'
 --where NGweight is  null
 full outer join data1 on data1.MaterialCode=lastqty.MaterialCot
order by lastqty.MaterialCot desc, lastqty.RouteCode ,lastqty.ProductGroupCode

END



--      [usp_bomreport_get] '','','2023-07-05','2023-07-15'


-- select (case when CODEPRODUTION is not null and CODEPRODUTION<>''  then CODEPRODUTION else CODENAME end)CODENAME,
--					 (case when PRODUCTIONNAME is not null and PRODUCTIONNAME<>''  then PRODUCTIONNAME else INPUT end)PRODUCTIONNAME,
--					--  isnull(PRODUCTIONNAME,INPUT)PRODUCTIONNAME,
--					 sum(convert(float,isnull(qty,'0')))QTY,max(isnull(UNIT,''))UNIT 
--					  from STB_VN_SCRAP_AFTERPRODUCTIONS 
--where CreateDateTime between '2023-01-01' and '2023-07-31' and qty is not null
--   group by (case when CODEPRODUTION is not null and CODEPRODUTION<>''  then CODEPRODUTION else CODENAME end),
--					  (case when PRODUCTIONNAME is not null and PRODUCTIONNAME<>''  then PRODUCTIONNAME else INPUT end)







	--declare @CompanyCode VARCHAR(20) = 'VVT'
	--DECLARE @FromDate    datetime =  '2022-10-01';
	--DECLARE @ToDate      datetime =  '2022-10-31';

--;with BOMkehoach1 as (
--SELECT
--distinct
--					POB.MaterialCode,

--				--	POB.BomVersion,
--					POB.ChildMaterialCode,

	
--					isnull((bh.BomHeaderDesc),(select top 1 (publiccode) from STB_VN_FINISHGOODS  fg with(nolock) where MaterialCode = pob.MaterialCode )) as bomHeaderDesc,

--					mbi.MBIExtText03 as [type],
--					replace(mbi.MBIExtText04,'2.7','3.0') as vol,
--					mbi.MBIExtText05 as farad,

--					CASE WHEN MBI.MBISizeW IS NOT NULL
--						 THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
--						 ELSE CONVERT(VARCHAR(10), CONVERT(INT,MBI.MBISizeD) ) END as size,
						 					

--					POB.UsedQty,

--					POB.RouteCode

--			FROM
--					STB_ProductionOrderBom POB WITH(NOLOCK)
--					left outer join STB_BomHeader  bh with(nolock) on pob.MaterialCode = bh.MaterialCode and bh.BomHeaderDesc like 'V%'
--					--left outer join STB_VN_FINISHGOODS  fg with(nolock) on pob.MaterialCode = fg.MaterialCode  and fg.PublicCode like 'V%'
--					INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON	POi.PONo = POB.PONo
--					left outer join STB_ModelBasicInfo mbi WITH(NOLOCK) ON	mbi.ModelCode=pob.MaterialCode
--					--inner join STB_DayProdPlan  dpp  WITH(NOLOCK)     on po.PONo = dpp.PONo
--					--LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
--					--	ON	MM.MaterialCode = POB.MaterialCode
--					--LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
--					--	ON	CMM.MaterialCode = POB.ChildMaterialCode
--					--LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
--					--	ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
--					--LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
--					--	ON	PG.ProductGroupCode = CMM.ProductGroupCode
--			WHERE
--					POB.CreateDateTime>=@FromDate and pob.CreateDateTime<=@ToDate --and RouteCode is null
--					and (POI.CompanyCode=@CompanyCode or pob.RouteCode like 'V%')
--					--and pob.createdatetime >'2022-10-20'
--					--and pob.materialcode in ('ECVT30-116','ECVT30-220')
--)

--, ViewBarcode as (
--		 select distinct c.Barcode
--		 from 
--		 STB_SetInfo c with(nolock) 
--		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
--		 where b.CompanyCode=@CompanyCode  and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
--		 --and c.MaterialCode in ('ECVT30-247','ECVT30-252')
--		-- and c.materialcode in ('ECVT30-116','ECVT30-220')
--		 --and c.createdatetime >'2022-10-20'
--	 )
--	 --,BTPHan as (
--		-- select  c.Barcode
--		-- from 
--		-- STB_SetInfo c with(nolock) 
--		-- left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
--		-- where b.CompanyCode='VNT' and b.RouteCode like 'V-%'  
--		-- and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
--		-- --and c.createdatetime >'2022-10-20'
--		-- --and c.materialcode in ('ECVT30-116','ECVT30-220')
--	 --),
--,RawView as (
--	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
--		max(b.ProdQty) as ProdQty, sum(a.DefectQty) as DefectQty,  sum(a.RepairQty) as RepairQty ,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
--		from  STB_SetInfo c with(nolock) 
--		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
--		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
--		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
--		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime
--)
--,

--DRI as(
--		select  
--		 RV.Barcode,
--		 RV.RouteCode,
--		 RV.RouteCode as FindRouteCode,
--		 ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
--		 ri.RouteName, 
--		 MM2.MaterialName,
--		 li.LineName, pwi.WorkerName,mm.MachineName,
--		 RV.ProdDateTime, 

--		 DATEPART(DAY, ProdDateTime)  as FindDateTime, 

--		  max(isnull(vfg.PackQty ,RV.ProdQty)) as ProdQty,
--		  sum(RV.DefectQty - RV.RepairQty) as DefectQty, 
--		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
--		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
--		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
--		  DATEPART(DAY, ProdDateTime)  as ProdDay,
--		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
--		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
--		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
--		  substring(MM2.MaterialName,CHARINDEX('(',MM2.MaterialName)+1,CHARINDEX(')',MM2.MaterialName)-CHARINDEX('(',MM2.MaterialName)-1 ) as SizeCode
--		--, (select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) 
--		from RawView RV 
--		left outer join STB_VN_FINISHGOODS vfg  with(nolock) on RV.barcode = vfg.Lotno 
--			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
--			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
--			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
--			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
--			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
--			  outer APPLY
--						 (SELECT distinct t1.Lotno
--						  FROM STB_MaterialLotInfo t1  with(nolock) 
--						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
--						 ) mli	
--		where 
--		( 
--			(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
--			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode ) > 0 or
--			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
--		) 
--		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
--		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
--		--order by RV.Barcode,RV.RouteCode 
--)
--, DuLieuSXThanhPham as (
--	select
--		   @CompanyCode   AS 사업장
--		  --,DRI.ControlNo
--	      --,DRI.Barcode
--		  ,DRI.MaterialCode
--		  ,MaterialName
--		 -- ,InputLineCode
--		 -- ,LI.LineName
--		  ,DRI.RouteCode as RouteCode
--		 -- ,RouteName
--		  	  ,sum(isnull(DRI.ProdQty,0) )  as "totalqty"	
		 
--		  ,sum(isnull(DRI.DefectQty,0)) as DefectQty
		
--	from DRI  WITH(NOLOCK)  
--			--LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
--			--  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
--			--  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)     ON InputLineCode = LI.LineCode			 
--			--  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)     ON DRI.MachineCode = MM.MachineCode
--			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)    ON DRI.WorkerCode = PWI.WorkerCode
--    -- where 1=1
--	   --AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
--	   --AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
--	   --AND (@MaterialCode = '*' OR DRI.MaterialCode   = @MaterialCode)
--	   --and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   
--	 group by 	  --DRI.ControlNo
--	      --,DRI.Barcode 
--		  DRI.MaterialCode
--		  ,MaterialName
--		  --,InputLineCode
--		  --,LI.LineName
--		  ,DRI.RouteCode
--		  --,RouteName		
--		  --,DRI.FindDateTime
--)
--, CodeBtP as (
--select '0813' as size, 'VEC' as type, '2.7' as vol , '1' as farad , 'VW0813105V' as codehaiquan  union
--select '0816' as size, 'WEC' as type, '3' as vol , '2' as farad , 'VW0816205V' as codehaiquan  union
--select '0820' as size, 'VEC' as type, '2.7' as vol , '3.3' as farad , 'VW0820335V' as codehaiquan  union
--select '0820' as size, 'VET' as type, '2.7' as vol , '3.3' as farad , 'VW0820335V-02' as codehaiquan  union
--select '0825' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VW0825505V' as codehaiquan  union
--select '0830' as size, 'VEC' as type, '3' as vol , '7' as farad , 'VW0830705V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VW1020505V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VW1020705V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VW1025106V' as codehaiquan  union
--select '1025-L' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VW1025106V-L' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VW1025705V' as codehaiquan  union
--select '1030' as size, 'WEC' as type, '3' as vol , '12' as farad , 'VW1030126V' as codehaiquan  union
--select '1030' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VW1030106V' as codehaiquan  union
----select '1030' as size, 'VEC' as type, '2.7' as vol , '10L' as farad , 'VW1030106V-L' as codehaiquan  union
--select '1035' as size, 'WEC' as type, '3' as vol , '10' as farad , 'VW1035156V' as codehaiquan  union
--select '1320' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VW1320106V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '15' as farad , 'VW1325156V' as codehaiquan  union
--select '1325' as size, 'WEC' as type, '3' as vol , '18' as farad , 'VW1325186V' as codehaiquan  union
--select '1346' as size, 'VEC' as type, '2.7' as vol , '40' as farad , 'VW1346406V' as codehaiquan  union
--select '1625' as size, 'VEC' as type, '2.7' as vol , '25' as farad , 'VW1625256V' as codehaiquan  union
--select '1635' as size, 'VEC' as type, '3' as vol , '35' as farad , 'VW1635356V' as codehaiquan  union
--select '1830' as size, 'VEC' as type, '2.7' as vol , '34' as farad , 'VW1830346V' as codehaiquan  union
--select '1840' as size, 'VHC' as type, '2.3' as vol , '120' as farad , 'VW1840127V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '2.7' as vol , '50' as farad , 'VW1840506V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '3' as vol , '60' as farad , 'VW1840606V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VW1859107V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '3' as vol , '100' as farad , 'VW1859107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VW2245107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '3' as vol , '100L' as farad , 'VW2245107V-L' as codehaiquan  union
--select '2570' as size, 'VEC' as type, '2.7' as vol , '220' as farad , 'VW2570227V' as codehaiquan  union
--select '3562' as size, 'VEC' as type, '2.7' as vol , '360' as farad , 'VW3562367V' as codehaiquan  union
--select '3567' as size, 'VEC' as type, '3' as vol , '400' as farad , 'VW3567407V' as codehaiquan  union
--select '3582' as size, 'VEC' as type, '3' as vol , '500' as farad , 'VW3582507V' as codehaiquan  union
--select '0813' as size, 'VEC' as type, '2.7' as vol , '1' as farad , 'VR0813105V' as codehaiquan  union
--select '0816' as size, 'WEC' as type, '3' as vol , '2' as farad , 'VR0816205V' as codehaiquan  union
--select '0820' as size, 'VEC' as type, '2.7' as vol , '3.3' as farad , 'VR0820335V' as codehaiquan  union
--select '0825' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VR0825505V' as codehaiquan  union
--select '0830' as size, 'VEC' as type, '3' as vol , '7' as farad , 'VR0830705V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VR1020505V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VR1020705V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VR1025106V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VR1025705V' as codehaiquan  union
--select '1030' as size, 'VEC' as type, '3' as vol , '12' as farad , 'VR1030126V' as codehaiquan  union
--select '1030' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VR1030106V' as codehaiquan  union
----select '1030' as size, 'VEC' as type, '2.7' as vol , '10L' as farad , 'VR1030106V-L' as codehaiquan  union
--select '1035' as size, 'WEC' as type, '3' as vol , '10' as farad , 'VR1035156V' as codehaiquan  union
--select '1320' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VR1320106V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '15' as farad , 'VR1325156V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '18' as farad , 'VR1325186V' as codehaiquan  union
--select '1346' as size, 'VEC' as type, '2.7' as vol , '40' as farad , 'VR1346406V' as codehaiquan  union
--select '1625' as size, 'VEC' as type, '2.7' as vol , '25' as farad , 'VR1625256V' as codehaiquan  union
--select '1635' as size, 'VEC' as type, '3' as vol , '35' as farad , 'VR1635356V' as codehaiquan  union
--select '1830' as size, 'VEC' as type, '2.7' as vol , '34' as farad , 'VR1830346V' as codehaiquan  union
--select '1840' as size, 'VHC' as type, '2.3' as vol , '120' as farad , 'VR1840127V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '2.7' as vol , '50' as farad , 'VR1840506V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '3' as vol , '60' as farad , 'VR1840606V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VR1859107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VR2245107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100L' as farad , 'VR2245107V-L' as codehaiquan  union
--select '2570' as size, 'VEC' as type, '3' as vol , '220' as farad , 'VR2570227V' as codehaiquan  union
--select '3562' as size, 'VEC' as type, '3' as vol , '360' as farad , 'VR3562367V' as codehaiquan  union
--select '3567' as size, 'VEC' as type, '3' as vol , '400' as farad , 'VR3567407V' as codehaiquan  union
--select '3582' as size, 'VEC' as type, '3' as vol , '500' as farad , 'VR3582507V' as codehaiquan  union
--select '0813' as size, 'VEC' as type, '2.7' as vol , '1' as farad , 'VB0813105V' as codehaiquan  union
--select '0816' as size, 'WEC' as type, '3' as vol , '2' as farad , 'VB0816205V' as codehaiquan  union
--select '0820' as size, 'VEC' as type, '2.7' as vol , '3.3' as farad , 'VB0820335V' as codehaiquan  union
--select '0825' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VB0825505V' as codehaiquan  union
--select '0830' as size, 'VEC' as type, '3' as vol , '7' as farad , 'VB0830705V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VB1020505V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VB1020705V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VB1025106V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VB1025705V' as codehaiquan  union
--select '1030' as size, 'WEC' as type, '3' as vol , '12' as farad , 'VB1030126V' as codehaiquan  union
--select '1030' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VB1030106V' as codehaiquan  union
----select '1030' as size, 'VEC' as type, '2.7' as vol , '10L' as farad , 'VB1030106V-L' as codehaiquan  union
--select '1035' as size, 'WEC' as type, '3' as vol , '10' as farad , 'VB1035156V' as codehaiquan  union
--select '1320' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VB1320106V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '15' as farad , 'VB1325156V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '18' as farad , 'VB1325186V' as codehaiquan  union
--select '1346' as size, 'VEC' as type, '2.7' as vol , '40' as farad , 'VB1346406V' as codehaiquan  union
--select '1625' as size, 'VEC' as type, '2.7' as vol , '25' as farad , 'VB1625256V' as codehaiquan  union
--select '1635' as size, 'WEC' as type, '3' as vol , '35' as farad , 'VB1635356V' as codehaiquan  union
--select '1830' as size, 'VEC' as type, '2.7' as vol , '34' as farad , 'VB1830346V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '2.7' as vol , '50' as farad , 'VB1840506V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '3' as vol , '60' as farad , 'VB1840606V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VB1859107V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '3' as vol , '100' as farad , 'VB1859107V1' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VB2245107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100L' as farad , 'VB2245107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100L' as farad , 'VB2245107V-L' as codehaiquan  union
--select '2570' as size, 'VEC' as type, '3' as vol , '220' as farad , 'VB2570227V' as codehaiquan  union
--select '3562' as size, 'VEC' as type, '3' as vol , '360' as farad , 'VB3562367V' as codehaiquan  union
--select '3572' as size, 'VEC' as type, '2.7' as vol , '400' as farad , 'VB3572407V' as codehaiquan  union
--select '3582' as size, 'VEC' as type, '3' as vol , '500' as farad , 'VB3582507V' as codehaiquan  union
--select '0813' as size, 'VEC' as type, '2.7' as vol , '1' as farad , 'VC0813105V' as codehaiquan  union
--select '0816' as size, 'WEC' as type, '3' as vol , '2' as farad , 'VC0816205V' as codehaiquan  union
--select '0820' as size, 'VEC' as type, '2.7' as vol , '3.3' as farad , 'VC0820335V' as codehaiquan  union
--select '0825' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VC0825505V' as codehaiquan  union
--select '0830' as size, 'VEC' as type, '3' as vol , '7' as farad , 'VC0830705V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '5' as farad , 'VC1020505V' as codehaiquan  union
--select '1020' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VC1020705V' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VC1025106V' as codehaiquan  union
--select '1025-L' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VC1025106V-L' as codehaiquan  union
--select '1025' as size, 'VEC' as type, '2.7' as vol , '7' as farad , 'VC1025705V' as codehaiquan  union
--select '1030' as size, 'WEC' as type, '3' as vol , '12' as farad , 'VC1030126V' as codehaiquan  union
--select '1030' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VC1030106V' as codehaiquan  union
----select '1030' as size, 'VEC' as type, '2.7' as vol , '10L' as farad , 'VC1030106V' as codehaiquan  union
-------select '1030' as size, 'VEC' as type, '2.7' as vol , '10L' as farad , 'VC1030106V-L' as codehaiquan  union
--select '1035' as size, 'WEC' as type, '3' as vol , '10' as farad , 'VC1035156V' as codehaiquan  union
--select '1320' as size, 'VEC' as type, '2.7' as vol , '10' as farad , 'VC1320106V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '15' as farad , 'VC1325156V' as codehaiquan  union
--select '1325' as size, 'VEC' as type, '2.7' as vol , '18' as farad , 'VC1325186V' as codehaiquan  union
--select '1346' as size, 'VEC' as type, '2.7' as vol , '40' as farad , 'VC1346406V' as codehaiquan  union
--select '1625' as size, 'VEC' as type, '2.7' as vol , '25' as farad , 'VC1625256V' as codehaiquan  union
--select '1635' as size, 'WEC' as type, '3'   as vol , '35' as farad , 'VC1635356V' as codehaiquan  union
--select '1830' as size, 'VEC' as type, '2.7' as vol , '34' as farad , 'VC1830346V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '2.7' as vol , '50' as farad , 'VC1840506V' as codehaiquan  union
--select '1840' as size, 'VEC' as type, '3'   as vol , '60' as farad , 'VC1840606V' as codehaiquan  union
--select '1859' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VC1859107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100' as farad , 'VC2245107V' as codehaiquan  union
--select '2245' as size, 'VEC' as type, '2.7' as vol , '100L' as farad , 'VC2245107V-L' as codehaiquan  union
--select '2570' as size, 'VEC' as type, '3'   as vol , '220' as farad , 'VC2570227V' as codehaiquan  union
--select '3562' as size, 'VEC' as type, '3'   as vol , '360' as farad , 'VC3562367V' as codehaiquan  union
--select '3567' as size, 'VEC' as type, '3'   as vol , '400' as farad , 'VC3567407V' as codehaiquan  union
--select '3582' as size, 'VEC' as type, '3'   as vol , '500' as farad , 'VC3582507V' as codehaiquan
--)
--,codebtp1 as (
--	select replace(replace(size,'-L',''),'L','') size,
--	replace(replace([type],'-L',''),'L','') [type],
--	replace(replace(replace([vol],'2.7','3.0'),'-L',''),'L','') [vol],
--	replace(replace(farad,'-L',''),'L','') farad,

--	case when codehaiquan like 'VB%' then
--		case when (size like '%L' or farad like '%L') and codehaiquan not like '%L' 
--		then codehaiquan+'-L' else codehaiquan end 
--	else codehaiquan end
--	as codehaiquan,

--	case when substring(codehaiquan,1,2)='VW' then 'V-22'
--	when substring(codehaiquan,1,2)='VR' then 'V-23'
--	when substring(codehaiquan,1,2)='VB' then 'V-24'
--	when substring(codehaiquan,1,2)='VC' then 'V-24' else '' end as RouteCode

--	from CodeBtP
--)

--,BTPDauKy as (

--select distinct '-->'BTPDauKy, CODENAME,case when unit is null or unit='' then 'Thieu don vi B723' else unit end as unit,qty 
--,isnull(BOMkehoach.ChildMaterialCode,'Sai BOM hoac Thieu CodeHQ_route Size Farad cua BTP') as ChildMaterialCode
--,BOMkehoach.UsedQty,BOMkehoach.RouteCode,BOMkehoach.size,BOMkehoach.vol,BOMkehoach.farad
--,qty * BOMkehoach.UsedQty as qty_BTPDauKy
----,BOMkehoach.MaterialCode 
--, ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 ) in ('VE','WE','VH')   and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'BTPDauKyEnd
--from (
--		SELECT 		
		
--				sum(isnull(QTY,0)) as qty,
--		ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--		then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))	 as PRODUCTIONNAME
--				,CODENAME 
--				,UNIT						
--		FROM
--				STB_VN_ITEM_CHECK WITH(NOLOCK)
--	    WHERE
--			 CreateDateTime BETWEEN  dateadd(day,-5,@FromDate) AND dateadd(day,5,@FromDate)
--			 and ( TYPEINPUT  not like 'NVL%' or  substring(CODENAME,1,2)  in ('VV','VN') )
--		group by ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--				then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))
--				, CODENAME  ,UNIT	
--) as tb1
--		left outer join  codebtp1 on codebtp1.codehaiquan=tb1.CODENAME
--		 outer apply (select distinct vol,	farad,	size, type,	UsedQty,	RouteCode,ChildMaterialCode
--				 from BOMkehoach1 
--				where  codebtp1.size = BOMkehoach1.size 
--				and codebtp1.vol=BOMkehoach1.vol
--			 	and codebtp1.farad = BOMkehoach1.farad 
--				and codebtp1.RouteCode=BOMkehoach1.RouteCode
--								and codebtp1.type = substring(tb1.PRODUCTIONNAME,1,3)
--				)as BOMkehoach
--)
--, BTPCUOIKY as (
--select distinct '-->'BTPCUOIKY,CODENAME
--,case when unit is null or unit='' then 'Thieu don vi B723' else unit end as unit,qty 
--,isnull(BOMkehoach.ChildMaterialCode,'Sai BOM hoac Thieu CodeHQ_route Size Farad cua BTP') as ChildMaterialCode
--,BOMkehoach.UsedQty,BOMkehoach.RouteCode,BOMkehoach.size,BOMkehoach.vol,BOMkehoach.farad
--,qty * BOMkehoach.UsedQty as qty_BTPCUOIKY
----,BOMkehoach.MaterialCode 
--, ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 ) in ('VE','WE','VH')   and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'BTPCUOIKYEnd
--from (
--		SELECT 		
		
--				sum(isnull(QTY,0)) as qty,

--		ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--		then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))	 as PRODUCTIONNAME
--				,CODENAME 
--				,UNIT						
--		FROM
--				STB_VN_ITEM_CHECK WITH(NOLOCK)
--	    WHERE
--			 CreateDateTime BETWEEN  dateadd(day,-5,@ToDate) AND dateadd(day,5,@ToDate)
--			 and ( TYPEINPUT  not like 'NVL%' or  substring(CODENAME,1,2)  in ('VV','VN') )
--		group by ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--				then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))
--				,CODENAME  ,UNIT	
--) as tb1
--		left outer join  codebtp1 on codebtp1.codehaiquan=tb1.CODENAME
--		 outer apply (select distinct vol,	farad,	size, type,	UsedQty,	RouteCode,ChildMaterialCode
--				 from BOMkehoach1 
--				where  codebtp1.size = BOMkehoach1.size 
--				and codebtp1.vol=BOMkehoach1.vol
--			 	and codebtp1.farad = BOMkehoach1.farad 
--				and codebtp1.RouteCode=BOMkehoach1.RouteCode
--								and codebtp1.type = substring(tb1.PRODUCTIONNAME,1,3)
--				)as BOMkehoach

--)
--,NG_BTPTrongKi as (

--select distinct '-->'NG_BTPTrongKi,CODENAME
--,case when unit is null or unit='' then 'Thieu don vi B726' else unit end as unit,qty 
--,isnull(BOMkehoach.ChildMaterialCode,'Sai BOM hoac Thieu CodeHQ_route Size Farad cua BTP') as ChildMaterialCode
--,BOMkehoach.UsedQty,BOMkehoach.RouteCode,BOMkehoach.size,BOMkehoach.vol,BOMkehoach.farad
--,qty * BOMkehoach.UsedQty as qty_NG_BTPTrongKi
----,BOMkehoach.MaterialCode 
--, ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 ) in ('VE','WE','VH')   and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'NG_BTPTrongKiEnd
--		from (
--				SELECT  			
--					isnull(CODEPRODUTION,CODENAME) as CODENAME,
--				ltrim(rtrim(case when substring(isnull(PRODUCTIONNAME,INPUT),5,1)='_' 
--				then	stuff(isnull(PRODUCTIONNAME,INPUT),1,5,'') else isnull(PRODUCTIONNAME,INPUT) end))
		
--				as PRODUCTIONNAME,			
--					max(UNIT) UNIT,			
--					sum(cast( replace(replace(replace(case when ltrim(rtrim(qty))='' or qty is null then '0' else qty end,'kg',''),'GRAM',''),' ','')  as float )) QTY
		
--				FROM
--					STB_VN_SCRAP_AFTERPRODUCTIONS WITH(NOLOCK)
--				WHERE
--					(unit  in ('PCS','EA')
--					  and isnull(CODENAME,CODEPRODUTION) not in (
--									select materialcode from STB_MaterialMaster with(nolock)
--									except
--									select modelcode from STB_ModelBasicInfo with(nolock)
--									)
--					)
--					and CONVERT(DATE,CreateDateTime) BETWEEN @FromDate AND @ToDate	
--				group by 						
--					isnull(CODEPRODUTION,CODENAME) ,
--					ltrim(rtrim(case when substring(isnull(PRODUCTIONNAME,INPUT),5,1)='_' 
--					then	stuff(isnull(PRODUCTIONNAME,INPUT),1,5,'') else isnull(PRODUCTIONNAME,INPUT) end))
--		) as tb1 

--		left outer join  codebtp1 on codebtp1.codehaiquan=tb1.CODENAME
--		 outer apply (select distinct vol,	farad,	size, type,	UsedQty,	RouteCode,ChildMaterialCode 
--				 from BOMkehoach1 
--				where  codebtp1.size = BOMkehoach1.size  
--				and codebtp1.vol=BOMkehoach1.vol 
--			 	and codebtp1.farad = BOMkehoach1.farad  
--				and codebtp1.RouteCode=BOMkehoach1.RouteCode 
--								and codebtp1.type = substring(tb1.PRODUCTIONNAME,1,3) 
--				)as BOMkehoach
		
--)
--,NG_NVL_TrongKi as (
---- them B598 vao day, nhung can co code
--select distinct '-->'NG_NVL_TrongKi,CODENAME
--,case when unit is null or unit='' then 'Thieu don vi B726' else unit end as unit,qty as qty_NG_NVL_TrongKi
--,isnull(BOMkehoach.ChildMaterialCode,CODENAME) as ChildMaterialCode
--,BOMkehoach.UsedQty,BOMkehoach.RouteCode,BOMkehoach.size,BOMkehoach.vol,BOMkehoach.farad
----,qty  as NVL_NG_TrongKy
----,BOMkehoach.MaterialCode 
--, ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 ) in ('VE','WE','VH')   and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'NG_NVL_TrongKiEnd
--		from (
--				SELECT  			
--					isnull(CODEPRODUTION,CODENAME) as CODENAME,
--				ltrim(rtrim(case when substring(isnull(PRODUCTIONNAME,INPUT),5,1)='_' 
--				then	stuff(isnull(PRODUCTIONNAME,INPUT),1,5,'') else isnull(PRODUCTIONNAME,INPUT) end))
		
--				as PRODUCTIONNAME,			
--					 UNIT,			
--					 qty
--					--sum(cast( replace(replace(replace(case when ltrim(rtrim(qty))='' or qty is null then '0' else qty end,'kg',''),'GRAM',''),' ','')  as float )) QTY
		
--				FROM
--					STB_VN_SCRAP_AFTERPRODUCTIONS WITH(NOLOCK)
--				WHERE
--					(unit not in ('PCS','EA')
--					  or isnull(CODENAME,CODEPRODUTION) in (
--									select materialcode from STB_MaterialMaster with(nolock)
--									except
--									select modelcode from STB_ModelBasicInfo with(nolock)
--									)
--					)
--					and CONVERT(DATE,CreateDateTime) BETWEEN @FromDate AND @ToDate	
--				group by 						
--					isnull(CODEPRODUTION,CODENAME) ,
--					ltrim(rtrim(case when substring(isnull(PRODUCTIONNAME,INPUT),5,1)='_' 
--				then	stuff(isnull(PRODUCTIONNAME,INPUT),1,5,'') else isnull(PRODUCTIONNAME,INPUT) end)),
--					UNIT ,
--					qty
--		) as tb1 

--		left outer join  codebtp1 on codebtp1.codehaiquan=tb1.CODENAME
--		 outer apply (select distinct vol,	farad,	size,	UsedQty,	RouteCode,ChildMaterialCode
--				 from BOMkehoach1 
--				where  codebtp1.size = BOMkehoach1.size 
--				and codebtp1.vol=BOMkehoach1.vol
--			 	and codebtp1.farad = BOMkehoach1.farad 
--				and codebtp1.RouteCode=BOMkehoach1.RouteCode
				
--				)as BOMkehoach
		
--)
--,NVLDauKy as (

--select '-->'NVLDauKy, CODENAME as ChildMaterialCode
--,case when unit is null or unit='' then 'Thieu don vi B723' else unit end as unit,qty as qty_NVLDauKy, 
--ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 ) in ('VE','WE','VH')  and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'NVLDauKyEnd
--from (
--		SELECT 				
--				sum(isnull(QTY,0)) as qty, 
--		ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_'  
--		then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))	 as PRODUCTIONNAME
--				,CODENAME 
--				,UNIT						
--		FROM
--				STB_VN_ITEM_CHECK WITH(NOLOCK)
--	    WHERE
--			 CreateDateTime BETWEEN  dateadd(day,-5,@FromDate) AND dateadd(day,5,@FromDate)
--			 and TYPEINPUT   like 'NVL%'
--			 and substring(CODENAME,1,2) not in ('VV','VN')
--		group by ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_'  
--		then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))
--		,CODENAME  ,UNIT	
--) as tb1

--)
--, NVLCUOIKY as (

--select '-->'NVLCUOIKY,CODENAME as ChildMaterialCode
--,case when unit is null or unit='' then 'Thieu don vi B723' else unit end as unit,qty as qty_NVLCUOIKY, 
--ltrim(rtrim(case when SUBSTRING(PRODUCTIONNAME,1,2 )  in ('VE','WE','VH') and charindex('(',tb1.PRODUCTIONNAME)>0
--				then SUBSTRING(PRODUCTIONNAME,1,case when charindex('(',tb1.PRODUCTIONNAME)-1 < 1 then 1 else charindex('(',tb1.PRODUCTIONNAME)-1 end  )
--				else PRODUCTIONNAME end)) PRODUCTIONNAME
--				,'<--'NVLCUOIKYEnd
--from (
--		SELECT 				
--				sum(isnull(QTY,0)) as qty,
--		ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--		then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))	 as PRODUCTIONNAME
--				,CODENAME 
--				,UNIT						
--		FROM
--				STB_VN_ITEM_CHECK WITH(NOLOCK)
--	    WHERE
--			 CreateDateTime BETWEEN  dateadd(day,-5,@ToDate) AND dateadd(day,5,@ToDate)
--			 and TYPEINPUT   like 'NVL%'
--			 and substring(CODENAME,1,2) not in ('VV','VN')
--		group by 		ltrim(rtrim(case when substring(isnull(INPUT,INPUT),5,1)='_' 
--				then	stuff(isnull(INPUT,INPUT),1,5,'') else isnull(INPUT,INPUT) end))
--				,CODENAME  ,UNIT	
--) as tb1
--)
--, NVL_Nhap_trongKy as (
--	select '-->'NVL_Nhap_trongKy,MaterialCode,sum(isnull(CurrentQty,0)) as qty_NVL_Nhap_trongKy ,'<--'NVL_Nhap_trongKyEnd
--	from STB_MaterialWarehouseInOutHist MWIOH with(nolock)
--	join STB_MaterialLotInfo mli with(nolock) on MWIOH.LotID = mli.LotID
--	where isnull(ProcessedLotID,'')<>'' 
--	and MWIOH.CreateDateTime between @FromDate and @ToDate
--	and WarehouseInOutCode='O' 
--	--and SourceMaterialWarehouseCode = 'ROH_VN_WH' 
--	and TargetMaterialWarehouseCode = 'ROUTE_VN_WH'
--	and  isnull(MWIOH.linecode,'') not in ('R-KR','XCDMDSD','XTH','XK','KVHD') 
--	group by MaterialCode
--)

--, NVL_Sudung_Xuat_trongKy_B782 as (
--	select   '-->'NVL_Sudung_Xuat_trongKy_B782,
--	DuLieuSXThanhPham.MaterialCode
--		  ,MaterialName
--		 -- ,InputLineCode
--		 -- ,LineName
--		  , DuLieuSXThanhPham.RouteCode
--		  --,RouteName
--		  ,DefectQty
--		  ,totalqty
--		  ,vol,	farad,	size,	UsedQty,	
--		  isnull(childMaterialCode,'Sai BOM hoac Thieu CodeHQ_route Size Farad cua BTP') as childMaterialCode
--		  ,totalqty * UsedQty as NVL_Sudung_trongky_SX
--		  ,DefectQty * UsedQty as NVL_NG_trongky_SX
--		  ,'<--'NVL_Sudung_Xuat_trongKy_B782End
--	from DuLieuSXThanhPham 
	
--		 outer apply (select distinct vol,	farad,type,	size,	UsedQty,	RouteCode,ChildMaterialCode
--				 from BOMkehoach1 
--				  where DuLieuSXThanhPham.MaterialCode=BOMkehoach1.MaterialCode 
--				and DuLieuSXThanhPham.RouteCode = BOMkehoach1.RouteCode		
--				and type=substring(replace(replace(DuLieuSXThanhPham.MaterialName,'HY-CAP ',''),'HY-CAP',''),1,3)
--				)as BOMkehoach 				
--) 
----, NVL_Sudung_Xuat_trongKy_FG01 as (
----	select vfg.* from STB_VN_FINISHGOODS vfg with(nolock)
----	join ViewBarcode on vfg.LotNo=ViewBarcode.Barcode
----)

--select 
-- isnull(qty_NVLDauKy,0)+isnull(qty_NVL_Nhap_trongKy,0)+isnull(qty_BTPCUOIKY,0)-isnull(totalqty,0)-isnull(DefectQty,0)-isnull(qty_BTPDauKy,0) 
-- as Cover_Ton_NVL_CuoiKy ,

--0 Cover_Ton_BTP_CuoiKy,

--(isnull(totalqty,0)+isnull(DefectQty,0))/isnull(totalqty,1)  Dinh_muc_BOM_B782,

--0 Dinh_muc_BOM,
--*
--from NVL_Sudung_Xuat_trongKy_B782
--full outer join NVL_Nhap_trongKy on NVL_Sudung_Xuat_trongKy_B782.childMaterialCode=NVL_Nhap_trongKy.MaterialCode 

--full outer join NVLDauKy on NVLDauKy.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode or NVLDauKy.childMaterialCode=NVL_Nhap_trongKy.MaterialCode 
--full outer join NVLCUOIKY on NVLCUOIKY.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode or NVLCUOIKY.childMaterialCode=NVL_Nhap_trongKy.MaterialCode 

--full outer join NG_NVL_TrongKi 
--on (NG_NVL_TrongKi.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode 
--and NG_NVL_TrongKi.RouteCode=NVL_Sudung_Xuat_trongKy_B782.RouteCode
--and NVL_Sudung_Xuat_trongKy_B782.MaterialName like  '%'+NG_NVL_TrongKi.PRODUCTIONNAME+'%' 
--and NVL_Sudung_Xuat_trongKy_B782.vol = NG_NVL_TrongKi.vol
--and NVL_Sudung_Xuat_trongKy_B782.farad = NG_NVL_TrongKi.farad
--and NVL_Sudung_Xuat_trongKy_B782.size = NG_NVL_TrongKi.size
--)

--full outer join NG_BTPTrongKi 
--on (NG_BTPTrongKi.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode 
--and NG_BTPTrongKi.RouteCode=NVL_Sudung_Xuat_trongKy_B782.RouteCode
--and NVL_Sudung_Xuat_trongKy_B782.MaterialName like  '%'+NG_BTPTrongKi.PRODUCTIONNAME+'%' 
--and NVL_Sudung_Xuat_trongKy_B782.vol = NG_BTPTrongKi.vol
--and NVL_Sudung_Xuat_trongKy_B782.farad = NG_BTPTrongKi.farad
--and NVL_Sudung_Xuat_trongKy_B782.size = NG_BTPTrongKi.size
--and NG_BTPTrongKi.CODENAME = NG_NVL_TrongKi.CODENAME
--) or 
--(NG_BTPTrongKi.ChildMaterialCode=NG_NVL_TrongKi.childMaterialCode 
--and NG_BTPTrongKi.RouteCode=NG_NVL_TrongKi.RouteCode
--and '%'+NG_NVL_TrongKi.PRODUCTIONNAME+'%' like  '%'+NG_BTPTrongKi.PRODUCTIONNAME+'%' 
--and NG_NVL_TrongKi.vol = NG_BTPTrongKi.vol
--and NG_NVL_TrongKi.farad = NG_BTPTrongKi.farad
--and NG_NVL_TrongKi.size = NG_BTPTrongKi.size
--and NG_BTPTrongKi.CODENAME = NG_NVL_TrongKi.CODENAME
--)
--full outer join BTPDauKy 
--on (BTPDauKy.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode 
--and BTPDauKy.RouteCode=NVL_Sudung_Xuat_trongKy_B782.RouteCode
--and NVL_Sudung_Xuat_trongKy_B782.MaterialName like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and NVL_Sudung_Xuat_trongKy_B782.vol = BTPDauKy.vol
--and NVL_Sudung_Xuat_trongKy_B782.farad = BTPDauKy.farad
--and NVL_Sudung_Xuat_trongKy_B782.size = BTPDauKy.size
--and BTPDauKy.CODENAME = NG_NVL_TrongKi.CODENAME
--)
-- or 
--(BTPDauKy.ChildMaterialCode=NG_NVL_TrongKi.childMaterialCode 
--and BTPDauKy.RouteCode=NG_NVL_TrongKi.RouteCode
--and '%'+NG_NVL_TrongKi.PRODUCTIONNAME+'%' like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and NG_NVL_TrongKi.vol = BTPDauKy.vol
--and NG_NVL_TrongKi.farad = BTPDauKy.farad
--and NG_NVL_TrongKi.size = BTPDauKy.size
--and BTPDauKy.CODENAME = NG_NVL_TrongKi.CODENAME
--) or
--(BTPDauKy.ChildMaterialCode=NG_BTPTrongKi.childMaterialCode 
--and BTPDauKy.RouteCode=NG_BTPTrongKi.RouteCode
--and '%'+NG_BTPTrongKi.PRODUCTIONNAME+'%' like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and NG_BTPTrongKi.vol = BTPDauKy.vol
--and NG_BTPTrongKi.farad = BTPDauKy.farad
--and NG_BTPTrongKi.size = BTPDauKy.size
--and BTPDauKy.CODENAME = NG_BTPTrongKi.CODENAME
--)
--full outer join BTPCUOIKY 
--on (BTPCUOIKY.ChildMaterialCode=NVL_Sudung_Xuat_trongKy_B782.childMaterialCode 
--and BTPCUOIKY.RouteCode=NVL_Sudung_Xuat_trongKy_B782.RouteCode 
--and NVL_Sudung_Xuat_trongKy_B782.MaterialName like  '%'+BTPCUOIKY.PRODUCTIONNAME+'%' 
--and NVL_Sudung_Xuat_trongKy_B782.vol = BTPCUOIKY.vol
--and NVL_Sudung_Xuat_trongKy_B782.farad = BTPCUOIKY.farad
--and NVL_Sudung_Xuat_trongKy_B782.size = BTPCUOIKY.size
--and NG_BTPTrongKi.CODENAME = NG_NVL_TrongKi.CODENAME
--)
--or 
--(BTPCUOIKY.ChildMaterialCode=NG_NVL_TrongKi.childMaterialCode 
--and BTPCUOIKY.RouteCode=NG_NVL_TrongKi.RouteCode
--and '%'+NG_NVL_TrongKi.PRODUCTIONNAME+'%' like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and NG_NVL_TrongKi.vol = BTPCUOIKY.vol
--and NG_NVL_TrongKi.farad = BTPCUOIKY.farad
--and NG_NVL_TrongKi.size = BTPCUOIKY.size
--and NG_BTPTrongKi.CODENAME = NG_NVL_TrongKi.CODENAME
--) or
--(BTPCUOIKY.ChildMaterialCode=NG_BTPTrongKi.childMaterialCode 
--and BTPCUOIKY.RouteCode=NG_BTPTrongKi.RouteCode
--and '%'+NG_BTPTrongKi.PRODUCTIONNAME+'%' like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and NG_BTPTrongKi.vol = BTPCUOIKY.vol
--and NG_BTPTrongKi.farad = BTPCUOIKY.farad
--and NG_BTPTrongKi.size = BTPCUOIKY.size
--and NG_BTPTrongKi.CODENAME = NG_BTPTrongKi.CODENAME
--) or
--(BTPCUOIKY.ChildMaterialCode=BTPDauKy.childMaterialCode 
--and BTPCUOIKY.RouteCode=BTPDauKy.RouteCode
--and '%'+BTPDauKy.PRODUCTIONNAME+'%' like  '%'+BTPDauKy.PRODUCTIONNAME+'%' 
--and BTPDauKy.vol = BTPCUOIKY.vol
--and BTPDauKy.farad = BTPCUOIKY.farad
--and BTPDauKy.size = BTPCUOIKY.size
--and NG_BTPTrongKi.CODENAME = BTPDauKy.CODENAME
--)


--	--select distinct a.BomHeaderDesc,a.MaterialCode, c.MaterialName, c.MaterialUnit, b.ChildMaterialCode,d.materialname,d.MMExtText03,d.MMExtText04,b.BomUnit,b.UsedQty/1000000 as Quota from STB_BomHeader a left join STB_BomDetail b ON a.materialcode = b.MaterialCode and a.BomVersion = b.BomVersion
--	--left join STB_MaterialMaster c ON a.MaterialCode = c.MaterialCode
--	--left join STB_MaterialMaster d ON b.ChildMaterialCode = d.MaterialCode
--	--WHERE a.BomHeaderDesc in (SELECT distinct PublicCode FROM fnBOMChange(@pFromDate ,@pToDate))
		
--END


