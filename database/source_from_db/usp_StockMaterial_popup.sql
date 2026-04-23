
-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2016-09-26
-- Description: 재고에 있는 자재리스트 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_StockMaterial_popup]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID
	;
	WITH Stock AS
	(
		SELECT
				DISTINCT
				MS.MaterialCode
		FROM
				STB_MaterialStock MS WITH(NOLOCK)
	
		
	)
	SELECT
			S.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec
	FROM
			Stock S
			INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = S.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
	
END

