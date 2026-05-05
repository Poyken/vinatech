

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
	@pFileID BIGINT = NULL --OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FileID BIGINT = @pFileID,
			@FileExt VARCHAR(20),
			@SystemName VARCHAR(50) = @pSystemName
	
	
	--2016.06.14 수정----------------------------------------
	IF ISNULL(@pFileName,'') <> '' BEGIN
		SET @FileExt = RIGHT( @pFileName, CharIndex('.', REVERSE(@pFileName))-1 )
	END

	--SET @FileExt = RIGHT( @pFileName, CharIndex('.', REVERSE(@pFileName))-1 )
	
	
	
	IF @pFileContents IS NOT NULL
	BEGIN
		--IF @FileID IS NULL
		IF ISNULL(@FileID,'') = ''
		BEGIN	
			INSERT INTO SmartFramework_File.dbo.STB_AttachedFileMaster
				(FileName, FileSize, FileExt, FileContents, SystemName, CreateDateTime, CreateUserID)
			VALUES
				(@pFileName, @pFileSize, @FileExt, @pFileContents, @SystemName, GETDATE(), @pUserID)
			
			SET @pFileID = @@IDENTITY

		END ELSE
		
		 BEGIN

			UPDATE SmartFramework_File.dbo.STB_AttachedFileMaster
			SET
				FileContents = @pFileContents,
				FileName = @pFileName,
				FileSize = @pFileSize,
				FileExt = @FileExt,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pUserID
			WHERE
				FileID = @FileID
		END

	END
	--2016.06.15 Park Jong Hoon(이미지 삭제시) 
	ELSE IF ISNULL(@pFileName,'') = '' 

	BEGIN
			DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
			WHERE
					FileID = @FileID
			SET @pFileID = 0

			---- 추가부분
			--	Update  SmartFramework_File.dbo.STB_AttachedFileMaster 
			--     set  FileName = null
			--	 where 1=1
			--	 and FileID = @FileID
			--	 and FileName = @pFileName


	END
	
END