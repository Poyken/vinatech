-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	기종변경을 위한 PO를 불러옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionOrderForChangeMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pPlanYearMonth DATE = NULL,
	@pPOType VARCHAR(20) = 'FERT'
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@PlanYearMonth VARCHAR(7) = CASE WHEN @pPlanYearMonth IS NULL THEN '' ELSE CONVERT(VARCHAR,@pPlanYearMonth) END,
			@POType VARCHAR(20) = @pPOType

	SELECT
			POI.PONo,
			POI.CompanyCode,
			POI.WorkCenterCode,
			POI.POType,
			POI.PlanYearMonth,
			POI.MaterialCode,
			MBI.ModelName AS MaterialName,
			POI.BomVersion,
			POI.PlanQty,
			POI.ProdOrderQty,
			POI.ProdFinishQty
			--'' AS TargetMaterialCode,
			--'' AS TargetMaterialName,
			--'' AS TargetBomVersion
	FROM
			STB_ProductionOrderInfo POI WITH(NOLOCK)
			INNER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MBI.ModelCode = POI.MaterialCode
	WHERE
			POI.CompanyCode = @CompanyCode AND
			POI.WorkCenterCode = @WorkCenterCode AND
			POI.PlanYearMonth = @PlanYearMonth AND
			POI.POType = POI.POType AND
			((POI.ProdFinishQty IS NULL) OR (POI.ProdFinishQty = 0))

END


