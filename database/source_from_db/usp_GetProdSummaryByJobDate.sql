-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 생산관리
-- Description:	PO의 생산현황을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdSummaryByJobDate]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo

	SELECT
			POI.PONo,
			PRS.LineCode,
			LI.LineName,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode,
			POI.PlanQty,
			DPP.PlanQty AS DayPlanQty,
			SUM(PRS.InputQty) AS InputQty,
			SUM(PRS.OutputQty) AS OutputQty,
			SUM(PRS.DefectQty) AS DefectQty,
			SUM(PRS.RepairQty) AS RepairQty,
			SUM(PRS.LossQty) AS LossQty,
			--SUM(PRS.OutputQty) / POI.PlanQty * 100.0 AS ProdRate,
			--CASE
			--	WHEN ISNULL(POI.PlanQty,0) = 0 THEN 0.0
			--	ELSE SUM(PRS.InputQty) / POI.PlanQty * 100.0
			--END AS InputRate,
			--CASE
			--	WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0
			--	ELSE SUM(PRS.DefectQty) / SUM(PRS.OutputQty) * 100.0
			--END AS DefectRate,
			--CASE
			--	WHEN ISNULL(SUM(PRS.RepairQty),0) = 0 THEN 0.0
			--	ELSE SUM(PRS.DefectQty) / SUM(PRS.RepairQty) * 100.0
			--END AS RepairRate,
			--CASE
			--	WHEN ISNULL(SUM(PRS.LossQty),0) = 0 THEN 0.0
			--	ELSE SUM(PRS.OutputQty) / SUM(PRS.LossQty) * 100.0
			--END AS LossRate
			CASE
				WHEN ISNULL(DPP.PlanQty,0) = 0 THEN 0
				ELSE SUM(PRS.OutputQty) / DPP.PlanQty * 100.0
			END AS ProdRate,
			CASE
				WHEN ISNULL(DPP.PlanQty,0) = 0 THEN 0.0
				ELSE SUM(PRS.InputQty) / DPP.PlanQty * 100.0
			END AS InputRate,
			CASE
				WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0
				ELSE SUM(PRS.DefectQty) / SUM(PRS.OutputQty) * 100.0
			END AS DefectRate,
			CASE
				WHEN ISNULL(SUM(PRS.RepairQty),0) = 0 THEN 0.0
				ELSE SUM(PRS.DefectQty) / SUM(PRS.RepairQty) * 100.0
			END AS RepairRate,
			CASE
				WHEN ISNULL(SUM(PRS.LossQty),0) = 0 THEN 0.0
				ELSE SUM(PRS.OutputQty) / SUM(PRS.LossQty) * 100.0
			END AS LossRate

	FROM
			STB_ProductionOrderInfo POI WITH(NOLOCK)
			INNER JOIN STB_ProdRouteSummary PRS WITH(NOLOCK)
				ON PRS.PONo = POI.PONo
			LEFT OUTER JOIN VW_ShiftCode SC
				ON SC.ShiftCode = PRS.ShiftCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = PRS.LineCode
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
				ON DPP.PONo = POI.PONo AND
				DPP.LineCode = PRS.LineCode AND
				DPP.PlanDate = PRS.JobDate
	WHERE
			POI.PONo = @PONo
	GROUP BY
			POI.PONo,
			POI.PlanQty,
			PRS.LineCode,
			LI.LineName,
			DPP.PlanQty,
			PRS.JobDate,
			PRS.ShiftCode,
			SC.Shift,
			PRS.TimeCode
END
