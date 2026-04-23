-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량원인 그룹정보를 가져옵니다.(popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectCauseGroup_popup]
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN

	SET NOCOUNT ON;
	
	SELECT
			DCG.DefectCauseGroupCode,
			DCG.BasicDefectCauseGroupName,
			DCG.DisplayIndex
	FROM
			STB_DefectCauseGroup DCG WITH(NOLOCK)
	WHERE
			DCG.IsUsed = 1		

END

