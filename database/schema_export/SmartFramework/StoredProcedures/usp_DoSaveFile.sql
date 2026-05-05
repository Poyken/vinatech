-- Procedure: usp_DoSaveFile






-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.05.04
-- Description:	첨부파일을 등록합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveFile]
	@pSystemName VARCHAR(50) = NULL,
	@pFileContents VARBINARY(MAX) = NULL,
	@pFileName NVARCHAR(255) = NULL,
	@pFileSize BIGINT = NULL,
	@pUserID VARCHAR(20) = NULL,
	@pFileID BIGINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FileID BIGINT = @pFileID,
			@FileExt VARCHAR(20),
			@SystemName VARCHAR(50) = @pSystemName
	
	SET @FileExt = RIGHT( @pFileName, CharIndex('.', REVERSE(@pFileName))-1 )
	
	IF @pFileName IS NULL
	BEGIN
		DELETE FROM	SmartFramework_File.dbo.STB_AttachedFileMaster
		WHERE
				FileID = @FileID
	END
	ELSE IF @FileID IS NULL
	BEGIN	
			INSERT INTO SmartFramework_File.dbo.STB_AttachedFileMaster
				(FileName, FileSize, FileExt, FileContents, SystemName, CreateDateTime, CreateUserID)
			VALUES
				(@pFileName, @pFileSize, @FileExt, @pFileContents, @SystemName, GETDATE(), @pUserID)
			
			SET @pFileID = @@IDENTITY

	END ELSE BEGIN
			UPDATE SmartFramework_File.dbo.STB_AttachedFileMaster
			SET
				FileContents = @pFIleContents,
				FileName = @pFileName,
				FileSize = @pFileSize,
				FileExt = @FileExt,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pUserID
			WHERE
				FileID = @FileID	
				
			SET @pFileID = @FileID
	END
END







GO

