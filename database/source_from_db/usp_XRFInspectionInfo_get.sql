-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-05-02
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	XRF검사결과를 조회합니다.
-- Modified:
-- =============================================
CREATE PROC usp_XRFInspectionInfo_get
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

	SELECT XII.InspectionNo
          ,XII.MachineID
		  ,IMI.MachineName
          ,XII.LotNo
          ,XII.Barcode
          ,XII.Idx
          ,XII.RunTime
          ,XII.Detector
          ,XII.Result1
          ,XII.Result2
          ,XII.Result3
          ,XII.LogDateTime
	  FROM STB_XRFInspectionInfo XII
	  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	    ON IMI.MachineID = XII.MachineID
	 WHERE XII.LogDateTime BETWEEN @FromDate AND @ToDate
	   AND (@Barcode = '*' OR XII.Barcode = @Barcode)
	 ORDER BY XII.LogDateTime
END