
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-11
-- Browsable : true
-- Group : 모니터링
-- Description:	라인별 생산현황을 가져옵니다
-- Modified:
-- =============================================

-- EXEC usp_GetProductionForMonitoringChart_VNT '','',''

CREATE PROCEDURE [dbo].[usp_GetProductionForMonitoringChart_VNT]
	@pCompanyCode VARCHAR(20) = 'VNT',
	@pWorkCenterCode VARCHAR(20) = 'VNT_F1',
	@pLineCode VARCHAR(20) = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	
	DECLARE @LineName NVARCHAR(100)
	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(GETDATE(),@CompanyCode,@WorkCenterCode,@LineCode,NULL,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	SET @JobDate = '2018-09-05'
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)
	SET @ShiftCode = '1'

	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE = DATEADD(DAY,-1,DATEADD(MONTH,1,@FromDate))
	
	;WITH ProdPlan AS
	(
		SELECT
				SUM(POI.PlanQty) AS PlanQty
		FROM
				STB_ProductionOrderInfo POI WITH(NOLOCK)
		WHERE
				POI.PlanYearMonth = SUBSTRING(CONVERT(VARCHAR,@FromDate,120),1,7) AND
				POI.IsFix = 1 AND
				POI.IsCancel = 0 AND
				POI.POType = 'FERT'
	), Prod AS
	(
		SELECT
				PRS.JobDate,
				SUM(PRS.OutputQty) AS ProdQty
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
				INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
					ON POI.PONo = PRS.PONo
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
					ON POR.PONo = PRS.PONo AND
					POR.RouteCode = PRS.RouteCode AND
					POR.IsInputRoute = 1
		WHERE
				PRS.JobDate BETWEEN @FromDate AND @ToDate AND
				POI.IsFix = 1 AND
				POI.IsCancel = 0 AND
				POI.POType = 'FERT'
		GROUP BY
				PRS.JobDate
	)
		SELECT
				PP.PlanQty,
				Prod.JobDate,
				Prod.ProdQty + ISNULL((
										SELECT
												SUM(PD.ProdQty)
										FROM
												Prod PD
										WHERE
												PD.JobDate < Prod.JobDate
									),0) AS ProdQty
		FROM
				ProdPlan PP
				LEFT OUTER JOIN Prod
					ON Prod.JobDate = Prod.JobDate
END
