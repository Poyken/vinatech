-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-24
-- Browsable : true
-- Group : 자재관리
-- Description:	[F110] 자재재고관리속성 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialStockAttributeInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
    @pMaterialCode VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProductGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
	DECLARE @MaterialTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

    
	SELECT
	        MM.MaterialCode AS OldMaterialCode,
	        MM.MaterialCode,
	        MM.MaterialName,
	        MM.MaterialNameL,
	        MM.MaterialTypeCode,
	        MT.BasicMaterialType,
	        MT.MaterialTypeName,
	        MT.MaterialTypeNameL,
	        MM.ProductGroupCode,
	        PG.ProductGroupName,
	        PG.ProductGroupNameL,
	        PG.ProductGroupDesc,
	        PG.ProductGroupDescL,
	        MM.MaterialUnit,
	        MM.BasicGrQty,
	        MM.MaterialSpec,
	        MM.MaterialSpecL,
	        MM.MaterialSource,
	        MM.AvgGrDay,
	        MM.IsPurchase,
	        MM.IsOrder,
	        MM.IsClosed,
	        MM.BeforeMaterialCode,
	        
	        ISNULL(MSAI.IsUseBarcode, CONVERT(BIT, 0)) AS IsUseBarcode,
	        ISNULL(MSAI.IsLotUse, CONVERT(BIT, 0)) AS IsLotUse,
	        ISNULL(MSAI.IsVendorLotUse, CONVERT(BIT, 0)) AS IsVendorLotUse,
	        ISNULL(MSAI.IsLifetimeUse, CONVERT(BIT, 0)) AS IsLifetimeUse,
			ISNULL(MSAI.IsFIFO, CONVERT(BIT, 0)) AS IsFIFO,
	        ISNULL(MSAI.SaftyStock, 0) AS SaftyStock,
			ISNULL(MSAI.IsUseVendorBarcode, CONVERT(BIT, 0)) AS IsUseVendorBarcode,
	        MSAI.CreateDateTime,
	        MSAI.CreateUserID,
	        MSAI.ChangeDateTime,
	        MSAI.ChangeUserID
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialStockAttributeInfo MSAI WITH(NOLOCK)				ON MM.MaterialCode = MSAI.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				                    ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				                    ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
			((@ProductGroupCode = '*') OR (MM.ProductGroupCode = @ProductGroupCode)) AND
			((@MaterialTypeCode = '*') OR (MM.MaterialTypeCode = @MaterialTypeCode)) AND
	        ((@MaterialCode = '*') OR (MM.MaterialCode = @MaterialCode)) 
	        

END

