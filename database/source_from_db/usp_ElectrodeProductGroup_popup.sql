-- =============================================
-- Author:		Kangs
-- Create date: 2021-12-09
-- Group : 공통
-- Description:	ProductGroup 조회합니다.
-- usp_ElectrodeProductGroup_popup
-- =============================================
Create PROCEDURE [dbo].[usp_ElectrodeProductGroup_popup]
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
	  AND ProductGroupCode in ('COATING-ROLL','MEA_PEMFC')
END

/*

SELECT * FROM STB_ProductGroup WHERE ProductGroupCode = 'MEA_PEMFC'

*/