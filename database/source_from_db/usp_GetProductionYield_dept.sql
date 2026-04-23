-- ===========================================================
-- Author: kilee
-- Create date: 2019-03-05
-- Browsable : true
-- Group : 생산관리
-- Description:	공정별 생산수율을 가져옵니다
-- Modified: 2019.03.05 라인정렬 (kilee)
--              2019.03.07 FromTo 일자 변경  (kilee)
--              2019.12.05 SQL수정 (Kilee)
--              2020.07.27 합계부분 최덕렬님 요청  - 권취공정 수율이 합계로 보일수 있게 
--              2022.02.23 합계부분 변경 (채민수)  
  
-- 실행 :  usp_GetProductionYield_dept '','','VNT','','','', '2022-02-23'
-- ================================================================
CREATE PROCEDURE [dbo].[usp_GetProductionYield_dept]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pLineCode VARCHAR(20) = NULL,
						@pRouteCode VARCHAR(20) = NULL,
						@pJobDate DATE = NULL
AS

BEGIN
   SET NOCOUNT ON;
     DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,	
				@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
				@LineCode VARCHAR(20) = @pLineCode,		-- 라인별 카렌더가 다르면 전일이 다를수 있음
				--@RouteCode VARCHAR(20) = @pRouteCode,
				@JobDate DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate DATE    = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')

	--DECLARE @BefFromDate DATE = DATEADD(MONTH,-1,@FromDate)   -- 기존소스 백업 (지우지말것)
	--DECLARE @BefToDate DATE   = DATEADD(DAY,-1,@FromDate)     -- 기존소스 백업 (지우지말것)

	--[FROM_DATE검증방법] 화면의년월일기입 : 2019-03-07 이면  SELECT  SUBSTRING(CONVERT(VARCHAR,'2019-03-07',120),1,8) + '01'                                    ->  SELECT DATEADD(MONTH, 0,'2019-03-01')
	--[TO DATE검증방법]   화면의년월일기입 :                  SELECT  DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,'2019-03-07'),120),1,8) + '01')   ->  SELECT  DATEADD(DAY,-1,'2019-03-01')   -> SELECT  DATEADD(DAY, -1, (DATEADD(MONTH,1,'2019-03-01')))


	DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                  -- Kangs수정 (2019.03.07)
	DECLARE @BefToDate    DATE = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))          -- Kangs수정 (2019.03.07)


-- 정상원본 데이터부분!!		
SELECT Z.RouteCode  AS RouteCode
		, Z.RouteName
		, Z.TotalQty
		, Z.OutputQty
		, Z.DefectQty
		, Z.RepairQty
		, Z.LossQty		   
		, Z.TotalRate			 
	 FROM 
				(
				   SELECT PRS.RouteCode  AS RouteCode
						   , RI.RouteName
						   , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2) AS TotalQty
						   , SUM(PRS.OutputQty) AS OutputQty
						   , SUM(PRS.DefectQty) AS DefectQty
						   , SUM(PRS.RepairQty) AS RepairQty
						   , SUM(PRS.LossQty) AS LossQty		   
						   , ROUND(SUM(PRS.OutputQty) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  * 100.0, 3)  AS TotalRate
					FROM STB_ProdRouteSummary PRS
					LEFT OUTER JOIN STB_RouteInfo RI	  ON PRS.RouteCode = RI.RouteCode
				   WHERE 1=1
					 AND TimeCode <> 'E'  
					 AND PRS.RouteCode LIKE 'E%'	   
					 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
					 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate           		
				   GROUP BY PRS.RouteCode, RI.RouteName

				   Union All

			   -- 합계	  
					SELECT		''    AS RouteCode
							, '합계'  AS  RouteName
							, ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
							, SUM(PRS.OutputQty)                                                                      AS OutputQty
							, SUM(PRS.DefectQty)                                                                      AS DefectQty
							, SUM(PRS.RepairQty)                                                                      AS RepairQty
							, SUM(PRS.LossQty)                                                                        AS LossQty
							--, SUM(PRS.OutputQty) /  ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2  *  100.0 	)     AS TotalRate
							, ROUND(SUM(PRS.OutputQty) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  * 100.0, 3)  AS TotalRate
					FROM STB_ProdRouteSummary PRS
								LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
					WHERE 1=1
						AND TimeCode <> 'E'  						  
						AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
						AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate												  						   
 ) Z
	ORDER BY Z.RouteCode

END
