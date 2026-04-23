-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-01-26
-- Browsable : true
-- Group : 생산관리, 품질관리
-- Description:	일일불량현황을 가져옵니다
-- Modified:
-- =============================================
--         EXEC usp_GetDailyDefectSummary  'kilee', 'Korean', '', '',  'ASSYLINE-03',  '2018-09-03'

CREATE PROCEDURE [dbo].[usp_GetDailyDefectSummary]
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
			@LineCode VARCHAR(20) = @pLineCode,
			@JobDate DATE = @pJobDate

	DECLARE @DefectSummary TABLE
	(
		RouteCode VARCHAR(20),
		DefectCode VARCHAR(20),
		DefectQty NUMERIC(20,5)
	)
			    
	SELECT
			LRM.RouteCode,
			RI.RouteName
	FROM
			STB_LineRouteMapping LRM WITH(NOLOCK)
			INNER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = LRM.RouteCode
	WHERE			LRM.LineCode = @LineCode


	SELECT
			DISTINCT
			'불량항목' AS BandName,
			DRI.DefectCode,
			DI.BasicDefectName AS DefectName,
			'int' AS DataType
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)				ON DI.DefectCode = DRI.DefectCode
	WHERE
			DRI.FindJobdate = @JobDate AND
			DRI.DefectQty > 0
	UNION ALL


	-- 2.
	SELECT
			'불량항목',
			'Total',
			'Total',
			'int'

	INSERT INTO @DefectSummary
	SELECT
			DRI.FindRouteCode,
			DRI.DefectCode,
			SUM(DRI.DefectQty)
	FROM
			STB_DefectRepairInfo DRI WITH(NOLOCK)
			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)
				ON DI.DefectCode = DRI.DefectCode
	WHERE
			DRI.FindJobdate = @JobDate AND
			DRI.DefectQty > 0
	GROUP BY
			DRI.FindRouteCode,
			DRI.DefectCode,
			DI.BasicDefectName


   -- 3. 
	;WITH DefectSummary AS
	(
		SELECT
				'불량항목' AS BandName,
				DS.RouteCode,
				DS.DefectCode,
				DI.BasicDefectName AS DefectName,
				DS.DefectQty
		FROM
				@DefectSummary DS
				LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)					ON DI.DefectCode = DS.DefectCode
	)
		SELECT
				DS.BandName,
				DS.RouteCode,
				DS.DefectCode,
				DS.DefectName,
				DS.DefectQty
		FROM
				DefectSummary DS
		UNION ALL


		SELECT
				DS.BandName,
				DS.RouteCode,
				'Total',
				'Total',
				SUM(DS.DefectQty)
		FROM
				DefectSummary DS
		GROUP BY
				DS.BandName,
				DS.RouteCode


	;WITH RouteTotalDefect AS
	(
		SELECT
				DS.RouteCode,
				RI.RouteName,
				SUM(DS.DefectQty) AS DefectQty
		FROM
				@DefectSummary DS
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
					ON RI.RouteCode = DS.RouteCode
		GROUP BY
				DS.RouteCode,
				RI.RouteName
	)
		SELECT
				'Total'           AS RouteCode,
				'금일불량수량' AS RouteName,
				RTD.RouteCode AS DefectCode,
				RTD.RouteName AS DefectName,
				RTD.DefectQty,
				RTD.DefectQty / (SELECT SUM(DefectQty) FROM @DefectSummary) AS DefectRate
		FROM
				RouteTotalDefect RTD
		UNION ALL

		SELECT
				DS.RouteCode,
				RI.RouteName,
				DS.DefectCode,
				DI.BasicDefectName AS DefectName,
				DS.DefectQty,
				DS.DefectQty / RTD.DefectQty AS DefectRate
		FROM
				@DefectSummary DS
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)					ON RI.RouteCode = DS.RouteCode
				LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)					ON DI.DefectCode = DS.DefectCode
				LEFT OUTER JOIN RouteTotalDefect RTD					ON RTD.RouteCode = DS.RouteCode
END



--SELECT * FROM STB_RouteInfo


--SELECT
--			DRI.FindRouteCode,
--			DRI.DefectCode,
--			SUM(DRI.DefectQty)
--	FROM
--			STB_DefectRepairInfo DRI WITH(NOLOCK)			
--			LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)				ON DI.DefectCode = DRI.DefectCode
--	WHERE 1=1
--			--AND DRI.FindJobdate = @JobDate 
--			AND			DRI.DefectQty > 0
--	GROUP BY
--			DRI.FindRouteCode,
--			DRI.DefectCode,
--			DI.BasicDefectName


--			SELECT * FROM STB_DefectRepairInfo

--			UPDATE STB_DefectRepairInfo
--			SET FINDROUTECODE = 'ASSY-01'
--			WHERE FINDROUTECODE = 'ASSY-1'