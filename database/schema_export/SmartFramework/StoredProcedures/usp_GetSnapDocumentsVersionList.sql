-- Procedure: usp_GetSnapDocumentsVersionList



-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date : 2017-08-02
-- Description : Snap문서 버전리스트를 가져옵니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSnapDocumentsVersionList]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId

	SELECT
			SDV.DocumentId AS OldDocumentId,
			SDV.Version AS OldVersion,
			SDV.DocumentId,
			SDV.Version,
			SDV.VersionDescription,
			SDV.ApplyDate,
			SDV.IsApproval,
			SDV.ApprovalUserID,
			SDV.ApprovalDateTime,
			SDV.CreateDateTime,
			SDV.CreateUserID,
			SDV.ChangeDateTime,
			SDV.ChangeUserID
	FROM
			STB_SnapDocumentsVersion SDV WITH(NOLOCK)
	WHERE
			SDV.DocumentId = @DocumentId
	ORDER BY
			SDV.Version
END


GO

