-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량원인정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pDefectCauseCode [varchar](20) = NULL,
	@pBasicDefectCauseName [nvarchar](50) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @DefectCauseCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCauseCode,'') = '' THEN '*' ELSE @pDefectCauseCode END
      DECLARE @BasicDefectCauseName NVARCHAR(50) = CASE WHEN ISNULL(@pBasicDefectCauseName,'') = '' THEN '*' ELSE @pBasicDefectCauseName END

    
	SELECT
	        DCI.DefectCauseCode AS OldDefectCauseCode,
	        DCI.DefectCauseCode,
	        DCI.BasicDefectCauseName,
	        DCI.DefectCauseDesc,
	        DCI.DefectCauseGroupCode,
	        DCG.BasicDefectCauseGroupName,
	        DCG.DisplayIndex,
	        DCI.DisplayIndex AS DefectCauseDisplayIndex,
	        DCI.IsUsed,
	        DCI.CreateDateTime,
	        DCI.CreateUserID,
	        DCI.ChangeDateTime,
	        DCI.ChangeUserID
	FROM
	        STB_DefectCauseInfo DCI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_DefectCauseGroup DCG WITH(NOLOCK)
				ON DCI.DefectCauseGroupCode = DCG.DefectCauseGroupCode
	WHERE
	        ((@DefectCauseCode = '*') OR (DCI.DefectCauseCode = @DefectCauseCode)) AND
	        ((@BasicDefectCauseName = '*') OR (DCI.BasicDefectCauseName LIKE @BasicDefectCauseName + '%')) 

END
