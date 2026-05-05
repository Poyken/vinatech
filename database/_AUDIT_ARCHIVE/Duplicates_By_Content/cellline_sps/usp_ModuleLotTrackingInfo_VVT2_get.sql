

/* exec usp_ModuleLotTrackingInfo_VVT2_get '','','VVT','2021-12-01','2021-12-30','','','',''    */

CREATE  PROCEDURE [dbo].[usp_ModuleLotTrackingInfo_VVT2_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pMarkingLetter VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE	@MarkingLetter VARCHAR(30) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END

BEGIN

	SET NOCOUNT ON;

---if @MarkingLetter is not null begin

	
;with   ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 ),
RawView0 as (
	 	select  b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, 
		case when a.DefectCode not in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() ) then sum(a.DefectQty)  - sum(a.RepairQty) else 0 end as DefectQty ,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='pqc') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as PQC,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='qcpart') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as QcPart,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='rely') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as DoTinCay,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='sxdestroy') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as QcSx,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='thietbi') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as SuaMay,
		max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and   b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		 
		 group by b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode--,b.CreateDateTime
),

RawView as (
	 	select  CreateUserID,Barcode,RouteCode, FindRouteCode,
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
		 group by CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01 --,a.DefectCode--,b.CreateDateTime
),

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
		distinct RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		 RV.ProdDateTime, 
		 rv.CreateUserID,
		 (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>0)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end 
		 )    
		 -- +
		 --(case  when   ((DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)  )   
			--			and  (DATEPART(HOUR, ProdDateTime)<21)     or    (DATEPART(HOUR, ProdDateTime)=20 and DATEPART(MINUTE, ProdDateTime)<30) 
			--	then     '-1' 
			--	else     '-2'    
			--	end 
		 --)    
		  as  JobDate,

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
		from RawView RV  with(nolock)   

			 OUTER APPLY (select top 1 * from    STB_RouteInfo          RI	  with(nolock)     where RV.RouteCode = RI.RouteCode)
			RI

			 OUTER APPLY (select top 1 * from    STB_MaterialMaster     MM2      with(nolock)     where  MM2.MaterialCode = RV.MaterialCode
			  )MM2

			  OUTER APPLY (select top 1 * from    STB_LineInfo         LI	  with(nolock)    where RV.InputLineCode = LI.LineCode			 
			  )LI

			   OUTER APPLY (select top 1 * from    STB_MachineMaster    MM	  with(nolock)     where RV.MachineCode = MM.MachineCode
			  )MM

			   OUTER APPLY (select top 1 * from    STB_ProdWorkerInfo   PWI	  with(nolock)     where RV.WorkerCode = PWI.WorkerCode
			   )PWI

			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	
		where 
		( 
			(mli.Lotno is not null )  or  --RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode    ) > 0 or
			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode  ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		group by 		 rv.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
		--order by RV.Barcode,RV.RouteCode 
)
	select
		   'VVT'   AS 사업장
		  ,DRI.ControlNo
	      ,DRI.Barcode
		  ,DRI.MaterialCode
		  ,MM2.MaterialName
		  ,DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName
		  ,convert(datetime,DRI.ProdDateTime,120) as ProdDateTime
		  ,DRI.JobDate
		  ,DRI.MachineCode
		  ,MM.MachineName
		  ,DRI.WorkerCode
		  ,PWI.WorkerName
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN '' 
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격' 
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult 
		  --,CONVERT(BIT,CASE WHEN ISNULL(DRI.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd*/ 
		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량 
		  , ISNULL(DRI.DefectQty, 0)                    AS DefectQty          -- 불량수량 	
		 -- , weight3.valweight as WeightUnit 
		--  , ISNULL(DRI.DefectQty, 0) * weight3.valweight/1000 as WasteWeight
		  , ww.Weight as WeightUnit 
		  , ISNULL(DRI.DefectQty, 0) * ww.Weight/1000 as WasteWeight
		  , ISNULL(DRI.DefectQty, 0) * ww.Weight as WasteWeightGr
		    , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(pqc, 0) - ISNULL(qcpart, 0) - ISNULL(DoTinCay, 0) -ISNULL(QcSx, 0) - ISNULL(SuaMay, 0)) AS ProdQty           -- 생산수량		  	  
		  , SIExtText07 AS MarkingLetter   
		  ,ISNULL(DRI.DefectQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,isnull(vwup1.ProcessUnitPriceEA,0))  as DefectPrice 
		   , ISNULL(DRI.ProdQty,0)  * ISNULL(vwup.ProcessUnitPriceEA,isnull(vwup1.ProcessUnitPriceEA,0))  as BeginPrice 
		 ,
		PQC,
		QcPart,
		 DoTinCay,
		QcSx as SX_kiemtra,
		 SuaMay

	from DRI  WITH(NOLOCK) 
			 left join stb_moudleWeightNG ww on DRI.MaterialCode = ww.MaterialCode and DRI.RouteCode= ww.Stage
			
			 OUTER APPLY (select top 1 * from    STB_RouteInfo          RI	  WITH(NOLOCK)    where DRI.FindRouteCode = RI.RouteCode
			 )RI

			  OUTER APPLY (select top 1 * from    STB_MaterialMaster   MM2	   WITH(NOLOCK)   where DRI.MaterialCode = MM2.MaterialCode
			  )MM2

			   OUTER APPLY (select top 1 * from    STB_LineInfo         LI	  WITH(NOLOCK)    where DRI.InputLineCode = LI.LineCode			 
			  )LI
			   OUTER APPLY (select top 1 * from    STB_MachineMaster    MM	   WITH(NOLOCK)   where DRI.MachineCode = MM.MachineCode
			  )MM
			   OUTER APPLY (select top 1 * from    STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)   where DRI.WorkerCode = PWI.WorkerCode
			  )PWI
		left outer join [dbo].[fn_VVT_StagePricesMODULE]() vwup on vwup.model = DRI.MaterialCode  and vwup.routecode=DRI.FindRouteCode
		outer apply(select top 1 * from [dbo].[fn_VVT_StagePricesMODULE]() vwup1 where  DRI.MaterialName  like '%'+vwup1.model +'%' and vwup1.routecode=DRI.FindRouteCode )vwup1
	 
			  
			 --OUTER APPLY (select top 1  sizecode,RouteCode,max(ProcessUnitPriceEA) as ProcessUnitPriceEA
				--from STB_Vietnam_WasteUnitPrice vwup WITH(NOLOCK)
				--where DRI.MaterialCode=vwup.sizecode and vwup.RouteCode=DRI.RouteCode
				--group by sizecode,RouteCode
				--) vwup  
			    
	 where 1=1
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   and (@MarkingLetter='*' or SIExtText07= @MarkingLetter )
	   and  SUBSTRING (DRI.Barcode, 1, 1) ='M'
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)  
	
END
 
