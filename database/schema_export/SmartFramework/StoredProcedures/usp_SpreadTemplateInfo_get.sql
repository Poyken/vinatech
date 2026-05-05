-- Procedure: usp_SpreadTemplateInfo_get







-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-16
-- Browsable : false
-- Group : 시스템
-- Description:	Spread Report용 템플릿 파일을 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SpreadTemplateInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pTemplateName NVARCHAR(100) = NULL,
	@pIncludeFile BIT = 0

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @TemplateName NVARCHAR(100) = CASE WHEN ISNULL(@pTemplateName,'') = '' THEN '*' ELSE @pTemplateName END

    
	SELECT
	        STI.TemplateName AS OldTemplateName,
	        STI.TemplateName,
	        STI.TemplateDescription,
	        STI.FileID,
	        AFM.FileName,
	        AFM.FileExt,
	        AFM.FileSize,
			CASE @pIncludeFile
				WHEN 1 THEN AFM.FileContents
				ELSE CONVERT(VARBINARY(MAX), NULL) 
			END AS [FileContents],
	        STI.CreateDateTime,
	        STI.CreateUserID,
	        STI.ChangeDateTime,
	        STI.ChangeUserID
	FROM
	        SmartFramework_File.dbo.STB_SpreadTemplateInfo STI WITH(NOLOCK)
	        LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = STI.FileID)
	WHERE
	        ((@TemplateName = '*') OR (STI.TemplateName LIKE '%' + @TemplateName + '%')) 

END







GO

