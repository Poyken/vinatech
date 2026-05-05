-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 생산관리 > 조립불량현황
-- Description:	[B660] 조립불량현황상세
-- Modified: 
-- 2020-01-29 : 불량 수리 시 수리 수량을 잘못 반영하는 부분이 있어 쿼리를 수정함 by Jackaroe #20200129

-- 실행 :   EXEC  [usp_GetProdBadStatus_Detail] '','','VVT','','','','','2020-07-17','2020-07-23',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_Detail_202008015]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
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
	DECLARE @FromDate DATE                   = @pFromDate
	DECLARE @ToDate DATE                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

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
			SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) AS 불량수량, --#20200129
			(SUM(PRS.OutputQty) - SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))) AS 양품수량, --#20200129
			--SUM(PRS.RepairQty) AS RepairQty,
			--SUM(PRS.LossQty) AS LossQty
			--CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)),0) = 0 THEN 0.0 
			        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) / SUM(PRS.OutputQty) * 100.0 END AS 불량율 --#20200129
	FROM
			STB_ProdRouteSummary                    PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)  ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo            RI WITH(NOLOCK) ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster   MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode           SC                      ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan            DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			--#20200129
			LEFT OUTER JOIN (
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



















--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode   
-- 실행 :   EXEC  [usp_GetProdBadStatus_Detail] '','',420,'VVT','','','','','2020-07-17','2020-07-23',''    
if @CompanyCode='VVT' begin
		
	declare @FromDate1    varchar(19)= CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:29:59'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	declare @ToDate1     varchar(19)  = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:30:01'

	 ; with tung as (
		 select  c.Barcode   --,b.RouteCode,RouteCode as FindRouteCode,min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		 from 
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where b.CompanyCode='VVT'  and b.ProdDateTime>@FromDate1  and b.ProdDateTime<@ToDate1
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
		 STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung)
		 group by c.Barcode
	 ),
	 tungfinished2 as (		
		 select  c.Barcode,b.RouteCode	, (row_number() over (partition by c.Barcode order by b.Routecode ASC)-tungfinished.totalcount )	  as ProdQtyFinishYn 	 
		 from 
		 STB_SetInfo c 
		 left outer join tungfinished on tungfinished.Barcode=c.Barcode 
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where  c.Barcode in (select Barcode from tung) 
		 --group by c.Barcode,b.RouteCode--,tungfinished.totalcount	 
	 ), 
	  tung0 as ( 
	 	select  c.Barcode,b.RouteCode,RouteCode as FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,shiftcode,b.PONo, 
		min(b.ProdQty) as ProdQty,0 as DefectQty,max(ProdDateTime) as ProdDateTime 
		from  STB_SetInfo c
		 left outer join  STB_ProdRouteHist b	on c.ControlNo=b.ControlNo	 
		 where c.Barcode in (select Barcode from tung)
		 group by c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,shiftcode,b.PONo
		 --order by a.FindRouteCode 
		 union
		 select  c.Barcode, FindRouteCode as RouteCode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode,'' as MachineCode,'' as shiftcode,'' as PONo,
		 0 as ProdQty,sum(a.DefectQty) as DefectQty,max(FindDateTime) as ProdDateTime 
		 from  STB_SetInfo c
		 full outer join  STB_DefectRepairInfo a on  a.ControlNo=c.ControlNo
		 where   c.Barcode in (select Barcode from tung)
		 group by c.Barcode,a.FindRouteCode,c.ControlNo,c.MaterialCode,InputLineCode/*c.MachineCode,c.WorkerCode,*/
		 --order by a.FindRouteCode 
	 ),
	 tung11 as (
	 select Barcode,RouteCode,FindRouteCode,max(ControlNo) as ControlNo,max(MaterialCode) as MaterialCode,max(InputLineCode) as InputLineCode,max(MachineCode) as MachineCode,
	 sum(ProdQty)as ProdQty,sum(DefectQty) as DefectQty,max(shiftcode) as shiftcode,max(PONo) as PONo,
	 /*sum(ProdQty)-sum(DefectQty) as soluongOut,*/max(ProdDateTime) as ProdDateTime
	 from tung0
		group by Barcode,RouteCode,FindRouteCode --,ControlNo,MaterialCode,InputLineCode,MachineCode
	 --	order by RouteCode
	),
	tung1 as (
	select 
	tung11.*, isnull(ProdQtyFinishYn,0) as ProdQtyFinishYn
	 from tung11
	 left outer join tungfinished2 
	 on tung11.Barcode = tungfinished2.Barcode and tung11.RouteCode = tungfinished2.RouteCode	 
	 ),
	tung22 as (
	select *
	from tung1 where RouteCode='V-22'
	),
	tung23 as (
	select *
	from tung1 where RouteCode='V-23'
	)
	,
	tung24 as (
	select *
	from tung1 where RouteCode='V-24'
	)
	,
	tung25 as (
	select *
	from tung1 where RouteCode='V-25'
	)
	,
	tung27 as (
	select *
	from tung1 where RouteCode='V-27'
	)
	,
	tung28 as (
	select *
	from tung1 where RouteCode='V-28'
	)
	,
	tung40 as (
	select *
	from tung1 where RouteCode='V-40'
	),
	tlast as (
	select *from tung22 --where  ProdDateTime>'2020-07-01'
	union
	select tung23.* from tung23--,tung22  where tung23.Barcode = tung22.Barcode --and ( tung23.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union  																	
	select tung40.* from tung40--,tung22  where tung40.Barcode = tung22.Barcode --and ( tung40.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) )
	union									 								
	select tung24.* from tung24,tung22  where tung24.Barcode = tung22.Barcode and ( tung24.ProdDateTime >= DATEADD(ss,5,tung22.ProdDateTime) or tung24.ProdQtyFinishYn<0)
	union  									  									
	select tung25.* from tung25,tung24  where tung25.Barcode = tung24.Barcode and ( tung25.ProdDateTime >= DATEADD(ss,5,tung24.ProdDateTime) or tung25.ProdQtyFinishYn<0)
	union  									 									
	select tung27.* from tung27,tung25  where tung27.Barcode = tung25.Barcode and ( tung27.ProdDateTime >= DATEADD(ss,5,tung25.ProdDateTime) or tung27.ProdQtyFinishYn<0)
	union  									 									
	select tung28.* from tung28,tung27  where tung28.Barcode = tung27.Barcode and ( tung28.ProdDateTime >= DATEADD(ss,5,tung27.ProdDateTime) or tung28.ProdQtyFinishYn<0)
	),
	last2 as (
	select 'VVT' as CompanyCode, 'VVT_F1' as WorkCenterCode,
	Barcode,(RouteCode),(FindRouteCode),ControlNo,MaterialCode,InputLineCode as LineCode,shiftcode,PONo
	,MachineCode, ProdQty as OutputQty, DefectQty,/*soluongOut,*/ 
	CONVERT(varchar(19),ProdDateTime,120) as ProdDateTime
	from tlast
	
	),
	DRI0 as (
	select  CompanyCode,  WorkCenterCode,
	(RouteCode),(FindRouteCode),ControlNo,MaterialCode, LineCode,shiftcode,PONo
	,MachineCode,   OutputQty,  DefectQty
	, (case  when   (DATEPART(HOUR, ProdDateTime)>10)     or    (DATEPART(HOUR, ProdDateTime)=10 and DATEPART(MINUTE, ProdDateTime)>30)     
				then     convert(varchar(10),ProdDateTime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  ProdDateTime),120)       
				end )    as  JobDate 
	from last2
	where  ProdDateTime>@FromDate1  and ProdDateTime<@ToDate1
	),
	DRI as (
		select  CompanyCode,  WorkCenterCode,
		(RouteCode),(FindRouteCode),MaterialCode, LineCode,shiftcode,PONo
		,max(MachineCode) as MachineCode,  sum(OutputQty) as OutputQty, sum(DefectQty	) as DefectQty
		,   JobDate 
		from DRI0
			group by CompanyCode,  WorkCenterCode,
		(RouteCode),(FindRouteCode),MaterialCode, LineCode,shiftcode,PONo
		,JobDate
	)
	SELECT
           dbo.fnGetLocalTime(PRS.JobDate, 420) as 작업일자,
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
			SUM(PRS.DefectQty -- ISNULL(RepairInfo.RepairQty, 0)
			) AS 불량수량, --#20200129
			(SUM(PRS.OutputQty) - SUM(PRS.DefectQty -- ISNULL(RepairInfo.RepairQty, 0)
			)) AS 양품수량, --#20200129
			--SUM(PRS.RepairQty) AS RepairQty,
			--SUM(PRS.LossQty) AS LossQty
			--CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.DefectQty -- ISNULL(RepairInfo.RepairQty, 0)
			),0) = 0 THEN 0.0 
			        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE SUM(PRS.DefectQty -- ISNULL(RepairInfo.RepairQty, 0)
					) / SUM(PRS.OutputQty) * 100.0 END AS 불량율 --#20200129
	FROM
			DRI                    PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo              LI WITH(NOLOCK)  ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo            RI WITH(NOLOCK) ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster   MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode           SC                      ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan            DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
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
        --  AND	(@LineCode = '*' OR PRS.LineCode = @LineCode )
      --   AND	(@RouteCode = '*' OR PRS.RouteCode = @RouteCode )
		-- AND	(@MaterialCode = '*' OR PRS.MaterialCode = @MaterialCode )
		 --AND	(PRS.JobDate BETWEEN @FromDate1 AND @ToDate1) 
		 AND (('VVT' = '*') OR (PRS.CompanyCode = 'VVT'))   	                     -- 2019.12.16 추가		   		 
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
			--PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift--,
			--PRS.TimeCode
  --order by PRS.RouteCode
end 


END



