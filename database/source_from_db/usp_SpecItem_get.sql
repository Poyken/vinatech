
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 사양항목정보
-- Description:	사양항목정보조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecItem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pSpecGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SpecGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pSpecGroupCode,'') = '' THEN '%' ELSE @pSpecGroupCode END

    
	SELECT
			SI.SpecItemCode AS OldSpecItemCode,
			SI.SpecItemCode,
			SI.ProductGroupCode,
			PG.ProductGroupName,
			SI.SpecGroupCode,
			SG.SpecGroupName,
			SI.SpecItemName,
			SI.SpecItemNameL,
			SI.SpecItemCheckType,
			SICT.SpecItemCheckTypeName,
			SI.IsUsed,
			SI.CreateDateTime,
			SI.CreateUserID,
			SI.ChangeDateTime,
			SI.ChangeUserID,
			SI.Remark
	FROM
			STB_SpecItem SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SpecGroup SG WITH(NOLOCK)
				ON	SI.SpecGroupCode		= SG.SpecGroupCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	SI.ProductGroupCode		= PG.ProductGroupCode
			LEFT OUTER JOIN VW_SpecItemCheckType SICT WITH(NOLOCK)
				ON	SI.SpecItemCheckType	= SICT.SpecItemCheckType
	WHERE
			(SI.SpecGroupCode LIKE @SpecGroupCode) 

END