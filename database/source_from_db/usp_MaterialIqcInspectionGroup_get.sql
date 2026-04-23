

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : true
-- Group : 품질관리
-- Description:	자재별수입검사그룹을 조회합니다
-- Modified:
-- 프로시저 실행문 :  usp_MaterialIqcInspectionGroup_get '','','ECVT27-382'
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialIqcInspectionGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

    
	SELECT
	        MIIG.MaterialCode AS OldMaterialCode,
	        MIIG.QcInspectionGroupCode AS OldQcInspectionGroupCode,
	        MIIG.MaterialCode,
	        MIIG.QcInspectionGroupCode,
	        IIG.QcInspectionGroupName,
	        IIG.QcInspectionGroupDesc,
	        MIIG.GroupInspectionPrior,
	        MIIG.GroupReportPrior,
	        MIIG.IsUsed,
	        MIIG.CreateDateTime,
	        MIIG.CreateUserID,
	        MIIG.ChangeDateTime,
	        MIIG.ChangeUserID
	FROM
	        STB_MaterialQcInspectionGroup MIIG WITH(NOLOCK)
	        LEFT OUTER JOIN STB_QcInspectionGroup IIG WITH(NOLOCK)				ON MIIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode
	WHERE
	        ((MIIG.MaterialCode = @MaterialCode)) 

END


