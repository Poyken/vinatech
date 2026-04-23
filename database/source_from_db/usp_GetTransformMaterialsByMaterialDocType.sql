-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-28
-- Group : 제품관리
-- Description:	기종변경 자재출고내역을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTransformMaterialsByMaterialDocType]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20) = NULL,
	@pMaterialDocTypeCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE	@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@MaterialDocNo VARCHAR(20) = @pMaterialDocNo,
			@MaterialDocTypeCode VARCHAR(20) = @pMaterialDocTypeCode

	SELECT
			MDI.MaterialDocNo,
			MDD.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MDD.MaterialStockAttribute,
			MDD.ProcessFixQty
	FROM
			STB_MaterialDocInfo MDI
			INNER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)
				ON	MDD.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MDD.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
	WHERE
			MDI.RefMaterialDocNo = @MaterialDocNo AND
			MDI.MaterialDocTypeCode = @MaterialDocTypeCode	-- 'GI_ETC'
END

