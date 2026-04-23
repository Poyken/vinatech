-- =============================================
-- Author: kilee
-- Create date: 2019-04-03
-- Browsable : true
-- Group : 생산관리
-- Description:	일일실적보고 > 수율관련 3번째 Grid
-- Modified: 조회조건의 전일자 수율입니다.
  
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayYield_dept]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pJobDate DATE = NULL
AS

--   EXEC usp_DayYield_dept   '', '','' ,'','','','2019-04-11 08:00:00'


BEGIN
   SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)   = CASE WHEN ISNULL(@pCompanyCode,'') = ''    THEN '%' ELSE @pCompanyCode    END,
			    @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			    @LineCode VARCHAR(20) = @pLineCode,		                                                                                                               -- 라인별 카렌더가 다르면 전일이 다를수 있음
			  --@RouteCode VARCHAR(20) = @pRouteCode,
			    @JobDate DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromMonth  VARCHAR(20) = SUBSTRING(CONVERT(VARCHAR,@JobDate,121),1, 7)  + '%'                                                                               -- ex) 2018-04               SELECT  SUBSTRING(CONVERT(VARCHAR,'2019-04-09 08:30:00',121),1, 7)  + '%' 
	DECLARE @ToDay         VARCHAR(20) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 1, 10)                                                                      -- ex) 2018-04-02                 SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 1, 10)  

	

	--DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                        --- kilee수정 (2019.03.07)
	--DECLARE @BefToDate     DATE   = DATEADD(DAY, -1, (DATEADD(MONTH,1,@FromDate)))                --- kilee수정 (2019.03.07)

--    select SUBSTRING(CONVERT(VARCHAR,'2019-04-02 08:00:00',121),1,7) 






-------------- 풋터

SELECT '총합계'                                    AS RouteName
			, '99'                                        AS 누계목표
			, SUM(C.일일생산수량)                 AS  일일생산수량
			, SUM(C.누계생산)                       AS  누계생산
			, SUM(C.월수율)                          AS 누계달성율   			
			, CASE WHEN  SUM(C.월수율)   = 0 THEN 1 ELSE  (SUM(C.월수율) / 99) * 100 END       AS 누계진도율                         --> (월수율 / 월계획) * 100
	FROM (
						SELECT
								SUM(ISNULL(PRS.OUTPUTQTY, 0))                                                                  AS 일일생산수량
							, 0                                                                                                             AS 누계생산
							,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                AS  일수율
							, 0                                                                                                              AS 월수율
						FROM STB_ProdRouteSummary PRS
						WHERE 1=1
							AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!
							AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	 
							--AND PRS.JobDate = '2019-04-10'                                                                                                                       ----- ^^^^^
							AND PRS.JobDate = @ToDay 

					     UNION  ALL

						SELECT 
								0                                                                                                   AS 일일생산수량
							, ROUND(SUM(PRS.OUTPUTQTY), 0)                                                        AS 누계생산
							,  0                                                                                                   AS 일수율
							,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0      AS 월수율		   
						FROM STB_ProdRouteSummary PRS
						WHERE 1=1
							AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!	 
							--AND PRS.JobDate LIKE '2019-04%' 		     		
							AND PRS.JobDate LIKE @FromMonth										 
							AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	 							
			) C



UNION  ALL


------------------  공정별수율부분

SELECT A.RouteName                         AS RouteName
        , 99           	                             AS 누계목표	
		, A.생산수량                              AS 일일생산수량
		, B.생산수량                              AS 누계생산         
		, B.수율                                    AS  누계달성율            -- B테이블이 월별
		,   CASE WHEN  B.수율   = 0 THEN 1 ELSE    (B.수율  / 99) * 100    END           AS 누계진도율
 FROM 
		 
( 		
    -- A : 일자별수율 
	 SELECT PRS.RouteCode                                                                            AS RouteCode
	    -- , ''     AS RouteName
		   ,  (SELECT X.공정명 FROM ERPSVR.ERPDB.DBO.공정코드 X WHERE X.공정코드 = PRS.RouteCode)      AS RouteName
		  
		   , '' AS 누계달성율
		   , '' AS 누계진도율		
		   ,   ROUND(SUM(PRS.INPUTQTY),2)    AS 총수량
		   ,   SUM(PRS.OUTPUTQTY)               AS 생산수량
		   ,  SUM(PRS.DEFECTQTY)                AS 불량수량
		   ,  SUM(PRS.RepairQty)                  AS 수리수량
		   ,  SUM(PRS.LOSSQty)                    AS 폐기수량
		   ,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0           AS 수율
		   ,  JOBDATE AS 일자
	    FROM STB_ProdRouteSummary PRS
	   WHERE 1=1
	     AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!
	    -- AND PRS.JobDate = '2019-04-08'                                                                                           
		AND PRS.JobDate = @ToDay		 
		 AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	     		
       GROUP BY PRS.RouteCode, PRS.JobDate
	  -- ORDER BY PRS.RouteCode
) A

LEFT OUTER JOIN

  
  (   
	 SELECT  --JOBDATE AS 일자
	         PRS.RouteCode                                                                                                          AS RouteCode	    
		   ,  (SELECT X.공정명 FROM ERPSVR.ERPDB.DBO.공정코드 X WHERE X.공정코드 = PRS.RouteCode )  AS RouteName		  
		   ,  SUM(PRS.INPUTQTY)                                                                                                  AS 총수량
		   ,  ROUND(SUM(PRS.OUTPUTQTY), 0)                                                                                AS 생산수량
		   ,  SUM(PRS.DEFECTQTY)                                                                                                AS 불량수량
		   ,  SUM(PRS.RepairQty)                                                                                                  AS 수리수량
		   ,  SUM(PRS.LOSSQty)                                                                                                    AS 폐기수량
		   ,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                              AS 수율
		   , '' AS JOBDATE
	    FROM STB_ProdRouteSummary PRS
	   WHERE 1=1
	     AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!	 
	    --AND PRS.JobDate LIKE '2019-04%' 		     		
			AND PRS.JobDate LIKE @FromMonth 
		 AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	     		
       GROUP BY   PRS.RouteCode
	  
    ) B    ON A.RouteCode = B.RouteCode AND A.RouteName = B.RouteName


		
END


