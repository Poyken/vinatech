-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량유형 그룹정보를 가져옵니다.(popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectGroup_popup]
WITH RECOMPILE, EXECUTE AS CALLER
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT
			DG.DefectGroupCode,
			DG.BasicDefectGroupName,
			DG.DisplayIndex
	FROM
			STB_DefectGroup DG WITH(NOLOCK)
	WHERE
			DG.IsUsed = 1			

END
