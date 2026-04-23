
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-29
-- Browsable : true
-- Group : 품질관리
-- Description: 출하검사 Lot생성을 위한 Set정보를 조회합니다.
-- Modified: 2019.07.20 바코드추가

-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='yjyu',@pProcessLanguage='Korean',@pCompanyCode='VNT',@pWorkCenterCode='VNT_F1',@pLineCode=default,@pRouteCode=''

-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='yjyu',@pProcessLanguage='Korean',@pCompanyCode='VNT',@pWorkCenterCode='VNT_F1',@pLineCode=default,@pRouteCode='',@pBarCode = 'VJJU202R718605'
-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='yjyu',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode=default,@pRouteCode='V-27'
-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='yjyu',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='VVC-01',@pRouteCode='V-22',@pBarCode = ''
-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pRouteCode='V-22',@pBarCode = 'VVKK093R033504'      ---베트남 제품검사 LOT관리 (되는것)
-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pRouteCode='',@pBarCode = 'VVKK122R740611'      ---베트남 제품검사 LOT관리 (안되는것)

-- EXEC usp_GetSetListForOqcLot_VNT @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pBarCode = 'VVKK083R025601'      ---베트남 제품검사 LOT관리 (안되는것)

-- =============================================
-- 513
--select * from STB_ProdRouteHist where RouteCode = ''


CREATE PROCEDURE [dbo].[usp_GetSetListForOqcLot_VVT_20200221]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	--@pRouteCode VARCHAR(20) = NULL,             -- 베트남법인 문제로 제외 (2020.02.12 kilee)
	@pBarCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	--DECLARE @RouteCode VARCHAR(20)        = @pRouteCode                                                                                                -- 베트남법인 문제로 제외 (2020.02.12 kilee)
	DECLARE @BarCode VARCHAR(20)           = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE @pBarCode END

	;WITH SetList AS
	(
		SELECT
				DISTINCT
				LI.CompanyCode,
				SI.ControlNo,
				SI.PONo,
				SI.InputLineCode,
				MBI.ModelName,
				LI.LineName,
				POR.RouteIndex,
				POR.RouteCode,
				SI.Barcode
		FROM
				STB_SetInfo SI WITH(NOLOCK)
				INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)				ON POI.PONo = SI.PONo
				--INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND					POR.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND					POR.RouteCode IN ('E-22','V-22')
				INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)					ON MBI.ModelCode = SI.MaterialCode AND					MBI.InspectionType NOT IN ('NONE')
				LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)					        ON LI.LineCode = SI.InputLineCode
				--INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo AND					PRH.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
				--INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo AND					PRH.RouteCode IN ('E-22','V-22')
		WHERE 1=1
				--AND ((@CompanyCode = '*') OR (POI.CompanyCode = @CompanyCode))                             -- 추가 용은재 (2020.01.23)
				--AND POI.WorkCenterCode LIKE @WorkCenterCode 
				--AND SI.InputLineCode LIKE @LineCode 
				--AND (SI.LotNumber IS NULL OR SI.LotNumber = '')
				AND SI.Barcode LIKE @Barcode 				


	), ProdRouteHist AS
	(
		SELECT
				SL.ControlNo,
				SUM(PRH.ProdQty) AS ProdQty
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
				INNER JOIN SetList SL					ON SL.ControlNo = PRH.ControlNo       --AND					SL.RouteCode = PRH.RouteCode
		GROUP BY
				SL.ControlNo
	
	
	), ProductMachine AS
	(
		SELECT
				SL.ControlNo,
				POR.RouteCode,
				PM.MachineCode,
				POR.RouteIndex
		FROM
				SetList SL
				INNER JOIN       STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SL.PONo AND					POR.RouteIndex <= SL.RouteIndex
				LEFT OUTER JOIN STB_ProductMachine PM WITH(NOLOCK)					ON PM.LineCode = SL.InputLineCode    --AND					PM.RouteCode = POR.RouteCode
	
	), RouteMachine AS
	(
		SELECT
				PM.ControlNo,
				PM.RouteIndex,
				PM.RouteCode,
				CASE WHEN ISNULL(PM.MachineCode,'') = '' THEN PRH.MachineCode ELSE PM.MachineCode END AS MachineCode
		FROM
				ProductMachine PM
				LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)			ON PRH.ControlNo = PM.ControlNo                        --AND					PRH.RouteCode = PM.RouteCode
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)		ON MCM.MachineCode = PRH.MachineCode
	)

	SELECT
			CASE WHEN SL.ComPanyCode = 'VNT' THEN '전주본사'
			WHEN SL.ComPanyCode = 'VVT' THEN '베트남' ELSE 'VietNam' END   AS 사업장,
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode AS ModelCode,
			SL.ModelName,
			SI.Barcode,
			SI.InputLineCode,
			SL.LineName AS InputLineName,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotDecisionResult,
			SI.LotCreateDateTime,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.GradeCode,
			SI.ProdQty AS LotQty,
			PRH.ProdQty,
			CASE	WHEN SI.SIExtInt01 IS NULL THEN '정상제품'
				    WHEN SI.SIExtInt01 = 0      THEN '검사부적합 이력제품'
				    WHEN SI.SIExtInt01 = 1      THEN '검사부적합품'		END    AS RouteTestResult
			/*
			(
				SELECT
						MCM.MachineName
				FROM
						RouteMachine RM
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)							ON MCM.MachineCode = RM.MachineCode
				WHERE
						RM.ControlNo = SL.ControlNo AND
						RM.RouteIndex = 1
			) AS MachineName1,

			(
				SELECT
						MCM.MachineName
				FROM
						RouteMachine RM
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)
							ON MCM.MachineCode = RM.MachineCode
				WHERE
						RM.ControlNo = SL.ControlNo AND
						RM.RouteIndex = 2
			) AS MachineName2,

			(
				SELECT
						MCM.MachineName
				FROM
						RouteMachine RM
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)							ON MCM.MachineCode = RM.MachineCode
				WHERE 1=1
				   AND RM.ControlNo = SL.ControlNo 
				   AND RM.RouteIndex = 3
			) AS MachineName3,

			(
				SELECT
						MCM.MachineName
				FROM
						RouteMachine RM
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)							ON MCM.MachineCode = RM.MachineCode
				WHERE
						RM.ControlNo = SL.ControlNo AND
						RM.RouteIndex = 4
			) AS MachineName4,

			(
				SELECT
						MCM.MachineName
				FROM
						RouteMachine RM
						LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)
							ON MCM.MachineCode = RM.MachineCode
				WHERE
						RM.ControlNo = SL.ControlNo AND
						RM.RouteIndex = 5
			) AS MachineName5
			*/
	FROM
			SetList SL
			INNER JOIN        STB_SetInfo     SI WITH(NOLOCK)	 ON SI.ControlNo = SL.ControlNo
			LEFT OUTER JOIN ProdRouteHist PRH				     ON PRH.ControlNo = SL.ControlNo
   WHERE 1=1                                  
			
END