-- =============================================
-- Author : Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-08-24
-- Description : Production Order 생산현황조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdSummaryByProductionOrder]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromYearMonth DATE  = NULL,
	@pToYearMonth DATE = NULL,
	@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@FromYearMonth VARCHAR(7) = CONVERT(VARCHAR,@pFromYearMonth,120),
			@ToYearMonth VARCHAR(7) = CONVERT(VARCHAR,ISNULL(@pToYearMonth,'9999-12-31'),120),
			@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	;WITH POInfo AS
	(
		SELECT
				POI.PONo,
				POI.CompanyCode,
				POI.WorkCenterCode,
				POI.PlanYearMonth,
				POI.POType,
				POI.IsReworkPO,
				POI.MaterialCode,
				MM.MaterialName,
				POI.PlanQty,
				POI.ProdOrderQty,
				POI.ProdFinishQty
		FROM
				STB_ProductionOrderInfo POI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = POI.MaterialCode
				LEFT OUTER JOIN STB_BasicRoutingInfo BRI WITH(NOLOCK)
					ON BRI.BasicRoutingCode = POI.BasicRoutingCode
		WHERE
				POI.CompanyCode LIKE @CompanyCode AND
				POI.WorkCenterCode LIKE @WorkCenterCode AND
				@FromYearMonth <= POI.PlanYearMonth AND
				POI.PlanYearMonth <= @ToYearMonth AND
				POI.MaterialCode LIKE @MaterialCode AND
				POI.IsCancel = 0 AND
				POI.IsFix = 1
	), ProdSummary AS
	(
		SELECT
				PRS.PONo,
				--PRS.JobDate,
				SUM(PRS.InputQty) AS InputQty,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
		WHERE
				PRS.PONo IN (
								SELECT PONo FROM POInfo
							)
		GROUP BY
				PRS.PONo
				--PRS.JobDate
	)
		SELECT
				POI.PONo,
				POI.CompanyCode,
				POI.WorkCenterCode,
				POI.PlanYearMonth,
				POI.POType,
				POI.IsReworkPO,
				POI.MaterialCode,
				POI.MaterialName,
				POI.PlanQty,
				POI.ProdOrderQty,
				--PS.JobDate,
				POI.ProdFinishQty,
				PS.OutputQty,
				PS.DefectQty,
				PS.RepairQty,
				PS.LossQty,
				POI.ProdOrderQty / POI.PlanQty * 100.0 AS ProdOrderRate,
				POI.ProdFinishQty / POI.PlanQty * 100.0 AS ProdRate,
				--PS.OutputQty / POI.PlanQty * 100.0 AS ProdRate,
				CASE
					WHEN POI.ProdFinishQty = 0 THEN 0.0
					ELSE PS.DefectQty / POI.ProdFinishQty * 100.0
				END AS DefectRate,
				CASE
					WHEN ISNULL(PS.RepairQty,0) = 0 THEN 0.0
					ELSE PS.DefectQty / PS.RepairQty * 100.0
				END AS RepairRate,
				CASE
					WHEN ISNULL(PS.LossQty,0) = 0 THEN 0.0
					ELSE POI.ProdFinishQty / PS.LossQty * 100.0
				END AS LossRate
		FROM
				POInfo POI
				LEFT OUTER JOIN ProdSummary PS
					ON PS.PONo = POI.PONo
END
