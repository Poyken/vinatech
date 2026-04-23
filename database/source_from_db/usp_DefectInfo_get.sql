-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리 > [C132] 불량증상정보
-- Description:	불량유형정보를 가져옵니다.
-- Modified: 
-- exec usp_DefectInfo_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pDefectCode [varchar](20) = NULL,
	@pBasicDefectName [nvarchar](50) = NULL,
	@pDefectGroupCode VARCHAR(20) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @DefectCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END
      DECLARE @BasicDefectName NVARCHAR(50) = CASE WHEN ISNULL(@pBasicDefectName,'') = '' THEN '*' ELSE @pBasicDefectName END
	  Declare @DefectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

    
	SELECT
	        DI.DefectCode AS OldDefectCode,
	        DI.DefectCode,
	        DI.BasicDefectName,
	        DI.DefectDesc,
	        DI.DefectGroupCode,
	        DG.BasicDefectGroupName,
	        DG.DisplayIndex AS DefectGroupDisplayIndex,
	        DI.DisplayIndex,
	        DI.IsRealDefect,
	        DI.IsUsed,
	        DI.UseGroup,
	        DI.DefectImage,
			DI.DirectlyUnder,
	        AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
	        
	        DI.CreateDateTime,
	        DI.CreateUserID,
	        DI.ChangeDateTime,
	        DI.ChangeUserID,
			DI.WorkCenterCode,
			DI.DefectCause
	FROM
	        STB_DefectInfo DI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				                                        ON DI.DefectGroupCode = DG.DefectGroupCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)				ON AFM.FileID = DI.DefectImage
	WHERE
	        ((@DefectCode = '*') OR (DI.DefectCode = @DefectCode)) AND
	        ((@BasicDefectName = '*') OR (DI.BasicDefectName LIKE @BasicDefectName + '%')) AND 
			((@DefectGroupCode = '*') OR (DI.DefectGroupCode = @DefectGroupCode)) 

END
