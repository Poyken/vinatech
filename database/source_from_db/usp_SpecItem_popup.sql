-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 팝업
-- Description:	사양항목정보 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecItem_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	    
	SELECT
			SI.SpecItemCode,
			SI.ProductGroupCode,
			PG.ProductGroupName,
			SI.SpecGroupCode,
			SG.SpecGroupName,
			SI.SpecItemName,
			SI.SpecItemNameL,
			SI.SpecItemCheckType,
			SICT.SpecItemCheckTypeName,
			SI.IsUsed
	FROM
			STB_SpecItem SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_SpecGroup SG WITH(NOLOCK)
				ON	SI.SpecGroupCode		= SG.SpecGroupCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	SI.ProductGroupCode		= PG.ProductGroupCode
			LEFT OUTER JOIN VW_SpecItemCheckType SICT WITH(NOLOCK)
				ON	SI.SpecItemCheckType	= SICT.SpecItemCheckType
	WHERE
			SI.IsUsed = 1
END

