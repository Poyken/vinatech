
-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable: true
-- Create date: 2018-11-01
-- Description:	자재,BomVersion에 해당하는 종료되지않은 PO를 가져옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionOrderInfoForMaterial]
	@pMaterialCode VARCHAR(50) = NULL,
	@pBomVersion VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode,
			@BomVersion VARCHAR(20) = @pBomVersion

	SELECT
			POI.CompanyCode,
			CI.CompanyName,
			POI.WorkCenterCode,
			WCI.WorkCenterName,
			POI.PONo,
			POI.PlanYearMonth,
			POI.MaterialCode,
			MM.MaterialName
	FROM
			STB_ProductionOrderInfo POI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = POI.MaterialCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = POI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = POI.WorkCenterCode
	WHERE
			POI.IsFinish = 0 AND
			POI.IsCancel = 0 AND
			POI.IsFix = 1 AND
			POI.MaterialCode = @MaterialCode AND
			POI.BomVersion = @BomVersion
END