-- Procedure: usp_DoDeleteSnapDocumentVersion


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-03
-- Description : Snap 버전을 삭제합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteSnapDocumentVersion]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pVersion INT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId,
			@Version INT = @pVersion

	DELETE FROM	STB_SnapDocumentsVersion
	WHERE
			DocumentId = @DocumentId AND
			Version = @Version
END


GO

