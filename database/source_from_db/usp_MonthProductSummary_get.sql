-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-12-07
-- Browsable : true
-- Group : 생산관리
-- =============================================
CREATE PROCEDURE [dbo].[usp_MonthProductSummary_get]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pCompanyCode VARCHAR(20) = NULL,
					@pWorkCenterCode VARCHAR(20) = NULL,
					@pLineCode VARCHAR(200) = NULL,
					@pRouteCode VARCHAR(20) = NULL,
					@pMaterialCode VARCHAR(50) = NULL,
					@pFromDate DATE = NULL,
					@pToDate DATE = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN '*'     ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(200)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	DECLARE @FromDate            DATE                   = @pFromDate
	DECLARE @ToDate               DATE                      = @pToDate

	IF @FromDate IS NULL OR @FromDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	;WITH NextProd AS
	(
		SELECT
				PRH.PoNo
			 ,	SUM(PRH.ProdQty) AS AftProdQty
		FROM
									   STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN        STB_ProductionOrderRouting POR WITH(NOLOCK)			 ON POR.PONo = SI.PONo             AND	POR.RouteCode = @RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)	     ON NPOR.PONo = SI.PONo           AND	NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN        STB_ProdRouteHist PRH WITH(NOLOCK)					     ON PRH.ControlNo = SI.ControlNo  AND	PRH.RouteCode = NPOR.RouteCode
		GROUP BY
		        PRH.PoNo
	)

	SELECT
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			CONVERT(DATE, CONVERT(DATETIMEOFFSET, PRS.JobDate)) AS JobDate,
			YEAR(CONVERT(DATETIMEOFFSET, PRS.JobDate)) AS BaseYear,
			MONTH(CONVERT(DATETIMEOFFSET, PRS.JobDate)) AS BaseMonth,
			DAY(CONVERT(DATETIMEOFFSET, PRS.JobDate)) AS BaseDay,
			CONVERT(CHAR(7), dbo.fnGetAggregationPeriodWithDate(PRS.JobDate, 3), 121) AS YearMonth,
			PRS.MaterialCode,
			MM.MaterialName,
			RIGHT('0'+CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) AS ProdSize,
			PRS.LineCode,
			LI.LineName,
			--LI.LineDesc As LineName,
			PRS.RouteCode,
			RI.RouteName,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			SUM(PRS.OutputQty)              AS OutputQty,
			SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))             AS DefectQty,
			(SUM(PRS.OutputQty) - SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)))  AS GoodsQty,
			dbo.fnGetWastePriceByMaterialIncludeOutputRoute(PRS.CompanyCode
				                                  , PRS.WorkCenterCode
												  , PRS.LineCode
												  , PRS.MaterialCode
												  , 'PC'
												  , PRS.RouteCode
												  , SUM(PRS.OutputQty) - SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))) AS ProdPrice,

			dbo.fnGetWastePriceByMaterial(PRS.CompanyCode
				                        , PRS.WorkCenterCode
										, PRS.LineCode
										, PRS.MaterialCode
										, 'DC'
										, PRS.RouteCode
										, SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))) AS DefectPrice
	FROM
			STB_ProdRouteSummary PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)  ON RI.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode SC                     ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) 
			  ON DPP.PONo = PRS.PONo 
			 AND DPP.LineCode = PRS.LineCode 
			 AND DPP.PlanDate = PRS.JobDate 
			 AND DPP.PlanShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN NextProd NP ON NP.PONo = PRS.PONo
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
			  LEFT OUTER JOIN VW_ModelBasicInfo MBI
			    ON MBI.ModelCode = PRS.MaterialCode
	WHERE 1=1
	 AND (@CompanyCode = '*' OR PRS.CompanyCode = @CompanyCode)  		  
	 AND (@WorkCenterCode = '*' OR PRS.WorkCenterCode = @WorkCenterCode)
     AND (@LineCode = '*' OR PRS.LineCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @LineCode)))
     AND (@RouteCode = '*' OR PRS.RouteCode LIKE @RouteCode)
	 AND (@MaterialCode = '*' OR PRS.MaterialCode LIKE @MaterialCode)
	 AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 	
	 --AND POR.IsOutputRoute = CONVERT(BIT, 1)	 
	 AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '*' THEN -1   
													WHEN (dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IN ('E-28', 'V-28')) THEN -1  ELSE 0 END       -- 추가
	GROUP BY
	        PRS.RouteCode,
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.MaterialCode,
			MM.MaterialName,
			PRS.LineCode,
			LI.LineName,
			--LI.LineDesc,             --추가사항
			RI.RouteName,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			RIGHT('0'+CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH))
  ORDER BY PRS.LineCode, PRS.RouteCode

END
