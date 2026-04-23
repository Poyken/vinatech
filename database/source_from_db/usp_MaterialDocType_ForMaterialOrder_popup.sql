
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-28
-- Browsable : true
-- Group : 공통
-- Description:	납품서용 자재수불유형정보 POPUP
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocType_ForMaterialOrder_popup]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			MDT.MaterialDocTypeCode,
			MDT.MaterialDocType,
			MDT.MaterialDocTypeName,
			MOT.MaterialOrderType,
			MOT.MaterialOrderTypeName
	FROM
			STB_MaterialDocType MDT WITH(NOLOCK)
			LEFT OUTER JOIN VW_MaterialOrderType MOT
				ON	MOT.MaterialDocTypeCode = MDT.MaterialDocTypeCode
	WHERE
			MDT.MaterialDocTypeCode IN ('GR_NORMAL','GR_EXT_PROD_W_BOM','GR_RETURN')

END
