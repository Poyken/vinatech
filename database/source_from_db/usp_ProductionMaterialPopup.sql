-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-26
-- Description : 생산가능한 자재 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductionMaterialPopup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL,
	@pBasicMaterialType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			@BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '%' ELSE @pBasicMaterialType END

	SELECT
			MM.MaterialCode,
			MM.MaterialName
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MT.MaterialTypeCode = MM.MaterialTypeCode
	WHERE
			ISNULL(MM.IsClosed, 0) = 0 AND
			MM.IsProdPlan = 1 AND
			ISNULL(MM.ProductGroupCode, '') LIKE @ProductGroupCode AND
			ISNULL(MT.BasicMaterialType, '') LIKE @BasicMaterialType
END