-- Procedure: usp_DoAddSnapDocument


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-03
-- Description : Snap 문서를 추가합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddSnapDocument]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentName NVARCHAR(100),
	@pDocumentDescription NVARCHAR(MAX),
	@pScreenName VARCHAR(50),
	@pViewName VARCHAR(100),
	@pDocumentId VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20)

	EXEC usp_DoCreateSerial 'SmartFramework.STB_SnapDocuments', @DocumentId OUTPUT

	SET @pDocumentId = @DocumentId

	INSERT INTO STB_SnapDocuments
	(
		DocumentId,
		DocumentName,
		DocumentDescription,
		ScreenName,
		ViewName,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@DocumentId,
		@pDocumentName,
		@pDocumentDescription,
		@pScreenName,
		@pViewName,
		GETDATE(),
		@ProcessUserID
	)

	INSERT INTO STB_SnapDocumentsVersion
	(
		DocumentId,
		Version,
		ApplyDate,
		IsApproval,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@DocumentId,
		1,
		CONVERT(DATE,GETDATE()),
		0,
		GETDATE(),
		@ProcessUserID
	)
END


GO

