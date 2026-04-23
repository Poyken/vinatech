-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-27
-- Description : 해당월 반제품 수주 및 출고예약조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSubPOCandidate]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pYearMonth DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@YearMonth VARCHAR(7) = @pYearMonth,
			@FromDate DATE = dbo.fnGetFirstDayOfMonth(@pYearMonth),
			@ToDate DATE = DATEADD(DD,1,dbo.fnGetLastDayOfMonth(@pYearMonth))
	;
	WITH MainPO AS
	(
		SELECT
				POB.ChildMaterialCode AS MaterialCode,
				POB.ChildBomVersion AS BomVersion,
				MM.MaterialName,
				SUM(POB.TotalUsedQty) AS TotalUsedQty
		FROM
				STB_ProductionOrderInfo POI WITH(NOLOCK)		
				INNER JOIN STB_ProductionOrderBom POB WITH(NOLOCK)
					ON	POB.PONo = POI.PONo
				INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = POB.ChildMaterialCode
				INNER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
		WHERE
				POI.POType = 'FERT' AND
				POI.PlanYearMonth = @YearMonth AND
				POI.IsCancel = 0 AND
				MT.BasicMaterialType = 'HALB' AND
				MM.IsProdPlan = 1
		GROUP BY
				POB.ChildMaterialCode,				
				POB.ChildBomVersion,
				MM.MaterialName
	)
	,PO AS
	(
		SELECT
				POI.MaterialCode,
				SUM(POI.PlanQty) AS PlanQty
		FROM
				STB_ProductionOrderInfo POI WITH(NOLOCK)				
				INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = POI.MaterialCode
				INNER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
		WHERE
				POI.PlanYearMonth = @YearMonth AND
				MT.BasicMaterialType = 'HALB'
		GROUP BY
				POI.MaterialCode				
	)	
	SELECT
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			MP.MaterialCode,
			MP.MaterialName,
			MP.TotalUsedQty,
			MBI.MaterialUnit,
			D.PlanQty,
			CONVERT(VARCHAR(7), @pYearMonth, 120) AS PlanYearMonth,
			--'' AS BomVersion,
			--'' AS BomHeaderSesc,
			ISNULL(BH.BomVersion, '') AS BomVersion,
			ISNULL(BH.BomHeaderDesc, '') AS BomHEaderDesc,
			0 AS POQty
	FROM
			MainPO MP
			LEFT OUTER JOIN PO D
				ON	D.MaterialCode = MP.MaterialCode
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)
				ON	MBI.ModelCode = MP.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MBI.ProductGroupCode
			LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
				ON (BH.MaterialCode = MP.MaterialCode AND BH.IsBasic = 1)

END
