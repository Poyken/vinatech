
-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 재고관리
-- Browsable : true
-- Create date: 2016-09-26
-- Description: 재고에 있는 자재리스트 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialSlitting_popup]

AS
BEGIN
	SET NOCOUNT ON;

 
	SELECT
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec
	FROM
			 STB_MaterialMaster MM WITH(NOLOCK)
			 
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = MM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = MM.ProductGroupCode
				
				where materialcode like '1030P000%'
END


 

