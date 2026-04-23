
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 수입검사 불량률
-- Description:	수입검사 불량률 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialQcDefectRate_get]
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
    
	;WITH CTE_MQI AS
	(
		SELECT
				dbo.fnConvertDateTimeToVarchar('mm',MQI.CreateDateTime) AS ArriveMonth,
				ISNULL(MQI.QcQty,0) AS ArriveQty,
				ISNULL(MQI.DefectSampleQty,0) AS DefectQty
		FROM
				STB_MaterialQcInfo MQI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
					ON MDD.MaterialIqcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
					ON MDI.MaterialDocNo = MDD.MaterialDocNo
		WHERE
				((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode)) AND
				(CONVERT(DATE,MQI.CreateDateTime) >= @FromDate AND CONVERT(DATE,MQI.CreateDateTime) <= @ToDate)
	)

	SELECT
			CTE_MQI.ArriveMonth,
			SUM(ArriveQty) AS ArriveQty,
			SUM(DefectQty) AS DefectQty,
			CASE	WHEN SUM(ArriveQty) = 0 THEN 0.0
					ELSE SUM(DefectQty)/SUM(ArriveQty)*100.0
			END DefectRate
	FROM
			CTE_MQI
	GROUP BY
			CTE_MQI.ArriveMonth
			


END

