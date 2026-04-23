-- =============================================
-- Author: kilee
-- Create date: 2019-03-07
-- Browsable : true
-- Group : 생산관리
-- Description:	공정별 생산수율 상세(detail)
-- Modified:
-- exec usp_GetProductionYield_dept2 '','','', '', '', '', '2022-01-01 00:00:00'
-- exec usp_GetProductionYield_dept2 '','','', '', '', '', '2021-12-01 00:00:00'
-- exec usp_GetProductionYield_dept2 '','','', '', '', '', '2021-11-01 00:00:00'
-- =========================================================

CREATE PROCEDURE [dbo].[usp_GetProductionYield_dept2]
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

	DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
			    @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			    @LineCode           VARCHAR(20) = @pLineCode,		-- 라인별 카렌더가 다르면 전일이 다를수 있음
			    @JobDate             DATE = @pJobDate


    DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END			    
	DECLARE @FromDate DATE = SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,8) + '01'
	DECLARE @ToDate   DATE = DATEADD(DAY,-1,SUBSTRING(CONVERT(VARCHAR,DATEADD(MONTH,1,@JobDate),120),1,8) + '01')
	DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                       -- Kangs 수정 (2019.03.07)
	DECLARE @BefToDate DATE   = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                -- Kangs 수정 (2019.03.07)

	
	---- 2022년 1월 / 2021년 12월 데이터

	--IF @JobDate  LIKE '2022-01%' or @JobDate  LIKE '2021-12%' 
	
	--      BEGIN 		 		
	--				SELECT Right(JobDate, 2) + '일'   AS DDAY 
	--						, RouteCode                                                         
	--						--, RouteName
	--						, TotalQty   
	--						, OutputQty 
	--						, DefectQty
	--						, LossQty AS RepairQty
	--						, LossQty		    
	--						, TotalRate
	--						, MaterialCode
	--						, MaterialName
	--					FROM STB_ProdRouteSummary_NEW 	
	--					WHERE 1=1
	--					  --  AND JOBDATE Like Substring(@JobDate, 0, 7) + '%'

	--						AND JOBDATE Like  SUBSTRING(CONVERT(VARCHAR,@JobDate,120),1,7) + '%'
	--					ORDER BY JobDate
 --              END
   
	-- ELSE

	  --- 이 부분이 정상 원래데이터 부분
	         -- BEGIN 
		 		
						 SELECT RIGHT(CONVERT(varchar(30), PRS.JOBDATE,120),2)  + '일'   AS DDAY 
							   , PRS.RouteCode                                                        AS RouteCode
							   , RI.RouteName
							   , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DEFECTQTY) +SUM(PRS.RepairQty)  + SUM(PRS.LOSSQty) , 2)                            AS TotalQty
							   , SUM(PRS.OutputQty)                                                                      AS OutputQty
							   , SUM(PRS.DefectQty)                                                                      AS DefectQty
							   , SUM(PRS.RepairQty)                                                                      AS RepairQty
							   , SUM(PRS.LossQty)                                                                        AS LossQty		    
							   , CASE  WHEN SUM(PRS.OutputQty)   = 0 THEN 0 ELSE  ISNULL(SUM(PRS.OutputQty), 0) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  *  100.0 	    END     AS TotalRate
							   , PRS.MaterialCode
							   , MM.MaterialName
							FROM STB_ProdRouteSummary PRS							
								LEFT OUTER JOIN STB_RouteInfo RI			  ON PRS.RouteCode = RI.RouteCode
								LEFT OUTER JOIN STB_MaterialMaster MM ON MM.MaterialCode = PRS.MaterialCode
						   WHERE 1=1
							 AND TimeCode <> 'E'     
							 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
							 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
						   GROUP BY PRS.RouteCode, RI.RouteName, PRS.JOBDATE, PRS.MaterialCode, MM.MaterialName
						   ORDER BY PRS.JOBDATE, PRS.RouteCode

            --END

  END	