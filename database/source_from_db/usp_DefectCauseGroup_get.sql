-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량원인 그룹정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseGroup_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pDefectCauseGroupCode [varchar](20) = NULL
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefectCauseGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCauseGroupCode,'') = '' THEN '*' ELSE @pDefectCauseGroupCode END
    
	SELECT
			DCG.DefectCauseGroupCode AS OldDefectCauseGroupCode,
	        DCG.DefectCauseGroupCode,
	        DCG.BasicDefectCauseGroupName,
	        DCG.DisplayIndex,
	        DCG.IsUsed,
	        DCG.CreateDateTime,
	        DCG.CreateUserID,
	        DCG.ChangeDateTime,
	        DCG.ChangeUserID
	FROM
	        STB_DefectCauseGroup DCG WITH(NOLOCK)
	WHERE
			((@DefectCauseGroupCode = '*') OR (DCG.DefectCauseGroupCode = @DefectCauseGroupCode))

END
