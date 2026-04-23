CREATE PROCEDURE view_data212345
    @WorkCenterCode VARCHAR(20),
    @pFromDate DATETIME,
    @pToDate DATETIME
AS
BEGIN
    ;WITH ViewBarcode AS (
        SELECT c.Barcode
        FROM STB_SetInfo c WITH (NOLOCK)
        LEFT JOIN STB_ProdRouteHist b WITH (NOLOCK) ON c.ControlNo = b.ControlNo
        WHERE b.CompanyCode = 'VVT'
          AND b.WorkCenterCode = @WorkCenterCode
          AND b.ProdDateTime >= @pFromDate
          AND b.ProdDateTime < @pToDate
          AND b.CreateUserID NOT IN ('test_worker', 'assy_packing', 'assy_packing2', 'roh_worker', 'electrode_worker', 'dryroom_worker')
    ),
    RawView0 AS (
        SELECT 
            b.CreateUserID, c.Barcode, b.RouteCode, b.RouteCode AS FindRouteCode, c.ControlNo, c.MaterialCode,
            InputLineCode, b.MachineCode, b.WorkerCode, SIExtText07, SIExtInt01,
            MAX(b.ProdQty) AS ProdQty,
            CASE 
                WHEN a.DefectCode NOT IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]()) 
                     AND a.DefectCode NOT LIKE 'V-29_XX1' 
                     AND a.DefectCode NOT LIKE 'V-29_XX2' 
                     AND a.DefectCode NOT LIKE 'V-29_XX3' 
                     AND b.RouteCode NOT LIKE 'V-34_BG' 
                     AND POI.DefectSummaryNoBeforeDroping IS NULL
                THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS DefectQty,
            CASE 
                WHEN a.DefectCode IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'pqc') 
                THEN SUM(a.DefectQty) - SUM(a.RepairQty) 
                ELSE 0 
            END AS PQC,
            CASE 
                WHEN a.DefectCode IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'qcpart') 
                THEN SUM(a.DefectQty) - SUM(a.RepairQty) 
                ELSE 0 
            END AS QcPart,
            CASE 
                WHEN a.DefectCode IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'rely') 
                THEN SUM(a.DefectQty) - SUM(a.RepairQty) 
                ELSE 0 
            END AS DoTinCay,
            CASE 
                WHEN a.DefectCode IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'sxdestroy') 
                THEN SUM(a.DefectQty) - SUM(a.RepairQty) 
                ELSE 0 
            END AS QcSx,
            CASE 
                WHEN a.DefectCode IN (SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'thietbi') 
                THEN SUM(a.DefectQty) - SUM(a.RepairQty) 
                ELSE 0 
            END AS SuaMay,
            MAX(b.ProdDateTime) AS ProdDateTime,
            MAX(b.CreateDateTime) AS CreateDateTime
        FROM STB_SetInfo c WITH (NOLOCK)
        LEFT JOIN STB_ProdRouteHist b WITH (NOLOCK) ON c.ControlNo = b.ControlNo
        LEFT JOIN STB_DefectRepairInfo a WITH (NOLOCK) ON a.ControlNo = c.ControlNo AND a.FindRouteCode = b.RouteCode
        LEFT JOIN STB_ProductionOrderInfo POI WITH (NOLOCK) ON c.PoNo = POI.PoNo
        WHERE c.Barcode IN (SELECT Barcode FROM ViewBarcode)
          AND b.WorkCenterCode = @WorkCenterCode
          AND a.DefectQty >= 1
          AND b.ProdDateTime >= @pFromDate 
          AND b.ProdDateTime < @pToDate
		  and a.DefectQty >=1
          AND b.CreateUserID NOT IN ('test_worker', 'assy_packing', 'assy_packing2', 'roh_worker', 'electrode_worker', 'dryroom_worker')
        GROUP BY b.CreateUserID, c.Barcode, b.RouteCode, c.ControlNo, c.MaterialCode, InputLineCode, b.MachineCode,
                 b.WorkerCode, SIExtText07, SIExtInt01, a.DefectCode, POI.DefectSummaryNoBeforeDroping
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
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno and routecode>RV.routecode    ) > 0-- or
			--(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode  ) > Dateadd(second,5,RV.CreateDateTime) 
		) 
		group by  rv.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,
		 ri.RouteName, MM2.MaterialName,li.LineName, pwi.WorkerName,mm.MachineName,RV.ProdDateTime)
    select * from DRI
END