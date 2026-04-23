-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-09
-- Browsable   : true
-- Group       : 2019-04-05 오전 08:31 자동실행  (매일 1번 자동실행)
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 매일 아침 8시30분기준으로 전일자 일일실적현황을 자동으로 계산해서 넣어준다.  (오늘이 10일이면 9일 실적을 9일에 자동입력)
--                   2019-04-09 정상실행                       
-- ==================================================================

CREATE PROC [dbo].[usp_CurlingLine_Daily_Input_jackaroe]
AS

---[실행문]    EXEC usp_CurlingLine_Daily_Input

BEGIN
	SET NOCOUNT ON;

 --[기존형식]
	DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                                                                             -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10), GetDate(),    121) + ' 08:30:00'                                                                             -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	DECLARE @ToDay      VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                                        -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)
	----DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'                                                           -- SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00', 121) + ' 20:30:00'  

-- [수동으로 실행시 -> 지우지말것]	
	--DECLARE @FromDt             VARCHAR(19) =  '2019-09-01 08:30:00'            -- 전일                    
	--DECLARE @ToDt                VARCHAR(19) =  '2019-09-02 08:30:00'            -- 금일
	--DECLARE @ToDay              VARCHAR(02) =   '01'                                -- 전일자로 넣음
	
--  SELECT * FROM CURLING_PROD               --> 일자별
--  SELECT * FROM CURLING_PLAN               --> 월별계획
--  SELECT * FROM CURLING_LINE WHERE 라인명 = '베트남'

  --BEGIN TRAN
  ---- COMMIT
  --UPDATE CURLING_PROD
  --SET DAY09 = '0'
  


  -- 2019.05.08 추가사항
    -- BEGIN TRAN
    -- COMMIT
	   UPDATE CURLING_PROD
			SET 사이즈 = B.사이즈
		 FROM CURLING_PROD  A
				  LEFT JOIN  CURLING_PLAN B  ON A.사이즈 = B.사이즈 AND A.라인코드 = B.라인코드
		WHERE 1=1
		    --AND A.기준년월 = '201905'                                                                                                            -- 수동으로 돌릴때 확인
			AND A.기준년월 =  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 8), '-', '')



				 -- SELECT *  FROM CURLING_LINE  WHERE 라인명 = '베트남' ORDER BY  라인명                                                                                                                                                                -- SELECT문
				 -- SELECT *  FROM CURLING_LINE  WHERE 지시번호 = 'VJJL282R725613'



		  		    DELETE FROM CURLING_LINE                                                                                                                                                                                             -- DELETE문

                    INSERT INTO CURLING_LINE                                                                                                                                                                                               -- INSERT문					  					  
					SELECT 지시번호                                                                                                                                                                AS 지시번호
						   , CASE WHEN MAX(라인명) LIKE '%셀98%'  THEN '셀10' 
						            WHEN MAX(라인명) LIKE '%셀99%'  THEN '셀11' 
						            WHEN MAX(라인명) LIKE '%셀%'      THEN MAX(라인명) ELSE '드라이룸'  END   AS 라인명				    
					FROM (
							  -- Q부분
								SELECT  Z.지시번호				                                  AS  지시번호							
									   , CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀10%'  THEN '셀98'
									            WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀11%'  THEN '셀99'
												WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀%'     THEN  ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 =  Z.설비코드), 3), '')  
												WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') = '베트남'       THEN  '베트남'
												ELSE '드라이룸'   END                            AS 라인명
								FROM 
									(
									 -- Z부분
												SELECT 지시번호
													 , 설비코드																												
													 , (SELECT X.설비명 FROM  ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = A.설비코드) AS 설비명													                                     
												 FROM ERPSVR.ERPDB.DBO.조립생산실적 A
												WHERE 1=1															   
												   AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '전체' = '전체' THEN '%' ELSE '전체' END 
												   AND 작업일자 BETWEEN  '2016-01-01 08:30:00'  AND  '2020-01-01 00:00:00'	
												   --AND 작업일자 BETWEEN '2019-01-01 08:30:00' and '2019-04-02 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)												   
												   AND 공정코드 = 'E-24'												  
									)  Z
							  -- Q부분
					     ) Q
					GROUP BY  지시번호 			



					  -- [베트남부분 추가예정]
						--사이즈 1625, 설비 권취 5호기
						--사이즈 1320, 설비 권취 2호기, 13일기준으로 이전은 베트남수량, 이후는 본사수량
						-- 사이즈 1325, 설비 권취 3호기, 13일기준으로 이전은 베트남수량, 이후는 본사수량  
						    SELECT A.지시번호
									--, B.공정코드, 공정명 = C.공정명																								
									--, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
									--, ISNULL(D.실적,0)                                              AS 양품수량
									--, SUM(ISNULL(F.수량,0))                                       AS 불량수량
									--, D.작업일자									
									, B.설비코드
									--, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  								 										
									, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' 
									         WHEN (TM.라인명) LIKE '셀11%'  THEN '셀11'  ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
									, P.사이즈 	
									, '베트남'  AS  라인명						
                            INTO  #TEMP_TABLE101                                                                                                                                                                                               -- 주석처리하면 안됨
							FROM ERPSVR.ERPDB.DBO.조립작업지시 A
										LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                     ON A.지시번호 = B.지시번호
										LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D               ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
										LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                     ON D.실적현황순번 = F.실적현황순번
										LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                          ON C.공정코드 = B.공정코드
										INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                      ON A.품목코드 = P.PRODCD																						  									  										
								        LEFT JOIN CURLING_LINE                                            TM ON A.지시번호 = TM.지시번호 	     AND D.지시번호 = TM.지시번호	                        
							WHERE 1=1																																						
								AND D.작업일자 BETWEEN '2018-01-01 00:00:00' and  '2020-01-01 00:00:00'	                             --  이설정대로 하면 주야간 모두
								--AND D.작업일자 > @FromDt AND D.작업일자 <= @ChangeTime
								AND B.공정코드 = 'E-22'								
								--AND (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)   LIKE '%권취%'
								AND B.설비코드 IN ('VNEP02102','VNEP02103','VNEP02104')
							    --AND P.사이즈 IN ('1625','1320','1325')
							GROUP BY  A.지시번호				
							 , TM.라인명, P.사이즈, B.설비코드


							--SELECT * FROM TEMP_TABLE101
						
                             UPDATE CURLING_LINE
							       SET 라인명 = B.라인명
                               FROM CURLING_LINE A
							            RIGHT  JOIN  #TEMP_TABLE101  B  ON A.지시번호 = B.지시번호
							 WHERE A.지시번호 IS NOT NULL


	
 --  [조회 QUERY]  *****************************************************************************************************************************************


 SELECT GG.라인명                         AS 정렬라인명
         , GG.라인별칭                      AS 라인명
         , GG.규격                            AS 규격
	     , GG.월간계획                      AS 월간계획
		 , (GG.월간계획/30)                 AS 누계목표 		 
		 , ( SS.일일총수량 + GG.월누적수량 )                                                      AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 , (   ( SS.일일총수량 + GG.월누적수량 )   /   (GG.월간계획/30) * 100 )            AS 누계달성율		   -- 누계생산 / 누계목표
		 , (  ( ( SS.일일총수량 + GG.월누적수량 )   /   GG.월간계획) * 100)                 AS 누계진도율       -- 누계생산 / 월간계획 		
		, CASE WHEN SS.주간수량 IS NULL THEN 0 ELSE    SS.주간수량 END             AS 주간수량
		, CASE WHEN SS.야간수량 IS NULL THEN 0 ELSE    SS.야간수량 END             AS 야간수량		
		, GG.특이사항                                                                                    AS 특이사항
		, SS.일일총수량                                                                                  AS 일일총수량	 
		, CONVERT(VARCHAR(10),  GetDate()-1, 121)                                               AS 기준일자                                                                                           -- 금일날짜
		, GG.라인코드                                                                                     AS 라인코드		
  INTO #TEMP_TABLE100                                                                                                                                                                                            -- 주석 미처리 할것
  FROM 
				(  
				 -- GG START
								SELECT  BB.*
										, AA.월누적수량 AS 월누적수량
								FROM 
								(
										  SELECT  PL.라인명
													, SUM(PO.월누적수량)  AS 월누적수량
											FROM CURLING_PLAN   PL                                                                                                                                             -- 월별계획 Table
													LEFT OUTER JOIN CURLING_PROD PO ON   PO.라인명 = PL.라인명                                                                                  -- 일별실적 Table (라인명으로 Join)
									WHERE 1=1
									--AND PL.라인명 = '01호기'
										AND PL.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 				       -- select 				REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 						
									GROUP BY  PL.라인명
								) AA
							,	(
										SELECT 라인코드
												, 라인명
												, 사이즈
												, 규격
												, 월간계획
												, 라인별칭
												, 특이사항
											FROM CURLING_PLAN            -- SELECT * FROM CURLING_PLAN WHERE 기준년월 = '201908'
										  WHERE 1=1									
										AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 	
								) BB
									WHERE 1=1
										AND AA.라인명 = BB.라인명
				-- GG END
			   ) GG

LEFT JOIN (	--> GG 테이블 기준으로 

					 SELECT 라인명                                   AS 라인명
						     , 규격                                      AS 규격
							 , SUM(주간수량)                        AS 주간수량
							 , SUM(야간수량)                        AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량) AS 일일총수량
						FROM (

										-- 주간 START
												  SELECT   MAX(라인명)     AS 라인명	
															, 사이즈             AS 규격					  		
															, SUM(양품수량)   AS 주간수량		
															, 0                    AS 야간수량
													FROM
													(			  
																SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																				   WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀98'  THEN '10호기'
																				   WHEN ISNULL(A.조립라인명, '')  = '셀11' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '11호기' 
																				   WHEN ISNULL(A.조립라인명, '')  LIKE '%베트남%'  THEN '베트남'                                        ELSE '드라이룸'  END    AS 라인명
																		, 지시번호                                                                                      AS 지시번호 
																		, A.품목코드                                                                                    AS 품목코드
																		, A.사이즈                                                                                       AS 사이즈								
																		, SUM(투입수량)                                                                               AS 투입수량
																		, SUM(양품수량)                                                                               AS 양품수량													
																	--	, ISNULL(SUM(금액), 0)                                                                       AS 총합      									       					  								
																FROM (
																			---- 
																				SELECT A.지시일자
																						, A.지시번호
																						, 투입일자 = B.작업시작시간
																						, 종료일자 = B.작업종료시간
																						, A.품목코드
																						, 품명 = P.PRODNM
																						, 규격 = P.PRODSP
																						, B.공정코드, 공정명 = C.공정명
																						, D.작업자, 작업자명 = (SELECT NAME FROM ERPSVR.ERPDB.DBO.EMPREF WHERE SABUN = D.작업자)
																						, B.순번
																						, B.작업구분
																						, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
																						, ISNULL(D.실적,0)                                              AS 양품수량
																						, SUM(ISNULL(F.수량,0))                                       AS 불량수량
																						, D.작업일자
																						, D.비고
																						, B.설비코드
																						, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  
																						--, (GD.PROD_UNIT_PRICE + GD.CASE_PRICE) * ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                                               AS 금액
																						, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 										
																						, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                       ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D                 ON B.지시번호 = D.지시번호             AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                       ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                            ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                        ON A.품목코드 = P.PRODCD	
																						--LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD  ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																						LEFT JOIN CURLING_LINE               TM                               ON A.지시번호 = TM.지시번호 	          AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE																			  
																			WHERE 1=1																		
																				AND D.작업일자 BETWEEN @FromDt AND  @ToDt 
																				--AND D.작업일자 BETWEEN '2019-05-01 08:30:00' and '2019-05-09 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
																				AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '주간' = '전체' THEN '%' ELSE '주간' END														
																				AND B.공정코드 = 'E-24'
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																						--, GD.PROD_UNIT_PRICE 
																						--, GD.CASE_PRICE
																						, TM.라인명		
																						, P.사이즈	
																			---- A		  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			 , 품명
																			 , 지시번호	 							
																			 , 설비명	
																			 , 조립라인명
																			 , 사이즈										
																) ZZ		
													GROUP BY 사이즈
																, 라인명

													 UNION ALL

													-- NAIS 추가부분

															SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = A.InputLineCode ) AS 라인명
																	--, A.InputLineCode AS 라인코드			 
																	, SP.사이즈 AS 규격
																	, (SUM(A.ProdQty) - SUM(A.DefectQty))  AS 주간수량
																	, 0 AS 야간수량
																FROM STB_SetInfo A     
																		LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
																WHERE 1=1
																    AND  A.CreateDateTime BETWEEN @FromDt AND  @ToDt 
																	--AND A.CreateDateTime > @FromDt AND A.CreateDateTime <= @ChangeTime
																	--AND A.CreateDateTime BETWEEN '2019-09-01 08:30:00'and '2019-09-01 20:30:00'																								 																								 
																	AND A.InputShiftCode = '1'
															GROUP BY A.InputLineCode 
																		, SP.사이즈		
                                                  --  주간 END



												UNION 


												 -- 야간 START
												  SELECT   MAX(라인명)    AS 라인명	
															, 사이즈             AS 규격	
															, 0                    AS 주간수량				  		
															, SUM(양품수량)   AS 야간수량		
													FROM
													(
																SELECT  CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																					WHEN ISNULL(A.조립라인명, '')  = '셀10' OR ISNULL(A.조립라인명, '')  = '셀98'  THEN '10호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '셀11' OR ISNULL(A.조립라인명, '')  = '셀99'  THEN '11호기' 
																					WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'    ELSE '드라이룸' END        AS 라인명
																		, 지시번호                                                                                      AS 지시번호 
																		, A.품목코드                                                                                    AS 품목코드
																		, A.사이즈                                                                                       AS 사이즈								
																		, SUM(투입수량)                                                                               AS 투입수량
																		, SUM(양품수량)                                                                               AS 양품수량													
																	--	, ISNULL(SUM(금액), 0)                                                                       AS 총합      									       					  								
																FROM (
																			---- A START
																				SELECT A.지시일자
																						, A.지시번호
																						, 투입일자 = B.작업시작시간
																						, 종료일자 = B.작업종료시간
																						, A.품목코드
																						, 품명 = P.PRODNM
																						, 규격 = P.PRODSP
																						, B.공정코드, 공정명 = C.공정명
																						, D.작업자, 작업자명 = (SELECT NAME FROM ERPSVR.ERPDB.DBO.EMPREF WHERE SABUN = D.작업자)
																						, B.순번
																						, B.작업구분
																						, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
																						, ISNULL(D.실적,0)                                              AS 양품수량
																						, SUM(ISNULL(F.수량,0))                                       AS 불량수량
																						, D.작업일자
																						, D.비고
																						, B.설비코드
																						, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  
																					--	, (GD.PROD_UNIT_PRICE + GD.CASE_PRICE) * ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                                               AS 금액
																						, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 										
																						, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                      ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D                ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                      ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                           ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                       ON A.품목코드 = P.PRODCD	
																						--LEFT JOIN ERPSVR.ERPDB.DBO.VECS_UNITCONVERT_PRICE GD ON C.공정코드 = GD.PROCESS_CODE  AND GD.prod_size = p.사이즈                                 -- 금액TABLE											  									  
																						LEFT JOIN CURLING_LINE                                            TM ON A.지시번호 = TM.지시번호 	         AND D.지시번호 = TM.지시번호	                             -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																			WHERE 1=1																		
																				AND D.작업일자 BETWEEN @FromDt AND  @ToDt 
																				--AND D.작업일자 BETWEEN  '2019-04-01 08:30:00' and '2019-04-02 08:30:00'                                     -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
																				AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '야간' = '전체' THEN '%' ELSE '야간' END
																				AND A.품목코드   LIKE ISNULL('','') + '%'			
																				AND P.PRODNM  LIKE '%' + ISNULL('','') + '%'
																				AND P.PRODSP    LIKE '%' + ISNULL('','') + '%' 															
																				AND B.공정코드 = 'E-24'
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드
																						--, GD.PROD_UNIT_PRICE 
																						--, GD.CASE_PRICE
																						, TM.라인명		
																						, P.사이즈	
																			---- A	 END	  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			, 품명
																			, 지시번호	 							
																			, 설비명	
																			, 조립라인명
																			, 사이즈										
																) ZZ		
													GROUP BY 사이즈
																, 라인명

												UNION ALL

												-- NAIS 추가부분 (야간)
														SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = A.InputLineCode ) AS 라인명																									
																, SP.사이즈 AS 규격
																, 0 AS 주간수량
													            , (SUM(A.ProdQty) - SUM(A.DefectQty))             AS 야간수량
															FROM STB_SetInfo A     
																	LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
															WHERE 1=1		
															    AND  A.CreateDateTime BETWEEN @FromDt AND  @ToDt 																						 
																--AND A.CreateDateTime > @FromDt AND A.CreateDateTime <= @ChangeTime
																--AND A.CreateDateTime BETWEEN '2019-09-01 08:30:00'and '2019-09-01 20:30:00'			            -- TEST용 : FromDt는 오전8시반, ChangTime는 당일 오후20시반
																AND A.InputShiftCode = '2'
														GROUP BY A.InputLineCode 
																	, SP.사이즈			

												   --- 야간실적 END
                              ) AA
							  GROUP BY 라인명, 규격

             ) SS	ON  SS.라인명 = GG.라인명 
			       --AND SS.규격 = GG.사이즈
ORDER BY GG.라인명 


--- 주요 INSERT문 ------------------------------------------------------
---- INSERT INTO CURLING_PROD 
 --SELECT  기준일자, 라인코드, 정렬라인명, 일일총수량  
  --FROM #TEMP_TABLE100
  
 -- 전일실적 UPDATE부분 --

   DECLARE @sqlStr VARCHAR(1000)
--DECLARE @ToDay VARCHAR(10) = '08'

   SET @sqlStr = 'UPDATE CURLING_PROD   SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)    FROM CURLING_PROD A     INNER JOIN #TEMP_TABLE100 B  ON A.[라인코드] = B.[라인코드] AND 기준년월 = ''201909'' '
  
  --UPDATE CURLING_PROD
  --SET DAY02 = ''
  -- FROM CURLING_PROD A     INNER JOIN #TEMP_TABLE100 B  ON A.[라인코드] = B.[라인코드] AND 기준년월 = '201909'


     --SET @sqlStr = 'UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)    FROM MEDIUM_PROD A     INNER JOIN #TEMP_TABLE51 B  ON A.[사이즈] = B.[사이즈] AND 기준년월 = ''201908'' AND CompanyCode = ''VNT''    '
  



   EXECUTE  (@sqlStr)



-- TEMP TABLE삭제
    DELETE FROM  #TEMP_TABLE100  
    DROP TABLE    #TEMP_TABLE101                                       --> 베트남관련 TEMP_TABLE

 END


 -- SELECT * FROM CURLING_PROD WHERE 기준년월 = '201909'
 -- SELECT * FROM CURLING_PLAN WHERE 기준년월 = '201909'

 --UPDATE CURLING_PROD   
 --SET DAY31 = ISNULL(B.[일일총수량], 0)    
 --FROM CURLING_PROD A     
 --INNER JOIN #TEMP_TABLE100 B  ON A.ASSYLINE-05 = B.ASSYLINE-05
  

