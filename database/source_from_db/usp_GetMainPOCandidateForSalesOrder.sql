-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : 해당월 영업오더 상세내역별 메인제품 수주 및 출고예약조회
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMainPOCandidateForSalesOrder]
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
				SO.SalesOrderNo,
				SO.CustomerCode,
				CI.CustomerName,
				SOI.SOISequence,
				SOI.ModelCode,
				MBI.ModelName,
				SOI.OrderQty
		FROM
				STB_SalesOrder SO WITH(NOLOCK)
				INNER JOIN STB_SalesOrderItem SOI WITH(NOLOCK)
					ON	SOI.SalesOrderNo = SO.SalesOrderNo			
				LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
					ON	CI.CustomerCode = SO.CustomerCode
				LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)
					ON	MBI.ModelCode = SOI.ModelCode
		WHERE
				@FromDate <= SOI.RequestDeliveryDate AND
				SOI.RequestDeliveryDate < @ToDate AND
				SO.IsCancel = 0
	)
	,PO AS
	(
		SELECT
				POSI.SOISequence,
				POI.MaterialCode,
				POSI.PlanQty
		FROM
				STB_ProductionOrderSalesInfo POSI
				INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)				
					ON	POI.PONo = POSI.PONo
				INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON	MM.MaterialCode = POI.MaterialCode
				INNER JOIN STB_MaterialType MT WITH(NOLOCK)
					ON	MT.MaterialTypeCode = MM.MaterialTypeCode
		WHERE
				POI.PlanYearMonth = @YearMonth AND
				MT.BasicMaterialType = 'FERT'
	)	
	SELECT
			SO.SalesOrderNo,
			SO.CustomerCode,
			SO.CustomerName,
			SO.SOISequence,
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			SO.ModelCode AS MaterialCode,
			MBI.ModelName AS MaterialName,
			SO.OrderQty,
			SUM(D.PlanQty) AS PlanQty,
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
				ON	D.SOISequence = SO.SOISequence AND
					D.MaterialCode = SO.ModelCode
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)
				ON	MBI.ModelCode = SO.ModelCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MBI.ProductGroupCode
			LEFT OUTER JOIN STB_BomHeader BH WITH (NOLOCK)
				ON (BH.MaterialCode = SO.ModelCode AND BH.IsBasic = 1)
	GROUP BY
			SO.SalesOrderNo,
			SO.CustomerCode,
			SO.CustomerName,
			SO.SOISequence,
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			SO.ModelCode,
			MBI.ModelName,
			SO.OrderQty,
			MBI.MaterialUnit,
			BH.BomVersion,
			BH.BomHeaderDesc
END
