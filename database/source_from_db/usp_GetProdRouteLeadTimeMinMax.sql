
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리
-- Description: 공정별 리드타임을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdRouteLeadTimeMinMax]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
	DECLARE @MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate

	;WITH RouteLead AS
	(
		SELECT
				SI.Barcode,
				PRH.MaterialCode,
				MM.MaterialName,
				PRH.LineCode,
				LI.LineName,
				PRH.RouteCode,
				RI.RouteName,
				POR.RouteIndex,
				CASE
					WHEN MIN(BPRH.ProdDateTime) IS NULL THEN 0
					ELSE DATEDIFF(MINUTE,MIN(BPRH.ProdDateTime),MIN(PRH.ProdDateTime)) 
				END AS RouteLeadTime
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)
					ON SI.ControlNo = PRH.ControlNo
				INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)
					ON POR.PONo = PRH.PONo AND
					POR.RouteCode = PRH.RouteCode
				LEFT OUTER JOIN STB_ProductionOrderRouting BPOR WITH(NOLOCK)
					ON BPOR.PONo = PRH.PONo AND
					BPOR.RouteIndex = POR.RouteIndex - 1
				LEFT OUTER JOIN STB_ProdRouteHist BPRH WITH(NOLOCK)
					ON BPRH.ControlNo = PRH.ControlNo AND
					BPRH.RouteCode = BPOR.RouteCode
				LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
					ON LI.LineCode = PRH.LineCode
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
					ON RI.RouteCode = PRH.RouteCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON MM.MaterialCode = PRH.MaterialCode
		WHERE
				PRH.CompanyCode LIKE @CompanyCode AND
				PRH.WorkCenterCode LIKE @WorkCenterCode AND
				PRH.LineCode LIKE @LineCode AND
				PRH.MaterialCode LIKE @MaterialCode AND
				(PRH.JobDate BETWEEN @FromDate AND @ToDate)
		GROUP BY
				SI.Barcode,
				PRH.MaterialCode,
				MM.MaterialName,
				PRH.LineCode,
				LI.LineName,
				PRH.RouteCode,
				RI.RouteName,
				POR.RouteIndex
	)
		SELECT
				RL.RouteCode,
				RL.RouteName,
				MIN(RL.RouteLeadTime) MinRouteLeadTime,
				MAX(RL.RouteLeadTime) MaxRouteLeadTime,
				AVG(RL.RouteLeadTime) AvgRouteLeadTime
		FROM
				RouteLead RL
		GROUP BY
				RL.RouteCode,
				RL.RouteName
END

