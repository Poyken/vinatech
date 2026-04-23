
-- =============================================
-- Author:	   kilee
-- Create date: 2019-03-19
-- Browsable : true
-- Group : 공통
-- Description:	ERP 생산실적 I/F
-- Modified: 자동 인터페이스 부분
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdSummaryList_IF]
AS


BEGIN
	SET NOCOUNT ON;

-----------> [라인설정 Table] 부분

              DELETE FROM ERPSVR.erpdb.DBO.TEST_LINE    -- DELETE문

			  --  SELECT * FROM ERPSVR.erpdb.DBO.TEST_LINE  

	            INSERT INTO ERPSVR.erpdb.DBO.TEST_LINE      -- INSERT문					  					  
					SELECT 지시번호                                                                                                                                                           AS 지시번호
						 , CASE WHEN MAX(라인명) LIKE '%셀99%'   THEN '셀10' WHEN MAX(라인명) LIKE '%셀%'  THEN MAX(라인명) ELSE '드라이룸'  END  AS 라인명				   
					FROM 
					       (
					        -- [Q부분]
							SELECT Z.지시번호				                            AS  지시번호
							--    , CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 2), '') LIKE '%셀%'  THEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 =  Z.설비코드), 2), '')  ELSE '드라이룸' END    AS 라인명
							      , CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀10%'  THEN '셀99'
										 WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀%'    THEN  ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 =  Z.설비코드), 3), '')  
									      ELSE '드라이룸'   END                           AS 라인명
							FROM 
								(
								 -- Z부분
											SELECT 지시번호
												 , 설비코드																												
												 , (SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = A.설비코드) AS 설비명													                                     
											 FROM ERPSVR.erpdb.DBO.조립생산실적 A
											WHERE 1=1			
											  --AND 작업일자 BETWEEN @dt1 AND @dt2
             --        						  AND CASE WHEN (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN @dn = '전체' THEN '%' ELSE @dn END  
												
																							 
											   AND 작업일자 BETWEEN '2018-01-01 08:30:00' and '2019-12-31 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
											   AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '전체' = '전체' THEN '%' ELSE '전체' END 
											     AND 공정코드 IN ('E-22', 'E-24')						
											   --AND A.지시번호 = 'VJIN033R015606'
                                      -- Z부분
								) Z
                               -- [Q부분]
					    ) Q
					GROUP BY  지시번호 ;			



-----------> 1. [계획 Table]   Insert 부분

        --[DELETE문]  : 123,164개  (2019. 03. 20 기준)
		  DELETE FROM STB_DayProdPlan WHERE DPPExtText05 = 'ERP' 

		    INSERT INTO STB_DayProdPlan ( DayPlanNo, CompanyCode, WorkcenterCode, PONo, MaterialCode, LineCode, RouteCode, MachineCode, PlanDate, PlanShiftCode, PlanQty, CreateUserID, CreateDateTime, DPPExtText05, CurrentTarget)		
			SELECT  CONVERT(VARCHAR(8), A.지시일자, 112) + RIGHT('000000' + CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY  A.지시일자)), 6)                                       AS DayPlanNo	
					 , 'VNT'                                                                                                                                                                                                                    AS CompanyCode	
					 , 'VNT_F1'                                                                                                                                                                                                                AS WorkcenterCode
					, SUBSTRING(REPLACE(CONVERT(varchar(30), A.지시일자,120),'-',''), 3, 6)  + RIGHT('000000' + CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY  A.지시일자)), 6)  AS PONo
					, A.품목코드                                                                                                                 AS MaterialCode
					,  CASE WHEN B.라인명 = '셀10' THEN 'ASSYLINE-10'
							  WHEN B.라인명 = '셀9' THEN 'ASSYLINE-09'
							  WHEN B.라인명 = '셀8' THEN 'ASSYLINE-08'
							  WHEN B.라인명 = '셀7' THEN 'ASSYLINE-07'
							  WHEN B.라인명 = '셀6' THEN 'ASSYLINE-06'
							  WHEN B.라인명 = '셀5' THEN 'ASSYLINE-05'
							  WHEN B.라인명 = '셀4' THEN 'ASSYLINE-04'
							  WHEN B.라인명 = '셀3' THEN 'ASSYLINE-03'
							  WHEN B.라인명 = '셀2' THEN 'ASSYLINE-02'
							  WHEN B.라인명 = '셀1' THEN 'ASSYLINE-01'					  ELSE 'DRYROOM-01' END                                                                                                       AS LineCode
					, 'E-22'                                                                                                                                                                                                                     AS RouteCode                   -- 계획 Table에서 RouteCode는 권취공정으로 동일시
					, ''                                                                                                                                                                                                                           AS MachineCode			  
					, CONVERT(varchar(30), A.지시일자, 120)                                                                                                                                                                          AS PlanDate
					, CASE WHEN (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),지시일자,121),12,5),':','')) > 830) AND (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),지시일자,121),12,5),':','')) <= 2030) THEN '1'  ELSE '2' END  AS  PlanShiftCode    -- 주간 : 1, 야간 : 2
					,  ISNULL(A.수량, '0')                                                                                                        AS PLANQTY	
					, 'kilee'                                                                                                                        AS CreateUserID
					, GETDATE()                                                                                                                  AS CreateDateTime
					, 'ERP'                                                                                                                         AS DPPExtText05
					, 100                                                                                                                           AS CurrentTarget
			FROM 
					ERPSVR.erpdb.DBO.조립작업지시 A		    LEFT JOIN ERPSVR.erpdb.DBO.TEST_LINE B        ON A.지시번호 = B.지시번호
			WHERE 1=1
					 --AND A.지시일자 BETWEEN '2016-01-01 08:30:00' and '2018-12-31 23:59:59'                                                                                                                              	
			ORDER BY A.지시일자 


-----------> 2. [실적 Table]   Insert 부분
	 
	   -- SELECT * FROM STB_ProdRouteSummary WHERE TimeCode = 'E'         -- 총 건수 : 651,670  (2019.03.19 기준)
	       DELETE   FROM STB_ProdRouteSummary WHERE TimeCode = 'E' ;        


	  INSERT INTO STB_ProdRouteSummary ( ProductSummaryID, CompanyCode, WorkcenterCode, PoNo, LineCode, MaterialCode, MachineCode, RouteCode, JobDate, ShiftCode, InputQty, OutputQty, DefectQty, RepairQty, LossQty, TimeCode)	
	  SELECT  CONVERT(VARCHAR(8), ISNULL(A.작업일자, '2019-01-01 00:00:00'), 112) + RIGHT('000000' + CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY  A.작업일자)), 6)     AS ProductSummaryID
			   ,  'VNT'                                                                                                                                                                                                                          AS CompanyCode			
 			   ,  'VNT_F1'                                                                                                                                                                                                                      AS WorkcenterCode		  
			   ,  SUBSTRING(REPLACE(CONVERT(varchar(30), A.작업일자,120),'-',''), 3, 6)  + RIGHT('000000' + CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY  A.작업일자)), 6)      AS PoNo              
			   ,  CASE WHEN B.라인명 = '셀10' THEN 'ASSYLINE-10'
			             WHEN B.라인명 = '셀9'  THEN 'ASSYLINE-09'
						  WHEN B.라인명 = '셀8'  THEN 'ASSYLINE-08'
						  WHEN B.라인명 = '셀7'  THEN 'ASSYLINE-07'
						  WHEN B.라인명 = '셀6'  THEN 'ASSYLINE-06'
						  WHEN B.라인명 = '셀5'  THEN 'ASSYLINE-05'
						  WHEN B.라인명 = '셀4'  THEN 'ASSYLINE-04'
						  WHEN B.라인명 = '셀3'  THEN 'ASSYLINE-03'
						  WHEN B.라인명 = '셀2'  THEN 'ASSYLINE-02'
						  WHEN B.라인명 = '셀1'  THEN 'ASSYLINE-01'	 ELSE 'DRYROOM-01' END                                                                                                                AS LineCode
			, A.품목코드                                                                                                                                                                                                               AS MaterialCode
			, A.설비코드                                                                                                                                                                                                               AS MachineCode			
			, A.공정코드                                                                                                                                                                                                               AS RouteCode
			, CONVERT(varchar(30), A.작업일자,120)                                                                                                                                                                                                                                                            AS JobDate			
			, CASE WHEN (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '1'  ELSE '2' END   AS  ShiftCode    -- 주간 : 1, 야간 : 2
			, (ISNULL(A.실적, '0') + ISNULL(A.불량, '0'))                                                                                                                                                                                                                                                         AS  InputQty
			, ISNULL(A.실적, '0')                                                                                                                                                                                                                                                                                      AS OutputQty		   
			, ISNULL(A.불량, '0')                                                                                                                                                                                                                                                                                      AS DefectQty
			, '0'                                                                                   AS RepairQty
			, '0'                                                                                   AS LossQty		       
			, 'E'                                                                                   AS TimeCode 		
FROM  ERPSVR.erpdb.DBO.조립생산실적 A
		  LEFT JOIN ERPSVR.erpdb.DBO.TEST_LINE B        ON A.지시번호 = B.지시번호
WHERE 1=1     
ORDER BY A.작업일자;


END







