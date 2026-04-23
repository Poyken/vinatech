-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 생산관리
-- Description:	[B640] 라인별 생산현황 , [B710] 품목별 생산현황
-- Modified: 2019-03-08 라인정리 (kilee) 
--             2019-09-18 대기공정 가실적 처리 (최덕렬과장 요청사항) 
--             2020-01-29 불량 수리 시 수리 수량을 잘못 반영하는 부분이 있어 쿼리를 수정함 by Jackaroe  #20200129
--             2020-03-12 베트남 날짜함수 추가

-- 실행 :   EXEC  [usp_GetProdRouteSummary] '','','','','ASSYLINE-12','E-24','ECVT30-115','2019-09-01','2019-09-18',''
--           EXEC  [usp_GetProdRouteSummary] '','','','','ASSYLINE-12',' ','ECVT30-076','2019-09-01','2019-09-18',''
-- =============================================
 -- 공정별 생산현황 전체조회 -> EXEC  usp_GetProdRouteSummary '','','','','ASSYLINE-07','','','2019-09-22','2019-09-23',''
--                                           EXEC   usp_GetProdRouteSummary_vvt22  '','','','','','','','','',''

CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_vvt22]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pCompanyCode VARCHAR(20) = NULL,
					@pWorkCenterCode VARCHAR(20) = NULL,
					@pLineCode VARCHAR(200) = NULL,
					@pRouteCode VARCHAR(20) = NULL,
					@pMaterialCode VARCHAR(50) = NULL,
					@pFromDate DATE = NULL,
					@pToDate DATE = NULL,
					@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VVT'     ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VVT_F1' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(200)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
	--DECLARE @FromDate            DATE                   = @pFromDate
	--DECLARE @ToDate               DATE                      = @pToDate

	DECLARE @FromDate   VARCHAR(19) = '2020-03-23 10:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) =  '2020-03-23 10:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

  --DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)   

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
			RI.RouteName,
			POR.RouteIndex,
			PRS.MoldNumber,
			PRS.MachineCode,
			MCM.MachineName,
			PRS.PONo,
			--RepairInfo.FindJobDate,
			ROUND(SUM(POI.PlanQty), 0) AS POPlanQty,
	      --PRS.JobDate,                                                        -- 원본백업
			CONVERT(DATETIMEOFFSET, PRS.JobDate) AS JobDate,     -- 2020.03.12 변경 (kilee)
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			ROUND(SUM(DPP.PlanQty), 0) AS PlanQty,
			SUM(PRS.InputQty)              AS InputQty,
			SUM(PRS.OutputQty)            AS OutputQty,
			(SUM(PRS.OutputQty) - SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)))  AS GoodsQty,
			SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0))             AS DefectQty,
			SUM(PRS.RepairQty)             AS RepairQty,
			SUM(PRS.LossQty)                AS LossQty,
			CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0    THEN 0.0 ELSE SUM(PRS.OutputQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate,
			CASE WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 ELSE SUM(PRS.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) / SUM(PRS.OutputQty) * 100.0 END AS DefectRate
		  , CONVERT(BIT,CASE WHEN ISNULL(NP.AftProdQty,0) > 0 THEN 1	ELSE 0  END)                                                 AS IsHasNextProd		  
		  , dbo.fnGetWastePrice(PRS.LineCode, PRS.RouteCode, PRS.MaterialCode, SUM(ISNULL(PRS.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0)))                                    AS DefectPrice

		  ,  (	 SELECT top 1 BaseMonth
			     FROM STB_AggregationPeriod
				 WHERE 1=1										   
				  --AND  FromDate  <= PRS.JobDate  AND  ToDate     >=PRS.JobDate
										)  as YearMonth
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
			LEFT OUTER JOIN NextProd                 NP	    ON NP.PONo = PRS.PONo  -- 추가
			LEFT OUTER JOIN (
									SELECT CompanyCode, WorkCenterCode, FindJobDate,FindDateTime, FindShiftCode, PONo
										  ,MaterialCode, FindLineCode, FindRouteCode, ISNULL(SUM(RepairQty), 0) AS RepairQty
									  FROM STB_DefectRepairInfo
									 WHERE RepairType NOT IN ('MISSING') 
									 --and FindDateTime >= '2020-03-23 00:00:00' and FindDateTime<'2020-03-23 23:59:59'
									 GROUP BY CompanyCode, WorkCenterCode, FindJobDate,FindDateTime, FindShiftCode, PONo
											 ,MaterialCode, FindLineCode, FindRouteCode
								) RepairInfo
				ON RepairInfo.CompanyCode = PRS.CompanyCode
			   AND RepairInfo.WorkCenterCode = PRS.WorkCenterCode
			   --AND RepairInfo.FindJobDate = PRS.JobDate
			   and RepairInfo.FindDateTime >= '2020-03-23 00:00:00' and RepairInfo.FindDateTime<'2020-03-23 23:59:59'
			   AND RepairInfo.FindShiftCode = PRS.ShiftCode
			   AND RepairInfo.PONo = PRS.PONo
			   AND RepairInfo.MaterialCode = PRS.MaterialCode
			   AND RepairInfo.FindLineCode = PRS.LineCode
			   AND RepairInfo.FindRouteCode = PRS.RouteCode
	WHERE 1=1
	 AND PRS.TimeCode <> 'E'                                                                                             -- MES 등록한것만 (2019.07.15)
	 AND PRS.CompanyCode = @CompanyCode 		  
	 AND PRS.WorkCenterCode = @WorkCenterCode 
     AND (@LineCode = '*' OR PRS.LineCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @LineCode)))
     AND (@RouteCode = '*' OR PRS.RouteCode LIKE @RouteCode)
	 AND (@MaterialCode = '*' OR PRS.MaterialCode LIKE @MaterialCode)
	 --AND (PRS.JobDate BETWEEN @FromDate AND @ToDate) 		 
	 AND ISNULL(NP.AftProdQty,0) > CASE WHEN @RouteCode = '%' THEN -1   
													WHEN (dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) IS NULL OR dbo.fnGetNextRouteCode(PRS.PONo, @RouteCode) = 'E-28') THEN -1  ELSE 0 END       -- 추가
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