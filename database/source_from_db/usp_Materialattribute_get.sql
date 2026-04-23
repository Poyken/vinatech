-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-31
-- Browsable : true
-- Group : 공통
-- Description:	제품별 특성정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_Materialattribute_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END

	SELECT
			MA.MaterialCode,
			MM.MaterialName,
			MA.AttribType,
			MA.StockAttrib,
			MA.StockAttribDesc,
			MA.CreateDateTime,
			MA.CreateUserID,
			MA.ChangeDateTIme,
			MA.ChangeUserID
	FROM
			STB_MaterialAttribute MA WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = MA.MaterialCode
	WHERE
			MA.MaterialCode LIKE @MaterialCode AND
			MM.ProductGroupCode LIKE @ProductGroupCode
END
