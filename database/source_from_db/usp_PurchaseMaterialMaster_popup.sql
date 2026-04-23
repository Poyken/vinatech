
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-01-13
-- Group : 공통
-- Description:	품목마스터(구매자재) 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_PurchaseMaterialMaster_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSource,
			MM.AvgGrDay,
			MM.IsPurchase,
			MM.IsOrder,
			MM.IsClosed,
			MM.BeforeMaterialCode
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
			MM.IsClosed = 0 AND
			MM.IsPurchase = 1
END

