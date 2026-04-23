-- ========================================================================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : True
-- Group : 생산관리
-- Description:	[B640] 라인별 생산현황 , [B710] 품목별 생산현황
-- Modified: 
--           2019-03-08 라인정리 (Kangs) 
--           2019-09-18 대기공정 가실적 처리 (최덕렬 요청사항) 
--           2020-01-29 불량 수리 시 수리 수량을 잘못 반영하는 부분이 있어 쿼리를 수정함 by Jackaroe  #20200129
--           2020-05-28 공정검사 부적합 포함여부 추가. 최덕렬 요청 by Jackaroe  #20200528

-- 프로시저 실행문 :   usp_GetProdRouteSummary_DashBoard  '','','','','','','','2020-12-26','2022-12-25','',0
-- ==========================================================================================
CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_Dashboard]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pMaterialCode VARCHAR(50) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pIsOutputRoute BIT = NULL,
						@pIsIncludeRouteInspDefect BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode    VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20)    = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode    END	
	DECLARE @LineCode           VARCHAR(20)   = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'     ELSE @pLineCode       END
	DECLARE @RouteCode         VARCHAR(20)   = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'     ELSE @pRouteCode     END
	DECLARE @MaterialCode       VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'     ELSE @pMaterialCode  END
	DECLARE @FromDate           DATE            = @pFromDate
	DECLARE @ToDate              DATE            = @pToDate
	DECLARE @IsIncludeRouteInspDefect BIT = CASE WHEN ISNULL(@pIsIncludeRouteInspDefect, CONVERT(BIT, 1)) = CONVERT(BIT, 1) THEN CONVERT(BIT, 1) ELSE @pIsIncludeRouteInspDefect END
	DECLARE @IsOutputRoute               BIT = @pIsOutputRoute


	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01'
	
	 BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	 END

	;WITH NextProd AS
	(
		SELECT
				--SI.ControlNo,
				PRH.PoNo
			 ,  PRH.RouteCode
			 ,	SUM(PRH.ProdQty) AS AftProdQty
		FROM
				STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
				   ON POR.PONo = SI.PONo
				  AND (@RouteCode = '*' OR POR.RouteCode = @RouteCode)
				LEFT OUTER JOIN STB_ProductionOrderRouting NPOR WITH(NOLOCK)
				  ON NPOR.PONo = SI.PONo
				 AND NPOR.RouteIndex = POR.RouteIndex + 1
				INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)
				   ON PRH.ControlNo = SI.ControlNo  
				  AND PRH.RouteCode = NPOR.RouteCode
		GROUP BY
		        PRH.PoNo
			   ,PRH.RouteCode
	)


	SELECT
			IsNull(PRS.CompanyCode, 'VNT') AS CompanyCode,
			IsNull(PRS.WorkCenterCode, 'VNT_F1') AS WorkCenterCode,
			PRS.MaterialCode,
			MM.MaterialName,
			LI.LineCode,
			LI.LineName,                   -- 원본백업
			Replace(PRS.RouteCode, 'V', 'E') AS RouteCode,

			CASE WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-22' THEN '권취'
			       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-23' THEN '고무전'
			       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-24' THEN '커링'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-25' THEN '슬리빙'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-26' THEN '에이징'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-27' THEN '외관'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-29' THEN '도핑'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-33' THEN '절곡'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-34' THEN '재검'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-28' THEN '포장'  ELSE '기타' END RouteName,

			POR.RouteIndex,
			PRS.MoldNumber,
			PRHWorker.MachineCode,
			IsNull(PRHWorker.MachineName, '정보없음') ,
			PRS.PONo,
			ROUND(SUM(ISNULL(POI.PlanQty,0)), 0) AS POPlanQty,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			ROUND(SUM(ISNULL(DPP.PlanQty,0)), 0) AS PlanQty,
			SUM(ISNULL(PRS.InputQty, 0))              AS InputQty,
			SUM(ISNULL(PRS.OutputQty,0))            AS OutputQty,
			(SUM(ISNULL(PRS.OutputQty,0)) - SUM(ISNULL(RepairInfo.DefectQty,0) - ISNULL(RepairInfo.RepairQty, 0)))  AS GoodsQty,
			SUM(ISNULL(RepairInfo.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))             AS DefectQty,
			SUM(ISNULL(PRS.RepairQty, 0))             AS RepairQty,
			SUM(ISNULL(PRS.LossQty, 0))                AS LossQty,
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0    THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 ELSE SUM(RepairInfo.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) / SUM(PRS.OutputQty) * 100.0 END      AS DefectRate
		  , CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0  END)                                                                                              AS IsHasNextProd		  
		  , ISNULL(dbo.fnGetWastePriceByMaterial(PRS.CompanyCode, PRS.WorkCenterCode, LI.LineCode, PRS.MaterialCode, 'DC', PRS.RouteCode, SUM(ISNULL(RepairInfo.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))), 0) AS DefectPrice		  
		 
		  , dbo.fnGetWastePriceByMaterial(PRS.CompanyCode, PRS.WorkCenterCode, LI.LineCode, PRS.MaterialCode, 'DC', PRS.RouteCode, 1)                                                                                            AS DefectUnitPrice		  
		  , dbo.fnGetWastePriceByMaterial(PRS.CompanyCode, PRS.WorkCenterCode, LI.LineCode, PRS.MaterialCode, 'DC', PRS.RouteCode, (SUM(ISNULL(PRS.OutputQty,0)) - SUM(ISNULL(RepairInfo.DefectQty,0) - ISNULL(RepairInfo.RepairQty, 0)))) AS GoodsPrice
		  ,  (	SELECT BaseMonth
			     FROM STB_AggregationPeriod
				 WHERE 1=1										   
				   AND  FromDate <= PRS.JobDate
				   AND  ToDate    >= PRS.JobDate
			  )  AS YearMonth
			,PRHWorker.WorkerCode
			,PWI.WorkerName

	FROM
			STB_ProdRouteSummary                             PRS WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo                     LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode  
			LEFT OUTER JOIN STB_MaterialMaster            MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode                     SC  WITH(NOLOCK)                    ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo      POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan                DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = LI.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN NextProd NP	 WITH(NOLOCK)		  ON NP.PONo = PRS.PONo			 AND NP.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN (
									SELECT CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
										  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(RepairQty), 0) AS RepairQty
										  ,ISNULL(SUM(DefectQty), 0) AS DefectQty
										  , Max(ControlNo) as ControlNo
									  FROM STB_DefectRepairInfo  WITH(NOLOCK)
									 WHERE RepairType NOT IN ('MISSING')
									   AND (@IsIncludeRouteInspDefect = CONVERT(BIT, 1) 
									          OR ControlNo NOT IN (SELECT ControlNo FROM STB_SetInfo WHERE SIExtInt01 = 1))
									 GROUP BY CompanyCode, WorkCenterCode, FindJobDate, FindShiftCode, PONo
											 ,MaterialCode, FindLineCode, FindRouteCode
								) RepairInfo
				ON RepairInfo.CompanyCode = PRS.CompanyCode
				AND RepairInfo.WorkCenterCode = PRS.WorkCenterCode
				AND RepairInfo.FindJobDate = PRS.JobDate
				AND RepairInfo.FindShiftCode = PRS.ShiftCode
				AND RepairInfo.PONo = PRS.PONo
				AND RepairInfo.MaterialCode = PRS.MaterialCode
				AND RepairInfo.FindLineCode = LI.LineCode
				AND RepairInfo.FindRouteCode = PRS.RouteCode

			LEFT OUTER JOIN (SELECT A.CompanyCode
								   ,A.WorkCenterCode
								   ,A.MaterialCode
								   ,A.ShiftCode
								   ,A.PONo
								   ,A.JobDate
								   ,A.LineCode
								   ,A.RouteCode
								   ,A.MachineCode
								   ,B.MachineName
								   ,A.ProdQty
								   ,WorkerCode
							  FROM (SELECT CompanyCode 
										  ,WorkCenterCode
										  ,MaterialCode
										  ,ShiftCode
										  ,PONo
										  ,JobDate
										  ,LineCode
										  ,RouteCode
										  ,MAX(MachineCode) AS MachineCode
										  ,Sum(ProdQty) AS ProdQty
										  ,MAX(WorkerCode) AS WorkerCode
									  FROM STB_ProdRouteHist WITH(NOLOCK)
									 GROUP BY CompanyCode, WorkCenterCode, JobDate, ShiftCode, PONo, MaterialCode, LineCode, RouteCode) A 
							   LEFT OUTER JOIN STB_MachineMaster B								 ON A.MachineCode = B.MachineCode) PRHWorker	                    
			  ON PRS.CompanyCode = PRHWorker.CompanyCode
			 AND PRS.WorkCenterCode = PRHWorker.WorkCenterCode
			 AND PRS.JobDate = PRHWorker.JobDate
			 AND PRS.ShiftCode = PRHWorker.ShiftCode
			 AND PRS.PONo = PRHWorker.PONo
			 AND PRS.LineCode = PRHWorker.LineCode
			 AND PRS.RouteCode = PRHWorker.RouteCode

			 LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)			   ON PWI.WorkerCode = PRHWorker.WorkerCode

	WHERE 1=1	 
      AND (@LineCode = '*' OR LI.LineCode = @LineCode)
	  AND (NP.AftProdQty > 0 OR NP.RouteCode IS NULL)
	  AND ((@CompanyCode = '*') OR (PRS.CompanyCode = @CompanyCode))   	        
	  AND ((@WorkCenterCode = '*') OR (PRS.WorkCenterCode = @WorkCenterCode)) 
	  AND (@RouteCode = '*'        OR PRS.RouteCode LIKE @RouteCode)
	  AND (@MaterialCode = '*'     OR PRS.MaterialCode LIKE @MaterialCode)
	  AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 
	GROUP BY
	        PRS.RouteCode,
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.PONo,
			PRS.MaterialCode,
			MM.MaterialName,
			LI.LineCode,
			LI.LineName,
			POR.RouteIndex,
			PRS.MoldNumber,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			NP.AftProdQty  --추가
			, LI.LineDesc
			,PRHWorker.WorkerCode
			,PWI.WorkerName
			,PRHWorker.MachineCode
			,PRHWorker.MachineName
  ORDER BY LI.LineDesc, LI.LineCode, PRS.RouteCode
            , PRS.JobDate Desc


END