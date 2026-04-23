
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수리이력상세정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairDetailInfo_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectSummaryNo VARCHAR(20) = @pDefectSummaryNo

    SELECT
			DRDI.DefectSummaryDetailNo AS OldDefectSummaryDetailNo,
			DRDI.DefectSummaryDetailNo,
			DRDI.DefectSummaryNo,
			DRI.PONo,
			DRI.DayPlanNo,
			DRI.ControlNo,
			DRI.MaterialCode,
			DRI.FindRouteCode,
			DRDI.CauseLineCode,
			LI.LineName AS CauseLineName,
			DRDI.DefectCauseCode,
			DCI.BasicDefectCauseName AS DefectCauseName,
			DRDI.DefectCauseDetailCode,
			DRDI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			CASE
				WHEN DRDI.DefectCauseType = 'S' THEN DRDI.DutyCostCenterCode
				ELSE DRDI.DutyVendorCode
			END AS CostCenterCode,
			CASE
				WHEN DRDI.DefectCauseType = 'S' THEN CCI.CostCenterName
				ELSE CUI.CustomerName
			END AS CostCenterName,
			DRDI.DutyCostCenterCode,
			CCI.CostCenterName AS DutyCostCenterName,
			DRDI.DutyVendorCode,
			CUI.CustomerName AS DutyVendorName,
			DRDI.CauseJobDate,
			DRDI.CauseShiftCode,
			SC.[Shift] AS CauseShiftName,
			DRDI.CauseTimeCode,
			DRDI.RepairType,		-- 수리여부
			RT.RepairTypeName,
			DRDI.RepairDesc,
			DRDI.RepairUserID,
			UI.UserName AS RepairUserName,
			DRDI.RepairDateTime,
			CASE
				WHEN DRDI.RepairType = 'FINISH' THEN DRDI.RepairQty
				WHEN DRDI.RepairType = 'LOSS' THEN DRDI.LossQty
				WHEN DRDI.RepairType = 'MISSING' THEN DRDI.DefectQty
				ELSE DRI.DefectQty
			END AS ProcessQty
	FROM
			STB_DefectRepairDetailInfo DRDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = DRDI.CauseLineCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON	DCI.DefectCauseCode = DRDI.DefectCauseCode
			LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)
				ON	CUI.CustomerCode = DRDI.DutyVendorCode
			LEFT OUTER JOIN STB_CostCenterInfo CCI WITH(NOLOCK)
				ON CCI.CostCenterCode = DRDI.DutyCostCenterCode
			LEFT OUTER JOIN VW_RepairType RT
				ON	RT.RepairType = DRDI.RepairType
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON	DCT.DefectCauseType = DRDI.DefectCauseType
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = DRDI.RepairUserID
			LEFT OUTER JOIN VW_ShiftCode SC WITH(NOLOCK)
				ON	SC.ShiftCode = DRDI.CauseShiftCode
			LEFT OUTER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
				ON DRI.DefectSummaryNo = DRDI.DefectSummaryNo
	WHERE
			DRDI.DefectSummaryNo = @DefectSummaryNo
END
