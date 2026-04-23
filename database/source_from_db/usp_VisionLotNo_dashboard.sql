CREATE PROC usp_VisionLotNo_dashboard
AS
BEGIN
	SELECT LotNo, CONVERT(CHAR(10), MAX(DecisionDateTime), 121) AS BaseDate
	  FROM STB_VisionInspectionResult
	 GROUP BY LotNo
END