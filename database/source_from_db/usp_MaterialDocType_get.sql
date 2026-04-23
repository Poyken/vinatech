
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-24
-- Browsable : true
-- Group : 공통
-- Description:	자재수불유형 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocTypeName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaterialDocTypeName NVARCHAR(50) = CASE WHEN ISNULL(@pMaterialDocTypeName,'') = '' THEN '%' ELSE @pMaterialDocTypeName END

    
	SELECT
			MDT.MaterialDocTypeCode AS OldMaterialDocTypeCode,
			MDT.MaterialDocTypeCode,
			MDT.MaterialDocType,
			MDT.MaterialDocTypeName,
			MDT.MaterialDocTypeNameL,
			MDT.MaterialDocTypeDesc,
			MDT.MaterialDocTypeDescL,
			MDT.MaterialDocTypeGroup,
			MDT.IsProcessBom,
			MDT.IsProcessModelBom,
			MDT.IsAutoCreate,
			MDT.AutoCreateMoveType,
			MDT.IsDecSource,
			MDT.IsIncTarget,
			MDT.IsChangeStockAttribute,
			MDT.IsRequireQC,
			MDT.IsRequireApproval,
			MDT.IsProcessRefDoc,
			MDT.IsDisplay,
			MDT.CreateDateTime,
			MDT.CreateUserID,
			MDT.ChangeDateTime,
			MDT.ChangeUserID
	FROM
			STB_MaterialDocType MDT WITH(NOLOCK)
	WHERE
			(MDT.MaterialDocTypeName LIKE @MaterialDocTypeName) 

END

