-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pQcInspectionGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @QcInspectionGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionGroupCode,'') = '' THEN '*' ELSE @pQcInspectionGroupCode END

    
	SELECT
	        QIG.QcInspectionGroupCode AS OldQcInspectionGroupCode,
	        QIG.QcInspectionGroupCode,
	        QIG.QcInspectionGroupName,
	        QIG.QcInspectionGroupDesc,
	        QIG.IsUsed,
	        QIG.CreateDateTime,
	        QIG.CreateUserID,
	        QIG.ChangeDateTime,
	        QIG.ChangeUserID
	FROM
	        STB_QcInspectionGroup QIG WITH(NOLOCK)
	WHERE
	        ((@QcInspectionGroupCode = '*') OR (QIG.QcInspectionGroupCode = @QcInspectionGroupCode)) 

END
