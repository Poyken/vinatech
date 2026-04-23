
--  exec usp_GetDailyProdRouteSummary '','','VVT','','VVC-01','2020-08-22'   

CREATE  PROCEDURE [dbo].[usp_GetDailyProd_RouteSummary_VVT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL
AS	
	
BEGIN

	SET NOCOUNT ON;

		DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
	   --  @LineCode VARCHAR(20) = @pLineCode,		                                                                                                                    -- 라인별 카렌더가 다르면 전일이 다를수 있음
			@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END,	                                      	-- 라인별 카렌더가 다르면 전일이 다를수 있음
			@JobDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pJobDate)), 120)    +  ' 10:30:01' , 			    
			@YesterDay VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(smalldatetime, @pJobDate)), 120) +  ' 10:29:59'
			
			 
			--select @YesterDay,@JobDate
			--return;

		 ; with tung as (
		 select  c.Barcode--,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		 from 
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@YesterDay  and b.ProdDateTime<@JobDate
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
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 group by c.Barcode
	 ),
	 tungfinished2 as (		
		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
		 from 
		 STB_SetInfo c WITH(NOLOCK) 
		 left outer join tungfinished WITH(NOLOCK)  on tungfinished.Barcode=c.Barcode
		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
	 ),
	  tung0 as (
	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		min(b.ProdQty) as ProdQty,0 as DefectQty,0 as RepairQty,0 as LossQty,max(ProdDateTime) as ProdDateTime 
		from  STB_SetInfo c WITH(NOLOCK) 
		 left outer join  STB_ProdRouteHist b WITH(NOLOCK) 	on c.ControlNo=b.ControlNo	 
		 where c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
		 union
		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as WorkerCode,SIExtText07,SIExtInt01,
		 0 as ProdQty,sum(a.DefectQty) as DefectQty,sum(RepairQty) as RepairQty,sum(LossQty) as LossQty,max(FindDateTime) as ProdDateTime 
		 from  STB_SetInfo c WITH(NOLOCK) 
		 full outer join  STB_DefectRepairInfo a WITH(NOLOCK)  on  a.ControlNo=c.ControlNo
		 where   c.Barcode in (select Barcode from tung WITH(NOLOCK) )
		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,/*c.MachineCode,c.WorkerCode,*/SIExtText07,SIExtInt01
		 --order by a.FindRouteCode 
	 ),
	 tung11 as (
	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
	 max(WorkerCode) as WorkerCode,max(SIExtText07) as SIExtText07,max(SIExtInt01) as SIExtInt01,sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty, sum(RepairQty) as RepairQty,sum(LossQty) as LossQty,
	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
	 from tung0 WITH(NOLOCK) 
		group by Barcode,RouteCode,FindRouteCode--,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
	 --	order by RouteCode
	),
	tung1 as (
	select 
	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
	 from tung11 WITH(NOLOCK) 
	 left outer join tungfinished2  WITH(NOLOCK) 
	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
	 ),
	tung22 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-22'
	),
	tung23 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-23'
	)
	,
	tung24 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-24'
	)
	,
	tung25 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-25'
	)
	,
	tung27 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-27'
	)
	,
	tung28 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-28'
	)
	,
	tung40 as (
	select *
	from tung1 WITH(NOLOCK)  where RouteCode='V-40'
	),
	tlast as (
	select *from tung22 WITH(NOLOCK)  --where  ProdDateTime>'2020-07-01'
	union
	select tung23.* from tung23 WITH(NOLOCK) --,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union  																	
	select tung40.* from tung40 WITH(NOLOCK) --,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union									 								
	select tung24.* from tung24 WITH(NOLOCK) ,tung22 WITH(NOLOCK)   where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
	union  									  									
	select tung25.* from tung25 WITH(NOLOCK) ,tung24 WITH(NOLOCK)   where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
	union  									 									
	select tung27.* from tung27 WITH(NOLOCK) ,tung25 WITH(NOLOCK)   where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
	union  									 									
	select tung28.* from tung28 WITH(NOLOCK) ,tung27 WITH(NOLOCK)   where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
	),
	last2 as (
	select Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01, ProdQty, DefectQty, RepairQty, LossQty,/*soluongOut,*/ 
	CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
	from tlast WITH(NOLOCK) 
	--order by ProdDateTime
	),
	DRI as (
	select *, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  FindDateTime 
	from last2 WITH(NOLOCK) 
	where  ProdDateTime>@YesterDay  and ProdDateTime<@JobDate
	)
	,
	deptrai as (
		select
		   'VVT'   AS 사업장
		  --,DRI.ControlNo
	      --,DRI.Barcode
		  --,DRI.MaterialCode
		  --,MM2.MaterialName
		  ,DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.FindDateTime
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName
		  ,sum(DRI.ProdQty /*- ISNULL(DRI.DefectQty, 0)*/)  as "total"	

		  ,sum(DRI.DefectQty) as DefectQty
		  ,sum(DRI.RepairQty) as RepairQty
		  ,sum(DRI.LossQty) as LossQty
		  --,SUM(DRI.OutputQty) + SUM(DRI.DefectQty) + SUM(DRI.RepairQty) + SUM(DRI.LossQty) AS TotalQty
		 
		from DRI  WITH(NOLOCK) 
			LEFT OUTER JOIN STB_RouteInfo          RI	 WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
			  LEFT OUTER JOIN STB_MaterialMaster   MM2	 WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	 WITH(NOLOCK)     ON DRI.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)    ON DRI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	 WITH(NOLOCK)     ON DRI.WorkerCode = PWI.WorkerCode
		where 1=1
	   --AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)

		group by 	  
		  --DRI.ControlNo
	      --,DRI.Barcode
		  --DRI.MaterialCode
		  --,MM2.MaterialName
		  DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode
		  ,RI.RouteName		
		  ,DRI.FindDateTime
		)
		,
	baihatcuoi as (
		select 	 --'VVT' as ComPanyCode
		  --,MaterialCode
		  --,MaterialName
		  InputLineCode
		  ,LineName
		  ,FindDateTime
		  ,RouteCode
		  ,RouteName

		  ,sum(total) as OutputQty	
		  
		  ,sum(DefectQty) as DefectQty
		  ,sum(RepairQty) as RepairQty
		  ,sum(LossQty) as LossQty

		  from deptrai WITH(NOLOCK) 

		   group by 
		   --MaterialCode
		  --,MaterialName
		  InputLineCode
		  ,LineName
		  ,FindDateTime
		  ,RouteCode
		  ,RouteName
		  -- sum(LossQty) as LossQty
		  )
		  ,
	watuyetwoi as (
		  select
		  RouteCode
		  ,RouteName		  
			,	case when finddatetime=SUBSTRING(@YesterDay,1,10) then sum(OutputQty) end as befOutputQty
			,	case when finddatetime<>SUBSTRING(@YesterDay,1,10) then sum(OutputQty) end as OutputQty
						,	case when finddatetime=SUBSTRING(@YesterDay,1,10) then sum(DefectQty) end as befDefectQty
			,	case when finddatetime<>SUBSTRING(@YesterDay,1,10) then sum(DefectQty) end as DefectQty
						,	case when finddatetime=SUBSTRING(@YesterDay,1,10) then sum(RepairQty) end as befRepairQty
			,	case when finddatetime<>SUBSTRING(@YesterDay,1,10) then sum(RepairQty) end as RepairQty
						,	case when finddatetime=SUBSTRING(@YesterDay,1,10) then sum(LossQty) end as befLossQty
			,	case when finddatetime<>SUBSTRING(@YesterDay,1,10) then sum(LossQty) end as 		LossQty	
		    ,SUM(OutputQty) + SUM(DefectQty) + SUM(RepairQty) + SUM(LossQty) AS TotalQty

			from 
			baihatcuoi  WITH(NOLOCK) 
			group by 		  
			RouteCode
			,RouteName
			,FindDateTime
		)
	select 
		   RouteCode
		  ,RouteName		  
		  ,max(OutputQty) as OutputQty		  
		  ,max(DefectQty) as DefectQty		 
		  ,max(RepairQty) as RepairQty
		  ,SUM(OutputQty) + SUM(DefectQty) + SUM(RepairQty) + SUM(LossQty) AS TotalQty
		  ,max(LossQty) as LossQty

		  ,max(befOutputQty) as BefOutputQty
		  ,max(befDefectQty) as BefDefectQty
		  ,max(befRepairQty) as BefRepairQty
		  ,max(befLossQty) as BefLossQty
		  ,SUM(befOutputQty) + SUM(befDefectQty) + SUM(befRepairQty) + SUM(befLossQty) AS BefTotalQty
	   from watuyetwoi WITH(NOLOCK) 
	   group by 		   RouteCode ,RouteName
	   --,total,beftotal,DefectQty,befDefectQty,RepairQty,befRepairQty,LossQty,befLossQty

	--	exec usp_GetDailyProd_RouteSummary_VVT '','','VVT','','VVC-01','2020-10-07'   
END
