-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-08-25
-- Description : 수불문서유형 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocType_popup]
	@pMaterialDocType VARCHAR(20) = NULL,
	@pMaterialDocTypeGroup NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialDocType VARCHAR(20) = @pMaterialDocType,
			@MaterialDocTypeGroup NVARCHAR(50) = CASE WHEN ISNULL(@pMaterialDocTypeGroup,'') = '' THEN '%' ELSE @pMaterialDocTypeGroup END

    SELECT
			MDT.MaterialDocTypeCode,
			MDT.MaterialDocTypeName,
			MDT.MaterialDocTypeDesc
	FROM
			STB_MaterialDocType MDT WITH(NOLOCK)
	WHERE
			MDT.MaterialDocType = @pMaterialDocType AND
			(
				MDT.MaterialDocTypeGroup IS NULL OR 
				MDT.MaterialDocTypeGroup = '' OR
				MDT.MaterialDocTypeGroup LIKE @MaterialDocTypeGroup
			) AND
			MDT.IsDisplay = 1
END
