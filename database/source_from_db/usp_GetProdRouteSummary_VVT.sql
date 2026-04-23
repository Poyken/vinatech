-- =============================================
-- Author:	    kilee
-- Create date: 2020-03-03
-- Browsable : true
-- Group : Power-BI > 대시보드
-- Description:	
-- Modified: 

-- 실행 :            usp_GetProdRouteSummary_VVT  '','','VVT','','VVC-01','','','2020-02-26','2020-03-25',''
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_VVT]
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

	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pCompanyCode END
	

	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'     ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'     ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'     ELSE @pMaterialCode     END
	DECLARE @FromDate DATE                   = @pFromDate
	DECLARE @ToDate DATE                      = @pToDate



	DECLARE @IsOutputRoute BIT = @pIsOutputRoute


	;WITH NextProd AS
	(
		SELECT
				--SI.ControlNo,
				PRH.PoNo
			 ,	SUM(PRH.ProdQty) AS AftProdQty
		FROM
									   STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	     ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					     ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
		GROUP BY
		        PRH.PoNo
				--SI.ControlNo
	)

	SELECT
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			PRS.RouteCode,
			--Replace(PRS.RouteCode, 'V', 'E') AS RouteCode,
			--(SELECT Replace(RouteCode, 'V', 'E') AS RouteCode  FROM STB_RouteInfo  RI WHERE RI.RouteCode = PRS.RouteCode) AS RouteCode, 

			--CASE WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-22' THEN '권취'
			--       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-23' THEN '고무전'
			--       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-24' THEN '커링'
			--	   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-25' THEN '슬리빙'
			--	   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-26' THEN '에이징'
			--	   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-27' THEN '외관'
			--	   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-28' THEN '포장'  ELSE '기타' END RouteName,

			RI.RouteName,
			POR.RouteIndex,
			PRS.MoldNumber,
			PRS.MachineCode,
			--MCM.MachineName,			
			PRS.PONo,
			ROUND(SUM(POI.PlanQty), 0) AS POPlanQty,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			ROUND(SUM(DPP.PlanQty), 0) AS PlanQty,
			SUM(ISNULL(PRS.InputQty,0))              AS InputQty,
			SUM(ISNULL(PRS.OutputQty,0))            AS OutputQty,
			(SUM(PRS.OutputQty) - SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)))  AS GoodsQty,
			SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))             AS DefectQty,
			SUM(PRS.RepairQty)             AS RepairQty,
			SUM(PRS.LossQty)                AS LossQty,
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0    THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 ELSE SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) / SUM(PRS.OutputQty) * 100.0 END AS DefectRate
		  , CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0  END)                                                 AS IsHasNextProd		  
		  , dbo.fnGetWastePrice(PRS.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0)))                                    AS DefectPrice
	FROM
			STB_ProdRouteSummary                             PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo                      LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode

			LEFT OUTER JOIN STB_RouteInfo                    RI WITH(NOLOCK)  ON RI.RouteCode = PRS.RouteCode
			--LEFT OUTER JOIN (SELECT Replace(RouteCode, 'V', 'E') AS RouteCode, RouteName  FROM STB_RouteInfo )         RI  ON RI.RouteCode = PRS.RouteCode
			--LEFT OUTER JOIN (SELECT Replace(RouteCode, 'V', 'E') AS RouteCode FROM STB_RouteInfo )         RI  ON RI.RouteCode = PRS.RouteCode

			LEFT OUTER JOIN STB_MachineMaster          MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster            MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode                     SC                     ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo      POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan                DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = PRS.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN NextProd                           NP	    ON NP.PONo = PRS.PONo  -- 추가
			LEFT OUTER JOIN (
									SELECT CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
										  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(RepairQty), 0) AS RepairQty
									  FROM STB_DefectRepairInfo
									 WHERE RepairType NOT IN ('MISSING') -- #20200129
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
	 AND PRS.TimeCode <> 'E'                                                                                             -- MES 등록한것만 (2019.07.15)
	 --AND PRS.CompanyCode = @CompanyCode 		  
	 --AND PRS.WorkCenterCode = @WorkCenterCode 

	 AND (@CompanyCode = '*'    OR PRS.CompanyCode = @CompanyCode)
	 AND (@WorkCenterCode = '*' OR PRS.WorkCenterCode = @WorkCenterCode)

	 --AND (PRS.CompanyCode LIKE @CompanyCode)
	 --AND (PRS.WorkCenterCode LIKE @WorkCenterCode)
	 

     AND (@LineCode = '*' OR PRS.LineCode LIKE @LineCode)
     AND (@RouteCode = '*' OR PRS.RouteCode LIKE @RouteCode)
	 AND (@MaterialCode = '*' OR PRS.MaterialCode LIKE @MaterialCode)
	 AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 		 
	 AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1   
													WHEN (dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) = 'V-28' ) THEN -1  ELSE 0 END       -- 추가
    
	AND NOT PRS.LineCode  = '%'
	AND NOT PRS.RouteCode = 'V-40'
	GROUP BY
	        PRS.RouteCode,
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.PONo,
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
			PRS.TimeCode,
			NP.AftProdQty  --추가
  ORDER BY PRS.LineCode, PRS.RouteCode

END