-- =============================================
-- Author: Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018.08.06
-- Browsable : true
-- Group : 품질관리
-- Description:	불량유형 그룹정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectGroup_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20)
WITH EXECUTE AS CALLER
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
	        DG.DefectGroupCode AS OldDefectGroupCode,
	        DG.DefectGroupCode,
	        DG.BasicDefectGroupName,
	        DG.UseGroup,
	        DG.DisplayIndex,
	        DG.IsUsed,
	        DG.CreateDateTime,
	        DG.CreateUserID,
	        DG.ChangeDateTime,
	        DG.ChangeUserID
	FROM
	        STB_DefectGroup DG WITH(NOLOCK)

END
