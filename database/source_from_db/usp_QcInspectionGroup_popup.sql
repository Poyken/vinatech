-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	QC검사그룹 팝업을 조회합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_popup]
AS
BEGIN
	SET NOCOUNT ON;
    
	SELECT
	        QIG.QcInspectionGroupCode,
	        QIG.QcInspectionGroupName,
	        QIG.QcInspectionGroupDesc
	FROM
	        STB_QcInspectionGroup QIG WITH(NOLOCK)
	WHERE
	        ((QIG.IsUsed = 1)) 

END
