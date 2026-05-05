-- Procedure: usp_DoDeleteSnapDocument


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-03
-- Description : Snap 문서를 삭제합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteSnapDocument]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId

	DELETE FROM STB_SnapDocuments
	WHERE	DocumentId = @DocumentId

	DELETE FROM STB_SnapDocumentsVersion
	WHERE	DocumentId = @DocumentId
END


GO

