
CREATE PROCEDURE [dbo].[usp_bomreport_get_TEST2]          ---   [usp_bomreport_get_TEST2] '','','2023-01-01','2023-03-31'
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
) ,
 
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
 
		from RawView RV 
 
			LEFT OUTER JOIN STB_RouteInfo          RI	  with(nolock)     ON RV.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MaterialMaster    MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			 
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
), NG_SX as
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


select * from NG_SX ---where barcode = 'MVVMU066R015501'

END