-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-05-02
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	비전검사결과 요약정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_VisionInspectionResult_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END

	SELECT VIR.ResultNo
          ,VIR.MachineID
		  ,IMI.MachineName
          ,VIR.LotNo
          ,VIR.Barcode
          ,VIR.ModelNo
          ,VIR.PannelID
          ,VIR.DecisionResult
          ,VIR.DefectNo
          ,VIR.DotBlackType
          ,VIR.LineBlackType
          ,VIR.MuraBlackType
          ,VIR.DotWhiteType
          ,VIR.LineWhiteType
          ,VIR.MuraWhiteType
          ,VIR.ExtenedType
          ,VIR.etc
		  ,VIR.Pitch
		  ,RIGHT(LEFT(VIR.SheetSize, 10),6) AS SheetSizeW
		  ,RIGHT(LEFT(VIR.SheetSize, 19),6) AS SheetSizeH
          ,VIR.DecisionDateTime
          ,VIR.CreateDateTime
	  FROM STB_VisionInspectionResult VIR
	  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	    ON IMI.MachineID = VIR.MachineID
	 WHERE VIR.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR VIR.Barcode = @Barcode)
	 ORDER BY VIR.CreateDateTime
END
