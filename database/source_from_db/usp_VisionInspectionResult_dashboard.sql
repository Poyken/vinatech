CREATE PROC usp_VisionInspectionResult_dashboard
	@pFromDate CHAR(10)
   ,@pToDate CHAR(10)
AS
	Declare @FromDate DATETIME = @pFromDate + ' 00:00:00'
	       ,@ToDate DATETIME = @pToDate + ' 23:59:59'
	BEGIN
		SELECT VIR.ResultNo
              ,VIR.MachineID
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
              ,VIR.DecisionDateTime
              ,VIR.CreateDateTime
              ,VIR.Pitch
              ,VIR.SheetSize
		  FROM STB_VisionInspectionResult VIR
		 WHERE VIR.DecisionDateTime BETWEEN @FromDate AND @ToDate
	END