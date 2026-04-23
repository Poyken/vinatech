-- =============================================
-- Author: kilee
-- Create date: 2019-03-05
-- Browsable : true
-- Group : 생산관리
-- Description:	공정별 생산수율을 가져옵니다
-- Modified: 2019.03.05 라인정렬 (kilee)
--           2019.03.07 FromTo 일자 변경  (kilee)
--           2019.12.05 SQL수정 (Kilee)
--           2020.07.27 
-- 실행 :  usp_GetProductionYield_dept '','','VNT','','','','2022-01-18'
-- =============================================
Create PROCEDURE [dbo].[usp_GetProductionYield_dept_20220122]
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
	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END,
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

	SELECT Z.RouteCode                                                                                               AS RouteCode
			, Z.RouteName
			, Z.TotalQty
			, Z.OutputQty
			, Z.DefectQty
			, Z.RepairQty
			, Z.LossQty		   
			, Z.TotalRate			 
	 FROM 
	(
	   SELECT PRS.RouteCode                                                                                               AS RouteCode
			   , RI.RouteName
			   , ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
			   , SUM(PRS.OutputQty)                                                                      AS OutputQty
			   , SUM(PRS.DefectQty)                                                                      AS DefectQty
			   , SUM(PRS.RepairQty)                                                                      AS RepairQty
			   , SUM(PRS.LossQty)                                                                        AS LossQty		   
			  -- , SUM(PRS.OutputQty) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  * 100.0  AS TotalRate
			   , ROUND(SUM(PRS.OutputQty) / (SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty))  * 100.0, 3)  AS TotalRate
	    FROM STB_ProdRouteSummary PRS
		LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
	   WHERE 1=1
	     AND TimeCode <> 'E'  
	    -- AND PRS.RouteCode = @RouteCode
		 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
		 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
	   --AND PRS.JobDate BETWEEN '2019-01-01' AND '2019-01-31'
       AND PRS.RouteCode LIKE 'E%'	     		
       GROUP BY PRS.RouteCode, RI.RouteName

	   Union ALL


	   -- 합계
	  SELECT ''    AS RouteCode
			   , '합계'  AS  RouteName
			   , SUM(A.TotalQty) AS TotalQty
			   , SUM(A.OutputQty) AS OutputQty
			   , SUM(B.DefectQty) AS DefectQty
			   , SUM(A.RepairQty)  AS RepairQty
			   , SUM(A.LossQty)   AS LossQty		   
	          , SUM(A.OutputQty) /  SUM(A.TotalQty)  *  100.0 	      AS TotalRate
		FROM
			    (	
					 SELECT PRS.RouteCode                                                                                               AS RouteCode
							   , RI.RouteName                                                                                               AS RouteName
								, ROUND(SUM(PRS.OutputQty) + SUM(PRS.DefectQty) +SUM(PRS.RepairQty)  + SUM(PRS.LossQty) , 2)    AS TotalQty
							   , SUM(PRS.OutputQty)                                                                      AS OutputQty
							   , SUM(PRS.DefectQty)                                                                      AS DefectQty
							   , SUM(PRS.RepairQty)                                                                      AS RepairQty
							   , SUM(PRS.LossQty)                                                                        AS LossQty		   							  
						FROM STB_ProdRouteSummary PRS
								 LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
					   WHERE 1=1
						 AND TimeCode <> 'E'  
						 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
						 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
						 AND PRS.RouteCode = 'E-22'	     		                               -- 권취에 해당
					   GROUP BY PRS.RouteCode, RI.RouteName
			   ) A

			, (
			   SELECT 
						  SUM(PRS.DefectQty)                                           AS DefectQty
				FROM STB_ProdRouteSummary PRS
						 LEFT OUTER JOIN STB_RouteInfo RI		  ON PRS.RouteCode = RI.RouteCode
			   WHERE 1=1
				 AND TimeCode <> 'E'  
				 AND ((@RouteCode = '*') OR (PRS.RouteCode = @RouteCode)) 
				 AND PRS.JobDate BETWEEN @BefFromDate AND @BefToDate
				 AND PRS.RouteCode LIKE 'E%'	     		
			   ) B

WHERE 1=1
GROUP BY A.RouteCode                                                                                         
			, A.RouteName
    
) Z
	ORDER BY Z.RouteCode


		
END
