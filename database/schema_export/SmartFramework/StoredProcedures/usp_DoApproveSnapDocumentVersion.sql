-- Procedure: usp_DoApproveSnapDocumentVersion


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date : 2017-08-03
-- Description : Snap 버전을 승인합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoApproveSnapDocumentVersion]
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

	UPDATE	STB_SnapDocumentsVersion
	SET
			IsApproval = 1,
			ApprovalUserID = @ProcessUserID,
			ApprovalDateTime = GETDATE(),
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			DocumentId = @DocumentId AND
			Version = @Version
END


GO

