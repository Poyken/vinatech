-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2018-08-07
-- Description : 재고속성 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialStockAttribute_popup]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			*
	FROM
			VW_MaterialStockAttribute
END
