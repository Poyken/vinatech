
/* exec usp_VVT_ProductionResult_get '','','VVT','2021-03-01','','','','',1    */

CREATE  PROCEDURE [dbo].[usp_VVT_ProductionResult_get]
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
		select @FromDate    = CONVERT(VARCHAR(7), DATEADD(MONTH, -1, CONVERT(smalldatetime, @pMonth)), 120)  +'-16'   + ' 10:30:00'
		select @ToDate      = CONVERT(VARCHAR(7), DATEADD(MONTH,  0, CONVERT(smalldatetime, @pMonth)), 120) +'-16'   + ' 10:30:00'
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
		  and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 ),
RawView0 as (
	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, 
		
		case when a.DefectCode not in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() ) then sum(a.DefectQty)  - sum(a.RepairQty) else 0 end as DefectQty ,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='pqc') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as PQC,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='qcpart') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as QcPart,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='rely') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as DoTinCay,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='sxdestroy') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as QcSx,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='thietbi') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as SuaMay
		
		,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		  and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime,a.DefectCode
),
RawView as (
	 	select  Barcode,RouteCode, FindRouteCode,
		ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,
		max(ProdQty) as ProdQty, 
		sum(DefectQty) as DefectQty ,
		sum( PQC) as PQC,
		sum( QcPart) as QcPart,
		sum( DoTinCay) as DoTinCay,
		sum( QcSx) as QcSx,
		sum( SuaMay) as SuaMay,
		max(ProdDateTime) as ProdDateTime, 
		max(CreateDateTime) as CreateDateTime
		from  RawView0		 
		 group by Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01 --,a.DefectCode--,b.CreateDateTime
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


		  max(RV.ProdQty  ) as ProdQty,
		  sum(RV.DefectQty  ) as DefectQty, 
		sum(PQC) as PQC,
		sum( QcPart) as QcPart,
		sum( DoTinCay) as DoTinCay,
		sum( QcSx) as QcSx,
		sum(  SuaMay) as SuaMay,


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
		  	  --,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  as "total"
			 ,sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) - ISNULL(qcpart, 0) - ISNULL(DoTinCay, 0) -ISNULL(QcSx, 0) - ISNULL(SuaMay, 0)) as "total"
		,sum(PQC) as PQC,
		sum( QcPart) as QcPart,
		sum( DoTinCay) as DoTinCay,
		sum( QcSx) as QcSx,
		sum(  SuaMay) as SuaMay
		 , (case when  FindDateTime=1  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "1"	
		  , (case when  FindDateTime=2  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "2"
		  , (case when  FindDateTime=3  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "3"
		  , (case when  FindDateTime=4  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "4"
		  , (case when  FindDateTime=5  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "5"
		  , (case when  FindDateTime=6  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "6"
		  , (case when  FindDateTime=7  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "7"
		  , (case when  FindDateTime=8  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "8"
		  , (case when  FindDateTime=9  then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "9"
		  , (case when  FindDateTime=10 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "10"
		  , (case when  FindDateTime=11 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "11"
		  , (case when  FindDateTime=12 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "12"
		  , (case when  FindDateTime=13 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "13"
		  , (case when  FindDateTime=14 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "14"
		  , (case when  FindDateTime=15 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "15"
		  , (case when  FindDateTime=16 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "16"
		  , (case when  FindDateTime=17 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "17"
		  , (case when  FindDateTime=18 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "18"
		  , (case when  FindDateTime=19 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "19"
		  , (case when  FindDateTime=20 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "20"
		  , (case when  FindDateTime=21 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "21"
		  , (case when  FindDateTime=22 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "22"
		  , (case when  FindDateTime=23 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "23"
		  , (case when  FindDateTime=24 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "24"
		  , (case when  FindDateTime=25 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "25"
		  , (case when  FindDateTime=26 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "26"
		  , (case when  FindDateTime=27 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "27"
		  , (case when  FindDateTime=28 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "28"
		  , (case when  FindDateTime=29 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "29"
		  , (case when  FindDateTime=30 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "30"
		  , (case when  FindDateTime=31 then sum(DRI.ProdQty - ISNULL(DRI.DefectQty, 0))  end) as "31"

		  ,sum(DRI.DefectQty) as DefectQty
		   ,(case when  FindDateTime=1 then sum(DRI.DefectQty)  end) as "1_Defect"	
		   ,(case when  FindDateTime=2 then sum(DRI.DefectQty)  end) as "2_Defect"
		   ,(case when  FindDateTime=3 then sum(DRI.DefectQty)  end) as "3_Defect"
		   ,(case when  FindDateTime=4 then sum(DRI.DefectQty)  end) as "4_Defect"
		   ,(case when  FindDateTime=5 then sum(DRI.DefectQty)  end) as "5_Defect"
		   ,(case when  FindDateTime=6 then sum(DRI.DefectQty)  end) as "6_Defect"
		   ,(case when  FindDateTime=7 then sum(DRI.DefectQty)  end) as "7_Defect"
		   ,(case when  FindDateTime=8 then sum(DRI.DefectQty)  end) as "8_Defect"
		   ,(case when  FindDateTime=9 then sum(DRI.DefectQty)  end) as "9_Defect"
		   ,(case when  FindDateTime=10 then sum(DRI.DefectQty)  end) as "10_Defect"
		  , (case when  FindDateTime=11 then sum(DRI.DefectQty)  end) as "11_Defect"
		  , (case when  FindDateTime=12 then sum(DRI.DefectQty)  end) as "12_Defect"
		  , (case when  FindDateTime=13 then sum(DRI.DefectQty)  end) as "13_Defect"
		  , (case when  FindDateTime=14 then sum(DRI.DefectQty)  end) as "14_Defect"
		  , (case when  FindDateTime=15 then sum(DRI.DefectQty)  end) as "15_Defect"
		  , (case when  FindDateTime=16 then sum(DRI.DefectQty)  end) as "16_Defect"
		  , (case when  FindDateTime=17 then sum(DRI.DefectQty)  end) as "17_Defect"
		  , (case when  FindDateTime=18 then sum(DRI.DefectQty)  end) as "18_Defect"
		  , (case when  FindDateTime=19 then sum(DRI.DefectQty)  end) as "19_Defect"
		  , (case when  FindDateTime=20 then sum(DRI.DefectQty)  end) as "20_Defect"
		  , (case when  FindDateTime=21 then sum(DRI.DefectQty)  end) as "21_Defect"
		  , (case when  FindDateTime=22 then sum(DRI.DefectQty)  end) as "22_Defect"
		  , (case when  FindDateTime=23 then sum(DRI.DefectQty)  end) as "23_Defect"
		  , (case when  FindDateTime=24 then sum(DRI.DefectQty)  end) as "24_Defect"
		  , (case when  FindDateTime=25 then sum(DRI.DefectQty)  end) as "25_Defect"
		  , (case when  FindDateTime=26 then sum(DRI.DefectQty)  end) as "26_Defect"
		  , (case when  FindDateTime=27 then sum(DRI.DefectQty)  end) as "27_Defect"
		  , (case when  FindDateTime=28 then sum(DRI.DefectQty)  end) as "28_Defect"
		  , (case when  FindDateTime=29 then sum(DRI.DefectQty)  end) as "29_Defect"
		  , (case when  FindDateTime=30 then sum(DRI.DefectQty)  end) as "30_Defect"
		  , (case when  FindDateTime=31 then sum(DRI.DefectQty)  end) as "31_Defect" 
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
	   --and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   
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
		
		sum(PQC) as PQC,
		sum( QcPart) as QcPart,
		sum( DoTinCay) as DoTinCay,
		sum( QcSx) as SX_kiemtra,
		sum(  SuaMay) as SuaMay,

		   sum("1") as "1" ,
		   sum("2") as "2" ,
		   sum("3") as "3" ,
		   sum("4") as "4" ,
		   sum("5") as "5" ,
		   sum("6") as "6" ,
		   sum("7") as "7" ,
		   sum("8") as "8" ,
		   sum("9") as "9" ,
		  sum("10") as "10" ,
		  sum("11") as "11" ,
		  sum("12") as "12" ,
		  sum("13") as "13" ,
		  sum("14") as "14" ,
		  sum("15") as "15" ,
		  sum("16") as "16" ,
		  sum("17") as "17" ,
		  sum("18") as "18" ,
		  sum("19") as "19" ,
		  sum("20") as "20" ,
		  sum("21") as "21" ,
		  sum("22") as "22" ,
		  sum("23") as "23" ,
		  sum("24") as "24" ,
		  sum("25") as "25" ,
		  sum("26") as "26" ,
		  sum("27") as "27" ,
		  sum("28") as "28" ,
		  sum("29") as "29" ,
		  sum("30") as "30" ,
		  sum("31") as "31" ,
		  
		  sum(DefectQty) as DefectQty,
		  sum("1_Defect"	) as  "1_Defect"	  ,
		  sum("2_Defect"	) as 	"2_Defect"	  ,
		  sum("3_Defect"	) as 	"3_Defect"	  ,
		  sum("4_Defect"	) as 	"4_Defect"	  ,
		  sum("5_Defect"	) as 	"5_Defect"	  ,
		  sum("6_Defect"	) as 	"6_Defect"	  ,
		  sum("7_Defect"	) as 	"7_Defect"	  ,
		  sum("8_Defect"	) as 	"8_Defect"	  ,
		  sum("9_Defect"	) as 	"9_Defect"	  ,
		  sum("10_Defect"	)  as	"10_Defect"	   ,
		  sum( "11_Defect"	)  as	 "11_Defect"   ,
		  sum( "12_Defect"	)  as	 "12_Defect"   ,
		  sum( "13_Defect"	)  as	 "13_Defect"   ,
		  sum( "14_Defect"	)  as	 "14_Defect"   ,
		  sum( "15_Defect"	)  as	 "15_Defect"   ,
		  sum( "16_Defect"	)  as	 "16_Defect"   ,
		  sum( "17_Defect"	)  as	 "17_Defect"   ,
		  sum( "18_Defect"	)  as	 "18_Defect"   ,
		  sum( "19_Defect"	)  as	 "19_Defect"   ,
		  sum( "20_Defect"	)  as	 "20_Defect"   ,
		  sum( "21_Defect"	)  as	 "21_Defect"   ,
		  sum( "22_Defect"	)  as	 "22_Defect"   ,
		  sum( "23_Defect"	)  as	 "23_Defect"   ,
		  sum( "24_Defect"	)  as	 "24_Defect"   ,
		  sum( "25_Defect"	)  as	 "25_Defect"   ,
		  sum( "26_Defect"	)  as	 "26_Defect"   ,
		  sum( "27_Defect"	)  as	 "27_Defect"   ,
		  sum( "28_Defect"	)  as	 "28_Defect"   ,
		  sum( "29_Defect"	)  as	 "29_Defect"   ,
		  sum( "30_Defect"	)  as	 "30_Defect"   ,
		  sum( "31_Defect"	)  as	 "31_Defect"   
		  from deptrai WITH(NOLOCK)  
		   group by 	 MaterialCode
		  ,MaterialName
		  ,InputLineCode
		  ,LineName
		  ,RouteCode
		  ,RouteName
		  order by RouteCode

END
