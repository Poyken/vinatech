-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-13
-- Group : 공통
-- Description:	자재유형코드을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialTypeCode_popup]
	@pBasicMaterialType VARCHAR(20) = NULL,
	@pExcludeBasicMaterialTypes VARCHAR(100) = 0
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @BasicMaterialType VARCHAR(20) = CASE WHEN ISNULL(@pBasicMaterialType,'') = '' THEN '%' ELSE @pBasicMaterialType END,
			@ExcludeBasicMaterialTypes VARCHAR(100) = @pExcludeBasicMaterialTypes
	
	SELECT
			MT.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL
	FROM
			STB_MaterialType MT WITH(NOLOCK)
	WHERE
			MT.IsUsed = 1 AND
			MT.BasicMaterialType LIKE @BasicMaterialType AND
			MT.BasicMaterialType NOT IN (
											SELECT
													T.Item
											FROM
													dbo.fnSplitToTable(',', @ExcludeBasicMaterialTypes) T
										)
	
END
