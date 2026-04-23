-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 품질관리
-- Description:	불량 제품의 수리자재를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectRepairPartInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20) = NULL,
	@pDefectSummaryDetailNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectSummaryNo VARCHAR(20) = @pDefectSummaryNo
	DECLARE @DefectSummaryDetailNo VARCHAR(20) = CASE WHEN ISNULL(@pDefectSummaryDetailNo,'') = '' THEN '%' ELSE @pDefectSummaryDetailNo END
	DECLARE @ControlNo VARCHAR(20)

	SELECT
			DRPI.MaterialCode,
			MM.MaterialName,			
			DRPI.DefectCode,
			DI.BasicDefectName AS DefectName,
			SUM(DRPI.LossQty) AS LossQty,
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
			END CostCenterName,
			DRPI.IsChangeMaterial,
			DRPI.ChangePartBarcode,
			DRPI.ChangePartSerial
	FROM
			STB_DefectRepairPartInfo DRPI WITH (NOLOCK)
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON CI.CustomerCode = DRPI.DutyVendorCode
			LEFT OUTER JOIN STB_CostCenterInfo CCI WITH(NOLOCK)
				ON CCI.CostCenterCode = DRPI.DutyCostCenterCode
			LEFT OUTER JOIN STB_Materialmaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DRPI.MaterialCode
			LEFT OUTER JOIN VW_DefectCauseType DCT
				ON	DCT.DefectCauseType = DRPI.DefectCauseType
			LEFT OUTER JOIN STB_DefectInfo DI WITH (NOLOCK)
				ON	DI.DefectCode = DRPI.DefectCode
			LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)
				ON	DCI.DefectCauseCode = DRPI.DefectCauseCode
	WHERE
			DRPI.DefectSummaryNo = @DefectSummaryNo  AND
			DRPI.DefectSummaryDetailNo LIKE @DefectSummaryDetailNo
	GROUP BY
			DRPI.MaterialCode,
			MM.MaterialName,			
			DRPI.DefectCode,
			DI.BasicDefectName,
			DRPI.DefectCauseCode,
			DCI.BasicDefectCauseName,
			DRPI.DefectCauseDesc,
			DRPI.DefectCauseType,
			DCT.DefectCauseName,
			DRPI.DutyCostCenterCode,
			DRPI.DutyVendorCode,
			CCI.CostCenterName,
			CI.CustomerName,
			DRPI.IsChangeMaterial,
			DRPI.ChangePartBarcode,
			DRPI.ChangePartSerial
END
