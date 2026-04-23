-- =============================================
-- Author:		소병운
-- Create date: 2026-04-17
-- GROUP : 공통
-- Description:	자재별 리비전 - 공급망 관리 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialVendor_get]
	-- Add the parameters for the stored procedure here
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	Declare @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	SET NOCOUNT ON;

	SELECT 
		MaterialCode,
		Revision,
		SupplierSeq,
		SupplierType,
		MfrName,
		MfrPartNumber,
		MfrPartLifecycle,
		MfrPartDesc,
		SupplierName,
		SupplierPartNumber,
		SupplierSite,
		PreferredStatus,
		AslEnabled,
		AslOrgList,
		SupplierComments,
		RefNotes,
		DocumentSaveCode,
		IsActive,
		CreateDateTime,
		CreateUserID,
		ChangeDateTime,
		ChangeUserID
	FROM STB_MaterialVendor	WITH(NOLOCK)
	WHERE
		(@MaterialCode = '*' OR MaterialCode = @MaterialCode)
END