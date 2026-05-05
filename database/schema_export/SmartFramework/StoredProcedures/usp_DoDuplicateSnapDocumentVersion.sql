-- Procedure: usp_DoDuplicateSnapDocumentVersion


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-03
-- Description : Snap 버전을 복제합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDuplicateSnapDocumentVersion]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pOriginalVersion INT,
	@pVersion INT,
	@pDescription NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId,
			@OriginalVersion INT = @pOriginalVersion,
			@Version INT = @pVersion

	IF EXISTS ( SELECT 1 FROM STB_SnapDocumentsVersion SDV WHERE DocumentId = @DocumentId AND Version = @Version) BEGIN
		DECLARE @DuplicateError NVARCHAR(MAX)
		EXEC usp_GetSystemStringResource @ProcessLanguage,
											'^The same version already exists.^',
											@DuplicateError OUTPUT
		RAISERROR(@DuplicateError,16,1)
		RETURN
	END

	INSERT INTO STB_SnapDocumentsVersion
	(
		DocumentId,
		Version,
		VersionDescription,
		Layout,
		PreviewPDF,
		IsApproval,
		ChangeDateTime,
		CreateUserID
	)
	SELECT
			SDV.DocumentId,
			@Version,
			@pDescription,
			SDV.Layout,
			SDV.PreviewPDF,
			0,
			GETDATE(),
			@ProcessUserID
	FROM
			STB_SnapDocumentsVersion SDV
	WHERE
			SDV.DocumentId = @DocumentId AND
			SDV.Version = @OriginalVersion
END


GO

