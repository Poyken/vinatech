-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2019-01-26
-- Browsable : true
-- Group : 생산관리
-- Description:	[B650] 일일생산현황을 가져옵니다
-- Modified: 2019.07.16 주영진차장 수정요청

-- TEST  :    [usp_GetDailyProdRouteSummary] '','','','','','2019-09-05'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDailyProdRouteSummary]
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
	   --  @LineCode VARCHAR(20) = @pLineCode,		                                                                                                                    -- 라인별 카렌더가 다르면 전일이 다를수 있음
			@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END,	                                      	-- 라인별 카렌더가 다르면 전일이 다를수 있음
			@JobDate DATE = @pJobDate
			    
	DECLARE @YesterDay DATE	

	SET @YesterDay = DATEADD(day, -1, @JobDate)
	
	-- 아래의 쿼리로는 전일자를 제대로 가져오지 못함.
	-- JobDate의 전일자로 일괄 계산하고, 휴무에 대해서는 휴무관리 이후 고려해야함. 2019.11.05 By Jackaroe
	/*
	SELECT
			TOP 1
			@YesterDay = DWC.JobDate
	FROM
			STB_DayWorkCalendar DWC WITH(NOLOCK)
	WHERE 1=1
		AND ((DWC.CompanyCode = '') OR (DWC.CompanyCode = @CompanyCode)) 
		AND ((DWC.WorkCenterCode = '') OR (DWC.WorkCenterCode = @WorkCenterCode)) 
		AND ((DWC.LineCode = '') OR (DWC.LineCode LIKE @LineCode)) 
		AND DWC.JobDate < @JobDate
	ORDER BY
	        DWC.RouteCode DESC,
			DWC.JobDate DESC,
			DWC.MachineCode DESC,			
			DWC.LineCode DESC,
			DWC.WorkCenterCode DESC,
			DWC.CompanyCode DESC

	*/

	;WITH BefProd 
	AS
	(

		SELECT
				PRS.RouteCode,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty,
				SUM(PRS.OutputQty) - SUM(PRS.DefectQty) + SUM(PRS.RepairQty) - SUM(PRS.LossQty) AS TotalQty
		FROM
				STB_ProdRouteSummary                PRS WITH(NOLOCK)
				INNER JOIN STB_LineRouteMapping LRM WITH(NOLOCK)					ON LRM.LineCode = PRS.LineCode AND					LRM.RouteCode = PRS.RouteCode
		WHERE 1=1
			AND  PRS.LineCode LIKE @LineCode 
			AND PRS.JobDate = @YesterDay
		GROUP BY PRS.RouteCode
  

	), ProdRoute AS

	(
		SELECT
				LRM.RouteCode,
				RI.RouteName,
				SUM(PRS.OutputQty) AS OutputQty,
				SUM(PRS.DefectQty) AS DefectQty,
				SUM(PRS.RepairQty) AS RepairQty,
				SUM(PRS.LossQty) AS LossQty,
				SUM(PRS.OutputQty) - SUM(PRS.DefectQty) + SUM(PRS.RepairQty) - SUM(PRS.LossQty) AS TotalQty,
				(	SELECT OutputQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefOutputQty,
				(	SELECT DefectQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefDefectQty,
				(	SELECT RepairQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefRepairQty,
				(	SELECT LossQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefLossQty,
				(	SELECT TotalQty FROM BefProd WHERE RouteCode = LRM.RouteCode) AS BefTotalQty
		FROM
				STB_LineRouteMapping                         LRM WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProdRouteSummary PRS WITH(NOLOCK)	 ON PRS.LineCode = LRM.LineCode    AND	PRS.RouteCode = LRM.RouteCode AND	 PRS.JobDate = @JobDate
				       INNER JOIN STB_RouteInfo                RI WITH(NOLOCK)  ON RI.RouteCode = LRM.RouteCode
		WHERE 1=1
				AND LRM.LineCode LIKE @LineCode
				AND TimeCode <> 'E' 
		GROUP BY
				LRM.RouteCode,
				RI.RouteName


	)
		SELECT
				PR.RouteCode,
				PR.RouteName,
				PR.OutputQty,
				PR.DefectQty,
				PR.RepairQty,
				PR.LossQty,
				PR.TotalQty,
				PR.BefOutputQty,
				PR.BefDefectQty,
				PR.BefRepairQty,
				PR.BefLossQty,
				PR.BefTotalQty
		FROM
				ProdRoute PR

		ORDER BY PR.RouteCode    -- 2019.07.16 추가 (kilee)

		--UNION ALL                   -- 여기부터 밑에까지 주석처리 (2019.07.16, kilee)

		--SELECT
		--	--	'Total',
		--		'총계',
		--		SUM(PR.OutputQty),
		--		SUM(PR.DefectQty),
		--		SUM(PR.RepairQty),
		--		SUM(PR.LossQty),
		--		SUM(PR.TotalQty),
		--		SUM(PR.BefOutputQty),
		--		SUM(PR.BefDefectQty),
		--		SUM(PR.BefRepairQty),
		--		SUM(PR.BefLossQty),
		--		SUM(PR.BefTotalQty)
		--FROM
		--		ProdRoute PR

				
END



--select * from STB_ProdRouteSummary where TimeCode = 'E' and JobDate = '2019-09-05'