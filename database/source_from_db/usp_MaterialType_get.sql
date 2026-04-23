
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	자재유형 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialTypeName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaterialTypeName NVARCHAR(100) = CASE WHEN ISNULL(@pMaterialTypeName,'') = '' THEN '%' ELSE @pMaterialTypeName END

    
	SELECT
			MT.MaterialTypeCode AS OldMaterialTypeCode,
			MT.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MT.IsUsed,
			MT.CreateDateTime,
			MT.CreateUserID,
			MT.ChangeDateTime,
			MT.ChangeUserID
	FROM
			STB_MaterialType MT WITH(NOLOCK)
	WHERE
			(MT.MaterialTypeName LIKE @MaterialTypeName) 

END

