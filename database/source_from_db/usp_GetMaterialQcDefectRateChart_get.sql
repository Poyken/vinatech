
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 수입검사 불량률
-- Description:	항목별 불량 분포도
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialQcDefectRateChart_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @TotalQcInspectionItemQty Numeric(20,5)
    
	SET @TotalQcInspectionItemQty = 0

	SELECT
			@TotalQcInspectionItemQty = SUM(ISNULL(MQD.DefectSampleQty,0))
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			INNER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK)
				ON MQI.MaterialQcNo = MQD.MaterialQcNo
	WHERE
			((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode)) AND
			(CONVERT(DATE,MQI.CreateDateTime) >= @FromDate AND CONVERT(DATE,MQI.CreateDateTime) <= @ToDate) AND
			MQD.DecisionResult = 'Reject'

	;WITH CTE_MQD AS
	(
		SELECT					
				MQD.QcInspectionItemCode,
				MQD.QcInspectionItemName,
				ISNULL(MQD.DefectSampleQty,0) AS QcInspectionItemQty
		FROM
				STB_MaterialQcInfo MQI WITH(NOLOCK)
				INNER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK)
					ON MQI.MaterialQcNo = MQD.MaterialQcNo
				LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
					ON MDD.MaterialIqcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
					ON MDI.MaterialDocNo = MDD.MaterialDocNo
				
		WHERE
				((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode)) AND
				(CONVERT(DATE,MQI.CreateDateTime) >= @FromDate AND CONVERT(DATE,MQI.CreateDateTime) <= @ToDate) AND
				MQD.DecisionResult = 'Reject'

	)

	SELECT
			QcInspectionItemName,
			CASE WHEN @TotalQcInspectionItemQty = 0 THEN 0 
			ELSE SUM(QcInspectionItemQty)/@TotalQcInspectionItemQty*100
			END QcInspectionItemRate
	FROM 
			CTE_MQD
	GROUP BY
			QcInspectionItemName
END

