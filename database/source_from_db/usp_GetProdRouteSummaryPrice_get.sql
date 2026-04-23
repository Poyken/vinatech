-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 생산관리
-- Description:	[B640] 라인별 생산현황 , [B710] 품목별 생산현황
-- Modified: 2019-03-08 라인정리 (kilee) 
--           2019-09-18 대기공정 가실적 처리 (최덕렬과장 요청사항) 
--           2020-01-29 불량 수리 시 수리 수량을 잘못 반영하는 부분이 있어 쿼리를 수정함 by Jackaroe  #20200129

-- 실행 :   EXEC  [usp_GetProdRouteSummary_Dashboard] '','','VVT','VVT_F1','',' ','','2020-01-26','2020-02-25',''
-- 실행 :   EXEC  [usp_GetProdRouteSummary_Dashboard] '','','','','','','','2020-01-26','2020-02-25',''
--                   usp_GetProdRouteSummary_Dashboard  '','','VVT','','','','','2020-02-26','2020-03-25',''
--					 usp_GetProdRouteSummary_Dashboard  '','','VVT','','VVM-07','','','2020-02-26','2020-03-25',''

--  usp_GetProdRouteSummaryPrice_get  '','','VNT','','ASSYLINE-05','E-28','','2020-03-26','2020-04-25',''
--  usp_GetProdRouteSummaryPrice_get  '','','VNT','','ASSYLINE-05','','','2020-03-26','2020-04-25',''

-- usp_GetProdRouteSummary_DashBoard  '','','','','ASSYLINE-07','','','2020-03-26','2020-04-25',''

--usp_GetProdRouteSummary_DashBoard  '','','','','ASSYLINE-05','','','2020-02-26','2020-03-25',''

-- =============================================

CREATE PROCEDURE [dbo].[usp_GetProdRouteSummaryPrice_get]
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

	DECLARE @CompanyCode    VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode, '') = ''    THEN '*' ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20)    = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pCompanyCode    END	
	DECLARE @LineCode           VARCHAR(20)   = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'     ELSE @pLineCode       END
	DECLARE @RouteCode         VARCHAR(20)   = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'     ELSE @pRouteCode     END
	DECLARE @MaterialCode       VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'     ELSE @pMaterialCode  END
	DECLARE @FromDate           DATE            = @pFromDate
	DECLARE @ToDate              DATE            = @pToDate

	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

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
			--PRS.CompanyCode,
			--PRS.WorkCenterCode,
			PRS.MaterialCode,
			MM.MaterialName,
			LI.LineCode,
			LI.LineName,
			----PRS.RouteCode,
			Replace(PRS.RouteCode, 'V', 'E') AS RouteCode,
			--(SELECT Replace(RouteCode, 'V', 'E') AS RouteCode  FROM STB_RouteInfo  RI WHERE RI.RouteCode = PRS.RouteCode) AS RouteCode, 

			CASE WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-22' THEN '권취'
			       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-23' THEN '고무전'
			       WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-24' THEN '커링'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-25' THEN '슬리빙'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-26' THEN '에이징'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-27' THEN '외관'
				   WHEN Replace(PRS.RouteCode, 'V', 'E') = 'E-28' THEN '포장'  ELSE '기타' END RouteName,			
			SUM(ISNULL(PRS.OutputQty,0))            AS OutputQty,
			(SUM(ISNULL(PRS.OutputQty,0)) - SUM(ISNULL(PRS.DefectQty,0) - ISNULL(RepairInfo.RepairQty, 0)))  AS GoodsQty,
			SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))             AS DefectQty,			
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0    THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 ELSE SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) / SUM(PRS.OutputQty) * 100.0 END      AS DefectRate
		  , CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0  END)                                                                                               AS IsHasNextProd		  
		 -- , ISNULL(dbo.fnGetWastePrice(LI.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))), 0)                 AS DefectPrice
		  , dbo.fnGetWastePrice(LI.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0)))                 AS DefectPrice
		  , (SUM(ISNULL(PRS.OutputQty,0)) - SUM(ISNULL(PRS.DefectQty,0) - ISNULL(RepairInfo.RepairQty, 0))) / 
		  CASE WHEN dbo.fnGetWastePrice(LI.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))) = 0 THEN 1 
		         WHEN dbo.fnGetWastePrice(LI.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))) = 1 THEN 1 
		          WHEN (SUM(ISNULL(PRS.OutputQty,0)) - SUM(ISNULL(PRS.DefectQty,0) - ISNULL(RepairInfo.RepairQty, 0))) = 0 THEN 0 
				  WHEN SUM(ISNULL(PRS.DefectQty, 0)) = 0 THEN 0
		  ELSE  dbo.fnGetWastePrice(LI.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))) END AS DefectPrice_EA
	FROM
			STB_ProdRouteSummary                             PRS WITH(NOLOCK)

			RIGHT OUTER JOIN STB_LineInfo                      LI WITH(NOLOCK)   ON LI.LineCode = PRS.LineCode  
									 AND (@CompanyCode = '*'    OR PRS.CompanyCode = @CompanyCode)
									 AND (@WorkCenterCode = '*' OR PRS.WorkCenterCode = @WorkCenterCode)
									 AND (@RouteCode = '*' OR PRS.RouteCode LIKE @RouteCode)
									 AND (@MaterialCode = '*' OR PRS.MaterialCode LIKE @MaterialCode)
									 AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 		 

			LEFT OUTER JOIN STB_MachineMaster          MCM WITH(NOLOCK)  ON MCM.MachineCode = PRS.MachineCode
			LEFT OUTER JOIN STB_MaterialMaster            MM WITH(NOLOCK)  ON MM.MaterialCode = PRS.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode                     SC                     ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRS.PONo AND POR.RouteCode = PRS.RouteCode
			LEFT OUTER JOIN STB_ProductionOrderInfo      POI WITH(NOLOCK) ON POI.PONo = PRS.PONo
			LEFT OUTER JOIN STB_DayProdPlan                DPP WITH(NOLOCK) ON DPP.PONo = PRS.PONo AND DPP.LineCode = LI.LineCode AND DPP.PlanDate = PRS.JobDate AND DPP.PlanShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN NextProd                           NP	                    ON NP.PONo = PRS.PONo  -- 추가
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
			   AND RepairInfo.FindLineCode = LI.LineCode
			   AND RepairInfo.FindRouteCode = PRS.RouteCode
	WHERE 1=1	 
      AND (@LineCode = '*' OR LI.LineCode LIKE @LineCode)
	 AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1   
													WHEN (dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IN ('E-28', 'V-28') ) THEN -1  ELSE 0 END       -- 추가

	GROUP BY
	        PRS.RouteCode,
			PRS.CompanyCode,
			PRS.WorkCenterCode,
			PRS.PONo,
			PRS.MaterialCode,
			MM.MaterialName,
			LI.LineCode,
			LI.LineName,
			--RI.RouteName,
			POR.RouteIndex,
			PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			NP.AftProdQty  --추가
  ORDER BY LI.LineCode, PRS.RouteCode

END