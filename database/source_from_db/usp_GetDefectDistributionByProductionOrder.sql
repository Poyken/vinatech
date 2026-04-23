-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-04-23
-- Browsable : true
-- Group : 품질관리
-- Description:	불량 유형 분포도
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectDistributionByProductionOrder]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromYearMonth DATE  = NULL,
	@pToYearMonth DATE = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@FromYearMonth VARCHAR(7) = CONVERT(VARCHAR,@pFromYearMonth,120),
			@ToYearMonth VARCHAR(7) = CONVERT(VARCHAR,ISNULL(@pToYearMonth,'9999-12-31'),120),
			@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			@PONo VARCHAR(20) = CASE WHEN ISNULL(@pPONo,'') = '' THEN '%' ELSE @pPONo END

	SELECT
			DRI.DefectCode,
			DI.BasicDefectName,
			SUM(DRI.DefectQty) AS DefectQty
	FROM
			STB_ProductionOrderInfo POI WITH(NOLOCK)
			INNER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
				ON DRI.PONo = POI.PONo
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON DI.DefectCode = DRI.DefectCode
	WHERE
			POI.CompanyCode LIKE @CompanyCode AND
			POI.WorkCenterCode LIKE @WorkCenterCode AND
			@FromYearMonth <= POI.PlanYearMonth AND
			POI.PlanYearMonth <= @ToYearMonth AND
			POI.MaterialCode LIKE @MaterialCode AND
			POI.PONo LIKE @PONo AND
			POI.IsCancel = 0 AND
			POI.IsFix = 1 AND
			((DRI.RepairType IS NULL) OR (DRI.RepairType IN ('NONE','FINISH','LOSS')))
	GROUP BY
			DRI.DefectCode,
			DI.BasicDefectName
END
