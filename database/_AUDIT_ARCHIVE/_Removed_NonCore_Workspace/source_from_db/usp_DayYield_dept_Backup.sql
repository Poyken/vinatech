-- =============================================
-- Author: kilee
-- Create date: 2019-04-03
-- Browsable : true
-- Group : 생산관리
-- Description:	일일실적보고 > 수율관련
-- Modified: 
  
-- =============================================

--> EXEC usp_DayYield_dept_Backup '','','','','','','2019-04-07 08:30:00'

CREATE PROCEDURE [dbo].[usp_DayYield_dept_Backup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pJobDate DATE  = NULL
AS



BEGIN
   SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20)   = CASE WHEN ISNULL(@pCompanyCode,'') = ''    THEN '%' ELSE @pCompanyCode    END,
			    @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END,
			    @LineCode VARCHAR(20) = @pLineCode,		                                                                                                               -- 라인별 카렌더가 다르면 전일이 다를수 있음
			  --@RouteCode VARCHAR(20) = @pRouteCode,
			    @JobDate DATE = @pJobDate


  DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
--((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
			    
	DECLARE @FromMonth  VARCHAR(20) = SUBSTRING(CONVERT(VARCHAR,@JobDate,121),1, 7)                                                                                 -- ex) 2018-04
	DECLARE @FromDay      VARCHAR(20) = SUBSTRING(CONVERT(VARCHAR,@JobDate,121),1, 10)                                                                                 -- ex) 2018-04-02


	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @JobDate, 121) + ' 08:30:00'    
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @JobDate)), 121) + ' 08:30:00'
	--DECLARE @BefFromDate DATE = DATEADD(MONTH, 0, @FromDate)                                        --- kilee수정 (2019.03.07)


--	select  CONVERT(VARCHAR(10),  '2019-04-02 00:00:00', 121) + ' 08:30:00'    
-- 	select   CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime,  '2019-04-02 00:00:00')), 121) + ' 08:30:00'






SELECT A.공정명  AS 공정명
        , 99           	 AS 누계목표	
		, A.생산수량     AS 일일생산수량
		, B.생산수량     AS 누계생산         --누계생산수량		
		, B.수율          AS  누계달성율    -- 누계수율    ---(누계달성율)
		, A.수율          AS 누계진도율    -- 일일수율
 FROM 
		 
( 		

---- A START
--	 SELECT PRS.RouteCode                                                                            AS RouteCode
--	    -- , ''     AS RouteName
--		   ,  (SELECT X.공정명 FROM ERPSVR.ERPDB.DBO.공정코드 X WHERE X.공정코드 = PRS.RouteCode)      AS RouteName
		  
--		   , '' AS 누계달성율
--		   , '' AS 누계진도율		
--		   ,   ROUND(SUM(PRS.INPUTQTY),2)    AS 총수량
--		   ,   SUM(PRS.OUTPUTQTY)               AS 생산수량
--		   ,  SUM(PRS.DEFECTQTY)                AS 불량수량
--		   ,  SUM(PRS.RepairQty)                  AS 수리수량
--		   ,  SUM(PRS.LOSSQty)                    AS 폐기수량
--		   ,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0           AS 수율
--		   ,  JOBDATE AS 일자
--	    FROM STB_ProdRouteSummary PRS
--	   WHERE 1=1
--	     AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!
--	    AND PRS.JobDate = '2019-04-02'                                                                                             -------------------------------------^^^^^^
--		-- AND PRS.JobDate LIKE @FromDay  + '%'
--		 AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	     		
--       GROUP BY PRS.RouteCode, PRS.JobDate
	    

--     EXEC usp_DayYield_dept   '', '', '',  '2019-04-02 00:00:00'

		-----------------
  

						SELECT   B.공정코드
						         ,  C.공정명 AS 공정명
								   , ''         AS 누계달성율
		                          , ''          AS 누계진도율									
								, SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0))              AS 총수량
								, SUM(ISNULL(D.실적,0))                                              AS 생산수량
								, SUM(ISNULL(F.수량,0))                                       AS 불량수량
								, CASE WHEN   SUM(ISNULL(D.실적,0))  = 0 THEN 0 
								         WHEN  SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0))    = 0 THEN 0 
								            ELSE  ROUND(SUM(ISNULL(D.실적,0))  / (SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0)))  * 100.0, 2)  END    AS 수율																															 																		


           
					FROM ERPSVR.ERPDB.DBO.조립작업지시 A
								LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
								LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
								LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
								LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드							
								LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE																																		  
					WHERE 1=1																		
						--AND D.작업일자 BETWEEN @FromDt AND  @ToDt 
						AND D.작업일자 BETWEEN '2019-04-06 08:30:00' and '2019-04-07 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)																									

						--AND SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121), 0, 11)   BETWEEN '2019-04-02 08:30:00' and '2019-04-03 08:30:00'                              
						--AND SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),0,11)   BETWEEN @FromDt AND  @ToDt 
						--AND D.작업일자 BETWEEN '2019-04-02 08:30:00' an                 
						AND B.공정코드 in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	  
					GROUP BY   B.공정코드, C.공정명
					        
				
										

) A

LEFT OUTER JOIN

  -- [월합계]
  (
	   			SELECT   B.공정코드
						,  C.공정명 AS 공정명
						, ''         AS 누계달성율
						, ''          AS 누계진도율									
					, SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0))              AS 총수량
					, SUM(ISNULL(D.실적,0))                                              AS 생산수량
					, SUM(ISNULL(F.수량,0))                                       AS 불량수량
					, CASE WHEN   SUM(ISNULL(D.실적,0))  = 0 THEN 0 
								WHEN  SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0))    = 0 THEN 0 
								ELSE  ROUND(SUM(ISNULL(D.실적,0))  / (SUM(ISNULL(D.실적,0)) + SUM(ISNULL(F.수량,0)))  * 100.0, 2)  END    AS 수율		
							
		FROM ERPSVR.ERPDB.DBO.조립작업지시 A
					LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
					LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
					LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
					LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드							
					LEFT JOIN ERPSVR.ERPDB.DBO.CURLING_LINE                TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE																																		  
		WHERE 1=1																		
			AND SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),0,11)  LIKE '2019-04%' 	
			--AND SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),0,11)  LIKE @FromMonth + '%'			 
			AND B.공정코드 in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   		  
		 GROUP BY   B.공정코드, C.공정명
		  --, d.작업일자
				


    ) B    ON A.공정코드 = B.공정코드 AND A.공정명 = B.공정명


UNION ALL


------------------- CD  풋터 합계부분---------------------------------------------


		 
SELECT '합계'                      AS RouteName
         , NULL                           AS 누계목표
         , SUM(C.일일생산수량) AS  일일생산수량
        , SUM(C.누계생산)        AS  누계생산
		, 0                            AS  누계달성율   
		, 0                            AS 누계진도율    
 FROM (

				 SELECT
						   SUM(PRS.OUTPUTQTY)               AS 일일생산수량
						, 0 AS 누계생산
					
					   --,  SUM(PRS.DEFECTQTY)                AS 불량수량
					   --,  SUM(PRS.RepairQty)                  AS 수리수량
					   --,  SUM(PRS.LOSSQty)                    AS 폐기수량
					   --,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0           AS 수율
					FROM STB_ProdRouteSummary PRS
				   WHERE 1=1
					 AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!
					  AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	 
					 AND PRS.JobDate = '2019-04-06'                                                                                                                       ----- ^^^^^
		           --AND PRS.JobDate LIKE @FromDay  + '%'

					 UNION  ALL

				 SELECT 
						  0               AS 일일생산수량
						, ROUND(SUM(PRS.OUTPUTQTY), 0) AS 누계생산
					    
					   --,  SUM(PRS.DEFECTQTY)                                AS 불량수량
					   --,  SUM(PRS.RepairQty)                                  AS 수리수량
					   --,  SUM(PRS.LOSSQty)                                   AS 폐기수량
					   --,  ISNULL(SUM(PRS.OutputQty),0) / ISNULL(SUM(PRS.INPUTQTY),0) *  100.0                 AS 수율		   
					FROM STB_ProdRouteSummary PRS
				   WHERE 1=1
					 AND TimeCode = 'E'                                                               -- NAIS 정상적으로 가동시 주석처리 꼭 할 것!!	 
					 AND PRS.JobDate LIKE '2019-04%' 		     		
					 --AND PRS.JobDate LIKE @FromMonth + '%'	     		
					  AND RouteCode in ( 'E-22', 'E-24' , 'E-26', 'E-27')	   	 
			)  C

		
END


