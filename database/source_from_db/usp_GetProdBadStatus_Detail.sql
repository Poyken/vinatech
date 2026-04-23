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
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_Detail]
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
			LEFT OUTER JOIN VW_ShiftCode           SC                      ON SC.ShiftCode = PRS.ShiftCode
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
				 
END



