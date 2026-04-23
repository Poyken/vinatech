-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-10-22
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReportImage_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL,
	@pImageDivisionCode VARCHAR(10) = NULL
AS
BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	       ,@ImageDivisionCode VARCHAR(10) = @pImageDivisionCode


	SELECT CASE WHEN @ImageDivisionCode = '1' THEN QDR.DefectImage ELSE QDR.ProdCauseImage END AS TargetImage
	  FROM STB_QcDefectReport QDR
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo
END