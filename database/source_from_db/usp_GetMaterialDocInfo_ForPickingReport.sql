
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-12
-- Browsable: true
-- Description:	피킹지시서 인쇄를 위한 수불문서정보를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialDocInfo_ForPickingReport]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo

	SELECT
			MDI.MaterialDocNo,
			MDI.SourceMaterialWarehouseCode,
			MW.MaterialWarehouseName,
			MDI.TargetCustomerCode,
			CI.CustomerName AS TargetCustomerName,
			MDI.MDIErpRefText07 AS RequestNo
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)
				ON	MW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON	ML.MaterialLocationCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
				ON	CI.CustomerCode = MDI.TargetCustomerCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocType = 'GI'

	SELECT
			ROW_NUMBER() OVER(ORDER BY MDD.MaterialDocDetailNo) AS Num,			
			MDI.MaterialDocNo,
			MDD.MaterialDocDetailNo,
			MDD.MaterialCode,
			MM.MaterialName,
			MM.MaterialSpec,
			MDD.RequestQty,
			MDD.AllowQty,
			MDD.PickingAssignQty
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)				
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MDD.MaterialCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocType = 'GI'
	
	-- FIFO
	SELECT
			MDD.MaterialDocDetailNo,
			ML.MaterialLocationName,
			MS.MaterialStockAttribute,
			MDPP.PickingAssingQty
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)				
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			INNER JOIN STB_MaterialDocPickingPlan MDPP WITH(NOLOCK)
				ON	MDPP.MaterialDocDetailNo = MDD.MaterialDocDetailNo
			INNER JOIN STB_MaterialStock MS WITH(NOLOCK)
				ON	MS.MaterialStockNo = MDPP.MaterialStockNo
			INNER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON	ML.MaterialLocationCode = MS.MaterialLocationCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocType = 'GI'

	-- NON FIFO
	SELECT
			MDD.MaterialDocDetailNo,
			ML.MaterialLocationName,
			MS.MaterialStockAttribute,
			MS.StockQty
			--MDD.AllowQty
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)				
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			INNER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)
				ON	MSAI.MaterialCode = MDD.MaterialCode
			INNER JOIN STB_MaterialStock MS WITH(NOLOCK)
				ON	MS.MaterialCode = MDD.MaterialCode AND
					MS.MaterialStockAttribute = MDD.MaterialStockAttribute AND
					MS.StockAttrib1 = MDD.StockAttrib1 AND
					MS.StockAttrib2 = MDD.StockAttrib2 AND
					MS.StockAttrib3 = MDD.StockAttrib3
			INNER JOIN STB_MaterialLocation ML WITH(NOLOCK)
				ON	ML.MaterialLocationCode = MS.MaterialLocationCode
	WHERE
			MDI.MaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocType = 'GI' AND
			MSAI.IsFIFO = 0 AND
			MS.StockQty > 0
			
END

