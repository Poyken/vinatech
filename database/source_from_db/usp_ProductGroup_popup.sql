-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-13
-- Group : 공통
-- Description:	ProductGroup 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductGroup_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT
			PG.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL
	FROM
			STB_ProductGroup PG WITH(NOLOCK)
	WHERE
			PG.IsUsed = 1
	
END
