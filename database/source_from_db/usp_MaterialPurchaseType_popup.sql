-- =============================================
-- Author:	Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-11-23
-- Browsable : true
-- Group : 팝업
-- Description:	MaterialPurchaseType popup
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialPurchaseType_popup]

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
			MPT.MaterialPurchaseType
	FROM
			VW_MaterialPurchaseType MPT WITH(NOLOCK)
	

END
