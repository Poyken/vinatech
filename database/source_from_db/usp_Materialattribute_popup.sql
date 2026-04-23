-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 팝업
-- Description:	제품별 특성정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_Materialattribute_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL,
	@pAttribType VARCHAR(1) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialCode VARCHAR(50) = @pMaterialCode
	DECLARE @AttribType VARCHAR(1) = @pAttribType

	SELECT
			MA.AttribType,
			MA.StockAttrib,
			MA.StockAttribDesc
	FROM
			STB_MaterialAttribute MA WITH(NOLOCK)
	WHERE
			MA.MaterialCode = @MaterialCode AND
			MA.AttribType = @AttribType
END
