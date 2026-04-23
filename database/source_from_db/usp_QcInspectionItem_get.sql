-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 항목정보를 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionItem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pQcInspectionGroupCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @QcInspectionGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionGroupCode,'') = '' THEN '' ELSE @pQcInspectionGroupCode END

    
	SELECT
	        QII.QcInspectionItemCode AS OldQcInspectionItemCode,
	        QII.QcInspectionItemCode,
	        QII.QcInspectionGroupCode,
	        QII.QcInspectionItemName,
	        QII.QcInspectionItemDesc,
	        QII.ItemInspectionPrior,
	        QII.ItemReportPrior,
	        QII.IsCanSkip,
	        QII.InspectionType,
	        QII.IsMaterialSpec,
	        QII.QcSpecDesc,
	        QII.InspectionLevel,
	        QII.AQL,
	        QII.SpecValue,
			QII.IsHideOrShowHistory, -- Mr.Duy add show hide history C540
	        QII.USL,
	        QII.LSL,
	        QII.UCL,
	        QII.LCL,
	        QII.TextSpecValue,
	        QII.CreateDateTime,
	        QII.CreateUserID,
	        QII.ChangeDateTime,
	        QII.ChangeUserID
	FROM
	        STB_QcInspectionItem QII WITH(NOLOCK)
	WHERE
	        ((QII.QcInspectionGroupCode = @QcInspectionGroupCode))

END
