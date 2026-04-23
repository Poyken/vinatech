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
--             2021-12-02 최종라우팅(IsOutputRoute가 참이고, 최종공정(포장)인 경우 불량수량 및 불량율를 무시하도록 쿼리 수정 #211202

 -- usp_GetProdRouteSummary_B620 'kilee2','Korean','VNT','VNT_F1','','','','2022-01-06','2022-01-07',''     -- 57건
-- ================================================================================

CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_B620]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pUtcOffset INT,
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

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(200)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '*'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '*'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '*'       ELSE @pMaterialCode     END
    DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                           
    DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'    
    -- #211202 프로시저에는 이미 선언되어 있는 파라미터이나 실제 쿼리에서는 사용하지 않음. 이 파라미터를 이용해 포장 실적의 불량수량을 예외처리함.
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute


	SELECT FIN.CompanyCode
		  ,FIN.WorkCenterCode
		  ,FIN.MaterialCode
		  ,FIN.MaterialName
		  ,FIN.LineCode
		  ,FIN.LineName
		  ,FIN.RouteCode
		  ,FIN.RouteName
		  ,FIN.RouteIndex
		  ,FIN.MachineCode
		  ,FIN.MachineName
		  ,FIN.PONo
		  --,FIN.POPlanQty
		  ,FIN.JobDate
		  ,FIN.ShiftCode
		  ,FIN.Shift
		  ,FIN.TimeCode
		  --,FIN.PlanQty
		  --,FIN.InputQty
		  --,FIN.OutputQty
		  --,FIN.GoodsQty
		  --,FIN.DefectQty
		  --,FIN.RepairQty
		  --,FIN.LossQty
		  --,FIN.ProdRate
		  --,FIN.DefectRate
		  --,FIN.DefectPrice
		  ,FIN.YearMonth
	  FROM (
				SELECT  TOP 100000
						PRH.CompanyCode,
						PRH.WorkCenterCode,
						PRH.MaterialCode,
						MM.MaterialName,
						PRH.LineCode,
						LI.LineName,
						PRH.RouteCode,
						RI.RouteName,
						POR.RouteIndex,
						PRH.MachineCode,
						MCM.MachineName,
						PRH.PONo,
						ROUND(SUM(POI.PlanQty), 0) AS POPlanQty,
						CONVERT(DATETIMEOFFSET, PRH.JobDate) AS JobDate,     -- 2020.03.12 변경 (kilee)
						PRH.ShiftCode,
						SC.Shift,
						PRH.TimeCode,
						ROUND(SUM(DPP.PlanQty), 0) AS PlanQty,
						SUM(PRH.ProdQty)              AS InputQty,
						--SUM(PRH.ProdQty) - SUM(RepairInfo.DefectQty - ISNULL(RepairInfo.RepairQty, 0))            AS OutputQty,                                                                      -- 투입수량 (kilee, 2020.03.25)
						--CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
						--	 THEN SUM(PRH.ProdQty) 
						--	 ELSE (SUM(PRH.ProdQty) - SUM(RepairInfo.DefectQty - ISNULL(RepairInfo.RepairQty, 0))) END AS GoodsQty,            -- 생산수량  (kilee, 2020.03.25) #211202
						--CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
						--	 THEN 0
						--	 ELSE SUM(RepairInfo.DefectQty - ISNULL(RepairInfo.RepairQty, 0))  END AS DefectQty, --#211202
						--SUM(RepairInfo.RepairQty)             AS RepairQty,
						--SUM(RepairInfo.LossQty)                AS LossQty,
						CASE WHEN ISNULL(SUM(DPP.PlanQty),0) = 0    THEN 0.0 ELSE SUM(PRH.ProdQty) / SUM(DPP.PlanQty) * 100.0   END AS ProdRate
						--, CASE WHEN ISNULL(SUM(PRH.ProdQty),0) = 0 
						--	 THEN 0.0 
						--	 ELSE CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
						--			   THEN 0
						--			   ELSE SUM(RepairInfo.DefectQty - ISNULL(RepairInfo.RepairQty, 0)) END / SUM(PRH.ProdQty) * 100.0 
						--	 END AS DefectRate --#211202  
					  --, dbo.fnGetWastePrice(PRH.LineCode, PRH.RouteCode, PRH.MaterialCode, SUM(ISNULL(RepairInfo.DefectQty, 0) - ISNULL(RepairInfo.RepairQty, 0))) AS DefectPrice

					  ,  (	 SELECT  BaseMonth
							 FROM STB_AggregationPeriod
							 WHERE 1=1										   
							  AND  FromDate  <= PRH.JobDate
							  AND  ToDate     >=PRH.JobDate
													)  as YearMonth
					   ,MAX(dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset)) AS ProdDateTime
					   ,LAG(MAX(dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset)))
								OVER(ORDER BY PRH.JobDate ,SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
																			THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
				FROM
						STB_ProdRouteHist PRH WITH(NOLOCK)
						LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = PRH.ControlNo
						LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)   ON LI.LineCode = PRH.LineCode
						LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)  ON RI.RouteCode = PRH.RouteCode
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)  ON MCM.MachineCode = PRH.MachineCode
						LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = PRH.MaterialCode
						LEFT OUTER JOIN VW_ShiftCode SC ON SC.ShiftCode = PRH.ShiftCode
						LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK) ON POR.PONo = PRH.PONo AND POR.RouteCode = PRH.RouteCode
						LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = PRH.PONo
						LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.PONo = PRH.PONo AND DPP.LineCode = PRH.LineCode AND DPP.PlanDate = PRH.JobDate AND DPP.PlanShiftCode = PRH.ShiftCode
						LEFT OUTER JOIN (
												SELECT ControlNo
											          ,FindRouteCode
													  --,ISNULL(SUM(RepairQty), 0) AS RepairQty
													  --,ISNULL(SUM(DefectQty), 0) AS DefectQty
													  --,ISNULL(SUM(LossQty), 0) AS LossQty
												  FROM STB_DefectRepairInfo
												 WHERE RepairType NOT IN ('MISSING') -- #20200129
												 GROUP BY ControlNo, FindRouteCode
											) RepairInfo
						    ON RepairInfo.ControlNo = PRH.ControlNo
						   AND RepairInfo.FindRouteCode = PRH.RouteCode
				WHERE 1=1                                                                                          -- MES 등록한것만 (2019.07.15)
				 AND PRH.CompanyCode = @CompanyCode 		  
				 AND PRH.WorkCenterCode = @WorkCenterCode 
				 AND (@LineCode = '*' OR PRH.LineCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @LineCode)))
				 AND (@MaterialCode = '*' OR PRH.MaterialCode LIKE @MaterialCode)
				 AND (PRH.ProdDateTime BETWEEN @FromDate AND @ToDate)
				GROUP BY
						PRH.RouteCode,
						PRH.CompanyCode,
						PRH.WorkCenterCode,
						PRH.PONo,
						PRH.MaterialCode,
						MM.MaterialName,
						PRH.LineCode,
						LI.LineName,
						RI.RouteName,
						POR.RouteIndex,
						PRH.MachineCode,
						MCM.MachineName,
						PRH.JobDate,
						PRH.ShiftCode,
						SC.Shift,
						PRH.TimeCode,
						SI.Barcode
			  ORDER BY PRH.JobDate
					     , SI.Barcode
					     , CASE WHEN PRH.RouteCode = 'E-28' 
							       THEN 'E-99' ELSE PRH.RouteCode END
		) FIN

		WHERE FIN.ProdDateTime <> FIN.PrevProdDateTime
		  AND (@RouteCode = '*' OR FIN.RouteCode LIKE @RouteCode)
		ORDER BY FIN.JobDate
			       , CASE WHEN FIN.RouteCode = 'E-28' THEN 'E-99' ELSE FIN.RouteCode END


END