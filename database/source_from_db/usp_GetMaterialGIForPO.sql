-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-08-02
-- Description : PO 자재출고내역
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialGIForPO]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo

	SELECT
			MDI.MaterialDocNo,
			MDI.SourceMaterialWarehouseCode,
			SMW.MaterialWarehouseName AS SourceMaterialWarehouseName,
			MDI.TargetMaterialWarehouseCode,
			TMW.MaterialWarehouseName AS TargetMaterialWarehouseName,
			MDLI.MaterialLotNo,
			MDLI.LotID,
			MDLI.LotNo,
			MDLI.MaterialCode,
			MM.MaterialName,
			MDLI.MaterialStockAttribute,
			MDLI.StockAttrib1,
			MDLI.StockAttrib2,
			MDLI.StockAttrib3,
			MDLI.StockQty,
			MDLI.CreateDateTime,
			MDLI.CreateUserID
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse SMW WITH(NOLOCK)
				ON	SMW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialWarehouse TMW WITH(NOLOCK)
				ON	TMW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode
			INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
				ON	MDLI.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MDLI.MaterialCode
	WHERE
			MDI.PONo = @PONo
END
