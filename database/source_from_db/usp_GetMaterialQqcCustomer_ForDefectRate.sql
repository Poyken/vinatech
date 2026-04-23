-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-28
-- Browsable : true
-- Group : 수입검사 불량률
-- Description:	업체별 수입검사 불량률
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialQqcCustomer_ForDefectRate]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
	WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate

	;WITH MTIQ AS
	(
		SELECT
				MQI.MaterialQcNo,
				MDD.MaterialCode,
				CI.CustomerCode,
				CI.CustomerName,
				dbo.fnConvertDateTimeToVarchar('mm',MQI.CreateDateTime) AS ArriveMonth,
				MQI.QcQty,
				MIQD.QcInspectionItemCode,
				MIQD.QcInspectionItemName,
				MIQD.QcInspectionItemDesc,
				ISNULL(MQI.DefectSampleQty,0) AS DefectQty
		FROM
				STB_MaterialQcInfo MQI WITH(NOLOCK)
				LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
					ON MDD.MaterialIqcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)
					ON MDI.MaterialDocNo = MDD.MaterialDocNo
				LEFT OUTER JOIN STB_MaterialQcDetail MIQD WITH(NOLOCK)
					ON MIQD.MaterialQcNo = MQI.MaterialQcNo
				LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
					ON CI.CustomerCode = MDI.SourceCustomerCode
		WHERE
				((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) AND
				((@WorkCenterCode = '*') OR (MQI.WorkCenterCode = @WorkCenterCode)) AND
				(CONVERT(DATE,MQI.CreateDateTime) >= @FromDate AND CONVERT(DATE,MQI.CreateDateTime) <= @ToDate)
	)
		SELECT
				RANK() OVER (ORDER BY SUM(MTIQ.DefectQty) DESC) AS Ranking,
				MTIQ.CustomerCode,
				MTIQ.CustomerName,
				SUM(MTIQ.DefectQty) AS DefectQty,
				CASE 
					WHEN (SELECT SUM(DefectQty) FROM MTIQ) = 0 THEN 0.0
					ELSE SUM(MTIQ.DefectQty) * 100.0 / (SELECT SUM(DefectQty) FROM MTIQ)
				END AS DefectRate
		FROM
				MTIQ
		WHERE
				MTIQ.DefectQty > 0
		GROUP BY
				MTIQ.CustomerCode,
				MTIQ.CustomerName
END
