-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 생산관리 > 조립불량현황
-- Description:	[B660] 조립불량현황상세
-- Modified: 
-- 2020-01-29 : 불량 수리 시 수리 수량을 잘못 반영하는 부분이 있어 쿼리를 수정함 by Jackaroe #20200129

-- 실행 :   EXEC  [usp_Get_VVT_Prod_Bad_Stat_tail] '','',420,'VVT','','','','','2021-04-30','2021-04-30',''    
 -- EXEC usp_Get_VVT_Prod_Bad_Stat_tail '','','','','VVT_F2','','','','2024-01-01','2024-01-30',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Get_VVT_Prod_Bad_Stat_tail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	-- DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END   -- 원본 백업
	-- DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END  -- 원본 백업

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'       ELSE @pCompanyCode    END      --2019.12.16 수정
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*'      ELSE @pWorkCenterCode END      --2019.12.16 수정

	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATETIME                   = @pFromDate
	DECLARE @ToDate DATETIME                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute





--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode   
-- 실행 :   EXEC  [usp_Get_VVT_Prod_Bad_Stat_tail] '','',420,'VVT','','','','','2021-04-30','2021-04-30',''       
if @CompanyCode='VVT' begin
		

	select @FromDate   = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	select @ToDate     = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'
	--select * from STB_SetInfo
	--and b.WorkCenterCode = @WorkCenterCode 
;with ViewBarcode as (
		 select  c.Barcode, b.WorkCenterCode
		 from 
		 STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist b	 with(nolock) on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT' and  b.WorkCenterCode = @WorkCenterCode and  b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate and   SUBSTRING (c.Barcode, 1, 1) !='M' --and b.WorkCenterCode = @WorkCenterCode
	 ),

RawView as (
	 	select  c.Barcode,b.RouteCode,b.RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,shiftcode,c.PONo,
		b.WorkCenterCode,
		max(b.ProdQty) as ProdQty, sum(a.DefectQty) as DefectQty,  sum(a.RepairQty) as RepairQty ,max(b.ProdDateTime) as ProdDateTime, max(b.CreateDateTime) as CreateDateTime
		from  STB_SetInfo c with(nolock) 
		 left outer join  STB_ProdRouteHist      b	 with(nolock) on c.ControlNo=b.ControlNo	
		 left  outer join  STB_DefectRepairInfo  a    with(nolock)  on  a.ControlNo=c.ControlNo and a.FindRouteCode = b.RouteCode
		 where  c.Barcode in (select  Barcode  from  ViewBarcode  with(nolock) ) and  b.WorkCenterCode = @WorkCenterCode and b.ProdDateTime>=@FromDate  and b.ProdDateTime<@ToDate --and  b.WorkCenterCode = @WorkCenterCode
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,b.CreateDateTime,shiftcode,c.PONo,b.WorkCenterCode
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
X as(
		select  
		RV.WorkCenterCode,
		 RV.Barcode,RV.RouteCode, RV.RouteCode as FindRouteCode 
		 ,ControlNo,RV.MaterialCode,
		 RV.InputLineCode as LineCode,RV.MachineCode,
		 RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,shiftcode,PONo,
		 ri.RouteName, 
		 MM2.MaterialName,
		 li.LineName, pwi.WorkerName,mm.MachineName,
		  RV.ProdDateTime	
		 , (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  JobDate ,
		  max(RV.ProdQty) as OutputQty,
		  sum(RV.DefectQty) as DefectQty, 
		  sum(RV.RepairQty) as RepairQty, 
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
			LEFT OUTER JOIN STB_MaterialMaster     MM2      with(nolock)     ON RV.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_LineInfo         LI	  with(nolock)    ON RV.InputLineCode = LI.LineCode			 
			  LEFT OUTER JOIN STB_MachineMaster    MM	  with(nolock)     ON RV.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo   PWI	  with(nolock)     ON RV.WorkerCode = PWI.WorkerCode
			  /*
			  outer APPLY
						 (SELECT distinct t1.Lotno
						  FROM STB_MaterialLotInfo t1  with(nolock) 
						  WHERE t1.Lotno=RV.Barcode and t1.CurrentQty>0
						 ) mli	

				
				
				*/
				/*
		where 
		( 
			(mli.Lotno is not null )  or -- RV.routecode='V-22' or 
			(select count(ControlNo)  from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>RV.routecode ) > 0 or
			(select min(ProdDateTime) from STB_ProdRouteHist  with(nolock) where ControlNo=RV.controlno  and routecode>=RV.routecode ) > Dateadd(second,5,RV.CreateDateTime) 
			--or RV.WorkCenterCode = @WorkCenterCode
		) 
		*/
		group by RV.WorkCenterCode,	 RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,shiftcode,PONo,
		 ri.RouteName, 		 MM2.MaterialName,	 li.LineName, pwi.WorkerName,mm.MachineName,		  RV.ProdDateTime
)
	SELECT
           dbo.fnGetLocalTime(PRS.JobDate, 420) as 작업일자,
			--PRS.CompanyCode,
			--PRS.WorkCenterCode,
			PRS.MaterialCode as 품목코드,
			MM.MaterialName as 품목명,
			--case when PRS.MaterialCode ='ECVT30-367' then 'HY-CAP  WEC3R0106QG (1030)' else MM.MaterialName end as 품목명, --Ms Phuong request update audit 2025-11-26
			PRS.LineCode as 라인코드,
			LI.LineName as 라인명,
			PRS.RouteCode as 공정코드,
			RI.RouteName as 공정명,
			POR.RouteIndex,
			--PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.PONo,
			POI.PlanQty AS POPlanQty,
			PRS.ShiftCode,
			SC.Shift,
			--(SELECT SC.Shift FROM VW_ShiftCode SC),
			--PRS.TimeCode,
			SUM(DPP.PlanQty) AS 계획수량,
			--MAX(DPP.PlanQty) AS PlanQty,
			--SUM(PRS.InputQty) AS InputQty,
			SUM(PRS.OutputQty) AS 투입수량,
			SUM(PRS.DefectQty - ISNULL(RepairQty, 0) ) AS 불량수량, --#20200129
			(SUM(isnull(PRS.OutputQty,0)) - SUM(isnull(PRS.DefectQty,0) -- ISNULL(RepairInfo.RepairQty, 0) 
			)) AS 양품수량, --#20200129
			SUM(PRS.RepairQty) AS RepairQty,
			--SUM(PRS.LossQty) AS LossQty
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.DefectQty - ISNULL(RepairQty, 0)
			),0) = 0 THEN 0.0 
			        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE SUM(PRS.DefectQty - ISNULL(RepairQty, 0)
					) / SUM(PRS.OutputQty) * 100.0 END AS 불량율 --#20200129
	FROM
			X   PRS WITH(NOLOCK)
			 OUTER APPLY (select top 1 * from  STB_LineInfo              LI WITH(NOLOCK)   where  LI.LineCode = PRS.LineCode
			) LI
			OUTER APPLY (select top 1 * from   STB_RouteInfo            RI WITH(NOLOCK)    where RI.RouteCode = PRS.RouteCode
			)	RI
			OUTER APPLY (select top 1 * from   STB_MachineMaster MCM WITH(NOLOCK)          where  MCM.MachineCode = PRS.MachineCode
			)MCM

			 OUTER APPLY (select top 1 * from   STB_MaterialMaster   MM WITH(NOLOCK)        where MM.MaterialCode = PRS.MaterialCode
			)MM

			 OUTER APPLY (select top 1 * from   VW_ShiftCode           SC     WITH(NOLOCK)  where SC.ShiftCode = PRS.ShiftCode
			)SC

			 OUTER APPLY (select top 1 * from   STB_ProductionOrderRouting POR WITH(NOLOCK) where POR.PONo = PRS.PONo 
																		AND POR.RouteCode = PRS.RouteCode
			)POR

			 OUTER APPLY (select top 1 * from   STB_ProductionOrderInfo POI WITH(NOLOCK)    where POI.PONo = PRS.PONo
			)POI 
			OUTER APPLY (select top 1 * from   STB_DayProdPlan            DPP WITH(NOLOCK) where DPP.PONo = PRS.PONo 
																		AND DPP.LineCode = PRS.LineCode 
																		AND DPP.PlanDate = PRS.JobDate 
																		AND DPP.PlanShiftCode = PRS.ShiftCode
			)DPP

			--LEFT OUTER JOIN STB_DefectRepairInfo RepairInfo WITH(NOLOCK) ON    RepairInfo.FindJobDate = PRS.JobDate
			--															   AND RepairInfo.FindShiftCode = PRS.ShiftCode
			--															   AND RepairInfo.PONo = PRS.PONo
			--															   AND RepairInfo.MaterialCode = PRS.MaterialCode
			--															   AND RepairInfo.FindLineCode = PRS.LineCode
			--															   AND RepairInfo.FindRouteCode = PRS.RouteCode
			
			--#20200129
			/*LEFT OUTER JOIN (
						SELECT CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
							  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(RepairQty), 0) AS RepairQty
						  FROM STB_DefectRepairInfo
						 WHERE RepairType NOT IN ('MISSING')
						 GROUP BY CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
								 ,MaterialCode, FindLineCode, FindRouteCode
					) RepairInfo
				ON RepairInfo.CompanyCode = PRS.CompanyCode
			   AND RepairInfo.WorkCenterCode = PRS.WorkCenterCode
			   AND RepairInfo.FindJobDate = PRS.JobDate
			   AND RepairInfo.FindShiftCode = PRS.ShiftCode
			   AND RepairInfo.PONo = PRS.PONo
			   AND RepairInfo.MaterialCode = PRS.MaterialCode
			   AND RepairInfo.FindLineCode = PRS.LineCode
			   AND RepairInfo.FindRouteCode = PRS.RouteCode*/
	--WHERE 1=1
	
	     --AND PRS.TimeCode <> 'E'    -- MES 등록한것만 (2019.07.15)
	   --  --AND DPP.DPPExtText05 = 'ERP'                                             --- ERP Data만
		  ----AND	PRS.CompanyCode LIKE @CompanyCode 		  
		  ----AND	PRS.WorkCenterCode LIKE @WorkCenterCode 
    --      AND	PRS.LineCode = 'ASSYLINE-10'  
    --      --AND	PRS.RouteCode LIKE @RouteCode 
		  --AND	PRS.MaterialCode = 'ECVT30-220'
		  --AND	(PRS.JobDate BETWEEN '2019-07-12' AND '2019-07-30')		            
         

		 		 --AND	PRS.WorkCenterCode LIKE @WorkCenterCode 
        --  AND	(@LineCode = '*' OR PRS.LineCode = @LineCode )
      --   AND	(@RouteCode = '*' OR PRS.RouteCode = @RouteCode )
		-- AND	(@MaterialCode = '*' OR PRS.MaterialCode = @MaterialCode )
		 --AND	(PRS.JobDate BETWEEN @FromDate1 AND @ToDate1) 
		 --AND (('VVT' = '*') OR (PRS.CompanyCode = 'VVT'))   	                     -- 2019.12.16 추가		   		 
		 --AND PRS.WorkCenterCode IS NOT NULL

	GROUP BY
			--PRS.CompanyCode,
			--PRS.WorkCenterCode,
			PRS.PONo,
			POI.PlanQty,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			PRS.RouteCode,
			RI.RouteName,
			POR.RouteIndex,
			--PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.JobDate,
			PRS.ShiftCode,
			RI.WorkCenterCode,
			SC.Shift--,
			--PRS.TimeCode
  --order by PRS.RouteCode

end 



if @CompanyCode='VNT' or @CompanyCode='*' begin

	SELECT
           dbo.fnGetLocalTime(PRS.JobDate, @pUtcOffset) as 작업일자,
			--PRS.CompanyCode,
			--PRS.WorkCenterCode,
			PRS.MaterialCode as 품목코드,
			MM.MaterialName as 품목명,
			PRS.LineCode as 라인코드,
			LI.LineName as 라인명,
			PRS.RouteCode as 공정코드,
			RI.RouteName as 공정명,
			--POR.RouteIndex,
			--PRS.MoldNumber,
			--PRS.MachineCode,
			--MCM.MachineName,
			--PRS.PONo,
			POI.PlanQty AS POPlanQty,
			
			--PRS.ShiftCode,
			SC.Shift,
			--(SELECT SC.Shift FROM VW_ShiftCode SC),
			--PRS.TimeCode,
			SUM(DPP.PlanQty) AS 계획수량,
			--MAX(DPP.PlanQty) AS PlanQty,
			--SUM(PRS.InputQty) AS InputQty,
			SUM(PRS.OutputQty) AS 투입수량,
			SUM(ISNULL(RepairInfo.DefectQty, 0)) - SUM(ISNULL(RepairInfo.RepairQty, 0)) AS 불량수량, --#20200129
			SUM(PRS.OutputQty) - (SUM(ISNULL(RepairInfo.DefectQty, 0)) - SUM(ISNULL(RepairInfo.RepairQty, 0))) AS 양품수량, --#20200129
			--SUM(PRS.RepairQty) AS RepairQty,
			--SUM(PRS.LossQty) AS LossQty
			--CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN SUM(ISNULL(RepairInfo.DefectQty, 0)) - SUM(ISNULL(RepairInfo.RepairQty, 0)) = 0 THEN 0.0 
			        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE (SUM(ISNULL(RepairInfo.DefectQty, 0)) - SUM(ISNULL(RepairInfo.RepairQty, 0))) / SUM(PRS.OutputQty) * 100.0 END AS 불량율 --#20200129
	FROM
			STB_ProdRouteSummary                    PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)  ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo            RI WITH(NOLOCK) ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster   MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode           SC     WITH(NOLOCK)                 ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan            DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			--#20200129
			LEFT OUTER JOIN (
						SELECT CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
							  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(DefectQty), 0) AS DefectQty, ISNULL(SUM(RepairQty), 0) AS RepairQty
						  FROM STB_DefectRepairInfo
						 WHERE RepairType NOT IN ('MISSING')
						 GROUP BY CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
								 ,MaterialCode, FindLineCode, FindRouteCode
					) RepairInfo
				ON RepairInfo.CompanyCode = PRS.CompanyCode
			   AND RepairInfo.WorkCenterCode = PRS.WorkCenterCode
			   AND RepairInfo.FindJobDate = PRS.JobDate
			   AND RepairInfo.FindShiftCode = PRS.ShiftCode
			   AND RepairInfo.PONo = PRS.PONo
			   AND RepairInfo.MaterialCode = PRS.MaterialCode
			   AND RepairInfo.FindLineCode = PRS.LineCode
			   AND RepairInfo.FindRouteCode = PRS.RouteCode
	WHERE 1=1
	     --AND PRS.TimeCode <> 'E'    -- MES 등록한것만 (2019.07.15)
	   --  --AND DPP.DPPExtText05 = 'ERP'                                             --- ERP Data만
		  ----AND	PRS.CompanyCode LIKE @CompanyCode 		  
		  ----AND	PRS.WorkCenterCode LIKE @WorkCenterCode 
    --      AND	PRS.LineCode = 'ASSYLINE-10'  
    --      --AND	PRS.RouteCode LIKE @RouteCode 
		  --AND	PRS.MaterialCode = 'ECVT30-220'
		  --AND	(PRS.JobDate BETWEEN '2019-07-12' AND '2019-07-30')		            
         

		 		 --AND	PRS.WorkCenterCode LIKE @WorkCenterCode 
          AND	(@LineCode = '*' OR PRS.LineCode = @LineCode )
         AND	(@RouteCode = '*' OR PRS.RouteCode = @RouteCode )
		 AND	(@MaterialCode = '*' OR PRS.MaterialCode = @MaterialCode )
		 AND	(PRS.JobDate BETWEEN @FromDate AND @ToDate) 
		 AND ((@CompanyCode = '*') OR (PRS.CompanyCode = @CompanyCode))   	                     -- 2019.12.16 추가		   		 
		 AND PRS.WorkCenterCode IS NOT NULL

	GROUP BY
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.PONo,
			POI.PlanQty,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			PRS.RouteCode,
			RI.RouteName,
			POR.RouteIndex,
			PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode
	 
end

END

--select * from STB_BasicRoutingDetail

--EXEC  [usp_Get_VVT_Prod_Bad_Stat_tail] '','',420,'VVT','','','','','2020-09-12','2020-09-18',''