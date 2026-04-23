-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-10-18
-- Browsable : true
-- Group : 팝업
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionItemForSpec_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pQcInspectionGroupCode VARCHAR(MAX) = NULL,
	@pQcInspectionItemCodeList VARCHAR(MAX) = NULL
AS
BEGIN
	Declare @QcInspectionGroupCode VARCHAR(MAX) = CASE WHEN ISNULL(@pQcInspectionGroupCode, '') = '' THEN '*' ELSE @pQcInspectionGroupCode END
	       ,@QcInspectionItemCodeList VARCHAR(MAX) = CASE WHEN ISNULL(@pQcInspectionItemCodeList, '') = '' THEN '*' ELSE @pQcInspectionItemCodeList END

	SELECT QIG.QcInspectionGroupName
	      ,QII.QcInspectionItemCode
	      ,QII.QcInspectionItemName
	  FROM STB_QcInspectionGroup QIG
	          INNER JOIN STB_QcInspectionItem QII	     ON QIG.QcInspectionGroupCode = QII.QcInspectionGroupCode
	 WHERE (@QcInspectionGroupCode = '*' OR QIG.QcInspectionGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@QcInspectionGroupCode)))
	   AND (@QcInspectionItemCodeList = '*' OR QII.QcInspectionItemCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@QcInspectionItemCodeList)))
	 ORDER BY QIG.QcInspectionGroupCode

END