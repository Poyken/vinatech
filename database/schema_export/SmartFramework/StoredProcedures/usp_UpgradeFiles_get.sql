-- Procedure: usp_UpgradeFiles_get






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-02-03
-- Browsable : true
-- Group : 시스템
-- Description:	업그레이드 파일리스트를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpgradeFiles_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProgramName NVARCHAR(50) = 'GUI',
    @pFileName NVARCHAR(255) = NULL,
	@pIgnoreBinary BIT = 0

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE	@ProgramName VARCHAR(50) = @pProgramName,
				@FileName NVARCHAR(255) = CASE WHEN ISNULL(@pFileName,'') = '' THEN '*' ELSE @pFileName END

    
	SELECT
			UF.ProgramName AS OldProgramName,
	        UF.FileName AS OldFileName,
			UF.Platform AS OldPlatform,
			UF.ProgramName,
	        UF.FileName,
			UF.Platform,
	        UF.Version,
			CASE @pIgnoreBinary
				WHEN 1 THEN CONVERT(VARBINARY(MAX), NULL)
				ELSE UF.FileData
			END AS FileData,
	        UF.TargetPath,
			UF.ExtractZip,
	        UF.CreateDateTime,
	        UF.CreateUserID,
	        UF.ChangeDateTime,
	        UF.ChangeUserID
	FROM
	        STB_UpgradeFiles UF WITH(NOLOCK)
	WHERE
			UF.ProgramName = @ProgramName AND
	        ((@FileName = '*') OR (UF.FileName = @FileName)) 

END







GO

