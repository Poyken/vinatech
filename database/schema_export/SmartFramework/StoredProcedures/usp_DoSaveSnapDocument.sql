-- Procedure: usp_DoSaveSnapDocument


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date : 2017-08-03
-- Description : Snap 문서를 수정합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveSnapDocument]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pDocumentName NVARCHAR(100),
	@pDocumentDescription NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId

	UPDATE	STB_SnapDocuments
	SET
			DocumentName = @pDocumentName,
			DocumentDescription = @pDocumentDescription,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			DocumentId = @DocumentId
END


GO

