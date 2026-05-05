-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 생산관리
-- Description:	[B640] 라인별 생산현황 , [B710] 품목별 생산현황
-- Modified: 2019-03-08 라인정리 (kilee) 

-- 실행 :   EXEC  [usp_GetProdRouteSummary] '','','','','','','','2019-07-22','2019-07-22',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_20190816]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
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

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '%'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '%'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATE                   = @pFromDate
	DECLARE @ToDate DATE                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

	SELECT
			PRS.CompanyCode,
			PRS.WorkCenterCode,
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
			PRS.PONo,
			ROUND(SUM(POI.PlanQty), 0) AS POPlanQty,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			--(SELECT SC.Shift FROM VW_ShiftCode SC),
			PRS.TimeCode,
			--SSI.Barcode,

			ROUND(SUM(DPP.PlanQty), 0) AS PlanQty,
			--MAX(DPP.PlanQty) AS PlanQty,
			SUM(PRS.InputQty) AS InputQty,
			SUM(PRS.OutputQty) AS OutputQty,
			SUM(PRS.DefectQty) AS DefectQty,
			SUM(PRS.RepairQty) AS RepairQty,
			SUM(PRS.LossQty) AS LossQty,
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0   THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 ELSE SUM(PRS.DefectQty) / SUM(PRS.OutputQty) * 100.0 END AS DefectRate
	FROM
			STB_ProdRouteSummary                             PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo                      LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo                    RI WITH(NOLOCK)  ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster          MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster            MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode                     SC                     ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo      POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan                DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
		--	LEFT OUTER JOIN STB_SetInfo                       SSI WITH(NOLOCK) ON SSI.PONo = PRS.PONo AND SSI.MaterialCode = PRS.MaterialCode  AND SSI.ControlNo = PRS.ProductSummaryID
	WHERE 1=1
	     AND PRS.TimeCode <> 'E'    -- MES 등록한것만 (2019.07.15)
	     --AND DPP.DPPExtText05 = 'ERP'                                             --- ERP Data만
		  AND	PRS.CompanyCode LIKE @CompanyCode 		  
		  AND	PRS.WorkCenterCode LIKE @WorkCenterCode 
          AND	PRS.LineCode LIKE @LineCode 
          AND	PRS.RouteCode LIKE @RouteCode 
		  AND	PRS.MaterialCode LIKE @MaterialCode 
		  AND	(PRS.JobDate BETWEEN @FromDate AND @ToDate) 
		            --AND	((@IsOutputRoute IS NULL) OR (POR.IsOutputRoute = @IsOutputRoute))
         
	GROUP BY
	        PRS.RouteCode,
	      --  SSI.Barcode,
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.PONo,
			--POI.PlanQty,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			
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