-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ProductionResult_webSystem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pMonth DATETIME = NULL,
	--@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pGetFrom26 BIT = 0
AS	
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN 'VVT' ELSE @pCompanyCode END

	DECLARE @FromDate    VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 0, CONVERT(smalldatetime, @pMonth)), 120)  +'-01'   + ' 10:30:00'
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(7), DATEADD(MONTH, 1, CONVERT(smalldatetime, @pMonth)), 120)  +'-01'   + ' 10:30:00'
	
	if(@pGetFrom26=1)
	begin
		select @FromDate    = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pMonth)), 120)  +'-26'   + ' 10:30:00'
		select @ToDate      = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @pMonth)), 120) +'-26'   + ' 10:30:00'
	end

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	SET NOCOUNT ON;



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
		  ,DRI.MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RouteName
		  	  ,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"	
		  , (case when  FindDateTime=1  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_1"	
		  , (case when  FindDateTime=2  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_2"
		  , (case when  FindDateTime=3  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_3"
		  , (case when  FindDateTime=4  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_4"
		  , (case when  FindDateTime=5  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_5"
		  , (case when  FindDateTime=6  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_6"
		  , (case when  FindDateTime=7  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_7"
		  , (case when  FindDateTime=8  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_8"
		  , (case when  FindDateTime=9  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_9"
		  , (case when  FindDateTime=10 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_10"
		  , (case when  FindDateTime=11 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_11"
		  , (case when  FindDateTime=12 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_12"
		  , (case when  FindDateTime=13 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_13"
		  , (case when  FindDateTime=14 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_14"
		  , (case when  FindDateTime=15 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_15"
		  , (case when  FindDateTime=16 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_16"
		  , (case when  FindDateTime=17 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_17"
		  , (case when  FindDateTime=18 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_18"
		  , (case when  FindDateTime=19 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_19"
		  , (case when  FindDateTime=20 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_20"
		  , (case when  FindDateTime=21 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_21"
		  , (case when  FindDateTime=22 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_22"
		  , (case when  FindDateTime=23 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_23"
		  , (case when  FindDateTime=24 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_24"
		  , (case when  FindDateTime=25 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_25"
		  , (case when  FindDateTime=26 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_26"
		  , (case when  FindDateTime=27 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_27"
		  , (case when  FindDateTime=28 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_28"
		  , (case when  FindDateTime=29 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_29"
		  , (case when  FindDateTime=30 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_30"
		  , (case when  FindDateTime=31 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "day_31"

		  ,sum(DRI.DefectQty) as DefectQty
		   ,(case when  FindDateTime=1 then sum(DRI.DefectQty)  end) as "Defect_1"	
		   ,(case when  FindDateTime=2 then sum(DRI.DefectQty)  end) as "Defect_2"
		   ,(case when  FindDateTime=3 then sum(DRI.DefectQty)  end) as "Defect_3"
		   ,(case when  FindDateTime=4 then sum(DRI.DefectQty)  end) as "Defect_4"
		   ,(case when  FindDateTime=5 then sum(DRI.DefectQty)  end) as "Defect_5"
		   ,(case when  FindDateTime=6 then sum(DRI.DefectQty)  end) as "Defect_6"
		   ,(case when  FindDateTime=7 then sum(DRI.DefectQty)  end) as "Defect_7"
		   ,(case when  FindDateTime=8 then sum(DRI.DefectQty)  end) as "Defect_8"
		   ,(case when  FindDateTime=9 then sum(DRI.DefectQty)  end) as "Defect_9"
		   ,(case when  FindDateTime=10 then sum(DRI.DefectQty)  end) as "Defect_10"
		  , (case when  FindDateTime=11 then sum(DRI.DefectQty)  end) as "Defect_11"
		  , (case when  FindDateTime=12 then sum(DRI.DefectQty)  end) as "Defect_12"
		  , (case when  FindDateTime=13 then sum(DRI.DefectQty)  end) as "Defect_13"
		  , (case when  FindDateTime=14 then sum(DRI.DefectQty)  end) as "Defect_14"
		  , (case when  FindDateTime=15 then sum(DRI.DefectQty)  end) as "Defect_15"
		  , (case when  FindDateTime=16 then sum(DRI.DefectQty)  end) as "Defect_16"
		  , (case when  FindDateTime=17 then sum(DRI.DefectQty)  end) as "Defect_17"
		  , (case when  FindDateTime=18 then sum(DRI.DefectQty)  end) as "Defect_18"
		  , (case when  FindDateTime=19 then sum(DRI.DefectQty)  end) as "Defect_19"
		  , (case when  FindDateTime=20 then sum(DRI.DefectQty)  end) as "Defect_20"
		  , (case when  FindDateTime=21 then sum(DRI.DefectQty)  end) as "Defect_21"
		  , (case when  FindDateTime=22 then sum(DRI.DefectQty)  end) as "Defect_22"
		  , (case when  FindDateTime=23 then sum(DRI.DefectQty)  end) as "Defect_23"
		  , (case when  FindDateTime=24 then sum(DRI.DefectQty)  end) as "Defect_24"
		  , (case when  FindDateTime=25 then sum(DRI.DefectQty)  end) as "Defect_25"
		  , (case when  FindDateTime=26 then sum(DRI.DefectQty)  end) as "Defect_26"
		  , (case when  FindDateTime=27 then sum(DRI.DefectQty)  end) as "Defect_27"
		  , (case when  FindDateTime=28 then sum(DRI.DefectQty)  end) as "Defect_28"
		  , (case when  FindDateTime=29 then sum(DRI.DefectQty)  end) as "Defect_29"
		  , (case when  FindDateTime=30 then sum(DRI.DefectQty)  end) as "Defect_30"
		  , (case when  FindDateTime=31 then sum(DRI.DefectQty)  end) as "Defect_31" 
	from DRI  WITH(NOLOCK)  
			--LEFT OUTER JOIN STB_RouteInfo          RI	  WITH(NOLOCK)     ON DRI.FindRouteCode = RI.RouteCode
			--  LEFT OUTER JOIN STB_MaterialMaster   MM2	  WITH(NOLOCK)     ON DRI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  WITH(NOLOCK)     ON InputLineCode = LI.LineCode			 
			--  LEFT OUTER JOIN STB_MachineMaster    MM	  WITH(NOLOCK)     ON DRI.MachineCode = MM.MachineCode
			--  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)    ON DRI.WorkerCode = PWI.WorkerCode
     where 1=1
	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   AND (@MaterialCode = '*' OR DRI.MaterialCode   = @MaterialCode)
	   and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   
	 group by 	  --DRI.ControlNo
	      --,DRI.Barcode
		  DRI.MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode
		  ,RouteName		
		  ,DRI.FindDateTime
	)
	select 	 @CompanyCode as ComPanyCode
		  ,MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
		  ,RouteCode
		  ,RouteName,

		  sum(total) as total,
		   sum("day_1") as "day_1" ,
		   sum("day_2") as "day_2" ,
		   sum("day_3") as "day_3" ,
		   sum("day_4") as "day_4" ,
		   sum("day_5") as "day_5" ,
		   sum("day_6") as "day_6" ,
		   sum("day_7") as "day_7" ,
		   sum("day_8") as "day_8" ,
		   sum("day_9") as "day_9" ,
		  sum("day_10") as "day_10" ,
		  sum("day_11") as "day_11" ,
		  sum("day_12") as "day_12" ,
		  sum("day_13") as "day_13" ,
		  sum("day_14") as "day_14" ,
		  sum("day_15") as "day_15" ,
		  sum("day_16") as "day_16" ,
		  sum("day_17") as "day_17" ,
		  sum("day_18") as "day_18" ,
		  sum("day_19") as "day_19" ,
		  sum("day_20") as "day_20" ,
		  sum("day_21") as "day_21" ,
		  sum("day_22") as "day_22" ,
		  sum("day_23") as "day_23" ,
		  sum("day_24") as "day_24" ,
		  sum("day_25") as "day_25" ,
		  sum("day_26") as "day_26" ,
		  sum("day_27") as "day_27" ,
		  sum("day_28") as "day_28" ,
		  sum("day_29") as "day_29" ,
		  sum("day_30") as "day_30" ,
		  sum("day_31") as "day_31" ,
		  
		  sum(DefectQty) as DefectQty,
		  sum("Defect_1"	) as    "Defect_1"	  ,
		  sum("Defect_2"	) as 	"Defect_2"	  ,
		  sum("Defect_3"	) as 	"Defect_3"	  ,
		  sum("Defect_4"	) as 	"Defect_4"	  ,
		  sum("Defect_5"	) as 	"Defect_5"	  ,
		  sum("Defect_6"	) as 	"Defect_6"	  ,
		  sum("Defect_7"	) as 	"Defect_7"	  ,
		  sum("Defect_8"	) as 	"Defect_8"	  ,
		  sum("Defect_9"	) as 	"Defect_9"	  ,
		  sum("Defect_10"	)  as	 "Defect_10"	   ,
		  sum( "Defect_11"	)  as	 "Defect_11"   ,
		  sum( "Defect_12"	)  as	 "Defect_12"   ,
		  sum( "Defect_13"	)  as	 "Defect_13"   ,
		  sum( "Defect_14"	)  as	 "Defect_14"   ,
		  sum( "Defect_15"	)  as	 "Defect_15"   ,
		  sum( "Defect_16"	)  as	 "Defect_16"   ,
		  sum( "Defect_17"	)  as	 "Defect_17"   ,
		  sum( "Defect_18"	)  as	 "Defect_18"   ,
		  sum( "Defect_19"	)  as	 "Defect_19"   ,
		  sum( "Defect_20"	)  as	 "Defect_20"   ,
		  sum( "Defect_21"	)  as	 "Defect_21"   ,
		  sum( "Defect_22"	)  as	 "Defect_22"   ,
		  sum( "Defect_23"	)  as	 "Defect_23"   ,
		  sum( "Defect_24"	)  as	 "Defect_24"   ,
		  sum( "Defect_25"	)  as	 "Defect_25"   ,
		  sum( "Defect_26"	)  as	 "Defect_26"   ,
		  sum( "Defect_27"	)  as	 "Defect_27"   ,
		  sum( "Defect_28"	)  as	 "Defect_28"   ,
		  sum( "Defect_29"	)  as	 "Defect_29"   ,
		  sum( "Defect_30"	)  as	 "Defect_30"   ,
		  sum( "Defect_31"	)  as	 "Defect_31"   
		  from deptrai WITH(NOLOCK)  
		   group by 	 MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
		  ,RouteCode
		  ,RouteName
		  order by RouteCode

END
