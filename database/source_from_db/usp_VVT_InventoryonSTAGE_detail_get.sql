
-- =============================================
-- Author:	    mrtung
-- Create date: 2023-03-23
-- =====================================================================================================
--- ==================     [usp_VVT_InventoryonSTAGE_detail_get] '',''
CREATE PROCEDURE [dbo].[usp_VVT_InventoryonSTAGE_detail_get] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = 'VVT', 
	@pMonth DATETIME = '2023-03-01',
	--@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pGetFrom26 BIT = 0

as

BEGIN

select '' tung;

return;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pMonth)), 120)  +'-01'   + ' 10:00:00'
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 1, CONVERT(smalldatetime, @pMonth)), 120)  +'-01'   + ' 10:00:00'
	
	if(@pGetFrom26=1)
	begin
		select @FromDate    = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pMonth)), 120)  +'-26'   + ' 10:00:00'
		select @ToDate      = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @pMonth)), 120) +'-26'   + ' 10:00:00'
	end

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END





;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode=@CompanyCode  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
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
		--left outer join STB_MaterialLotInfo mli  with(nolock) on RV.barcode = mli.Lotno 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
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
		group by 		 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
		--order by RV.Barcode,RV.RouteCode 
)
,
	deptrai as (
	select
		   'VVT'   AS 사업장
		  --,DRI.ControlNo
	      --,DRI.Barcode
		  ,DRI.MaterialCode as materialco
		  ,MaterialName as materialna
		 -- ,InputLineCode
		--  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RouteName
		  , sum(DRI.ProdQty) ProdQty
		  	  ,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
		
		  ,sum(DRI.DefectQty) as DefectQty
		  
	from DRI  WITH(NOLOCK)  
			--LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
			--  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)     ON InputLineCode = LI.LineCode			 
			--  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)     ON DRI.MachineCode = MM.MachineCode
			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)    ON DRI.WorkerCode = PWI.WorkerCode
     where 1=1
	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   --AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   AND (@MaterialCode = '*' OR DRI.MaterialCode   = @MaterialCode)
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
	,
	b11 as (
select  b1.MaterialCode,	max(b1.BomVersion)BomVersion,ChildMaterialCode, mm.ProductGroupCode
from STB_BomDetail b1 
join STB_BomHeader bh on b1.MaterialCode=bh.MaterialCode and b1.BomVersion=bh.BomVersion
join STB_MaterialMaster mm on b1.ChildMaterialCode=mm.MaterialCode
where 
isnull(bh.IsUsed,convert(bit,0))<>convert(bit,0) and
 (b1.BomVersion='99'  )
 group by b1.MaterialCode,	ChildMaterialCode, mm.ProductGroupCode,mm.MaterialName
 having  mm.ProductGroupCode in ('SLITTING-ROLL','COATING-ROLL','JELLY-ROLL','BINDER','SLEEVE','SURFACTANT','FOIL','A.C','CARBON','HC-EDLC','HC-VPC') 
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
materialcode, MaterialCode1, 
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
select  distinct b1.materialcode,b1.CreateDateTime,--b1.ChildMaterialCode,--mm.MaterialName,
 mm.ProductGroupCode,mm.MaterialName, --count(mm.ProductGroupCode) as totalissue,
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


from STB_BomDetail b1 

left outer join STB_BomDetail b2 on b2.MaterialCode=b1.ChildMaterialCode and b2.MaterialCode<>b2.ChildMaterialCode --and  (b2.BomVersion>='51' or b2.BomVersion='1000')
left outer join STB_BomDetail b3 on b3.MaterialCode=b2.ChildMaterialCode and b3.MaterialCode<>b3.ChildMaterialCode --and  (b3.BomVersion>='51' or b3.BomVersion='1000')
left outer join STB_BomDetail b4 on b4.MaterialCode=b3.ChildMaterialCode and b4.MaterialCode<>b4.ChildMaterialCode --and  (b4.BomVersion>='51' or b4.BomVersion='1000')
left outer join STB_BomDetail b5 on b5.MaterialCode=b4.ChildMaterialCode and b5.MaterialCode<>b5.ChildMaterialCode --and  (b5.BomVersion>='51' or b5.BomVersion='1000')
left outer join STB_BomDetail b6 on b6.MaterialCode=b5.ChildMaterialCode and b6.MaterialCode<>b6.ChildMaterialCode --and  (b6.BomVersion>='51' or b6.BomVersion='1000')
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


where  b11.BomVersion='99' 
--(BomVersion>='51' or BomVersion='1000') and 
--isnull(b11.IsUsed,convert(bit,0))<>convert(bit,0) and
and coalesce( 
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
--and 
--mm.MaterialCode in ( 
--select  distinct materialcode  from STB_MaterialLotInfo 
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

--and mm.MaterialCode in (
--select  distinct b1.ChildMaterialCode from STB_BomDetail b1 
--join STB_MaterialMaster mm on b1.ChildMaterialCode=mm.MaterialCode
--where (mm.ProductGroupCode='' or mm.ProductGroupCode is null)
----and substring(b1.materialcode,1,4) not in ( 'ECVT','EDVT','LIVT','HCVT','MMVC','RDMD')
--and mm.MaterialName not like '%HY%CAP%'
--and substring(b1.ChildMaterialCode,1,3) not in ('SLV','SRE','CRY','SRF')
--)
--where b1.MaterialCode in ('ECVT30-279','ECVT30-234','ECVT60-013')
--where (mm.ProductGroupCode='' or mm.ProductGroupCode is null)
--and substring(b1.materialcode,1,4) not in ( 'ECVT','EDVT','LIVT','HCVT','MMVC','RDMD')
--and mm.MaterialName not like '%HY%CAP%'
--and substring(b1.ChildMaterialCode,1,3) not in ('SLV','SRE','CRY','SRF')
) 
,bom1 as (
select 
*
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
'MD-WIRE'
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
select (case when  tb22.CodeBtp <>'' and tb22.CodeBtp is not null then tb22.CodeBtp else N'Thiếu Code' end) as CodeBtp
,deptrai.* ,bom1.*,MaterialUnit  --isnull(b1.MaterialUnit,mm.MaterialUnit)MaterialUnit
,''   Ma_Lieu_DAU_KY
,''   Ma_BTP_DAU_KY
,''  Donvi_DAU_KY
,0 as Ton_DAU_KY
,0 Xuat_trong_ky
,0 Tra_lai_trong_ky
,ProdQty*bom1.usedqty/1000000   as Tong_TRONG_KY 
,total*bom1.usedqty/1000000     as Good_TRONG_KY 
,DefectQty*bom1.usedqty/1000000 as Defect_TRONG_KY 
,0 as Ton_CUOI_KY 
from deptrai 
left outer join bom1 on deptrai.MaterialCo=bom1.MaterialCode and (deptrai.RouteCode=bom1.routeexpress or deptrai.RouteCode=bom1.routemodule)
left outer join STB_MaterialMaster mm on bom1.ChildMaterialCode=mm.MaterialCode
left outer join (  select [Size], [Modelname], [Modelcode],CodeBtp,RouteCode from stb_Vietnam_MapCode
  unpivot(
   CodeBtp for RouteCode in ( [V-22], [V-23], [V-24], [V-25], [V-26], [V-27], [V-28] , [V-29], [V-30], [V-33], [V-34], [MV-01], [MV-03], [MV-04], [MV-05])
  )tb2) tb22 on tb22.Modelcode=deptrai.MaterialCo and tb22.RouteCode=deptrai.RouteCode
)

--, lastqty1 as (
--	select ''사업장, ''MaterialCode,  ''MaterialName1 , '' RouteCode,   ''RouteName,
--	sum( ProdQty)ProdQty,
--	sum(total) total,
--	sum(DefectQty) DefectQty, ''matcode, 
--	''TargetMaterialWarehouseCode, ''MaterialName,   ''ProductGroupCode,
--	sum(usedqty) usedqty, ChildMaterialCode,
--	  ''routeexpress,  ''routemodule, 
--	 max(MaterialUnit) MaterialUnit,  
--	  ''Ma_Lieu_DAU_KY,  ''Ma_BTP_DAU_KY,  ''Donvi_DAU_KY,
--	  sum(Ton_DAU_KY)  Ton_DAU_KY,
-- sum(Xuat_trong_ky) Xuat_trong_ky,
--sum(Tra_lai_trong_ky) Tra_lai_trong_ky,
--	sum(Tong_TRONG_KY)  Tong_TRONG_KY,
--	sum(Good_TRONG_KY) Good_TRONG_KY,
--	sum(Defect_TRONG_KY)  Defect_TRONG_KY,
--	sum(Ton_CUOI_KY)  Ton_CUOI_KY
--	from lastqty
--	group by ChildMaterialCode--,MaterialUnit
--)
--, combine as
--(select 
--case when mo.사업장<>'' then mo.사업장 else lq.사업장 end 사업장, 
--case when mo.MaterialCode<>'' then mo.MaterialCode else lq.MaterialCode end MaterialCode,  
--case when mo.MaterialName1<>'' then mo.MaterialName1 else lq.MaterialName1 end MaterialName1 , 
--case when mo.RouteCode<>'' then mo.RouteCode else lq.RouteCode end  RouteCode,   
--case when mo.RouteName<>'' then mo.RouteName else lq.RouteName end RouteName,
--case when mo.ProdQty<>0 then mo.ProdQty else lq.ProdQty end ProdQty,
--case when mo.total<>0 then mo.total else lq.total end total,
--case when mo.DefectQty<>0 then mo.DefectQty else lq.DefectQty end  DefectQty, 
--case when mo.matcode<>'' then mo.matcode else lq.matcode end matcode, 
--case when mo.TargetMaterialWarehouseCode<>'' then mo.TargetMaterialWarehouseCode else lq.TargetMaterialWarehouseCode end TargetMaterialWarehouseCode, 
--case when mo.MaterialName<>'' then mo.MaterialName else lq.MaterialName end MaterialName,   
--case when mo.ProductGroupCode<>'' then mo.ProductGroupCode else lq.ProductGroupCode end ProductGroupCode,
--case when mo.usedqty<>0 then mo.usedqty else lq.usedqty end  usedqty, 
--case when mo.ChildMaterialCode<>'' then mo.ChildMaterialCode else lq.ChildMaterialCode end 	ChildMaterialCode,
--case when mo.routeexpress<>'' then mo.routeexpress else lq.routeexpress end routeexpress,  
--case when mo.routemodule<>'' then mo.routemodule else lq.routemodule end routemodule, 
--case when mo.MaterialUnit<>'' then mo.MaterialUnit else lq.MaterialUnit end 	  MaterialUnit,  
--case when mo.Ma_Lieu_DAU_KY<>'' then mo.Ma_Lieu_DAU_KY else lq.Ma_Lieu_DAU_KY end Ma_Lieu_DAU_KY,  
--case when mo.Ma_BTP_DAU_KY<>'' then mo.Ma_BTP_DAU_KY else lq.Ma_BTP_DAU_KY end Ma_BTP_DAU_KY,  
--case when mo.Donvi_DAU_KY<>'' then mo.Donvi_DAU_KY else lq.Donvi_DAU_KY end Donvi_DAU_KY,
--case when mo.Ton_DAU_KY<>0 then mo.Ton_DAU_KY else lq.Ton_DAU_KY end  Ton_DAU_KY,
--case when mo.Xuat_trong_ky<>0 then mo.Xuat_trong_ky else lq.Xuat_trong_ky end  Xuat_trong_ky,
--case when mo.Tra_lai_trong_ky<>0 then mo.Tra_lai_trong_ky else lq.Tra_lai_trong_ky end  Tra_lai_trong_ky,
--case when mo.Tong_TRONG_KY<>0 then mo.Tong_TRONG_KY else lq.Tong_TRONG_KY end   Tong_TRONG_KY,
--case when mo.Good_TRONG_KY<>0 then mo.Good_TRONG_KY else lq.Good_TRONG_KY end  Good_TRONG_KY,
--case when mo.Defect_TRONG_KY<>0 then mo.Defect_TRONG_KY else lq.Defect_TRONG_KY end   Defect_TRONG_KY,
--case when mo.Ton_CUOI_KY<>0 then mo.Ton_CUOI_KY else lq.Ton_CUOI_KY end   Ton_CUOI_KY

--from materialOut1 mo
--full outer join lastqty1 lq on mo.ChildMaterialCode=lq.ChildMaterialCode
--)
select * from lastqty
order by MaterialCode desc, RouteCode ,ProductGroupCode
--union all
--select * from combine

--union all
--select * from materialOut
--order by MaterialCode--,RouteCode




--outer apply (select ChildMaterialCode,max(MaterialUnit)MaterialUnit from STB_BomDetail 
--where ChildMaterialCode=bom1.ChildMaterialCode and MaterialCode=bom1.MaterialCode group by ChildMaterialCode) b1
--where b1.ChildMaterialCode=bom1.ChildMaterialCode
--left outer join (select top 1 BomUnit from STB_BomDetail b1 where MaterialCode = bom1.ChildMaterialCode) b1


--select * from STB_SetInfo
--where materialcode='EDVTMD-169'


--select  distinct b1.materialcode,--b1.ChildMaterialCode,--mm.MaterialName,
--mm.ProductGroupCode ,
--b2.ChildMaterialCode,b2.MaterialCode,
--b3.ChildMaterialCode,b3.MaterialCode,
--b4.ChildMaterialCode,b4.MaterialCode,
--b6.ChildMaterialCode,b6.MaterialCode,
--b6.ChildMaterialCode,b6.MaterialCode,
--coalesce(
--b6.ChildMaterialCode,
--b5.ChildMaterialCode,
--b4.ChildMaterialCode,
--b3.ChildMaterialCode,
--b2.ChildMaterialCode,
--b1.ChildMaterialCode
--) as ChildMaterialCode
--from STB_BomDetail b1 
--left outer join STB_MaterialMaster mm on b1.ChildMaterialCode=mm.MaterialCode and b1.MaterialCode<>b1.ChildMaterialCode and  (b1.BomVersion>='51' or b1.BomVersion='1000')
--left outer join STB_BomDetail b2 on b2.MaterialCode=b1.ChildMaterialCode and b2.MaterialCode<>b2.ChildMaterialCode and  (b2.BomVersion>='51' or b2.BomVersion='1000')
--left outer join STB_BomDetail b3 on b3.MaterialCode=b2.ChildMaterialCode and b3.MaterialCode<>b3.ChildMaterialCode and  (b3.BomVersion>='51' or b3.BomVersion='1000')
--left outer join STB_BomDetail b4 on b4.MaterialCode=b3.ChildMaterialCode and b4.MaterialCode<>b4.ChildMaterialCode and  (b4.BomVersion>='51' or b4.BomVersion='1000')
--left outer join STB_BomDetail b5 on b5.MaterialCode=b4.ChildMaterialCode and b5.MaterialCode<>b5.ChildMaterialCode and  (b5.BomVersion>='51' or b5.BomVersion='1000')
--left outer join STB_BomDetail b6 on b6.MaterialCode=b5.ChildMaterialCode and b6.MaterialCode<>b6.ChildMaterialCode and  (b6.BomVersion>='51' or b6.BomVersion='1000')
--where b1.materialcode in (
--'EDVTMD-169'
--)


END
