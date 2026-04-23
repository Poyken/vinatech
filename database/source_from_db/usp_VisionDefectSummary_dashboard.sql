CREATE Proc [dbo].[usp_VisionDefectSummary_dashboard]
AS
BEGIN
	SELECT 'DotBlackType' AS DefectCode
	      ,SUM(DotBlackType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT 'LineBlackType' AS DefectCode
	      ,SUM(LineBlackType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT 'MuraBlackType' AS DefectCode
	      ,SUM(MuraBlackType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT 'DotWhiteType' AS DefectCode
	      ,SUM(DotWhiteType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT 'LineWhiteType' AS DefectCode
	      ,SUM(LineWhiteType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT 'MuraWhiteType' AS DefectCode
	      ,SUM(MuraWhiteType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT '확장' AS DefectCode
	      ,SUM(ExtenedType) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
	UNION ALL
	SELECT '기타' AS DefectCode
	      ,SUM(etc) AS DefectQty
	  FROM STB_VisionInspectionResult VIR
	 WHERE VIR.DecisionResult = 'NG'
	   AND VIR.DecisionDateTime BETWEEN dbo.fnGetFirstDayOfMonth(GETDATE()) AND dbo.fnGetLastDayOfMonth(GETDATE())
END