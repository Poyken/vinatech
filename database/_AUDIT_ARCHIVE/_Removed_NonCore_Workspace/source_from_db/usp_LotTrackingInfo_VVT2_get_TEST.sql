

/* exec usp_LotTrackingInfo_VVT2_get '','','VVT','2021-04-30','2021-04-30','','','',''    */

-- exec usp_LotTrackingInfo_VVT2_get_TEST '','','','2024-07-16','2024-07-16','','','VVOP163R010520','','','VVT_F1'
--Update STB_SetInfo set MaterialCode ='ECVT30-115' where Barcode ='VVOM193R010701' // Chuyen doi cong doan 23/04/2024
--Update STB_ProdRouteHist  set MaterialCode ='ECVT30-115' WHERE ControlNo = ( SELECT ControlNo
--								     FROM STB_SetInfo SI
--								   where Barcode ='VVON073R010707'
--								   )   // Chuyen doi cong doan 23/04/2024

CREATE  PROCEDURE [dbo].[usp_LotTrackingInfo_VVT2_get_TEST] 
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
;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' AND b.WorkCenterCode = @WorkCenterCode  and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 ),
RawView0 as (
	 	select  b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, 
		case when a.DefectCode not in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() ) and   DefectCode not like 'V-29_XX1' and  DefectCode not like 'V-29_XX2' and DefectCode not like 'V-29_XX3' and  b.RouteCode not like 'V-34_BG' and POI.DefectSummaryNoBeforeDroping is null   then sum(a.DefectQty)  - sum(a.RepairQty) else 0 end as DefectQty , --and DefectCode not like 'V-29_XX1' and  DefectCode not like 'V-29_XX2' --- Them 26-06-2024 vì 2 mã này k phải là phế
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='pqc') then sum(a.DefectQty) -  sum(a.RepairQty) else 0 end as PQC,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='qcpart') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as QcPart,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='rely') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as DoTinCay,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='sxdestroy') then sum(a.DefectQty) -  sum(a.RepairQty)  else 0 end as QcSx,
		case when a.DefectCode in (select defectcode from [dbo].[fn_VVT_QCPARTCODE]() where work='thietbi') then sum(a.DefectQty) -  sum(a.RepairQty) else 0  end as SuaMay,
		max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 left outer join STB_ProductionOrderInfo POI with(nolock) on c.PoNo = POI.PoNo
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and  b.WorkCenterCode = @WorkCenterCode AND b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' ) 
		
		 
		 group by b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping--,b.CreateDateTime,
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
		  ProdDateTime as test,
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
		distinct   'VVT'   AS 사업장
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
		  
		  , ISNULL(DRI.DefectQty, 0)     AS DefectQty          -- 불량수량 	
		  , weightLast.valweight as WeightUnit 
		  , ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 as WasteWeight
		  , (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(pqc, 0) - ISNULL(qcpart, 0) - ISNULL(DoTinCay, 0) -ISNULL(QcSx, 0) - ISNULL(SuaMay, 0)) AS ProdQty           -- 생산수량		  
		  , SIExtText07 AS MarkingLetter  
		  
		  ,ISNULL(DRI.DefectQty, 0) * 
				case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 
				as DefectPrice 

		  , ISNULL(DRI.ProdQty,0)  * 
		  		case when ProdDateTime<'2023-10-01' then ISNULL(vwup.ProcessUnitPriceEA,0)
					when ProdDateTime>='2023-10-01' then ISNULL(vwupNEW.ProcessUnitPriceEA,vwupNEW1.ProcessUnitPriceEA)
					else 0 end 				
				as BeginPrice 

		,PQC
		,QcPart
		, DoTinCay
		,QcSx as SX_kiemtra
		, SuaMay
		, ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA,vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(pqc, 0) - ISNULL(qcpart, 0) - ISNULL(DoTinCay, 0) -ISNULL(QcSx, 0) - ISNULL(SuaMay, 0))  as PriceINCREMENTAL

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
			    
	 where 1=1
	  and dri.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	    --AND (@WorkCenterCode = '*' OR DRI.WorkerCode  = @WorkCenterCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   and (@MarkingLetter='*' or SIExtText07= @MarkingLetter )
	   and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	   --AND (@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)  
--	 and dri.barcode not in (
--'VVNK173R850611',
--'VVNK143R850607',
--'VVNK153R850601',
--'VVNK153R850618',
--'VVNK143R850611',
--'VVNK243R850604',
--'VVNK163R850628',
--'VVNK253R850608',
--'VVNK253R850609',
--'VVNK243R850608',
--'VVNK173R850618',
--'VVNK173R850617',
--'VVNK223R850601',
--'VVNK163R850606',
--'VVNK143R850612',
--'VVNK153R850608',
--'VVNK243R850607',
--'VVNK143R850613',
--'VVNK223R850602',
--'VVNK163R850629',
--'VVNK273R850601',
--'VVNK243R850602',
--'VVNK243R850601',
--'VVNK253R850601',
--'VVNK173R850612',
--'VVNK173R850604',
--'VVNK203R850612',
--'VVNK163R850602',
--'VVNK253R850606',
--'VVNK253R850602',
--'VVNK153R850612',
--'VVNK143R850618',
--'VVNK173R850616',
--'VVNK153R850619',
--'VVNK153R850606',
--'VVNK143R850616',
--'VVNK163R850601',
--'VVNK243R850606',
--'VVNK153R850616',
--'VVNK173R850607',
--'VVNK223R850606',
--'VVNK213R850611',
--'VVNK233R850603',
--'VVNK233R850606',
--'VVNK163R850633',
--'VVNK203R850608',
--'VVNK273R850602',
--'VVNK173R850601',
--'VVNK253R850607',
--'VVNK163R850609',
--'VVNK203R850613',
--'VVNK173R850603',
--'VVNK213R850608',
--'VVNK163R850608',
--'VVNK213R850602',
--'VVNK213R850612',
--'VVNK283R850601',
--'VVNK273R850614',
--'VVNK163R850630',
--'VVNK273R850616',
--'VVNK173R850614',
--'VVNK203R850616',
--'VVNK163R850631',
--'VVNK223R850608',
--'VVNK213R850606',
--'VVNK203R850601',
--'VVNK233R850601',
--'VVNK273R850612',
--'VVNK163R850634',
--'VVMP293R850602',
--'VVNK203R850604',
--'VVNK203R850607',
--'VVNK273R850617',
--'VVNK213R850607',
--'VVNK233R850602',
--'VVNK203R850611',
--'VVNK203R850602',
--'VVNK203R850614',
--'VVNK243R850603',
--'VVMS243R850613',
--'VVNK233R850605',
--'VVNK163R850603',
--'VVNK273R850611',
--'VVNK213R850609',
--'VVNK173R850606',
--'VVNK203R850618',
--'VVNK203R850603',
--'VVNK233R850610',
--'VVNK173R850608',
--'VVNK223R850609',
--'VVNK213R850601',
--'VVNK233R850607',
--'VVNK283R850607',
--'VVNK173R850602',
--'VVNK283R850603',
--'VVNK283R850604',
--'VVNK273R850608',
--'VVNK273R850613',
--'VVNK283R850602',
--'VVNK283R850608'
--)
END
 


 --select * from STB_ProdRouteHist