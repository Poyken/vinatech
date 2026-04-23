
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create Date: 2022-03-30
-- Browsable : True
-- Group : 생산관리 > 생산실적 > [B759] LOT Merge
-- Description: 
-- Modified:  제품검사 usp_GetSetListForOqcLot_VNT와 비슷한 조회 프로시저

-- 프로시저 실행부분
-- usp_CreateMergeLot_get @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VVT',@pWorkCenterCode='VVT_F1',@pLineCode='',@pRouteCode='V-22',@pBarCode = 'VVKK093R033504'  --베트남 제품검사 LOT관리 (되는것)
-- usp_CreateMergeLot_get @pProcessUserID='kilee',@pProcessLanguage='Korean',@pCompanyCode='VNT',@pWorkCenterCode='VNT_F1',@pLineCode='',@pRouteCode='',@pBarCode = 'VJKS092R750655'       
-- ====================================================================================================================================================
CREATE PROCEDURE [dbo].[usp_CreateMergeLot_get]
							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pCompanyCode VARCHAR(20) = NULL,
							@pWorkCenterCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(20) = NULL,
							@pRouteCode VARCHAR(20) = NULL,             
							@pBarCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @RouteCode VARCHAR(20)        = @pRouteCode                                                                                                -- 베트남법인 문제로 제외 (2020.02.12 kilee)
	DECLARE @BarCode VARCHAR(20)           = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE RTRIM(LTRIM(@pBarCode)) END
	DECLARE @NewBarchar VARCHAR(20)

	SELECT @NewBarchar = NewBarcode  
	  FROM STB_LotChangeMaterialHistory
	 WHERE OldBarcode = @Barcode

	-- SetList 
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
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		ON POR.PONo = SI.PONo AND					POR.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
				INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)					ON MBI.ModelCode = SI.MaterialCode AND					MBI.InspectionType NOT IN ('NONE')
				LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)					        ON LI.LineCode = SI.InputLineCode
				INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)					   ON PRH.ControlNo = SI.ControlNo AND					PRH.RouteCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@RouteCode))
		WHERE 1=1
				AND ((@CompanyCode = '*') OR (POI.CompanyCode = @CompanyCode))                             -- 추가 용은재 (2020.01.23)
				AND POI.WorkCenterCode LIKE @WorkCenterCode 
				AND SI.InputLineCode LIKE @LineCode 
				AND (SI.LotNumber IS NULL OR SI.LotNumber = '')				                                                                                                                                      -- 원본백업    
				AND (SI.Barcode = @Barcode OR SI.Barcode = @NewBarchar)            -- 2020.04.17 추가 (기종변경 바코드추가)

	), ProdRouteHist AS
	(
		SELECT
				SL.ControlNo,
				SUM(PRH.ProdQty) AS ProdQty
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
				INNER JOIN SetList SL					ON SL.ControlNo = PRH.ControlNo       AND					SL.RouteCode = PRH.RouteCode
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
				INNER JOIN       STB_ProductionOrderRouting POR WITH(NOLOCK)	 ON POR.PONo = SL.PONo AND					POR.RouteIndex <= SL.RouteIndex
				LEFT OUTER JOIN STB_ProductMachine PM WITH(NOLOCK)			 ON PM.LineCode = SL.InputLineCode    AND					PM.RouteCode = POR.RouteCode
	
	), RouteMachine AS
	(
		SELECT
				PM.ControlNo,
				PM.RouteIndex,
				PM.RouteCode,
				CASE WHEN ISNULL(PM.MachineCode,'') = '' THEN PRH.MachineCode ELSE PM.MachineCode END AS MachineCode
		FROM
				ProductMachine PM
				LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)	ON PRH.ControlNo = PM.ControlNo            AND PRH.RouteCode = PM.RouteCode
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)	ON MCM.MachineCode = PRH.MachineCode
	)

	SELECT
			CASE WHEN SL.ComPanyCode = 'VNT' THEN '전주본사'
			        WHEN SL.ComPanyCode = 'VVT' THEN '베트남' ELSE 'Vietnam' END   AS 사업장,
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
			PRH.ProdQty
			--CASE	WHEN SI.SIExtInt01 IS NULL THEN '정상제품'
			--	    WHEN SI.SIExtInt01 = 0      THEN '검사부적합 이력제품'
			--	    WHEN SI.SIExtInt01 = 1      THEN '검사부적합품'		END    AS RouteTestResult
	FROM
			SetList SL
			INNER JOIN        STB_SetInfo     SI WITH(NOLOCK)	 ON SI.ControlNo = SL.ControlNo
			LEFT OUTER JOIN ProdRouteHist PRH				     ON PRH.ControlNo = SL.ControlNo
   WHERE 1=1                                  
			
END