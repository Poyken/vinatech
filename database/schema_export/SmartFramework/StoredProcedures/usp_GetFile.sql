-- Procedure: usp_GetFile






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-02-25
-- Description:	Get Attached File
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFile]
	@pFileID BIGINT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			AFM.FileID,
			AFM.FileName,
			ISNULL(AFM.FileSize,0) AS FileSize,
			AFM.FileExt,
			AFM.FileContents,
			AFM.SystemName,
			AFM.CreateDateTime,
			AFM.CreateUserID,
			AFM.ChangeDateTime,
			AFM.ChangeUserID
    FROM
			SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
	WHERE
			AFM.FileID = @pFileID
END







GO

