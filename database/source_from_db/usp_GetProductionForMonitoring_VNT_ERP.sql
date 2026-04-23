
-- =============================================
-- Author:	    Jackaroe (yjyu@vina.co.kr)
-- Create date: 2018-11-01
-- Browsable : true
-- Group : 모니터링
-- Description:	라인별 생산현황을 가져옵니다(ERP기준)
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_GetProductionForMonitoring_VNT_ERP]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = 'VNT',
	@pWorkCenterCode VARCHAR(20) = 'VNT_F1',
	@pLineCode VARCHAR(20) = NULL,
	@pFirstRouteCode VARCHAR(20) = NULL,
	@pSecondRouteCode VARCHAR(20) = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) =@pProcessUserID
	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode
	DECLARE @WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	-- UserID로 라인코드를 조합한다.
	DECLARE @LineNo VARCHAR(20) = REPLACE(@ProcessUserID,'monitoring','')
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN CASE WHEN @LineNo = @ProcessUserID THEN 'ASSYLINE-1' ELSE 'ASSYLINE-' + @LineNo END ELSE @pLineCode END
	DECLARE @FirstRouteCode VARCHAR(20) = @pFirstRouteCode
	DECLARE @SecondRouteCode VARCHAR(20) = @pSecondRouteCode
	
	DECLARE @LineName NVARCHAR(100)
	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(GETDATE(),@CompanyCode,@WorkCenterCode,@LineCode,NULL,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	--SET @JobDate = '2018-08-23'
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)
	--SET @ShiftCode = '1'
	DECLARE @FirstWorkerName NVARCHAR(100)
	DECLARE @SecondWorkerName NVARCHAR(100)
	DECLARE @MaterialName NVARCHAR(100)
	DECLARE @ModelTypeName VARCHAR(50)
	DECLARE @ModelSpec VARCHAR(50)

	SELECT
			@LineName = LI.LineName
	FROM
			STB_LineInfo LI WITH(NOLOCK)
	WHERE
			LI.LineCode = @LineCode
	
	SELECT
			@MaterialName = MBI.ModelName,
			@ModelTypeName = MBI.MBIExtText03,
			@ModelSpec = MBI.MBIExtText04 + ' V - ' + MBI.MBIExtText05 + ' F'
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)
				ON PRH.ProdRouteHistNo = LRM.ProdRouteHistNo
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MBI.ModelCode = PRH.MaterialCode
	WHERE
			LRM.LineCode = @LineCode AND
			LRM.RouteCode = @FirstRouteCode

	SELECT
			TOP 1
			@FirstWorkerName = PWI.WorkerName
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			INNER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)
				ON PRWH.ProdRouteHistNo = LRM.ProdRouteHistNo
			INNER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
				ON PWI.WorkerCode = PRWH.WorkerCode
	WHERE
			LRM.LineCode = @LineCode AND
			LRM.RouteCode =	@FirstRouteCode

	SELECT
			TOP 1
			@SecondWorkerName = PWI.WorkerName
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			INNER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)
				ON PRWH.ProdRouteHistNo = LRM.ProdRouteHistNo
			INNER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
				ON PWI.WorkerCode = PRWH.WorkerCode
	WHERE
			LRM.LineCode = @LineCode AND
			LRM.RouteCode =	@FirstRouteCode AND
			PWI.WorkerName <> @FirstWorkerName
	
	DECLARE @Data TABLE
	(
		IDX INT,
		RouteCode VARCHAR(20),
		RouteName NVARCHAR(100),
		PlanQty INT,
		CurrentTarget INT,
		ProdQty INT,
		DefectQty INT
		--ProdRate NUMERIC(10,2),
		--DefectRate NUMERIC(10,2)
	)

	;WITH ProdPlan AS
	(
		SELECT
				@FirstRouteCode AS RouteCode,
				DPP.PlanQty,
				DPP.CurrentTarget,
				0 AS ProdQty,
				0 AS DefectQty
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE
				DPP.LineCode = @LineCode AND
				DPP.PlanDate = @JobDate AND
				DPP.PlanShiftCode = @ShiftCode
		UNION ALL
		SELECT
				@SecondRouteCode AS RouteCode,
				DPP.PlanQty,
				DPP.CurrentTarget,
				0 AS ProdQty,
				0 AS DefectQty
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE
				DPP.LineCode = @LineCode AND
				DPP.PlanDate = @JobDate AND
				DPP.PlanShiftCode = @ShiftCode
		UNION ALL
		SELECT
				PRS.RouteCode,
				0,
				0,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty
		FROM
				STB_ProdRouteSummary PRS WITH(NOLOCK)
		WHERE
				PRS.LineCode = @LineCode AND
				PRS.JobDate = @JobDate AND
				PRS.ShiftCode = @ShiftCode AND
				PRS.RouteCode IN (@FirstRouteCode,@SecondRouteCode)
		GROUP BY
				PRS.RouteCode
	)
		INSERT INTO @Data
		SELECT
				ROW_NUMBER() OVER (ORDER BY PP.RouteCode),
				PP.RouteCode,
				RI.RouteName,
				SUM(PP.PlanQty),
				SUM(PP.CurrentTarget),
				SUM(PP.ProdQty),
				SUM(PP.DefectQty)
				--CASE
				--	WHEN ISNULL(SUM(PP.ProdQty),0) = 0 THEN 0.0
				--	ELSE SUM(PP.CurrentTarget) / SUM(PP.ProdQty) * 100.0
				--END,
				--CASE 
				--	WHEN ISNULL(SUM(PP.DefectQty),0) = 0 THEN 0.0
				--	ELSE SUM(PP.ProdQty) / SUM(PP.DefectQty) * 100.0
				--END
		FROM
				ProdPlan PP
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
					ON RI.RouteCode = PP.RouteCode
		GROUP BY
				PP.RouteCode,
				RI.RouteName

	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			0 AS ID,
			'Current' AS ItemID,
			CONVERT(VARCHAR(19), GETDATE(), 120) AS ItemValue,
			2 AS TextColorID,
			1 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			0 AS ID,
			'LineName' AS ItemID,
			@LineName + ' 생산현황' AS ItemValue,
			2 AS TextColorID,
			4 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			0 AS ID,
			'ModelTypeName' AS ItemID,
			@ModelTypeName AS ItemValue,
			1 AS TextColorID,
			3 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			1 AS GroupID,
			1 AS ID,
			'WorkerName' AS ItemID,
			@FirstWorkerName AS ItemValue,
			1 AS TextColorID,
			3 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			1 AS GroupID,
			2 AS ID,
			'WorkerName' AS ItemID,
			@SecondWorkerName AS ItemValue,
			1 AS TextColorID,
			3 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			2 AS GroupID,
			DT.IDX AS ID,
			'CurrentTarget' AS ItemID,
			REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, DT.CurrentTarget), 1), '.00', '') AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	FROM
			@Data DT
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			3 AS GroupID,
			DT.IDX AS ID,
			'ProdQty' AS ItemID,
			REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, DT.ProdQty), 1), '.00', '') AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	FROM
			@Data DT
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			4 AS GroupID,
			DT.IDX AS ID,
			'DefectQty' AS ItemID,
			REPLACE(CONVERT(VARCHAR,CONVERT(MONEY, DT.DefectQty), 1), '.00', '') AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	FROM
			@Data DT
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			5 AS GroupID,
			DT.IDX AS ID,
			'RouteName' AS ItemID,
			DT.RouteName AS ItemValue,
			1 AS TextColorID,
			3 AS TextFontID
	FROM
			@Data DT
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			1 AS ID,
			'MaterialName' AS ItemID,
			@MaterialName AS ItemValue,
			1 AS TextColorID,
			2 AS TextFontID
	UNION ALL
	SELECT
			'ProdLayout' AS LayoutID,
			1 AS PageNo,
			0 AS GroupID,
			0 AS ID,
			'ModelSpec' AS ItemID,
			@ModelSpec AS ItemValue,
			1 AS TextColorID,
			5 AS TextFontID	 
			
END
