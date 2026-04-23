-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 팝업
-- Description:	검사유형팝업
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpecItemCheckType_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			SpecItemCheckType,
			SpecItemCheckTypeName
	FROM
			VW_SpecItemCheckType SICT WITH(NOLOCK)
END



