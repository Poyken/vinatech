
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	수리이력정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfo_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRepairType VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pDefectGroupCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE  WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE  WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @RepairType VARCHAR(20) = CASE WHEN ISNULL(@pRepairType ,'') = '' THEN '%' ELSE @pRepairType END
	DECLARE @DefectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectGroupCode ,'') = '' THEN '%' ELSE @pDefectGroupCode END
	
	;WITH DefectRepairInfo AS
	(
		SELECT
				DRI.*
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
		WHERE
				(DRI.CompanyCode LIKE @CompanyCode) AND
				(DRI.WorkCenterCode LIKE @WorkCenterCode) AND
				(DRI.FindLineCode LIKE @LineCode) AND
				(DRI.FindJobdate >= @FromDate AND DRI.FindJobdate <= @ToDate) AND
				DRI.RepairType LIKE @RepairType
	)
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
			--SRI.SubRouteName AS FindSubRouteName,
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
			--CASE 
			--	WHEN ISNULL(DCGL.DefectCauseName,'') = '' THEN DCI.BasicDefectCauseName
			--	ELSE DCGL.DefectCauseName
			--END AS DefectCauseName,
			DRI.DefectCauseDetailCode,
			DRI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			DRI.DutyCostCenterCode,
			DRI.DutyVendorCode,
			CUI.CustomerName AS DutyVendorName,
			DRI.DefectCode,
			DI.BasicDefectName AS DefectName,
			--CASE
			--	WHEN ISNULL(DLI.DefectName,'') = '' THEN DI.BasicDefectName
			--	ELSE DLI.DefectName
			--END AS DefectName,
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
			CASE WHEN (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0)) = 0 THEN 0
			     ELSE dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) / (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0)) END AS WasteUnitPrice,
			dbo.fnGetWastePrice(DRI.FindLineCode, DRI.FindRouteCode, DRI.MaterialCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS TotWastePrice,
			dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, 1) AS MaterialDcUnitPrice,
			dbo.fnGetWastePriceByBarcode(SI.Barcode, 'DC', DRI.FindRouteCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS MaterialDcPrice,
			dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, 1) AS MaterialPcUnitPrice,
			dbo.fnGetWastePriceByBarcode(SI.Barcode, 'PC', DRI.FindRouteCode, (DRI.DefectQty - ISNULL(DRDI.ProcessQty,0))) AS MaterialPcPrice,
			DRI.DRIExtText02
	FROM
			DefectRepairInfo DRI WITH(NOLOCK)
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
						DRDI.DefectSummaryNo IN (SELECT DefectSummaryNo FROM DefectRepairInfo)
				GROUP BY
						DRDI.DefectSummaryNo
			) DRDI
				ON DRDI.DefectSummaryNo = DRI.DefectSummaryNo
	WHERE
			(DRI.CompanyCode LIKE @CompanyCode) AND
			(DRI.WorkCenterCode LIKE @WorkCenterCode) AND
			(DRI.FindLineCode LIKE @LineCode) AND
			(DRI.FindJobdate >= @FromDate AND DRI.FindJobdate <= @ToDate) AND
			DRI.RepairType LIKE @RepairType AND
			DI.DefectGroupCode LIKE @DefectGroupCode
END
