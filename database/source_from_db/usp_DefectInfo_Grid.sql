-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2022.04.05
-- Browsable : true
-- Group : 
-- Description:	불량유형정보
-- Modified: 
-- Exec usp_DefectInfo_Grid '',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectInfo_Grid]
						@pProcessUserID [varchar](20),
						@pProcessLanguage [varchar](20)
						--@pDefectCode [varchar](20) = NULL,
						--@pBasicDefectName [nvarchar](50) = NULL,
						--@pDefectGroupCode VARCHAR(20) = NULL
WITH EXECUTE AS CALLER

AS
BEGIN
	SET NOCOUNT ON;
   --   DECLARE @DefectCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode,'') = '' THEN '*' ELSE @pDefectCode END
   --   DECLARE @BasicDefectName NVARCHAR(50) = CASE WHEN ISNULL(@pBasicDefectName,'') = '' THEN '*' ELSE @pBasicDefectName END
	  --Declare @DefectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

    
	SELECT
	        DI.DefectCode,
	        DI.BasicDefectName,
	        DI.DefectDesc,
	        DI.DefectGroupCode
	  --      DG.BasicDefectGroupName,
	  --      DG.DisplayIndex AS DefectGroupDisplayIndex,
	  --      DI.DisplayIndex,
	  --      DI.IsRealDefect,
	  --      DI.IsUsed,
	  --      DI.UseGroup,
	  --      DI.DefectImage,
	  --      AFM.[FileName],
			--AFM.FileSize,
			--CONVERT(VARBINARY(MAX),NULL) AS FileData,
	        
	  --      DI.CreateDateTime,
	  --      DI.CreateUserID,
	  --      DI.ChangeDateTime,
	  --      DI.ChangeUserID
	FROM
	        STB_DefectInfo DI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				                                        ON DI.DefectGroupCode = DG.DefectGroupCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)				ON AFM.FileID = DI.DefectImage
	WHERE 1=1
	  --AND 	        ((@DefectCode = '*') OR (DI.DefectCode = @DefectCode)) 
	  --AND	        ((@BasicDefectName = '*') OR (DI.BasicDefectName LIKE @BasicDefectName + '%')) 
	  --AND 			((@DefectGroupCode = '*') OR (DI.DefectGroupCode = @DefectGroupCode)) 

END
