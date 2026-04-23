-- =============================================
-- Author:	   kilee
-- Create date: 2019-07-31
-- Browsable : true
-- Group : 조립불량현황
-- Description:	[B660] 조립불량현황
-- Modified: 

-- 실행 :   EXEC  [usp_GetProdBadStatus] '','','','','','','','2019-08-01','2019-08-31',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdBadStatus_20190816]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pIsOutputRoute BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'')    = '' THEN 'VNT'     ELSE @pCompanyCode    END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN 'VNT_F1' ELSE @pWorkCenterCode END
	DECLARE @LineCode VARCHAR(20)          = CASE WHEN ISNULL(@pLineCode,'')           = '' THEN '%'        ELSE @pLineCode          END
	DECLARE @RouteCode VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END
	DECLARE @MaterialCode VARCHAR(50)     = CASE WHEN ISNULL(@pMaterialCode,'')       = '' THEN '%'       ELSE @pMaterialCode     END
	DECLARE @FromDate DATE                   = @pFromDate
	DECLARE @ToDate DATE                      = @pToDate
	DECLARE @IsOutputRoute BIT = @pIsOutputRoute

	SELECT  X.JobDate    AS 작업일자
		,  X.LineCode   AS  라인코드		  
		,  X.RouteCode AS 공정코드
		,  X.RouteName AS 공정명
		,  X.MaterialCode  AS 품목코드
		,  X.MaterialName  AS 품목명
		,  X.DefectCode AS  불량코드
		,  X.DefectName  AS 불량명 
		,  X.DefectQty AS 불량수량		
		, (X.DefectQty / Z.TotalQty) * 100 AS 누적불량률
FROM 
		(
		--불량항목별 (노승한)
			SELECT FindJobDate   as JobDate
				   , FindLineCode   as  LineCode
				   , FindRouteCode as RouteCode
				   , CASE WHEN FindRouteCode = 'E-22' THEN '권취'
							WHEN FindRouteCode = 'E-24' THEN '커링'
							WHEN FindRouteCode = 'E-25' THEN '슬리빙'
							WHEN FindRouteCode = 'E-26' THEN '에이징'
							WHEN FindRouteCode = 'E-27' THEN '외관' 
							WHEN FindRouteCode = 'E-28' THEN '포장'  ELSE '기타' END                                                          AS RouteName
				   , MaterialCode                                                                                                                               AS  MaterialCode
				   , (SELECT MM.MaterialName FROM STB_MaterialMaster MM WHERE MM.MaterialCode = A.MaterialCode )        AS MaterialName
				   , DefectCode                                                                                                                                  AS  DefectCode
				   , (SELECT BasicDefectName FROM STB_DefectInfo B WHERE B.DefectCode = A.DefectCode  AND Isused = '1')    AS DefectName
				   , SUM(DefectQty)                                                                                                                            AS DefectQty
				   , 0                                                                                                                                               AS TotalQty		
			  FROM STB_DefectRepairInfo A
			WHERE 1=1
			   --AND FindJobDate BETWEEN  '2019-08-01' AND '2019-08-04'
			   --AND FindLineCode = 'ASSYLINE-10'
			   --AND MaterialCode LIKE 'ECVT30-220'		 
			   
			   AND (FindJobDate BETWEEN @FromDate AND @ToDate) 
			  AND	FindLineCode LIKE @LineCode 
			  AND	FindRouteCode LIKE @RouteCode 
			  AND	MaterialCode LIKE @MaterialCode 	
			   		 
			group by FindJobDate, FindRouteCode, MaterialCode, DefectCode, FindLineCode
		) X
	 , 
		(
		 SELECT ''   as JobDate
				   , ''  as  LineCode		  
				   , '' as RouteCode
				   , '' AS RouteName
				  , ''  AS MaterialCode
				  , ''  AS MaterialName
				  , ''  AS  DefectCode
				  , ''  AS DefectName 
				  , 0 AS DefectQty
				  , SUM(DefectQty) AS TotalQty
		 FROM STB_DefectRepairInfo
		WHERE 1=1
		  --AND FindJobDate BETWEEN  '2019-08-01' AND '2019-08-04'
			   --AND FindLineCode = 'ASSYLINE-10'
			   --AND MaterialCode LIKE 'ECVT30-220'		 
			   
			   AND (FindJobDate BETWEEN @FromDate AND @ToDate) 
			  AND	FindLineCode LIKE @LineCode 
			  AND	FindRouteCode LIKE @RouteCode 
			  AND	MaterialCode LIKE @MaterialCode 	
		 )  Z

      ORDER BY X.JobDate  
		         ,  X.LineCode   

	--SELECT
	--		DRI.DefectSummaryNo,
	--		DRI.ControlNo,
	--		SI.PONo,
	--		SI.DayPlanNo,
	--		SI.Barcode,
	--		SI.MaterialCode,
	--		DI.DefectGroupCode,
	--		DG.BasicDefectGroupName,
	--		DRI.DefectCode,
	--		DI.BasicDefectName,
	--		DRI.DefectQty
	--		--@RouteCode AS RouteCode,
	--		--@LineCode AS LineCode
	--FROM
	--		STB_DefectRepairInfo DRI WITH(NOLOCK)
	--		INNER JOIN        STB_SetInfo SI WITH(NOLOCK)				ON SI.ControlNo = DRI.ControlNo
	--		LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)		ON DI.DefectCode = DRI.DefectCode
	--		LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)	ON DG.DefectGroupCode = DI.DefectGroupCode
	--WHERE 1=1
	--AND 			SI.Barcode = @Barcode 
	--AND			DRI.FindRouteCode = @RouteCode 
	--AND			(DRI.RepairType IS NULL OR DRI.RepairType NOT IN ('FINISH'))


	----불량항목별 (노승한)
	--SELECT FindJobDate   as 작업일자
	--       , FindLineCode   as  라인코드
	--	  -- , '' as 라인명 
	--       , FindRouteCode as 공정코드
	--	   , CASE WHEN FindRouteCode = 'E-22' THEN '권취'
	--	            WHEN FindRouteCode = 'E-24' THEN '커링'
	--	            WHEN FindRouteCode = 'E-25' THEN '슬리빙'
	--				WHEN FindRouteCode = 'E-26' THEN '에이징'
	--				WHEN FindRouteCode = 'E-27' THEN '외관' 
	--				WHEN FindRouteCode = 'E-28' THEN '포장'  ELSE '기타' END                                                          AS 공정명
	--	   , MaterialCode                                                                                                                               AS  품목코드
	--	   , (SELECT MM.MaterialName FROM STB_MaterialMaster MM WHERE MM.MaterialCode = A.MaterialCode )        AS 품목명
	--	   , DefectCode                                                                                                                                  AS  불량코드
	--	   , (SELECT BasicDefectName FROM STB_DefectInfo B WHERE B.DefectCode = A.DefectCode  AND Isused = '1')    AS 불량명
	--	   , SUM(DefectQty)                                                                                                                            AS 불량수량

	--	 -- , SUM(OutputQty) - SUM(DefectQty) AS 양품수량			
	--		--CASE WHEN ISNULL(SUM(PRS.DefectQty),0) = 0 THEN 0.0 
	--		--        WHEN ISNULL(SUM(PRS.OutputQty),0) = 0 THEN 0.0 	ELSE SUM(PRS.DefectQty) / SUM(PRS.OutputQty) * 100.0 END AS 불량율
	--  FROM STB_DefectRepairInfo A              -- select * from STB_DefectRepairInfo
	--WHERE 1=1
	--  --AND FindJobDate BETWEEN  '2019-07-12' AND '2019-07-30'
	--  --AND FindLineCode = 'ASSYLINE-10'
	--  --AND MaterialCode LIKE 'ECVT30-220'

	--  AND (FindJobDate BETWEEN @FromDate AND @ToDate) 
	--  AND	FindLineCode LIKE @LineCode 
	--  AND	FindRouteCode LIKE @RouteCode 
	--  AND	MaterialCode LIKE @MaterialCode 	  

 --  -- AND	CompanyCode LIKE @CompanyCode 		  
 --  -- AND	WorkCenterCode LIKE @WorkCenterCode       		 		 

	--group by FindJobDate, FindRouteCode, MaterialCode, DefectCode, FindLineCode
	--order by FindJobDate
		


END

-- SELECT SUM(DefectQty)
-- FROM STB_DefectRepairInfo
--WHERE 1=1
--   AND FindJobDate BETWEEN  '2019-07-12' AND '2019-07-30'
--   AND FindLineCode = 'ASSYLINE-10'
--   AND MaterialCode LIKE 'ECVT30-220'

	  --AND (FindJobDate BETWEEN @FromDate AND @ToDate) 
	  --AND	FindLineCode LIKE @LineCode 
	  --AND	FindRouteCode LIKE @RouteCode 
	  --AND	MaterialCode LIKE @MaterialCode 	  

--  select * FROM STB_DefectRepairInfo 
	  --select * from STB_DefectInfo where Isused = '1'

