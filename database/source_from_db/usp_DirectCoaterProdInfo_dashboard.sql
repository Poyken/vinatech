CREATE PROC [dbo].[usp_DirectCoaterProdInfo_dashboard]
	@pFromDate CHAR(10)
   ,@pToDate CHAR(10)
AS
	Declare @FromDate DATETIME = @pFromDate + ' 00:00:00'
	       ,@ToDate DATETIME = @pToDate + ' 23:59:59'
	BEGIN
		SELECT A.DecisionDate
		      ,A.LotNo
		      ,COUNT(*) AS InputQty
			  ,SUM(A.OutputQty) AS OutputQty
			  ,SUM(A.DefectQty) AS DefectQty
			  ,CONVERT(NUMERIC(20,5), SUM(A.DefectQty)) / COUNT(*) AS DefectRate
			  ,CONVERT(NUMERIC(20,5), SUM(A.OutputQty)) / COUNT(*) AS YieldRate
		  FROM (
				SELECT VIR.LotNo
				      ,VIR.ModelNo 
			          ,MAX(CONVERT(CHAR(10), VIR.DecisionDateTime, 121)) AS DecisionDate
					  ,CASE WHEN MAX(DecisionResult) = 'GOOD' THEN 1 ELSE 0 END AS OutputQty
					  ,CASE WHEN MAX(DecisionResult) = 'NG' THEN 1 ELSE 0 END AS DefectQty
				  FROM STB_VisionInspectionResult VIR
				 WHERE VIR.DecisionDateTime BETWEEN @FromDate AND @ToDate
				 GROUP BY VIR.LotNo, VIR.ModelNo 
		) A
		GROUP BY A.DecisionDate, A.LotNo
	END