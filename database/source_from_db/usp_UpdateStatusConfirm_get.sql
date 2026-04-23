-- =============================================

-- =============================================
CREATE  PROCEDURE [dbo].[usp_UpdateStatusConfirm_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pExportReferenceNo int= NULL
AS
BEGIN
	SET NOCOUNT ON;
    update Stb_ExportReference set status_confirm = 1 where ID=@pExportReferenceNo
	
END
