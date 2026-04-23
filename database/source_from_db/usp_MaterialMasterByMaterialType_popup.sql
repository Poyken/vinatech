-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-10
-- Group : 팝업
-- Description:	자재마스터를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMasterByMaterialType_popup]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(20) = NULL,
	@pExcludeBasicMaterialTypes VARCHAR(100) = 0
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType ,'') = '' THEN '%' ELSE @pBasicMaterialType END,
			@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes

	SELECT
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			MM.MaterialSpec
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_MaterialPurchaseType MPT WITH(NOLOCK)
				ON MPT.MaterialPurchaseType = MM.MaterialPurchaseType
			LEFT OUTER JOIN STB_BasicRoutingInfo BRI WITH (NOLOCK)
				ON BRI.BasicRoutingCode = MM.BasicRoutingCode
	WHERE
			MM.MaterialCode LIKE @MaterialCode AND
			MM.MaterialTypeCode LIKE @MaterialTypeCode AND
			((MM.ProductGroupCode IS NULL) OR (MM.ProductGroupCode LIKE @ProductGroupCode)) AND
			MT.BasicMaterialType LIKE @BasicMaterialType AND
			MT.BasicMaterialType NOT IN (
											SELECT
													T.Item
											FROM
													dbo.fnSplitToTable(',', @ExcludeBasicMaterialTypes) T
										) AND
			ISNULL(MM.IsClosed, 0) = 0
END
