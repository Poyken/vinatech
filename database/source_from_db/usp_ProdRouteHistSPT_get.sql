-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-03-15
-- Browsable : true
-- Group : 생산관리
-- Description:	지지체 실적정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ProdRouteHistSPT_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pBarcode VARCHAR(20) = NULL

AS
BEGIN
      DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
      DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	  DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode,'') = '' THEN '*' ELSE @pBarcode END
	  DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	  DECLARE @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'

	  SELECT PRH.CompanyCode
			,CI.CompanyName
			,PRH.WorkCenterCode
			,WI.WorkCenterName
			,PRH.PONo
			,PRH.DayPlanNo
			,SI.Barcode
			,PRH.MaterialCode
			,MM.MaterialName
			,PRH.JobDate
			,PRH.LineCode
			,LI.LineName
			,PRH.RouteCode
			,RI.RouteName
			,PRH.WorkerCode
			,PWI.WorkerName
			,PRH.MachineCode
			,MM2.MachineName
			,PRH.ProdQty
			,PRH.ProdDateTime
		FROM STB_ProdRouteHist PRH
		LEFT OUTER JOIN STB_SetInfo SI
		ON PRH.ControlNo = SI.ControlNo
		LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = PRH.CompanyCode
		LEFT OUTER JOIN STB_WorkCenterInfo WI
		ON WI.WorkCenterCode = PRH.WorkCenterCode
		LEFT OUTER JOIN STB_MaterialMaster MM
		ON MM.MaterialCode = PRH.MaterialCode
		LEFT OUTER JOIN STB_LineInfo LI
		ON LI.LineCode = PRH.LineCode
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI
		ON PWI.WorkerCode = PRH.WorkerCode
		LEFT OUTER JOIN STB_MachineMaster MM2
		ON MM2.MachineCode = PRH.MachineCode
		LEFT OUTER JOIN STB_RouteInfo RI
		ON RI.RouteCode = PRH.RouteCode
		WHERE 1=1
		  AND (@CompanyCode = '*' OR PRH.CompanyCode = @CompanyCode)
		  AND (@WorkCenterCode = '*' OR PRH.WorkCenterCode = @WorkCenterCode)
		  AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
		  AND (@Barcode = '*' OR SI.Barcode = @Barcode)
		  AND PRH.LineCode LIKE 'SPT%'
END