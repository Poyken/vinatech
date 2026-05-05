-- Procedure: usp_DoAddSnapDocumentVersion


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-03
-- Description : Snap 버전을 추가합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddSnapDocumentVersion]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pVersion INT,
	@pDescription NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@Version INT = @pVersion,
			@DocumentId VARCHAR(20) = @pDocumentId

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
		ApplyDate,
		IsApproval,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@DocumentId,
		@Version,
		@pDescription,
		GETDATE(),
		0,
		GETDATE(),
		@ProcessUserID
	)
END


GO

