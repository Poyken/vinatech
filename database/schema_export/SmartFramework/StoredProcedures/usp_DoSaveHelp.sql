-- Procedure: usp_DoSaveHelp






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr
-- Create date: 2016-07-21
-- Description:	도움말을 추가합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveHelp]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pId VARCHAR(20) = NULL OUTPUT,
	@pParentId VARCHAR(20) = NULL,
	@pTitle NVARCHAR(100),
	@pIsFolder BIT,
	@pContents VARBINARY(MAX) = NULL,
	@pChangeDefault BIT = 0
AS
BEGIN
	SET NOCOUNT ON;
		
    IF ISNULL(@pId,'') = '' BEGIN
		SELECT
				@pId = ISNULL(MAX(CONVERT(BIGINT,H.Id)),0) + 1
		FROM
				STB_Help H

		INSERT INTO STB_Help
		(
			Id,
			ParentId,
			Title,
			IsFolder,
			Contents,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@pId,
			@pParentId,
			@pTitle,
			@pIsFolder,
			@pContents,
			GETDATE(),
			@pProcessUserID
		)

		INSERT INTO STB_HelpLanguage
		(
			Id,
			Language,
			Title,			
			Contents,
			ChangeDateTime,
			ChangeUserID
		)
		VALUES
		(
			@pId,
			@pProcessLanguage,
			@pTitle,
			@pContents,
			GETDATE(),
			@pProcessUserID
		)
	END ELSE BEGIN
		UPDATE	STB_Help
		SET
				ParentId = @pParentId,
				Title = CASE @pChangeDefault
							WHEN 1 THEN @pTitle 
							ELSE Title
						END,
				--IsFolder = @pIsFolder,
				Contents = CASE @pChangeDefault
								WHEN 1 THEN ISNULL(@pContents,Contents)
								ELSE Contents
							END,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE
				Id = @pId

		UPDATE
				STB_HelpLanguage
		SET
				Title = @pTitle,
				Contents = ISNULL(@pContents,Contents),
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE
				Id = @pId
		IF @@ROWCOUNT = 0 BEGIN
			INSERT INTO STB_HelpLanguage
			(
				Id,
				Language,
				Title,			
				Contents,
				ChangeDateTime,
				ChangeUserID
			)
			VALUES
			(
				@pId,
				@pProcessLanguage,
				@pTitle,
				@pContents,
				GETDATE(),
				@pProcessUserID
			)
		END
	END
END







GO

