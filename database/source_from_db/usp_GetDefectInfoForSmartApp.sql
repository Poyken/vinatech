-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018.09.06
-- Browsable : true
-- Group : 현장용
-- Description:	불량유형정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDefectInfoForSmartApp]
	@pDefectGroupCode VARCHAR(20) = NULL,
	@pUseGroup NVARCHAR(100) = NULL
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '%' ELSE @pDefectGroupCode END
	DECLARE @UseGroup NVARCHAR(100) = CASE WHEN ISNULL(@pUseGroup,'') = '' THEN '%' ELSE @pUseGroup END
	
	SELECT
			DI.DefectCode,
			DI.BasicDefectName,
			DI.DefectDesc,
			DI.IsRealDefect,
			DI.UseGroup,
			AFM.FileContents AS DefectImage
	FROM
			STB_DefectInfo DI WITH(NOLOCK)
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH(NOLOCK)
				ON AFM.FileID = DI.DefectImage
	WHERE
			DI.DefectGroupCode LIKE @DefectGroupCode AND
			DI.UseGroup LIKE @UseGroup AND
			DI.IsUsed = 1
	ORDER BY
			DI.DisplayIndex

END
