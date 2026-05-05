-- Procedure: usp_GetSnapDocumentLayout



-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date : 2017-08-02
-- Description : Snap문서 현재버전리스트를 가져옵니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSnapDocumentLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDocumentId VARCHAR(20),
	@pVersion INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DocumentId VARCHAR(20) = @pDocumentId,
			@Version INT = @pVersion

	SELECT
			SDV.DocumentId,
			SDV.Version,
			SDV.ApplyDate,
			SDV.Layout,
			SDV.PreviewPDF,
			SDV.IsApproval,
			SDV.ApprovalUserID,
			SDV.ApplyDate,
			SDV.CreateDateTime,
			SDV.CreateUserID,
			SDV.ChangeDateTime,
			SDV.ChangeUserID
	FROM
			STB_SnapDocumentsVersion SDV WITH(NOLOCK)
	WHERE
			SDV.DocumentId = @DocumentId AND			
			(
				((@Version IS NOT NULL) AND (SDV.Version = @Version)) OR
				((@Version IS NULL) AND 
				 (
					SDV.IsApproval = 1 AND
					SDV.ApplyDate =	(
										SELECT
												MAX(ApplyDate)
										FROM
												STB_SnapDocumentsVersion
										WHERE
												DocumentId = @DocumentId AND
												IsApproval = 1 AND
												ApplyDate <= GETDATE()
									)
				))
			)
END


GO

