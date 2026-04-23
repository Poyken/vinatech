-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	세트 수리정보를 가져옵니다.
-- Modified:
-- ============================================= exec usp_GetDefectRepairInfoByBarcode_ForRepair '','','20250331001121','VE250203-011',''
CREATE PROCEDURE [dbo].[usp_GetDefectRepairInfoByBarcode_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pIsForLoss BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	----raiserror(@pDefectSummaryNo,16,1)
	--return

	DECLARE @DefectSummaryNo VARCHAR(20) = ISNULL(@pDefectSummaryNo,'')
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @IsForLoss BIT = ISNULL(@pIsForLoss,0)
	DECLARE @ERR_MSG NVARCHAR(500)

	--IF EXISTS (
	--			SELECT	1
	--			FROM
	--					STB_SetInfo SI WITH(NOLOCK)
	--			WHERE
	--					SI.OutSetNo = @OutSetNo AND
	--					SI.IsLoss = 1
	--			) BEGIN
	--		EXEC usp_GetAddonStringResource @pLanguage = @pProcessLanguage,
	--									@pName = '^이미 폐기된 세트입니다^',
	--									@pValue = @ERR_MSG OUTPUT	
	--	RAISERROR(@ERR_MSG, 16, 1)
	--	RETURN
	--END
	;WITH DefectRepairDetail AS
	(
		SELECT
				DRI.DefectSummaryNo,
				SUM(DRDI.RepairQty) + SUM(DRDI.LossQty) AS ProcessQty	-- DefectQty => MissingQty 는 제외 Missing처리시 불량수량을 감소시키므로
		FROM
				STB_DefectRepairInfo DRI WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)
					ON SI.ControlNo = DRI.ControlNo
				INNER JOIN STB_DefectRepairDetailInfo DRDI WITH(NOLOCK)
					ON DRDI.DefectSummaryNo = DRI.DefectSummaryNo
		WHERE
				SI.Barcode = @Barcode AND
				((@DefectSummaryNo = '') OR (DRI.DefectSummaryNo = @DefectSummaryNo))
		GROUP BY
				DRI.DefectSummaryNo
	)
	SELECT
			SI.PONo,
			SI.DayPlanNo,
			SI.Barcode,
			SI.ControlNo,
			SI.IsLoss,
			POI.CompanyCode,
			POI.WorkCenterCode,
			DRI.DefectSummaryNo AS OldDefectSummaryNo,
			DRI.DefectSummaryNo,
			SI.MaterialCode AS ModelCode,
			SI.MaterialCode,
			MM.MaterialName,
			DRI.FindLineCode,
			FLI.LineName AS FindLineName,
			DRI.FindRouteCode,
			RI.RouteName AS FindRouteName,
			DRI.FindSubRouteCode,
			DRI.FindJobdate,
			DRI.FindShiftCode,
			DRI.FindTimeCode,
			CASE
				WHEN DRI.CauseLineCode IS NULL THEN DRI.FindLineCode
				ELSE DRI.CauseLineCode
			END AS CauseLineCode,
			CASE
				WHEN DRI.CauseLineCode IS NULL THEN FLI.LineName
				ELSE CLI.LineName
			END AS CauseLineName,
			DRI.CauseShiftCode,
			DRI.CauseTimeCode,
			DRI.CauseJobDate,
			DCI.DefectCauseGroupCode,
			DCG.BasicDefectCauseGroupName AS DefectCauseGroupName,
			DRI.DefectCauseCode,
			DCI.BasicDefectCauseName AS DefectCauseName,
			DRI.DefectCauseDetailCode,
			DRI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			CASE
				WHEN DRI.DefectCauseType = 'S' THEN DRI.DutyCostCenterCode
				ELSE DRI.DutyVendorCode
			END AS CostCenterCode,
			CASE
				WHEN DRI.DefectCauseType = 'S' THEN CCI.CostCenterName
				ELSE CUI.CustomerName
			END AS CostCenterName,
			DRI.DutyCostCenterCode,
			DRI.DutyVendorCode,
			CCI.CostCenterName AS DutyCostCenterName,
			CUI.CustomerName AS DutyVendorName,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,

			DRI.DefectCode,
			DI.BasicDefectName AS DefectName,
			DRI.DefectExtDesc,
			ISNULL(DRI.DefectQty,1) AS DefectQty,
			DRI.DefectQty - ISNULL(DRDI.ProcessQty,0) AS RemainQty,
			ISNULL(DRI.RepairType,'NONE') AS RepairType,	-- 수리여부
			RT.RepairTypeName,
			DRI.RepairDesc,
			DRI.RepairUserID,
			DRI.RepairQty,
			DRI.RepairDateTime,
			@IsForLoss AS IsForLoss
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
				ON POI.PONo = SI.PONo
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
				ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = SI.MaterialCode
			LEFT OUTER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
				ON DRI.ControlNo = SI.ControlNo
				AND DRI.DefectSummaryNo = @DefectSummaryNo
			LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)
				ON	FLI.LineCode = DRI.FindLineCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = DRI.FindRouteCode
			LEFT OUTER JOIN STB_LineInfo CLI WITH(NOLOCK)
				ON CLI.LineCode = DRI.CauseLineCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON	DI.DefectCode = DRI.DefectCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON	DCI.DefectCauseCode = DRI.DefectCauseCode
			LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)
				ON	CUI.CustomerCode = DRI.DutyVendorCode
			LEFT OUTER JOIN VW_RepairType RT
				ON	RT.RepairType = DRI.RepairType
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON	DCT.DefectCauseType = DRI.DefectCauseType
			LEFT OUTER JOIN STB_CostCenterInfo CCI WITH(NOLOCK)
				ON CCI.CostCenterCode = DRI.DutyCostCenterCode
			LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)
				ON	DG.DefectGroupCode = DI.DefectGroupCode
			LEFT OUTER JOIN STB_DefectCauseGroup DCG WITH(NOLOCK)
				ON DCG.DefectCauseGroupCode = DCI.DefectCauseGroupCode
			LEFT OUTER JOIN DefectRepairDetail DRDI
				ON DRDI.DefectSummaryNo = DRI.DefectSummaryNo
	WHERE
			SI.Barcode = @Barcode AND
			((@DefectSummaryNo = '') OR (DRI.DefectSummaryNo = @DefectSummaryNo))
END
