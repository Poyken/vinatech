-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : 해당월 메인제품 수주 및 출고예약조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMainPOCandidate]
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
	WITH SalesOrder AS
	(
		SELECT
				SOI.ModelCode,
				SUM(SOI.OrderQty) AS OrderQty
		FROM
				STB_SalesOrder SO WITH(NOLOCK)
				INNER JOIN STB_SalesOrderItem SOI WITH(NOLOCK)
					ON	SOI.SalesOrderNo = SO.SalesOrderNo			
			
		WHERE
				@FromDate <= SOI.RequestDeliveryDate AND
				SOI.RequestDeliveryDate < @ToDate AND
				SO.IsCancel = 0
		GROUP BY
				SOI.ModelCode
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
				MT.BasicMaterialType = 'FERT'
		GROUP BY
				POI.MaterialCode
	)	
	SELECT
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			SO.ModelCode AS MaterialCode,
			MBI.ModelName AS MaterialName,
			SO.OrderQty,
			D.PlanQty,
			MBI.MaterialUnit,
			CONVERT(VARCHAR(7), @pYearMonth, 120) AS PlanYearMonth,
			--'' AS BomVersion,
			--'' AS BomHeaderSesc,
			ISNULL(BH.BomVersion, '') AS BomVersion,
			ISNULL(BH.BomHeaderDesc, '') AS BomHEaderDesc,
			0 AS POQty
	FROM
			SalesOrder SO
			LEFT OUTER JOIN PO D
				ON	D.MaterialCode = SO.ModelCode
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)
				ON	MBI.ModelCode = SO.ModelCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MBI.ProductGroupCode
			LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
				ON (BH.MaterialCode = SO.ModelCode AND BH.IsBasic = 1)
END
