

/* exec usp_LotTrackingInfo_VVT2_get '','','VVT','2025-03-01','2025-03-28','','','',''    */

-- exec usp_LotTrackingInfo_VVT2_get '','','','2026-03-18','2026-03-18','','','','','','VVT_F3'
--Update STB_SetInfo set MaterialCode ='ECVT30-115' where Barcode ='VVOM193R010701' // Chuyen doi cong doan 23/04/2024
--Update STB_ProdRouteHist  set MaterialCode ='ECVT30-115' WHERE ControlNo = ( SELECT ControlNo
--								     FROM STB_SetInfo SI
--								   where Barcode ='VVON073R010707'
--								   )   // Chuyen doi cong doan 23/04/2024
 -- exec usp_LotTrackingInfo_VVT2_get '','','VVT','2025-10-01','2025-10-30','','','VVPS063R010686','','','VVT_F2'
CREATE  PROCEDURE [dbo].[usp_LotTrackingInfo_VVT2_get] 
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pMarkingLetter VARCHAR(30) = NULL,
	@pWorkCenterCode VARCHAR(30) = NULL
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
	DECLARE	@WorkCenterCode VARCHAR(30) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END

BEGIN

	SET NOCOUNT ON;

---if @MarkingLetter is not null begin

	-- select * from STB_ProdRouteHist
if(@pWorkCenterCode<>'tonghainhamay')
begin
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' AND b.WorkCenterCode = @WorkCenterCode  and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate --and b.CompleteRoute=1 
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 ),
RawView0 as (
	 	select   b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, 
		SUM(CASE 
            WHEN Y.TypeErrorCode is null
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END) AS DefectQty,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='PQC') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as PQC,
		--case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where TypeErrorCode='Reliability') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as DoTinCay,
		--case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where TypeErrorCode='Production_Inspection') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as SX_Ktra,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Production_Defect') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as SX_NG,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Machine_Repair') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as SuaMay,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Regular_Production_Checks') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as Ktra_ThuongxuyenSX,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Fixed_Production_Inspection') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as Ktra_CoDinhSX,		
		case when DI.DirectlyUnder in  (select TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='NG_Setup_Machine') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as SetupMay,
		max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 left outer join STB_ProductionOrderInfo POI with(nolock) on c.PoNo = POI.PoNo
		 left  outer join  STB_DefectInfo     di   with(nolock)  on  a.DefectCode = di.DefectCode
		 left outer join STB_TypeErrorGroupOfFactory Y with(nolock)  on  Y.TypeErrorCode = di.DirectlyUnder

		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) )
		 --and  a.DefectQty >=1
		 --and (isnull(b.ProdDateTime,a.CreateDateTime)>@FromDate and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,a.CreateDateTime)<@ToDate)
		 AND b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )  --and b.CompleteRoute=1 --ducnv dev by iss a.Bach 
		
		 
		 group by b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping,di.DirectlyUnder,di.DefectCode,Y.TypeErrorCode
),

RawView as (
	 	select  CreateUserID,Barcode,RouteCode, FindRouteCode,
		ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,
		max(ProdQty) as ProdQty, 
		sum(DefectQty)+sum( SX_NG)+sum( SuaMay)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX) +sum(SetupMay)+sum(PQC)  as DefectQty ,
		sum(DefectQty)+sum( SX_NG)+sum( SuaMay)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX) +sum(SetupMay)as DefectQty1 ,
		sum(SuaMay)+sum(SetupMay) as DefectMachine,
		sum(DefectQty)+sum( SX_NG)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX)+sum(PQC) as DefectNornal,
		sum( PQC) as PQC,
		--sum( DoTinCay) as DoTinCay,
		SUM(SetupMay) AS SetupMay,
		--sum( SX_Ktra) as SX_Ktra,
		sum( SX_NG) as SX_NG,
		sum( SuaMay) as SuaMay,
		sum( Ktra_ThuongxuyenSX) as Ktra_ThuongxuyenSX,
		sum( Ktra_CoDinhSX) as Ktra_CoDinhSX,
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
		 (case 
				when RV.Barcode in (select * from stb_Changedate220924)  then '2024-07-19'   
				when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>0)     
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
		  ProdDateTime as test,
		  max(RV.ProdQty  ) as ProdQty,
		  sum(RV.DefectQty) as DefectQty, 
		  sum(RV.DefectQty1) as DefectQty1,
		  sum(DefectMachine) as DefectMachine,
		  sum(DefectNornal) as DefectNornal,
		sum( PQC) as PQC,
		--sum( DoTinCay) as DoTinCay,
		sum(SetupMay) as SetupMay,
		--sum( SX_Ktra) as SX_Ktra,
		sum( SX_NG) as SX_NG,
		sum( SuaMay) as SuaMay,
		sum( Ktra_ThuongxuyenSX) as Ktra_ThuongxuyenSX,
		sum( Ktra_CoDinhSX) as Ktra_CoDinhSX,
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
			   /*
			   
			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	
		where 
		( 
			(mli.Lotno is not null )  or  --RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode    ) > 0-- or
			--(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode  ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		*/
		
		group by  rv.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
		--order by RV.Barcode,RV.RouteCode 
)


	select
		distinct  'VVT'   AS 사업장
		  ,DRI.ControlNo
	      ,DRI.Barcode
		  ,DRI.MaterialCode
		  --,case when DRI.MaterialCode = 'ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else MM2.MaterialName end as MaterialName --Ms Phuong request update audit 2025-11-26
		  ,MM2.MaterialName
		  ,DRI.InputLineCode
		  ,LI.LineName
		  ,DRI.RouteCode as RouteCode
		  ,RI.RouteName
		  ,convert(datetime,DRI.ProdDateTime,120) as ProdDateTime
		  ,DRI.JobDate
		  ,DRI.MachineCode
		  ,MM.MachineName
		  ,MM.MachineNumber
		  ,DRI.WorkerCode
		  ,PWI.WorkerName
		  ,ISNULL(Note.Notes, '') AS Notes
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN '' 
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격' 
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult 
		  --,CONVERT(BIT,CASE WHEN ISNULL(DRI.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd*/ 
		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량 
		  
		  , ISNULL(DRI.DefectQty, 0)   AS DefectQty  ,
		   ISNULL(DRI.DefectQty1, 0)     AS DefectQty1-- 불량수량 	
		  , weightLast.valweight as WeightUnit 
		  , ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 as WasteWeight
		  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0)  -ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0)) -ISNULL(SetupMay,0) AS ProdQty           -- 생산수량		  
		  , SIExtText07 AS MarkingLetter  
		  
		  ,ISNULL(DRI.DefectQty, 0) * 
				case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 
				as DefectPrice 
			,ISNULL(DRI.DefectQty1, 0) * 
				case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 
				as DefectPriceSX
		  , ISNULL(DRI.ProdQty,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as BeginPrice ,
				 ISNULL(DRI.DefectMachine,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as DefectMachine ,
				 ISNULL(DRI.DefectNornal,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as DefectNornal 


		,PQC,
		--, DoTinCay
		SetupMay,
		--SX_Ktra
		SX_NG
		, SuaMay
		,Ktra_ThuongxuyenSX
		,Ktra_CoDinhSX
		,ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA,vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(pqc, 0)  -ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0)- ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0) -isnull(SetupMay,0)
		)  as PriceINCREMENTAL

	from DRI  WITH(NOLOCK) 
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

			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode  
			   ) weightLast 
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'A'
			   ) weightLastA
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'B'
			   ) weightLastB
				left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode=dri.RouteCode
				left outer join [dbo].[fn_VVT_StagePricesNEW]() vwupNEW on vwupNEW.model = DRI.MaterialCode and vwupNEW.routecode=dri.RouteCode

				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesNEW]()  vwupNEW1
				where MM2.MaterialName like '%'+vwupNEW1.partno+'%' and vwupNEW1.routecode=dri.RouteCode
				)vwupNEW1

				left outer join [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL on vwupINCREMENTAL.model = DRI.MaterialCode and vwupINCREMENTAL.routecode=dri.RouteCode
				 
				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesINCREMENTAL]()  vwupINCREMENTAL1
				where MM2.MaterialName like '%'+vwupINCREMENTAL1.partno+'%' and vwupINCREMENTAL1.routecode=dri.RouteCode
				)vwupINCREMENTAL1

				----outer apply (
				----select model,max(val) as ProcessUnitPriceEA
				----from Prices
				----where DRI.MaterialName like model  and routecode=DRI.RouteCode and replace(routecode,'E-','V-') <> 'V-28'
				----group by model
				----)  vwup	

				LEFT OUTER JOIN STB_ProdRouteHistNotes Note WITH(NOLOCK) ON DRI.ControlNo = Note.ControlNo AND DRI.RouteCode = Note.RouteCode
			    
	 where 1=1
	  and dri.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	    --AND (@WorkCenterCode = '*' OR DRI.WorkerCode  = @WorkCenterCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   and (@MarkingLetter='*' or SIExtText07= @MarkingLetter )
	   and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)  
	end
	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
else  -- đây là để lấy dữ liệu 2 nhà máy bắc ninh và bắc giang để làm BI Mr.Duy add 2025-04-23
	begin
		;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' AND b.WorkCenterCode in ('VVT_F1','VVT_F2')  and b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate and  b.CompleteRoute=1
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 ),
RawView0 as (
	 	select  b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, 
		SUM(CASE 
            WHEN Y.TypeErrorCode Is null
                 THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0)
            ELSE 0
        END) AS DefectQty,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='PQC') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as PQC,
		--case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where TypeErrorCode='Reliability') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as DoTinCay,
		--case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where TypeErrorCode='Production_Inspection') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as SX_Ktra,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Production_Defect') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as SX_NG,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Machine_Repair') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as SuaMay,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Regular_Production_Checks') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as Ktra_ThuongxuyenSX,
		case when DI.DirectlyUnder in (select TypeErrorCode from STB_TypeErrorGroupOfFactory where Y.TypeErrorCode='Fixed_Production_Inspection') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as Ktra_CoDinhSX,
		case when DI.DirectlyUnder in  (select TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='NG_Setup_Machine') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as SetupMay,
		
		max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 left outer join STB_ProductionOrderInfo POI with(nolock) on c.PoNo = POI.PoNo
		 left  outer join  STB_DefectInfo     di   with(nolock)  on  a.DefectCode = di.DefectCode
		 left outer join STB_TypeErrorGroupOfFactory Y with(nolock)  on  Y.TypeErrorCode = di.DirectlyUnder
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) )
		 --and  a.DefectQty >=1
		 --and (isnull(b.ProdDateTime,a.CreateDateTime)>@FromDate and b.WorkCenterCode = @WorkCenterCode  and isnull(b.ProdDateTime,a.CreateDateTime)<@ToDate)
		 AND b.ProdDateTime>@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' ) 
		and b.CompleteRoute=1
		 
		 group by b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping,di.DirectlyUnder,di.DefectCode,Y.TypeErrorCode
),

RawView as (
	 	select  CreateUserID,Barcode,RouteCode, FindRouteCode,
		ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,
		max(ProdQty) as ProdQty, 
		sum(DefectQty)+sum( SX_NG)+sum( SuaMay)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX)+sum(SetupMay)+sum( PQC) as DefectQty ,
		sum(DefectQty)+sum( SX_NG)+sum( SuaMay)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX)+sum(SetupMay) as DefectQty1 ,
		sum(SuaMay)+sum(SetupMay) as DefectMachine,
		sum(DefectQty)+sum( SX_NG)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX)+sum(PQC) as DefectNornal,
		sum( PQC) as PQC,
		--sum( DoTinCay) as DoTinCay,
		sum(SetupMay) as SetupMay,
		--sum( SX_Ktra) as SX_Ktra,
		sum( SX_NG) as SX_NG,
		sum( SuaMay) as SuaMay,
		sum( Ktra_ThuongxuyenSX) as Ktra_ThuongxuyenSX,
		sum( Ktra_CoDinhSX) as Ktra_CoDinhSX,
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
		 (case 
				when RV.Barcode in (select * from stb_Changedate220924)  then '2024-07-19'   
				when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>0)     
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
		  ProdDateTime as test,
		  max(RV.ProdQty  ) as ProdQty,
		  sum(RV.DefectQty) as DefectQty, 
		    sum(RV.DefectQty1) as DefectQty1, 
			sum(RV.DefectMachine) as DefectMachine,
			sum(RV.DefectNornal) as DefectNornal,
		sum( PQC) as PQC,
		--sum( DoTinCay) as DoTinCay,
		sum(SetupMay) as SetupMay,
		--sum( SX_Ktra) as SX_Ktra,
		sum( SX_NG) as SX_NG,
		sum( SuaMay) as SuaMay,
		sum( Ktra_ThuongxuyenSX) as Ktra_ThuongxuyenSX,
		sum( Ktra_CoDinhSX) as Ktra_CoDinhSX,
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
			   /*
			   
			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	
		where 
		( 
			(mli.Lotno is not null )  or  --RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode    ) > 0-- or
			--(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode  ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		*/
		
		group by  rv.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 		 MM2.MaterialName,		 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
		--order by RV.Barcode,RV.RouteCode 
)


	select
		distinct  'VVT'   AS 사업장
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
		  ,MM.MachineNumber
		  ,DRI.WorkerCode
		  ,PWI.WorkerName
		  ,ISNULL(Note.Notes, '') AS Notes
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN '' 
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격' 
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult 
		  --,CONVERT(BIT,CASE WHEN ISNULL(DRI.AftProdQty,0) > 0 THEN 1	ELSE 0 	END)   AS IsHasNextProd*/ 
		  , DRI.ProdQty                                   AS InputProdQty    -- 투입수량 
		  
		  , ISNULL(DRI.DefectQty, 0)     AS DefectQty ,         -- 불량수량 	
		     ISNULL(DRI.DefectQty1, 0)     AS DefectQty1-- 불량수량 	
		  , weightLast.valweight as WeightUnit 
		  , ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 as WasteWeight
		  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) -ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0)) -ISNULL(SetupMay,0) AS ProdQty           -- 생산수량		  
		  , SIExtText07 AS MarkingLetter  
		  
		  ,ISNULL(DRI.DefectQty, 0) * 
				case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 
				as DefectPrice 
			,ISNULL(DRI.DefectQty1, 0) * 
				case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 
				as DefectPriceSX
		  , ISNULL(DRI.ProdQty,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as BeginPrice ,
				ISNULL(DRI.DefectMachine,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as DefectMachine ,
				ISNULL(DRI.DefectNornal,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as DefectNornal 

		,PQC,
		SetupMay
		--, DoTinCay
		--,SX_Ktra
		,SX_NG
		, SuaMay
		,Ktra_ThuongxuyenSX
		,Ktra_CoDinhSX
		,ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA,vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(pqc, 0) - ISNULL(SetupMay, 0)  -ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0)- ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0)
		)  as PriceINCREMENTAL

		

	from DRI  WITH(NOLOCK) 
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

			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode  
			   ) weightLast 
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'A'
			   ) weightLastA
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'B'
			   ) weightLastB
				left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode=dri.RouteCode
				left outer join [dbo].[fn_VVT_StagePricesNEW]() vwupNEW on vwupNEW.model = DRI.MaterialCode and vwupNEW.routecode=dri.RouteCode

				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesNEW]()  vwupNEW1
				where MM2.MaterialName like '%'+vwupNEW1.partno+'%' and vwupNEW1.routecode=dri.RouteCode
				)vwupNEW1

				left outer join [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL on vwupINCREMENTAL.model = DRI.MaterialCode and vwupINCREMENTAL.routecode=dri.RouteCode
				 
				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesINCREMENTAL]()  vwupINCREMENTAL1
				where MM2.MaterialName like '%'+vwupINCREMENTAL1.partno+'%' and vwupINCREMENTAL1.routecode=dri.RouteCode
				)vwupINCREMENTAL1

				----outer apply (
				----select model,max(val) as ProcessUnitPriceEA
				----from Prices
				----where DRI.MaterialName like model  and routecode=DRI.RouteCode and replace(routecode,'E-','V-') <> 'V-28'
				----group by model
				----)  vwup	
			    
				LEFT OUTER JOIN STB_ProdRouteHistNotes Note WITH(NOLOCK) ON DRI.ControlNo = Note.ControlNo AND DRI.RouteCode = Note.RouteCode

	 where 1=1
	  and dri.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	    --AND (@WorkCenterCode = '*' OR DRI.WorkerCode  = @WorkCenterCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   and (@MarkingLetter='*' or SIExtText07= @MarkingLetter )
	   and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
		
	end
END
 


 --select * from STB_ProdRouteHist


