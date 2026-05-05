-- Procedure: usp_DoSaveDiagram




-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-07-03
-- Browsable: false
-- Description:	Diagram 을 저장합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveDiagram]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSeqNo BIGINT = 0 OUTPUT,
	@pTitle NVARCHAR(200),
	@pDescription NVARCHAR(MAX) = NULL,
	@pKeywords NVARCHAR(MAX) = NULL,
	@pDiagram NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @SeqNo BIGINT = @pSeqNo
	DECLARE @Diagram VARBINARY(MAX) = dbo.fnBase64ToBinary(@pDiagram)
	DECLARE @Size BIGINT = DATALENGTH(@Diagram)
	DECLARE @FileID BIGINT
	DECLARE @SystemCode VARCHAR(20)

	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI
	WHERE
			UI.UserID = @ProcessUserID
	
	SELECT
			@FileID = D.FileID
	FROM
			STB_Diagrams D
	WHERE
			D.SeqNo = @SeqNo

	IF @SeqNo > 0 BEGIN
		EXEC usp_DoSaveFile @pSystemName = 'DIAGRAM',
							@pFileContents = @Diagram,
							@pFileSize = @Size,
							@pUserID = @pProcessUserID,
							@pFileID = @FileID OUTPUT

		UPDATE
				STB_Diagrams
		SET
				Title = @pTitle,
				Description = @pDescription,
				Keywords = @pKeywords,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE
				SeqNo = @SeqNo
	END ELSE BEGIN
		SELECT 
				@SeqNo = ISNULL(MAX(SeqNo),0) + 1
		FROM 
				STB_Diagrams D

		EXEC usp_DoSaveFile @pSystemName = 'DIAGRAM',
							@pFileContents = @Diagram,
							@pFileSize = @Size,
							@pUserID = @pProcessUserID,
							@pFileID = @FileID OUTPUT

		INSERT INTO STB_Diagrams
		(
			SeqNo,
			SystemCode,
			Title,
			Description,
			Keywords,
			FileID,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@SeqNo,
			@SystemCode,
			@pTitle,
			@pDescription,
			@pKeywords,
			@FileID,
			GETDATE(),
			@pProcessUserID
		)

		SET @pSeqNo = @SeqNo
	END
END





GO

