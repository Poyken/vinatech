-- Procedure: usp_DoSaveSnapDocumentVersion


-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date : 2017-08-03
-- Description : Snap 버전을 추가합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveSnapDocumentVersion]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pVersion INT,
	@pDescription NVARCHAR(MAX) = NULL,
	@pApplyDate DATE = NULL,
	@pLayout NVARCHAR(MAX) = NULL,
	@pPreviewPDF NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId,
			@Version INT = @pVersion

	UPDATE	STB_SnapDocumentsVersion
	SET
			VersionDescription = ISNULL(@pDescription,VersionDescription),
			Layout = ISNULL(dbo.fnBase64ToBinary(@pLayout),Layout),
			PreviewPDF = ISNULL(dbo.fnBase64ToBinary(@pPreviewPDF), PreviewPDF),
			ApplyDate = ISNULL(@pApplyDate,ApplyDate),
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			DocumentId = @DocumentId AND
			Version = @Version
END


GO

