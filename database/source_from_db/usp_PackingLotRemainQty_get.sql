-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2019-07-24
-- Description : Lot 잔량 조회
-- Modified : [B520] 제품박스실적입력 화면에 있는 버튼 기능
--               2019.12.19 CompanyCode 추가
-- usp_PackingLotRemainQty_get '','','VVT'
-- =============================================
CREATE PROCEDURE [dbo].[usp_PackingLotRemainQty_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL 
AS

BEGIN

    DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END               -- 2019.12.19 추가

	;WITH ProdRoute AS
	(
		SELECT
				PRH.ControlNo,
				SUM(PRH.ProdQty) AS ProdRouteQty,
				PRH.CompanyCode                                -- 2019.12.19 추가
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
						INNER JOIN STB_SetInfo SI WITH(NOLOCK)  		   ON SI.ControlNo = PRH.ControlNo
						INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)		   ON POR.PONo = SI.PONo		  AND POR.IsOutputRoute = 1		  AND POR.RouteCode = PRH.RouteCode
		WHERE 1=1
		   AND ((@CompanyCode = '*') OR (PRH.CompanyCode = @CompanyCode))                                           -- 2019.12.19 추가
		GROUP BY PRH.ControlNo
		           , PRH.CompanyCode     
	
	), 
	
	ProdDefect AS

	(
		SELECT
				DRI.ControlNo,
				SUM(DRI.DefectQty) AS DefectQty,
				SUM(DRI.LossQty) AS LossQty
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		GROUP BY
				DRI.ControlNo
	)
	SELECT
			SI.ControlNo,
			SI.DayPlanNo,
			SI.PONo,
			SI.Barcode,
			SI.MaterialCode,
			MM.MaterialName,
			POI.PlanQty AS POPlanQty,
			POR.RouteCode,
			DPP.PlanQty,
			SI.ProdQty,
			SI.ProdQty - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0)  AS RemainQty,
			ISNULL(PR.ProdRouteQty,0) AS InputQty,
			ISNULL(PR.ProdRouteQty,0) AS OutputQty,
			PD.DefectQty,
			PD.LossQty,
			MM.BasicPackingQty,
			MM.BasicPackingQty AS InProdQty,
			1 AS BarcodeCount,
			0 AS LotCount,
			CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BasicBoxQty,
			CONVERT(INT,(SI.ProdQty - ISNULL(PR.ProdRouteQty,0)) / MM.BasicPackingQty) AS BoxQty,
			'' AS StockAttrib1
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK) ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN ProdRoute PR ON PR.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	ON POR.PONo = SI.PONo AND POR.IsOutputRoute = 1
			LEFT OUTER JOIN ProdDefect PD ON PD.ControlNo = SI.ControlNo
	WHERE SI.ProdQty - ISNULL(PR.ProdRouteQty,0) - ISNULL(PD.DefectQty, 0) > 0
	  AND SI.Barcode IN (SELECT LotNo FROM STB_MaterialLotInfo)	  
	  AND ((@CompanyCode = '*') OR (PR.CompanyCode = @CompanyCode))                                           -- 2019.12.19 추가
	ORDER BY Barcode


END
