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
-- ================================================================================

CREATE PROCEDURE [dbo].[usp_GetProdRouteSummary_VNT]
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

	-- 임시테이블이 존재하면 삭제하고
	IF OBJECT_ID('tempdb.dbo.#ProdRouteSummy') is not null BEGIN
		DROP TABLE #ProdRouteSummy
	END

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
		  ,FIN.POPlanQty
		  ,CONVERT(CHAR(10), FIN.JobDate, 121) AS JobDate
		  ,FIN.ShiftCode
		  ,FIN.Shift
		  ,FIN.TimeCode
		  ,FIN.PlanQty
		  ,FIN.InputQty
		  ,FIN.OutputQty
		  ,FIN.GoodsQty
		  ,FIN.DefectQty
		  ,FIN.RepairQty
		  ,FIN.LossQty
		  ,FIN.ProdRate
		  ,FIN.DefectRate
		  ,FIN.DefectPrice
		  ,FIN.YearMonth
	  INTO #ProdRouteSummy
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
						ROUND(POI.PlanQty, 0) AS POPlanQty,
						CASE WHEN CONVERT(CHAR(8), dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset), 108) <= '08:29:59' 
						     THEN DATEADD(day, -1, dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset)) 
							 ELSE dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset) END AS JobDate,
						PRH.ShiftCode,
						SC.Shift,
						PRH.TimeCode,
						ROUND(DPP.PlanQty, 0) AS PlanQty,
						PRH.ProdQty           AS InputQty,
						PRH.ProdQty           AS OutputQty,                                                                      -- 투입수량 (kilee, 2020.03.25)
						CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
							 THEN PRH.ProdQty 
							 ELSE PRH.ProdQty - ISNULL(DRI.DefectQty,0) END AS GoodsQty,            -- 생산수량  (kilee, 2020.03.25) #211202
						CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
							 THEN 0
							 ELSE ISNULL(DRI.DefectQty,0)  END AS DefectQty, --#211202
						0             AS RepairQty,
						0             AS LossQty,
						CASE WHEN ISNULL(DPP.PlanQty,0) = 0    THEN 0.0 ELSE PRH.ProdQty / DPP.PlanQty * 100.0   END AS ProdRate,
						CASE WHEN ISNULL(PRH.ProdQty,0) = 0 
							 THEN 0.0 
							 ELSE (CASE WHEN @IsOutputRoute = CONVERT(BIT, 1) AND PRH.RouteCode IN ('E-28', 'V-28') 
									   THEN 0
									   ELSE ISNULL(DRI.DefectQty,0) END / PRH.ProdQty) * 100.0 
							 END AS DefectRate --#211202  
					  , 0 AS DefectPrice

					  ,  (	 SELECT  BaseMonth
							 FROM STB_AggregationPeriod
							 WHERE 1=1										   
							  AND  FromDate <= dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset)
							  AND  ToDate >= dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset)
													)  as YearMonth
					   ,dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset) AS ProdDateTime
					   ,LAG(dbo.fnGetLocalTime(PRH.ProdDateTime, @pUtcOffset))
								OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 
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
						LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = PRH.DayPlanNo
						LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty) AS DefectQty 
												  FROM STB_DefectRepairInfo  WITH(NOLOCK) 
												 WHERE RepairType = 'NONE'
												 GROUP BY ControlNo, FindRouteCode
											  ) DRI	                                              
								ON PRH.ControlNo = DRI.ControlNo        
								AND PRH.RouteCode = DRI.FindRouteCode
				WHERE 1=1
				 AND PRH.CompanyCode = @CompanyCode 		  
				 AND PRH.WorkCenterCode = @WorkCenterCode 
				 AND (@LineCode = '*' OR PRH.LineCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @LineCode)))
				 AND (@MaterialCode = '*' OR PRH.MaterialCode LIKE @MaterialCode)
				 AND (PRH.ProdDateTime BETWEEN @FromDate AND @ToDate)
			  ORDER BY SI.Barcode
					  ,CASE WHEN PRH.RouteCode = 'E-28' 
							THEN 'E-99' ELSE PRH.RouteCode END
		) FIN
		WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
		  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
		  AND (@RouteCode = '*' OR FIN.RouteCode = @RouteCode)
		ORDER BY FIN.JobDate
			    ,CASE WHEN FIN.RouteCode = 'E-28' THEN 'E-99' ELSE FIN.RouteCode END

		-- 최종쿼리

		SELECT PRS.CompanyCode
			  ,PRS.WorkCenterCode
			  ,PRS.MaterialCode
			  ,PRS.MaterialName
			  ,PRS.LineCode
			  ,PRS.LineName
			  ,PRS.RouteCode
			  ,PRS.RouteName
			  ,PRS.RouteIndex
			  ,PRS.MachineCode
			  ,PRS.MachineName
			  ,PRS.PONo
			  ,PRS.POPlanQty
			  ,CONVERT(CHAR(10), PRS.JobDate, 121) AS JobDate
			  ,PRS.ShiftCode
			  ,PRS.Shift
			  ,PRS.TimeCode
			  ,PRS.PlanQty
			  ,PRS.InputQty
			  ,PRS.OutputQty
			  ,PRS.GoodsQty
			  ,PRS.DefectQty
			  ,PRS.RepairQty
			  ,PRS.LossQty
			  ,PRS.ProdRate
			  ,CASE WHEN PDS.InputQty = 0 THEN 0 ELSE (PDS.DefectQty / PDS.InputQty) * 100 END AS DefectRate
			  ,PRS.DefectPrice
			  ,PRS.YearMonth
		  FROM #ProdRouteSummy PRS
		  LEFT OUTER JOIN (
			SELECT MaterialCode
			      ,LineCode
				  ,RouteCode
				  ,JobDate
				  ,SUM(InputQty) AS InputQty
				  ,SUM(DefectQty) AS DefectQty
			  FROM #ProdRouteSummy
			 GROUP BY MaterialCode
					 ,LineCode
					 ,RouteCode
					 ,JobDate
		  ) PDS
		  ON PDS.MaterialCode = PRS.MaterialCode
		 AND PDS.LineCode = PRS.LineCode
		 AND PDS.RouteCode = PRS.RouteCode
		 AND PDS.JobDate = PRS.JobDate
END