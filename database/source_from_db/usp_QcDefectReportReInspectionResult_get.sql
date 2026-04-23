-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2019-10-22
-- Description : 
-- Modified : 2020.05.15 재검결과 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReportReInspectionResult_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20)
AS
BEGIN
	DECLARE @DefectReportNo VARCHAR(20) = @pDefectReportNo
	       ,@RowCnt INT

	SELECT @RowCnt = COUNT(*)
	  FROM STB_QcDefectReportReInspectionResult 
	  WHERE DefectReportNo = @DefectReportNo

	IF @RowCnt = 0 BEGIN 
		SELECT QDRRR.DefectReportNo
			  ,QDRRR.DefectCode
			  ,DI.BasicDefectName
			  ,QDRRR.InspectionQty
			  ,QDRRR.DefectQty
			  ,QDRRR.DefectRate
			  ,QDRRR.CreateDateTime
			  ,QDRRR.CreateUserID
			  ,QDRRR.ChangeDateTime
			  ,QDRRR.ChangeUserID
		  FROM STB_QcDefectReportReInspectionResult QDRRR
		  LEFT OUTER JOIN STB_DefectInfo DI
			ON DI.DefectCode = QDRRR.DefectCode
		 WHERE QDRRR.DefectReportNo = @DefectReportNo
	END ELSE BEGIN
		SELECT QDRRR.DefectReportNo
			  ,QDRRR.DefectCode
			  ,DI.BasicDefectName
			  ,QDRRR.InspectionQty
			  ,QDRRR.DefectQty
			  ,QDRRR.DefectRate
			  ,QDRRR.CreateDateTime
			  ,QDRRR.CreateUserID
			  ,QDRRR.ChangeDateTime
			  ,QDRRR.ChangeUserID
		  FROM STB_QcDefectReportReInspectionResult QDRRR
		  LEFT OUTER JOIN STB_DefectInfo DI
			ON DI.DefectCode = QDRRR.DefectCode
		 WHERE QDRRR.DefectReportNo = @DefectReportNo
		 UNION ALL
		 SELECT 'Total', NULL, NULL, SUM(InspectionQty), SUM(DefectQty)
			   ,CONVERT(NUMERIC(10,2), SUM(DefectQty)) / CONVERT(NUMERIC(10,2), SUM(InspectionQty)) * 100
			   ,NULL, NULL, NULL, NULL
		   FROM STB_QcDefectReportReInspectionResult 
		  WHERE DefectReportNo = @DefectReportNo
	END
END