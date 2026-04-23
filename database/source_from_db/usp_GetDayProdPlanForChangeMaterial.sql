-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	기종변경을 위한 일일계획를 불러옵니다
-- =============================================
-- exec usp_GetDayProdPlanForChangeMaterial '','','VVT','VVT_F1','','2025-05-01','2025-05-10','','MVVPN096R050402'
CREATE PROCEDURE [dbo].[usp_GetDayProdPlanForChangeMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pPOType VARCHAR(20) = 'FERT',
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END,
			@FromDate DATE = @pFromDate,
			@ToDate DATE = @pToDate,
			@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '*' ELSE @pBarcode END
		   declare  @POType VARCHAR(20) = case when @CompanyCode='VVT' and @Barcode like 'M%' then 'MODULE' else @pPOType end -- thêm phần chuyển hàng module
		   print @WorkCenterCode
	;WITH DayProdPlan AS
	(
		SELECT
				DPP.DayPlanNo,
				DPP.PONo,
				DPP.CompanyCode,
				CI.CompanyName,
				DPP.WorkCenterCode,
				WCI.WorkCenterName,
				DPP.MaterialCode,
				MBI.ModelName AS MaterialName,
				DPP.BomVersion,
				DPP.PlanQty
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
				INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
					ON MBI.ModelCode = DPP.MaterialCode
				INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
					ON POI.PONo = DPP.PONo AND
					POI.POType = @POType
				INNER JOIN STB_CompanyInfo CI WITH(NOLOCK)
					ON CI.CompanyCode = DPP.CompanyCode
				INNER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON WCI.WorkCenterCode = DPP.WorkCenterCode
		WHERE
				DPP.CompanyCode = @CompanyCode AND
				DPP.WorkCenterCode = @WorkCenterCode AND
				(@LineCode = '*' OR DPP.LineCode = @LineCode) AND
				DPP.PlanDate >= @FromDate AND
				DPP.PlanDate <= @ToDate AND
				DPP.IsFixed = 1 AND
				DPP.IsCancel = 0 AND
				(@Barcode = '*' OR DPP.DayPlanNo IN (SELECT DayPlanNo 
													   FROM STB_SetInfo 
													  WHERE Barcode LIKE @Barcode+'%'))
	),PRH AS
	(
		SELECT
				PRH.DayPlanNo,
				SUM(PRH.ProdQty) AS ProdQty
		FROM
				DayProdPlan DPP
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
					ON POR.PONo = DPP.PONo AND
					POR.IsOutputRoute = 1
				INNER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)
					ON DPP.DayPlanNo = PRH.DayPlanNo AND
					PRH.RouteCode = POR.RouteCode
		GROUP BY
				PRH.DayPlanNo
	) 
		SELECT
				DPP.DayPlanNo,
				DPP.PONo,
				DPP.CompanyCode,
				DPP.CompanyName,
				DPP.WorkCenterCode,
				DPP.WorkCenterName,
				DPP.MaterialCode,
				DPP.MaterialName,
				DPP.BomVersion,
				DPP.PlanQty,
				PRH.ProdQty
		FROM
				DayProdPlan DPP
				LEFT OUTER JOIN PRH
					ON PRH.DayPlanNo = DPP.DayPlanNo
END
--select * from STB_DayProdPlan where DayPlanNo='2024041800017'

-- select * from STB_SetInfo where ControlNo='20240418000132'
-- select * from STB_SetInfo where ControlNo='20240418000131'
--select * from STB_SetInfo where ControlNo='20240418000130'

--select * from STB_SetInfo where DayPlanNo='2024041800017'

--SELECT DayPlanNo FROM STB_SetInfo 
--													  WHERE Barcode ='VVOM183R070501'

--select* from STB_DayProdPlan where DayPlanNo='VVOM183R070501'


--SELECT DayPlanNo 
--													   FROM STB_SetInfo 
--													  WHERE Barcode LIKE 'VVOM183R070501'