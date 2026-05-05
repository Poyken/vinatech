-- Procedure: usp_DoDeleteFile






-- =============================================
-- Author:		Kim Han Young(jspark@awoo.co.kr)
-- Create date: 2016.07.03
-- Browsable: false
-- Description:	첨부파일을 삭제합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteFile]
	@pFileID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FileID BIGINT = @pFileID
	
	DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster 
	WHERE	FileID = @FileID
END







GO

