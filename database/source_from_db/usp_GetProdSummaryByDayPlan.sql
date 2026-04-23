-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 생산관리 > 일일생산현황
-- Description:	PO의 생산현황을 가져옵니다. 일일생산현황 Grid 및 Chart
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdSummaryByDayPlan]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	
	;WITH PROD AS
	(
		SELECT
				PRS.PONo,
				PRS.LineCode,
				PRS.MaterialCode,
				
				PRS.RouteCode,    --추가사항 (kilee)
			    

				PRS.JobDate,
				PRS.ShiftCode,
				0 AS PlanQty,
				SUM(PRS.InputQty) AS InputQty,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
		WHERE
				PRS.CompanyCode LIKE @CompanyCode AND
				PRS.WorkCenterCode LIKE @WorkCenterCode AND
				PRS.LineCode LIKE @LineCode AND
				PRS.MaterialCode LIKE @MaterialCode AND
				PRS.JobDate BETWEEN @FromDate AND @ToDate
		GROUP BY
				PRS.PONo,
				PRS.LineCode,
				PRS.MaterialCode,
				PRS.JobDate,
				PRS.RouteCode,
				PRS.ShiftCode
		UNION ALL



		SELECT
				DPP.PONo,
				DPP.LineCode,
				DPP.MaterialCode,
				DPP.ROUTECODE,       --kilee추가
				DPP.PlanDate,
				DPP.PlanShiftCode,
				SUM(DPP.PlanQty) AS PlanQty,
				0 AS InputQty,
				0 AS OutputQty,
				0 AS DefectQty,
				0 AS RepairQty,
				0 AS LossQty
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE
				DPP.CompanyCode LIKE @CompanyCode AND
				DPP.WorkCenterCode LIKE @WorkCenterCode AND
				DPP.LineCode LIKE @LineCode AND
				DPP.MaterialCode LIKE @MaterialCode AND
				DPP.PlanDate BETWEEN @FromDate AND @ToDate
		GROUP BY
				DPP.PONo,
				DPP.LineCode,
				DPP.MaterialCode,
				DPP.PlanDate,
				DPP.RouteCode,    --추가사항 (kilee)
				DPP.PlanShiftCode
	)
		SELECT
				PROD.PONo,
				PROD.LineCode,
				LI.LineName,
				PROD.MaterialCode,
				MM.MaterialName,				
				PROD.JobDate,
				PROD.ShiftCode,
				SUM(PROD.PlanQty) AS PlanQty,
				SUM(PROD.InputQty) AS InputQty,
				SUM(PROD.OutputQty) AS OutputQty,
				SUM(PROD.DefectQty) AS DefectQty,
				SUM(PROD.RepairQty) AS RepairQty,
				SUM(PROD.LossQty) AS LossQty
			,   CASE WHEN ISNULL(SUM(PROD.PlanQty),0) = 0 THEN 0     ELSE SUM(PROD.OutputQty) / SUM(PROD.PlanQty) * 100.0	END AS ProdRate
			,	CASE WHEN ISNULL(SUM(PROD.PlanQty),0) = 0 THEN 0.0   ELSE SUM(PROD.InputQty) / SUM(PROD.PlanQty) * 100.0    END AS InputRate
			,   CASE WHEN ISNULL(SUM(PROD.OutputQty),0) = 0 THEN 0.0 ELSE SUM(PROD.DefectQty) / SUM(PROD.OutputQty) * 100.0 END AS DefectRate
			,	CASE WHEN ISNULL(SUM(PROD.RepairQty),0) = 0 THEN 0.0 ELSE SUM(PROD.DefectQty) / SUM(PROD.RepairQty) * 100.0 END AS RepairRate
			,	CASE WHEN ISNULL(SUM(PROD.LossQty),0) = 0 THEN 0.0   ELSE SUM(PROD.OutputQty) / SUM(PROD.LossQty) * 100.0   END AS LossRate
		FROM
				PROD	LEFT OUTER JOIN VW_ShiftCode SC			            ON SC.ShiftCode = PROD.ShiftCode
						LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)		ON LI.LineCode = PROD.LineCode
				        LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = PROD.MaterialCode
		GROUP BY
				PROD.PONo,
				PROD.LineCode,
				LI.LineName,
				PROD.MaterialCode,
				MM.MaterialName,
				PROD.JobDate,
				PROD.ShiftCode
				
		ORDER BY
				PROD.LineCode,
				PROD.MaterialCode,
				PROD.JobDate
END
