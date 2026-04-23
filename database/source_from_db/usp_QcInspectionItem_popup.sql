
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-10
-- Browsable : true
-- Group : 팝업
-- Description:	수입검사 항목정보를 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionItem_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pQcInspectionGroupCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @QcInspectionGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionGroupCode,'') = '' THEN '%' ELSE @pQcInspectionGroupCode END
    
	SELECT
	        QII.QcInspectionItemCode,
	        QII.QcInspectionItemName,
	        QII.QcInspectionItemDesc,
	        QII.IsCanSkip,
	        QII.InspectionType,
	        QII.QcSpecDesc,
	        QII.InspectionLevel,
	        QII.AQL,
	        QII.SpecValue,
	        QII.USL,
	        QII.LSL,
	        QII.UCL,
	        QII.LCL,
	        QII.TextSpecValue
	FROM
	        STB_QcInspectionItem QII WITH(NOLOCK)
	WHERE
	        QII.QcInspectionGroupCode LIKE @QcInspectionGroupCode

END

