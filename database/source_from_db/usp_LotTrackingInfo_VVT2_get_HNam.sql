-- =============================================
-- Author:		Mr.Duy 
-- Create date: 2025-03-31
-- Description:	Tổng hợp sản lượng công đoạn cho nhà máy Hà Nam 
-- Change Logic: Mr.Triều thay đổi logic tính cả PQC vào công đoạn khi vậy sẽ chính xác số lượng
-- =============================================
--  exec usp_LotTrackingInfo_VVT2_get_HNam '','','VVT','2025-04-01','2025-04-28','','','','','',''
CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_VVT2_get_HNam]
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
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL('VVT','') = '' THEN '*' ELSE 'VVT' END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
	DECLARE	@MarkingLetter VARCHAR(30) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END
	DECLARE	@WorkCenterCode VARCHAR(30) = CASE WHEN ISNULL('VVT_F3', '') = '' THEN '*' ELSE 'VVT_F3' END

	, @TotalCount INT 

	;with ViewBarcode as (
		 select  c.Barcode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' AND b.WorkCenterCode = @WorkCenterCode  and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
		 AND (@LotNo = '*' OR c.Barcode = @LotNo)
		 -- Không lấy các mã Bắt đàu bằng SP để không ảnh hưởng đến sản xuất
		 and c.Barcode NOT LIKE 'SP%'
	 ),
RawView0 as (
	 	select  b.CreateUserID,c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,
		--max(d.markingname) as SIExtText07,SIExtInt01,
		max(b.ProdQty) as ProdQty, b.CompleteRoute,
               
        -- Cột PQC: Lỗi thuộc nhóm PQC
		SUM(CASE WHEN Y.TypeErrorCode = 'PQC' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS PQC,
        
        -- Cột DoTinCay: Lỗi thuộc nhóm Reliability
		SUM(CASE WHEN Y.TypeErrorCode = 'Reliability' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS DoTinCay,
        
        -- Cột SX_Ktra: Lỗi thuộc nhóm Production_Inspection
		SUM(CASE WHEN Y.TypeErrorCode = 'Production_Inspection' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS SX_Ktra,
        
        -- Cột SuaMay: Lỗi thuộc nhóm Machine_Repair
		SUM(CASE WHEN Y.TypeErrorCode = 'Machine_Repair' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS SuaMay,
        
        -- Cột Ktra_ThuongxuyenSX: Lỗi thuộc nhóm Regular_Production_Checks
		SUM(CASE WHEN Y.TypeErrorCode = 'Regular_Production_Checks' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS Ktra_ThuongxuyenSX,
        
        -- Cột Ktra_CoDinhSX: Lỗi thuộc nhóm Fixed_Production_Inspection
		SUM(CASE WHEN Y.TypeErrorCode = 'Fixed_Production_Inspection' THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS Ktra_CoDinhSX,

		max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 left outer join STB_ProductionOrderInfo POI with(nolock) on c.PoNo = POI.PoNo
		 LEFT OUTER JOIN STB_DefectInfo DI          WITH(NOLOCK)	ON DI.DefectCode = a.DefectCode
		  left outer join STB_TypeErrorGroupOfFactory Y with(nolock)  on  Y.TypeErrorCode = DI.DirectlyUnder
		 --Left outer join STB_CreateMarkingLetterAndQtyForBarcode d on c.barcode = d.barcode
		 where c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) 
		 and  b.WorkCenterCode = @WorkCenterCode 
		 AND b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate
		 and  b.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' ) 
		
		 
		 group by b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping ,DI.DirectlyUnder,b.CompleteRoute

),

RawView as (
	 	select  CreateUserID,Barcode,RouteCode, FindRouteCode,
		ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,
		max(ProdQty) as ProdQty,  
		
		-- Tính Tổng Defect
	    sum(DoTinCay)+sum(SX_Ktra)+sum(SuaMay)+sum(Ktra_ThuongxuyenSX)+sum(Ktra_CoDinhSX)as DefectQty ,
		sum( PQC) as PQC,
		sum( DoTinCay) as DoTinCay,
		sum( SX_Ktra) as SX_Ktra,
		sum( SuaMay) as SuaMay,
		sum( Ktra_ThuongxuyenSX) as Ktra_ThuongxuyenSX,
		sum( Ktra_CoDinhSX) as Ktra_CoDinhSX,
		max(ProdDateTime) as ProdDateTime, 
		max(CreateDateTime) as CreateDateTime,
		CompleteRoute
		from  RawView0		 
		 group by CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01,CompleteRoute 
		
),



DRI as(
	  select  
		RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode ,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		 RV.ProdDateTime, 
		 RV.CreateUserID,
		 (case 
				when RV.Barcode in (select * from stb_Changedate220924)  then '2024-07-19'   
				when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>0)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end 
		 )    
		  as  JobDate,
		  ProdDateTime as test,
        
        -- Tính InputProdQty dựa trên Output trước
		 RV.ProdQty,
        
		  RV.DefectQty  as DefectQty, 
			RV.PQC as PQC,
			RV.DoTinCay as DoTinCay,
			RV.SX_Ktra as SX_Ktra,
			RV.SuaMay as SuaMay,
			RV.Ktra_ThuongxuyenSX as Ktra_ThuongxuyenSX,
			RV.Ktra_CoDinhSX as Ktra_CoDinhSX,
		  CONVERT(varchar(10),RV.ProdDateTime,120) as ProdDate,  
		  DATEPART(YEAR, ProdDateTime)  as ProdYear,
		  DATEPART(MONTH, ProdDateTime)  as ProdMonth,
		  DATEPART(DAY, ProdDateTime)  as ProdDay,
		  DATEPART(HOUR, ProdDateTime)  as ProdHour,
		  DATEPART(MINUTE, ProdDateTime)  as ProdMinute,
		  DATEPART(SECOND, ProdDateTime)  as ProdSecond,
        -- Sửa lỗi SUBSTRING (giữ lại logic kiểm tra để tránh lỗi độ dài âm)
		CASE 
            WHEN MM2.MaterialName LIKE '%(%' AND MM2.MaterialName LIKE '%)%' 
                 AND CHARINDEX('(', MM2.MaterialName) < CHARINDEX(')', MM2.MaterialName) 
            THEN 
                SUBSTRING(
                    MM2.MaterialName,
                    CHARINDEX('(', MM2.MaterialName) + 1,
                    CHARINDEX(')', MM2.MaterialName) - CHARINDEX('(', MM2.MaterialName) - 1 
                )
            ELSE NULL 
        END AS SizeCode,
		  RV.CompleteRoute
		from RawView RV  WITH(NOLOCK)  
        
			 OUTER APPLY (select top 1 * from    STB_RouteInfo          RI	  WITH(NOLOCK)    where RV.RouteCode = RI.RouteCode)
			RI

			 OUTER APPLY (select top 1 * from    STB_MaterialMaster     MM2	   WITH(NOLOCK)   where RV.MaterialCode = MM2.MaterialCode
			  )MM2

			  OUTER APPLY (select top 1 * from    STB_LineInfo         LI	  WITH(NOLOCK)    where RV.InputLineCode = LI.LineCode			 
			  )LI

			   OUTER APPLY (select top 1 * from    STB_MachineMaster    MM	   WITH(NOLOCK)   where RV.MachineCode = MM.MachineCode
			  )MM

			   OUTER APPLY (select top 1 * from    STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)   where RV.WorkerCode = PWI.WorkerCode
			  )PWI

			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	
		  where 1=1
)


	select
		'VVT'   AS 사업장
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
		  ,CASE WHEN DRI.SIExtInt01 IS NULL THEN '' 
		          WHEN DRI.SIExtInt01 = 1      THEN '검사불합격' 
				  WHEN DRI.SIExtInt01 = 0       THEN '검사불합격이력'    END                    AS RouteInspectionResult 
		  , DRI.ProdQty                            AS InputProdQty    -- 투입수량 (Đã lấy Output trước)
		  
		  , ISNULL(DRI.DefectQty, 0)     AS DefectQty          -- 불량수량 	
		  , weightLast.valweight as WeightUnit 
		  , ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 as WasteWeight
		  , (DRI.ProdQty  - ISNULL(PQC, 0) - ISNULL(DoTinCay, 0) - ISNULL(SX_Ktra, 0) -ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0)- ISNULL(Ktra_CoDinhSX, 0)) AS ProdQty           -- Qty Thành phẩm		  
		  , SIExtText07 AS MarkingLetter  
		  
		  ,ISNULL(DRI.DefectQty, 0) * 
				case 
					when DRI.RouteCode like '%'+SP.RouteVE01+'%' then COALESCE(SP.PriceVE01,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE02+'%' then COALESCE(SP.PriceVE02,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE03+'%' then COALESCE(SP.PriceVE03,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE04+'%' then COALESCE(SP.PriceVE04,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE05+'%' then COALESCE(SP.PriceVE05,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE06+'%' then COALESCE(SP.PriceVE06,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE07+'%' then COALESCE(SP.PriceVE07,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE08+'%' then COALESCE(SP.PriceVE08,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE09+'%' then COALESCE(SP.PriceVE09,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE10+'%' then COALESCE(SP.PriceVE10,0.00)
					else 0 end 
				as DefectPrice 

		  , ISNULL(DRI.ProdQty,0)  * 
		  		case 
					when DRI.RouteCode like '%'+SP.RouteVE01+'%' then COALESCE(SP.PriceVE01,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE02+'%' then COALESCE(SP.PriceVE02,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE03+'%' then COALESCE(SP.PriceVE03,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE04+'%' then COALESCE(SP.PriceVE04,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE05+'%' then COALESCE(SP.PriceVE05,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE06+'%' then COALESCE(SP.PriceVE06,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE07+'%' then COALESCE(SP.PriceVE07,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE08+'%' then COALESCE(SP.PriceVE08,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE09+'%' then COALESCE(SP.PriceVE09,0.00)
					when DRI.RouteCode like '%'+SP.RouteVE10+'%' then COALESCE(SP.PriceVE10,0.00)
					else 0 end 				
				as BeginPrice 

		,PQC
		, DoTinCay
		,SX_Ktra
		, SuaMay
		,Ktra_ThuongxuyenSX
		,Ktra_CoDinhSX,
		
     DRI.ProdQty 
     - ISNULL(PQC, 0) 
     - ISNULL(DoTinCay, 0) 
     - ISNULL(SX_Ktra, 0) 
     - ISNULL(SuaMay, 0) 
     - ISNULL(Ktra_ThuongxuyenSX, 0) 
     - ISNULL(Ktra_CoDinhSX, 0)
as ActualQty

		, ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA,vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty  - ISNULL(pqc, 0) - ISNULL(DoTinCay, 0) - ISNULL(SX_Ktra, 0) -ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0)- ISNULL(Ktra_CoDinhSX, 0))  as PriceINCREMENTAL
		-- , CONVERT(BIT, CASE WHEN ROW_NUMBER () OVER (PARTITION BY DRI.Barcode  ORDER BY DRI.RouteCode ASC) = TC.TotalCount THEN 0 ELSE 1 END) AS ProdQtyFinishYn
	
	
	   from DRI  WITH(NOLOCK) 
			 OUTER APPLY (select top 1 * from    STB_RouteInfo          RI	  WITH(NOLOCK)    where DRI.FindRouteCode = RI.RouteCode
			 )RI

			  OUTER APPLY (select top 1 * from    STB_MaterialMaster   MM2	   WITH(NOLOCK)   where DRI.MaterialCode = MM2.MaterialCode
			  )MM2

			   OUTER APPLY (select top 1 * from    STB_LineInfo         LI	  WITH(NOLOCK)    where DRI.InputLineCode = LI.LineCode			 
			  )LI
			   OUTER APPLY (select top 1 * from    STB_MachineMaster    MM	   WITH(NOLOCK)   where DRI.MachineCode = MM.MachineCode
			  )MM
			   OUTER APPLY (select top 1 * from    STB_ProdWorkerInfo   PWI	   WITH(NOLOCK)   where DRI.WorkerCode = PWI.WorkerCode
			  )PWI
			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode  
			   ) weightLast 
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'A'
			   ) weightLastA
			   			   OUTER APPLY (select top 1 * from    [dbo].[fn_VVT_Stage2Weight]('') weight3 
							join  STB_ModelBasicInfo   modelInfo    WITH(NOLOCK) 
								on SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model  and  modelInfo.MBIExtText05+'F' = weight3.farad 								
							where SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model  and  weight3.routecode=DRI.RouteCode+'B'
			   ) weightLastB
				left outer join [dbo].[fn_VVT_StagePrices]() vwup on vwup.model = DRI.MaterialCode and vwup.routecode=dri.RouteCode
				left outer join [dbo].[fn_VVT_StagePricesNEW]() vwupNEW on vwupNEW.model = DRI.MaterialCode and vwupNEW.routecode=dri.RouteCode

				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesNEW]()  vwupNEW1
				where MM2.MaterialName like '%'+vwupNEW1.partno+'%' and vwupNEW1.routecode=dri.RouteCode
				)vwupNEW1

				left outer join [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL on vwupINCREMENTAL.model = DRI.MaterialCode and vwupINCREMENTAL.routecode=dri.RouteCode

				outer apply
				(select top 1 * from [dbo].[fn_VVT_StagePricesINCREMENTAL]()  vwupINCREMENTAL1
				where MM2.MaterialName like '%'+vwupINCREMENTAL1.partno+'%' and vwupINCREMENTAL1.routecode=dri.RouteCode
				)vwupINCREMENTAL1
				--left join  totalcountRouteByBarcode TC with(nolock) on  DRI.ControlNo = TC.ControlNo
				----outer apply (
				----select model,max(val) as ProcessUnitPriceEA
				----from Prices
				----where DRI.MaterialName like model  and routecode=DRI.RouteCode and replace(routecode,'E-','V-') <> 'V-28'
				----group by model
				----)  vwup	


				left join STB_VVT_StagePrices SP on DRI.materialcode = SP.Model 

			    
	 where 1=1
	  and dri.CreateUserID not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
	 	   AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
	   AND (@LineCode = '*' OR DRI.InputLineCode   = @LineCode)
	    --AND (@WorkCenterCode = '*' OR DRI.WorkerCode  = @WorkCenterCode)
	   AND (@LotNo = '*' OR DRI.Barcode       = @LotNo)
	   and (@MarkingLetter='*' or SIExtText07= @MarkingLetter )
	   and  SUBSTRING (DRI.Barcode, 1, 1) !='M'
	
END


