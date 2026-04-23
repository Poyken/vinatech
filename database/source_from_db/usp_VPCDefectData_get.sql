CREATE PROC [dbo].[usp_VPCDefectData_get]
AS
Declare @DefectData TABLE 
(
	BaseDate DATE
   ,ShiftCode VARCHAR(20)
   ,LineCode VARCHAR(20)
   ,DefectWeight NUMERIC(20,5)
   ,RouteCode VARCHAR(20)
);

;WITH CTE AS (
SELECT BaseDate
		,ShiftCode
		,LineCode
		,SUM(WindingDefectWeight) AS [E-22]
		,SUM(RubberDefectWeight) AS [E-23]
		,SUM(CurlingDefectWeight) AS [E-24]
		,SUM(SleeveDefectWeight) AS [E-25]
		,SUM(QcWindingInspWeight) AS [E-98]
		,SUM(QcSleeveInspWeight) AS [E-99]
	FROM STB_ManualDefectInfo
	GROUP BY BaseDate, ShiftCode, LineCode
)
INSERT INTO @DefectData
SELECT *
	FROM CTE
UNPIVOT ( DefectWeight FOR RouteCode IN ([E-22]
										,[E-23]
										,[E-24]
										,[E-25]
										,[E-98]
										,[E-99]
										)
		) AS unpvt
UNION ALL
SELECT FindJobDate
		,FindShiftCode
		,FindLineCode
		,SUM(DefectQty) * 2.541
		,FindRouteCode
	FROM STB_DefectRepairInfo
	WHERE DefectCode NOT IN ('E-33_5ET', 'E-33_X12', 'E-33_X20')
	AND CompanyCode = 'VNT'
	AND WorkCenterCode = 'VNT_F1'
	AND FindJobDate >= '2022-09-13'
	AND FindRouteCode = 'E-27'
	GROUP BY  FindJobDate
			,FindShiftCode
			,FindLineCode
			,FindRouteCode

SELECT *
  FROM (
	SELECT ISNULL(CONVERT(VARCHAR(20), pr.BaseDate, 121), '합계') AS BaseDate
		  ,CASE WHEN LI.MonitoringName IS NULL AND pr.BaseDate IS NOT NULL 
		        THEN '소계' 
				ELSE LI.MonitoringName 
		    END AS MonitoringName
		  ,CASE WHEN pr.ShiftCode IS NULL THEN '소계' 
		        WHEN pr.ShiftCode = '1' THEN '주간' 
				ELSE '야간' 
			END AS ShiftName
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-22],3)),0)) AS [권취]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-23],3)),0)) AS [고무전]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-24],3)),0)) AS [커링]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-25],3)),0)) AS [슬리브]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-27],3)),0)) AS [외관]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-98],3)),0)) AS [품질(권취)]
		  ,SUM(ISNULL(CONVERT(NUMERIC(20,3), ROUND(pr.[E-99],3)),0)) AS [품질(슬리브)]

	  FROM (
			SELECT DD.BaseDate
				  ,DD.ShiftCode
				  ,DD.LineCode
				  ,DD.RouteCode
				  ,DD.DefectWeight / DPC.ProductWeight * DPC.ProductCost AS TotalDefectCost
			  FROM @DefectData DD
			  LEFT OUTER JOIN STB_DefectProductionCost DPC
				ON DPC.RouteCode = DD.RouteCode
	 ) rs 
	 PIVOT ( SUM(TotalDefectCost) FOR RouteCode IN ([E-22],[E-23],[E-24],[E-25],[E-27],[E-98],[E-99])
	) AS pr
	LEFT OUTER JOIN STB_LineInfo LI
	  ON LI.LineCode = pr.LineCode
	 AND LI.IsUsed = CONVERT(BIT, 1)
	GROUP BY pr.BaseDate
			,LI.MonitoringName
			,CASE WHEN pr.ShiftCode IS NULL THEN '소계' 
		        WHEN pr.ShiftCode = '1' THEN '주간' 
				ELSE '야간' 
			END WITH ROLLUP
) Fin
ORDER BY Fin.BaseDate
        ,CASE WHEN Fin.MonitoringName = '소계' THEN 'Z' ELSE Fin.MonitoringName END
		,CASE WHEN ShiftName = '주간' THEN 1 WHEN ShiftName = '야간' THEN 2 ELSE 3 END