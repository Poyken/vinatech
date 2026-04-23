

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 모델별스팩정보
-- Description:	모델별스팩정보용 모델정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelForLabelSpec_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pModelCode VARCHAR(50) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '*' ELSE @pModelCode END
	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
    
	SELECT
			MM.MaterialCode AS ModelCode,
			MM.MaterialName AS ModelName,
			PG.ProductGroupName,
			MM.MaterialSpec AS ModelSpec,
			
			MBI.EanCode,
			MBI.UpcCode 
	FROM
			STB_MaterialMaster MM WITH (NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON (MM.MaterialTypeCode = MT.MaterialTypeCode)
			LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)
				ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MM.MaterialCode = MBI.ModelCode
	WHERE
			(MT.BasicMaterialType = 'FERT') AND
			((@ModelCode = '*') OR (MM.MaterialCode = @ModelCode)) AND
			((@ProductGroupCode = '*') OR (MM.ProductGroupCode = @ProductGroupCode))


END


