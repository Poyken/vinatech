-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-29
-- Browsable : true
-- Group : 품질관리
-- Description: 전극측정결과 일괄업로드용
-- Modified:
-- =============================================

CREATE PROCEDURE usp_ElectrodeRouteInspHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	SELECT ERIH.ElectrodeRouteInspHistNo
      ,ERIH.MeasureDate
      ,ERIH.MaterialName
      ,ERIH.Barcode
      ,ERIH.REQ_A011
      ,ERIH.REQ_A021
      ,ERIH.REQ_A031
	  ,ERIH.REQ_A012
      ,ERIH.REQ_A022
      ,ERIH.REQ_A032
	  ,ERIH.REQ_A013
      ,ERIH.REQ_A023
      ,ERIH.REQ_A033
      ,ERIH.REQ_W01
      ,ERIH.REQ_W02
      ,ERIH.REQ_W03
      ,ERIH.REQ_E01
      ,ERIH.REQ_E02
      ,ERIH.REQ_E03
      ,ERIH.Remark
      ,ERIH.InspWorkerName
      ,ERIH.CreateDateTime
      ,ERIH.ProcessDateTime
  FROM STB_ElectrodeRouteInspHist ERIH
END