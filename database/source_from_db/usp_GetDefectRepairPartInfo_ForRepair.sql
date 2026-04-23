-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	세트 수리정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairPartInfo_ForRepair]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pDefectSummaryNo VARCHAR(20) = NULL,
	@pDefectSummaryDetailNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @DefectSummaryNo VARCHAR(20) = @pDefectSummaryNo
	DECLARE @DefectSummaryDetailNo VARCHAR(20) = CASE WHEN ISNULL(@pDefectSummaryDetailNo,'') = '' THEN '%' ELSE @pDefectSummaryDetailNo END
	DECLARE @ERR_MSG NVARCHAR(500)
	
	SELECT
			@DefectSummaryNo AS DefectSummaryNo,
			@DefectSummaryDetailNo AS DefectSummaryDetailNo,
			POB.ChildMaterialCode AS MaterialCode,
			MM.MaterialName,
			POB.UsedQty,
			POB.BomUnit,
			POB.TotalUsedQty,
			POB.RouteCode,
			RI.RouteName,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName AS DefectGroupName,
			DRPI.DefectCode,
			DI.BasicDefectName AS DefectName,
			DRPI.LossQty,
			0 AS ProcessQty,
			DCI.DefectCauseGroupCode,
			DCG.BasicDefectCauseGroupName AS DefectCauseGroupName,
			DRPI.DefectCauseCode,
			DCI.BasicDefectCauseName AS DefectCauseName,
			DRPI.DefectCauseDesc,
			DRPI.DefectCauseType,
			DCT.DefectCauseName AS DefectCauseTypeName,
			CASE
				WHEN DRPI.DefectCauseType = 'S' THEN DRPI.DutyCostCenterCode
				ELSE DRPI.DutyVendorCode
			END AS CostCenterCode,
			CASE
				WHEN DRPI.DefectCauseType = 'S' THEN CCI.CostCenterName
				ELSE CI.CustomerName
			END AS CostCenterName,
			DRPI.DutyCostCenterCode,
			CCI.CostCenterName AS DutyCostCenterName,
			DRPI.DutyVendorCode,
			CI.CustomerName AS DutyVendorName,
			DRPI.IsChangeMaterial,
			DRPI.ChangePartBarcode,
			DRPI.ChangePartSerial
	FROM
			STB_ProductionOrderBom POB WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = POB.RouteCode
			LEFT OUTER JOIN STB_DefectRepairPartInfo DRPI WITH(NOLOCK)
				ON DRPI.DefectSummaryNo = @DefectSummaryNo AND
				DRPI.DefectSummaryDetailNo LIKE @DefectSummaryDetailNo AND
				DRPI.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON DI.DefectCode = DRPI.DefectCode
			LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)
				ON DG.DefectGroupCode = DI.DefectGroupCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON DCI.DefectCauseCode = DRPI.DefectCauseCode
			LEFT OUTER JOIN STB_DefectCauseGroup DCG WITH(NOLOCK)
				ON DCG.DefectCauseGroupCode = DCI.DefectCauseGroupCode
			LEFT OUTER JOIN STB_CostCenterInfo CCI WITH(NOLOCK)
				ON CCI.CostCenterCode = DRPI.DutyCostCenterCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON CI.CustomerCode = DRPI.DutyVendorCode
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON DCT.DefectCauseType = DRPI.DefectCauseType
	WHERE
			POB.PONo = @PONo AND
			POB.RouteCode = @RouteCode AND
			POB.IsUseProduction = 1
END
