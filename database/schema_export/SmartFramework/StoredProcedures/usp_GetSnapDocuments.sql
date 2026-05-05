-- Procedure: usp_GetSnapDocuments



-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date : 2017-08-02
-- Description : Snap 문서리스트를 가져옵니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSnapDocuments]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pScreenName VARCHAR(50) = NULL,
	@pViewName VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ScreenName VARCHAR(50) = CASE WHEN ISNULL(@pScreenName,'') = '' THEN '*' ELSE @pScreenName END,
			@ViewName VARCHAR(100) = CASE WHEN ISNULL(@pViewName,'') = '' THEN '*' ELSE @pViewName END

	SELECT
			SD.DocumentId AS OldDocumentId,
			SD.DocumentId,
			SD.DocumentName,
			SD.DocumentDescription,
			SD.ScreenName,
			SSR.Value AS ScreenCaption,
			SD.ViewName,
			VSR.Value AS ViewCaption,
			ISNULL((
				SELECT
						TOP 1
						SDV.Version
				FROM
						STB_SnapDocumentsVersion SDV WITH(NOLOCK)
				WHERE
						SDV.DocumentId = SD.DocumentId AND
						--SDV.IsApproval = 1 AND
						SDV.ApplyDate =		(
												SELECT 
														MAX(ApplyDate) 
												FROM 
														STB_SnapDocumentsVersion WITH(NOLOCK) 
												WHERE 
														DocumentId = SD.DocumentId AND 
														--IsApproval = 1 AND
														ApplyDate <= GETDATE()
											)
			),0) AS ActiveVersion,
			SD.CreateDateTime,
			SD.CreateUserID,
			SD.ChangeDateTime,
			SD.ChangeUserID
	FROM
			STB_SnapDocuments SD WITH(NOLOCK)
			LEFT OUTER JOIN STB_ScreenInfo SI WITH(NOLOCK)
				ON	SI.Name = SD.ScreenName
			LEFT OUTER JOIN STB_StringResources SSR WITH(NOLOCK)
				ON	SSR.Language = @ProcessLanguage AND
					SSR.Type = 'Addon' AND
					SSR.Name = SI.Caption
			LEFT OUTER JOIN STB_ScreenObjects SO WITH(NOLOCK)
				ON	SO.ScreenName = SD.ScreenName AND
					SO.ObjectName = 'View' AND
					SO.ObjectName = SD.ViewName
			LEFT OUTER JOIN STB_StringResources VSR WITH(NOLOCK)
				ON	VSR.Language = @ProcessLanguage AND
					VSR.Type = 'Addon' AND
					VSR.Name = SO.Caption

	WHERE
			((@ScreenName = '*') OR (SD.ScreenName = @ScreenName)) AND
			((@ViewName = '*') OR (SD.ViewName = @ViewName))
	ORDER BY
			SD.DocumentId
END


GO

