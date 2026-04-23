-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-01-26
-- Browsable : true
-- Group : 생산관리
-- Description:	생산수율을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProductionYield]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			@LineCode VARCHAR(20) = @pLineCode,		-- 라인별 카렌더가 다르면 전일이 다를수 있음
			@JobDate DATE = @pJobDate
			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')

	DECLARE @BefFromDate DATE = DATEADD(MONTH,-1,@FromDate)
	DECLARE @BefToDate DATE = DATEADD(DAY,-1,@FromDate)

	;WITH BefProd AS
	(
		SELECT
				LRM.RouteCode,
				RI.RouteName,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty,
				SUM(PRS.OutputQty) + SUM(PRS.DefectQty) + SUM(PRS.RepairQty) + SUM(PRS.LossQty) AS TotalQty,
				SUM(PRS.OutputQty) * 100.0 / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) + SUM(PRS.RepairQty) + SUM(PRS.LossQty)) AS TotalRate
		FROM
				STB_LineRouteMapping LRM WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProdRouteSummary PRS WITH(NOLOCK) ON PRS.LineCode = LRM.LineCode AND PRS.RouteCode = LRM.RouteCode AND (PRS.JobDate BETWEEN @BefFromDate AND @BefToDate)
				INNER JOIN STB_RouteInfo RI WITH(NOLOCK)			  ON RI.RouteCode = LRM.RouteCode
		WHERE
				LRM.LineCode = @LineCode
		GROUP BY
				LRM.RouteCode,
				RI.RouteName
	)
		SELECT
				LRM.RouteCode,
				RI.RouteName,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty,
				SUM(PRS.OutputQty) + SUM(PRS.DefectQty) + SUM(PRS.RepairQty) + SUM(PRS.LossQty) AS TotalQty,
				SUM(PRS.OutputQty) * 100.0 / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) + SUM(PRS.RepairQty) + SUM(PRS.LossQty)) AS TotalRate,
				(SELECT OutputQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefOutputQty,
				(SELECT DefectQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefDefectQty,
				(SELECT RepairQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefRepairQty,
				(SELECT LossQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefLossQty,
				(SELECT TotalRate FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefTotalRate
		FROM
				STB_LineRouteMapping LRM WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProdRouteSummary PRS WITH(NOLOCK) ON PRS.LineCode = LRM.LineCode AND PRS.RouteCode = LRM.RouteCode AND (PRS.JobDate BETWEEN @FromDate AND @ToDate)
				INNER JOIN STB_RouteInfo RI WITH(NOLOCK) ON RI.RouteCode = LRM.RouteCode
		WHERE
				LRM.LineCode = @LineCode
		GROUP BY
				LRM.RouteCode,
				RI.RouteName
END
