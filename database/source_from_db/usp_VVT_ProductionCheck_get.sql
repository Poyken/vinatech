
/* exec usp_VVT_ProductionCheck_get '','','VVT','2020-05-15','','','','ECVT27-247'    */

CREATE  PROCEDURE [dbo].[usp_VVT_ProductionCheck_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pMonth DATETIME = NULL,
	--@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL
AS	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	DECLARE @FromDate    VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pMonth)), 120)  +'-01'    + ' 10:29:59'
	DECLARE @ToDate      VARCHAR(10) = CONVERT(VARCHAR(7), DATEADD(MONTH,  1, CONVERT(smalldatetime, @pMonth)), 120) +'-01'    + ' 10:30:01'

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '')    = '' THEN '*' ELSE @pRouteCode    END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '')    = '' THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '')      = '' THEN '*' ELSE @pLotNo        END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

--DECLARE @baoloi  VARCHAR(30) = @FromDate+'---'+@ToDate
--				RAISERROR(@baoloi,16,1,'K123')
--				RETURN

	SET NOCOUNT ON;

	
	select 'http://192.168.1.23:8081/' as MaterialCode
	--select 'http://192.168.1.234:8080/' as MaterialCode

	return;

		 ; with tung as (
		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		 from 
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 ----group by c.Barcode,b.RouteCode--,(ProdDateTime)
		 ----order by a.FindRouteCode 
		 --union
		 --select  c.Barcode--, FindRouteCode as RouteCode,a.FindRouteCode,0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
		 --from 
		 --STB_SetInfo c
		 --full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
		 --where  (a.CompanyCode='VVT'  and a.FindDateTime>'2020-07-01' )
		 ----group by c.Barcode,a.FindRouteCode--,(FindDateTime)
		 ----order by a.FindRouteCode 
	 ),
	 tungfinished as (
	  	 select  c.Barcode,count(b.RouteCode) as totalcount
		 from 
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung)
		 group by c.Barcode
	 ),
	 tungfinished2 as (		
		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
		 from 
		 STB_SetInfo c
		 left outer join tungfinished on tungfinished.Barcode=c.Barcode
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung)
		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
	 ),
	  tung0 as (
	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		from  STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where c.Barcode in (select Barcode from tung)
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
		 union
		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
		 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
		 from  STB_SetInfo c
		 full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
		 where   c.Barcode in (select Barcode from tung)
		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
	 ),
	 tung11 as (
	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
	 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,
	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
	 from tung0
		group by Barcode,RouteCode,FindRouteCode--,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
	 --	order by RouteCode
	),
	tung1 as (
	select 
	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
	 from tung11
	 left outer join tungfinished2 
	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
	 ),
	tung22 as (
	select *
	from tung1 where RouteCode='V-22' 
	),
	tung23 as (
	select *
	from tung1 where RouteCode='V-23'
	)
	,
	tung24 as (
	select *
	from tung1 where RouteCode='V-24'
	)
	,
	tung25 as (
	select *
	from tung1 where RouteCode='V-25'
	)
	,
	tung27 as (
	select *
	from tung1 where RouteCode='V-27'
	)
	,
	tung28 as (
	select *
	from tung1 where RouteCode='V-28'
	)
	,
	tung40 as (
	select *
	from tung1 where RouteCode='V-40'
	),
	tlast as (
	select *from tung22 --where  ProdDateTime>'2020-07-01'
	--union
	--select tung23.* from tung23--,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	--union  																	
	--select tung40.* from tung40--,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union									 								
	select tung24.* from tung24,tung22  where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
	union  									  									
	select tung25.* from tung25,tung24  where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
	union  									 									
	select tung27.* from tung27,tung25  where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
	union  									 									
	select tung28.* from tung28,tung27  where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
	),
	last2 as (
	select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty,/*soluongOut,*/ 
	CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
	from tlast
	--order by ProdDateTime
	),
	DRI as (
	select *, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  FindDateTime 
	from last2
	where  ProdDateTime>@FromDate  and ProdDateTime<@ToDate
	),
	deptrai as (
	select
		   'VVT'   AS 사업장
		  --,DRI.ControlNo
	      --,DRI.Barcode
		  ,DRI.MaterialCode
		  ,MM2.MaterialName
		  --,DRI.InputLineCode
		  --,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName
		  ,FindDateTime
		  ,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
		  
		  ,sum(DRI.DefectQty) as DefectQty
		  
	from DRI 
			LEFT OUTER JOIN STB_RouteInfo          RI	    ON DRI.FindRouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MaterialMaster   MM2	    ON DRI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	    ON DRI.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	    ON DRI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	    ON DRI.WorkerCode = PWI.WorkerCode
	 group by 	  
		--DRI.ControlNo
	      --,DRI.Barcode
		  DRI.MaterialCode
		  ,MM2.MaterialName
		  --,DRI.InputLineCode
		  --,LI.LineName
		  ,DRI.RouteCode
		  ,RI.RouteName		
		  ,DRI.FindDateTime
	)--,
	--deptrai1 as (
	select 	 'VVT' as ComPanyCode
		  ,MaterialCode
		  ,MaterialName
		  --,InputLineCode
		  --,LineName
		  ,RouteCode
		  ,RouteName
		  ,FindDateTime
		  ,sum(total) as total		  
		  ,sum(DefectQty) as DefectQty
		  ,(case when RouteCode='V-22' then
		  sum(total)
		  when  RouteCode='V-24' then
		  sum(total) - ISNULL((select sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=MaterialCode /*and InputLineCode=deptrai1.InputLineCode*/
		     group by  MaterialCode/*,InputLineCode*/),0) + ISNULL((SELECT QTYONPAGER FROM STB_VN_InventoryFirst  WHERE STAGE='V-24' AND MODEL=MaterialCode AND CONVERT(VARCHAR(7),DateInput,120) = FindDateTime),0)
													   -  ISNULL((select sum(DefectQty) from deptrai where RouteCode='V-23' and MaterialCode=MaterialCode group by  MaterialCode/*,InputLineCode*/),0)
		  when  RouteCode='V-25' then
		  sum(total) - ISNULL((select sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=MaterialCode /*and InputLineCode=deptrai1.InputLineCode*/
		     group by  MaterialCode/*,InputLineCode*/),0) + ISNULL((SELECT QTYONPAGER FROM STB_VN_InventoryFirst  WHERE STAGE='V-24' AND MODEL=MaterialCode AND CONVERT(VARCHAR(7),DateInput,120) = FindDateTime),0)
		  when  RouteCode='V-27' then
		  sum(total) - ISNULL((select sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=MaterialCode /*and InputLineCode=deptrai1.InputLineCode*/
		     group by  MaterialCode/*,InputLineCode*/),0) + ISNULL((SELECT QTYONPAGER FROM STB_VN_InventoryFirst  WHERE STAGE='V-24' AND MODEL=MaterialCode AND CONVERT(VARCHAR(7),DateInput,120) = FindDateTime),0)
		  when  RouteCode='V-28' then
		  sum(total) - ISNULL((select sum(DefectQty) from deptrai where RouteCode='V-24' and MaterialCode=MaterialCode /*and InputLineCode=deptrai1.InputLineCode*/
		     group by  MaterialCode/*,InputLineCode*/),0) + ISNULL((SELECT QTYONPAGER FROM STB_VN_InventoryFirst  WHERE STAGE='V-24' AND MODEL=MaterialCode AND CONVERT(VARCHAR(7),DateInput,120) = FindDateTime),0)
		  else
		  0
		  end) as  "b2=a1+b1+d1-e1-c2"

		  from deptrai

		   group by 	 
		   MaterialCode
		  ,MaterialName
		  --,InputLineCode
		  --,LineName
		  ,RouteCode
		  ,RouteName,FindDateTime 	 
						
END
