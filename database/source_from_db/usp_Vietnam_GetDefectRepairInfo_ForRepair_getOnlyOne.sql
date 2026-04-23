-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-03-31
-- Description:	Lấy ra 1 bản ghi duy nhất cho QC để có thể thêm phế khi mang đi kiểm tra
-- =============================================
-- exec usp_Vietnam_GetDefectRepairInfo_ForRepair_getOnlyOne '','','VE250203-011','20250328001889'
CREATE PROCEDURE usp_Vietnam_GetDefectRepairInfo_ForRepair_getOnlyOne
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarCode VARCHAR(20) = NULL,
	@pDefectSummaryNo VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @BarCode VARCHAR(20) = CASE WHEN rtrim(ltrim(ISNULL(@pBarCode ,''))) = '' THEN '*' ELSE @pBarCode END
		DECLARE @DefectSummaryNo VARCHAR(20) = CASE WHEN rtrim(ltrim(ISNULL(@pDefectSummaryNo ,''))) = '' THEN '*' ELSE @pDefectSummaryNo END
  SELECT
			DRI.DefectSummaryNo AS OldDefectSummaryNo,
			DRI.DefectSummaryNo,
			DRI.PONo,
			DRI.DayPlanNo,
			SI.Barcode,
			SI.IsLoss,
			DRI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName AS FindLineName,
			DRI.FindRouteCode,
			RI.RouteName AS FindRouteName,
			DRI.FindSubRouteCode,
			DRI.FindJobdate,
			DRI.FindShiftCode,
			VFSC.[Shift] AS FindShiftName,
			DRI.FindTimeCode,
			DRI.CauseLineCode,
			CLI.LineName AS CauseLineName,
			DRI.CauseShiftCode,
			VCSC.[Shift] AS CuaseShiftName,
			DRI.CauseTimeCode,
			DRI.CauseJobDate,
			DRI.DefectCauseCode,
			DCI.BasicDefectCauseName,
			DRI.DefectCauseDetailCode,
			DRI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			DRI.DutyCostCenterCode,
			DRI.DutyVendorCode,
			CUI.CustomerName AS DutyVendorName,
			DRI.DefectCode,
			DI.BasicDefectName AS DefectName,
			DRI.DefectExtDesc,
			DRI.DefectQty,
			DRI.ControlNo,
			DRI.RepairType,		-- 수리여부
			RT.RepairTypeName,
			DRI.RepairDesc,
			DRI.RepairUserID,
			UI.UserName AS RepairUserName,
			DRI.RepairQty,
			DRI.RepairDateTime,
			ISNULL(DRDI.ProcessQty,0) AS ProcessQty,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,
			DRI.DRIExtText02
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DRI.MaterialCode
			LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)
				ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)
				ON	FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = DRI.FindRouteCode
			LEFT OUTER JOIN STB_LineInfo CLI WITH(NOLOCK)
				ON CLI.LineCode = DRI.CauseLineCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON	DI.DefectCode = DRI.DefectCode
			LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)
			    ON DI.DefectGroupCode = DG.DefectGroupCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON	DCI.DefectCauseCode = DRI.DefectCauseCode
			LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)
				ON	CUI.CustomerCode = DRI.DutyVendorCode
			LEFT OUTER JOIN VW_RepairType RT
				ON	RT.RepairType = DRI.RepairType
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON	DCT.DefectCauseType = DRI.DefectCauseType
			LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = DRI.RepairUserID
			LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)
				ON	VFSC.ShiftCode = DRI.FindShiftCode
			LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)
				ON	VCSC.ShiftCode = DRI.CauseShiftCode
			LEFT OUTER JOIN
			(
				SELECT
						DRDI.DefectSummaryNo,
						SUM(DRDI.RepairQty) + SUM(DRDI.LossQty) AS ProcessQty	-- SUM(DRDI.DefectQty) MissingQty는 제외
				FROM
						STB_DefectRepairDetailInfo DRDI WITH(NOLOCK)
				WHERE
						DRDI.DefectSummaryNo IN (SELECT DefectSummaryNo FROM STB_DefectRepairInfo)
				GROUP BY
						DRDI.DefectSummaryNo
			) DRDI
				ON DRDI.DefectSummaryNo = DRI.DefectSummaryNo
	WHERE
			(@BarCode='*' or si.Barcode = @BarCode) 
			AND  (@DefectSummaryNo='*' or DRI.DefectSummaryNo = @DefectSummaryNo) 
END
