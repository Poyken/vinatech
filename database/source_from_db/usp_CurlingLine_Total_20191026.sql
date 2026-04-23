-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-11
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
-- ==================================================================

--   EXEC [usp_CurlingLine_Total] '','', '2019-10-08 08:30:00'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

Create PROC [dbo].[usp_CurlingLine_Total_20191026] 
				@pProcessUserID     VARCHAR(20),
				@pProcessLanguage VARCHAR(20),	
				@pToDt                 Datetime
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 08:30:00'                                                                   
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDt)), 121) + ' 08:30:00'                  --  SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime,  '2019-05-01 08:00:00')), 121) + ' 08:30:00'
	--DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'    
	DECLARE @ToDay               VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @pToDt, 121), 9, 2)                                                                  --  1일부터 금일까지 일수  (5월 8일이면.. 08일)            --> SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-05-08 08:00:00', 121), 9, 2)    
    
	DECLARE @DayCnt               VARCHAR(02) = datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, @pToDt)+1, @pToDt))))                    -- 2019.05.08 추가변수 : 해당월의 일수 (31일 or 30일)  -->  SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-05-08')+1,'2019-05-08'))))


 ----  [합계부분]

SELECT  SUM(월간계획) / @DayCnt                                                        AS 일일목표               -- 전체목표에서 / 일수(31일이나 30일)  -> @DayCnt
         , SUM(전체수량)                                                                      AS 일일실적               -- 전체수량 (주간+야간)
		 --, SUM(전체수량)   /  (SUM(월간계획)  / @DayCnt) *  100                      AS 일일달성율            -- (일일실적/일일목표) * 100	         		 
		 , CASE WHEN  SUM(월간계획) = 0 THEN 0 ELSE  SUM(전체수량)   /  (SUM(월간계획)  / @DayCnt) *  100  END              AS 일일달성율            -- (일일실적/일일목표) * 100	         		 
		 , SUM(누계목표)                                                                      AS 누계목표
		 , SUM(누계생산)                                                                      AS 누계실적
		 --, SUM(누계생산) /   SUM(누계목표)  * 100                                       AS 누계달성율            -- (%)		 		 		
		 , CASE WHEN   SUM(누계목표)  * 100  = 0 THEN 0 ELSE  SUM(누계생산) /   SUM(누계목표)  * 100    END                    AS 누계달성율            -- (%)		 		 		
FROM  (

				SELECT 						
					  ISNULL(GG.월간계획, 0)                                                        AS 월간계획
					, (ISNULL(GG.월간계획, 0) / @DayCnt)  * @ToDay                            AS 누계목표 		-- 월간계획 / 일수 X 금일일수  ex)  
					, ISNULL(SS.전체수량, 0) + ISNULL(GG.월누적수량, 0)                       AS 누계생산         -- 1일부터 현재일까지의 생산량도 추가
					, CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.전체수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * @ToDay)  * 100        END  AS 누계달성율		-- 누계생산 / 누계목표										 										
	                , CASE WHEN ISNULL(GG.월간계획, 0)                * 100 = 0 THEN 0 ELSE  (ISNULL(SS.전체수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                                   END  AS 누계진도율
					, ISNULL(SS.전체수량, 0)                     AS 전체수량					
				FROM 
						(  
							-- GG START  (현재 19라인)
										SELECT  BB.*
												, AA.월누적수량      AS 월누적수량													
										FROM 
										(
												SELECT -- 라인명																 
														 라인코드
														, 월누적수량  AS 월누적수량																  																 
												FROM CURLING_PROD        -- [커링_일별실적]
												WHERE 1=1																	
													AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 		   -- TEST용 주석처리부분																												
													--AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 																							
										) AA
										LEFT OUTER JOIN (
																	SELECT 라인코드
																			--, 라인명
																			, 사이즈
																			, 규격
																			, 월간계획
																			, 라인별칭
																			, 특이사항
																		FROM CURLING_PLAN
																		WHERE 1=1
																		   AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '')
 															--) BB		    ON AA.라인명 = BB.라인명  
															) BB		    ON AA.라인코드 = BB.라인코드
															              --AND AA.라인코드 = BB.라인코드
							    -- GG END
						)   GG


			LEFT JOIN 	(	
								   SELECT --라인명             AS 라인명
											 규격
											, SUM(전체수량)   AS 전체수량											
									FROM (
													-- 주간+야간 START
																SELECT  --라인명           AS 라인명	
																		  사이즈            AS 규격					  		
																		 , SUM(양품수량) AS 전체수량																				
																FROM
																      (			  
																		 SELECT  --CASE WHEN ISNULL(A.조립라인명, '')  = '셀1' THEN '01호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀2' THEN '02호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀3' THEN '03호기' 
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀4' THEN '04호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀5' THEN '05호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀6' THEN '06호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀7' THEN '07호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀8' THEN '08호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀9' THEN '09호기'
																			--				WHEN ISNULL(A.조립라인명, '')  = '셀10'   OR ISNULL(A.조립라인명, '')  = '셀99'     THEN '10호기' 
																			--				WHEN ISNULL(A.조립라인명, '')  = '베트남' OR ISNULL(A.조립라인명, '')  = '베트남'  THEN '베트남'   ELSE '드라이룸' END      AS 라인명
																					 지시번호                                                                                      AS 지시번호 																					
																					, A.사이즈                                                                                       AS 사이즈								
																					, SUM(투입수량)                                                                               AS 투입수량
																					, SUM(양품수량)                                                                               AS 양품수량																																		
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
																						, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 										
																						, CASE WHEN (TM.라인명) LIKE '셀10%'  THEN '셀10' ELSE  ISNULL(TM.라인명, '')                   END                               AS 조립라인명
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                      ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D                ON B.지시번호 = D.지시번호            AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                      ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                            ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                        ON A.품목코드 = P.PRODCD																						
																						LEFT JOIN CURLING_LINE                  TM                            ON A.지시번호 = TM.지시번호 	          AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE											
								  
																			WHERE 1=1																		
																				--AND D.작업일자 BETWEEN '2019-09-01 08:30:00' AND '2019-09-03 08:30:00'
																				AND D.작업일자 BETWEEN @FromDt AND @ToDt
																				AND B.공정코드 = 'E-24'
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드																					
																						, TM.라인명		
																						, P.사이즈	
																						---- A		  							  
																					) A								
																			WHERE 1=1							  
																			GROUP BY  지시번호	, 설비명, 조립라인명, 사이즈										
																			) ZZ		
																GROUP BY 사이즈
																			--, 라인명
                                                                 
																 UNION ALL
																
																	-- NAIS 추가부분 (주간+야간)
																		SELECT -- (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = A.InputLineCode ) AS 라인명																				
																				 SP.사이즈                                                                                           AS 규격
																				, (SUM(A.ProdQty) - SUM(A.DefectQty))                                                         AS 전체수량																				
																			FROM STB_SetInfo A     
																					LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
																			WHERE 1=1
																				AND A.CreateDateTime BETWEEN @FromDt AND @ToDt
																				--AND A.CreateDateTime BETWEEN '2019-09-01 08:30:00' AND '2019-09-03 20:30:00'																								 																								 
																				--AND A.InputShiftCode = '1'   -- 주야간구분이므로 주석처리
																		GROUP BY A.InputLineCode 
																					, SP.사이즈																			

											--  주간+야간 END
											) AA
											GROUP BY 규격
                             
								 ) SS	ON  SS.규격 = GG.사이즈
											
)   PP								

 END
