-- ==================================================================
-- Author      : kilee
-- Create date : 2019-05-09
-- Browsable   : true
-- Group       : 2019-05-10 오전 08:31 자동실행  (매일 1번 자동실행)
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 매일 아침 8시30분기준으로 전일자 일일실적현황을 자동으로 계산해서 넣어준다.  (오늘이 10일이면 9일 실적을 9일에 자동입력)
--                   2019-04-09 정상실행     
--                   2019-09-04 ERP + NAIS 실적 추가
-- ==================================================================
-- 
---[실행문]    EXEC usp_Medium_Daily_Input_SUDONG 'E-22'

CREATE PROC [dbo].[usp_Medium_Daily_Input_SUDONG] 				
				@pRouteCode VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;


  Declare @RouteCode VARCHAR(20) = @pRouteCode
		

 --[기존형식]
  
	
-- [수동으로 실행시 -> 지우지말것]
	DECLARE @FromDt             VARCHAR(19) =  '2019-10-16 08:30:00'            -- 전일                    
	DECLARE @ToDt                VARCHAR(19) =  '2019-10-17 08:30:00'            -- 금일
	DECLARE @ToDay              VARCHAR(02) =   '16'                                -- 전일자로 넣음

	DECLARE @ToDay2     VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), @ToDt, 121), 9, 2)                                                                  --  1일부터 금일까지 일수  (5월 8일이면.. 08일)            --> SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-05-08 08:00:00', 121), 9, 2)    
	DECLARE @DayCnt     VARCHAR(02) = datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, @ToDt)+1, @ToDt))))                      -- 2019.05.08 추가변수 : 해당월의 일수 (31일 or 30일)  -->  SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-05-08')+1,'2019-05-08'))))
	--DECLARE @BaseYm    VARCHAR(6) = LEFT(@FromDt, 4) + SUBSTRING(@FromDt, 6, 2)

																																														 --  SELECT * FROM MEDIUM_PROD               --> 일자별
																																														 --  SELECT * FROM MEDIUM_PLAN               --> 월별계획
																																														 --  SELECT * FROM MEDIUM_LINE WHERE 라인명 = '베트남'

																																														 -- 데이터 업데이트를 위한 빈행이 존재하는지 확인 후 생성
	--SELECT @ExistRow = COUNT(*) 
	--FROM MEDIUM_PROD 
	--WHERE 기준년월 = @BaseYm 
	--   AND RouteCode = @RouteCode

	---- 계획테이블에 RouteCode 추가 후 활성화 할 것.
	
	--IF @ExistRow = 0 
	
	--BEGIN
	--	INSERT INTO MEDIUM_PROD (기준년월, LineCode,  RouteCode) 
	--		SELECT 기준년월, 라인코드,  RouteCode
	--		  FROM CURLING_PLAN
	--		 WHERE 기준년월 = @BaseYm 
	--		   AND RouteCode = @RouteCode
	--END

	
 --  [조회 QUERY]  *****************************************************************************************************************************************
 SELECT
           GG.사이즈                                                                       AS 사이즈
	     , GG.월간계획                                                                     AS 월간계획
		 , (GG.월간계획/@DayCnt)                                                       AS 누계목표 		 -- 월간계획 / 일수(30일 or 31일)
		 , (SS.일일총수량 + GG.월누적수량 )                                           AS 누계생산          -- 1일부터 현재일까지의 생산량도 추가
  	  -- , (( SS.일일총수량 + GG.월누적수량) /   (GG.월간계획/@DayCnt) * 100) AS 누계달성율		  -- 누계생산 / 누계목표
      -- , ((( SS.일일총수량 + GG.월누적수량) /   GG.월간계획) * 100)             AS 누계진도율       -- 누계생산 / 월간계획 		
		, CASE WHEN SS.주간수량 IS NULL THEN 0 ELSE SS.주간수량 END       AS 주간수량
		, CASE WHEN SS.야간수량 IS NULL THEN 0 ELSE SS.야간수량 END       AS 야간수량		
		, GG.특이사항                                                                      AS 특이사항
		, SS.일일총수량                                                                    AS 일일총수량	 
		, CONVERT(VARCHAR(10),  GetDate(), 121)                                    AS 기준일자         -- 금일날짜
		, GG.공정코드                                                                      AS 공정코드  
		, GG.LineCode                                                                     AS 라인코드          --추가
  INTO #TEMP_TABLE51     -- 주석아님!!!
  FROM 
				(  
				 -- GG START
								SELECT  BB.*
										, AA.월누적수량 AS 월누적수량
									  --, AA.공정코드
								FROM 
										(
											SELECT  PL.사이즈
													, SUM(PO.월누적수량)  AS 월누적수량
													, PL.공정코드
													, PL.LineCode             AS 라인코드    --추가
											FROM MEDIUM_PLAN PL                                                                                                                        -- 월별계획 Table
													LEFT OUTER JOIN MEDIUM_PROD PO ON   PO.사이즈 = PL.사이즈  AND PO.RouteCode = PL.공정코드                   -- 일별실적 Table (사이즈, 공정코드 Join)
											WHERE 1=1											
												AND PL.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 														
												AND PO.CompanyCode = 'VNT'
											GROUP BY  PL.사이즈 , PL.공정코드	
											            , PL.LineCode								  --추가
										) AA
									,	(
												SELECT  사이즈												
														, 월간계획												
														, 특이사항
														, 공정코드
														, LineCode
													FROM MEDIUM_PLAN                                          -- SELECT * FROM MEDIUM_PLAN
													WHERE 1=1 AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 
										) BB
							WHERE 1=1
							   AND AA.사이즈   = BB.사이즈
							   AND AA.공정코드 = BB.공정코드
							   AND AA.라인코드 = BB.LineCode     --추가
				-- GG END
			   ) GG

LEFT JOIN (	--> GG 테이블 기준으로 

					 SELECT  CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  ELSE 규격 END AS 규격    
							 , SUM(주간수량)                       AS 주간수량
							 , SUM(야간수량)                       AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량)  AS 일일총수량
							 , 공정코드                               AS 공정코드
							 , 라인코드                               AS 라인코드
						FROM (

								--  실적수량파악 START (ERP + NAIS)
												  SELECT   CASE WHEN 라인코드 = 'ASSYLINE-05' THEN 사이즈 + 'L'  ELSE 사이즈 END    AS 규격    	  		
												            , 공정코드          AS 공정코드	
															, 라인코드         AS 라인코드
															, SUM(주간수량)   AS 주간수량		
															, SUM(야간수량)   AS 야간수량																													
													FROM
													(		
													--- ERP기준	  
																SELECT  
																		  지시번호                                                                     AS 지시번호 
																		, A.품목코드                                                                   AS 품목코드
																		, A.사이즈                                                                      AS 사이즈																																																		
																	    , CASE WHEN A.작업구분 = '1' THEN SUM(양품수량) ELSE 0 END    AS 주간수량
                                                                        , CASE WHEN A.작업구분 = '2' THEN SUM(양품수량) ELSE 0 END    AS 야간수량			
																		, A.공정코드                                                                   AS 공정코드
																		, CASE WHEN A.사이즈 = '1840' THEN 'ASSSYLINE-11'
																				 WHEN A.사이즈 = '1030' AND A.품목코드  = 'ECVT27-370' THEN 'ASSSYLINE-05'
																				 WHEN A.사이즈 = '1030' AND A.품목코드  = 'ECVT27-343' THEN 'ASSSYLINE-09'
																				 WHEN A.사이즈 = '1325' THEN 'ASSSYLINE-07'
																				 WHEN A.사이즈 = '2245' THEN 'ASSSYLINE-12' ELSE ''   END       AS 라인코드
																    --	, ISNULL(SUM(금액), 0)                                                       AS 총합  
																FROM (
																			---- 
																				SELECT A.지시일자
																						, A.지시번호
																						, 투입일자 = B.작업시작시간
																						, 종료일자 = B.작업종료시간
																						, A.품목코드
																						, 품명 = P.PRODNM
																						, 규격 = P.PRODSP
																						, B.공정코드
																						, 공정명 = C.공정명
																						, D.작업자, 작업자명 = (SELECT NAME FROM ERPSVR.ERPDB.DBO.EMPREF WHERE SABUN = D.작업자)
																						, B.순번
																						, B.작업구분                                                     AS 작업구분
																						, ISNULL(D.실적,0) + SUM(ISNULL(F.수량,0))                AS 투입수량
																						, ISNULL(D.실적,0)                                              AS 양품수량
																						, SUM(ISNULL(F.수량,0))                                       AS 불량수량
																						, D.작업일자
																						, D.비고
																						, B.설비코드
																						, (SELECT X.설비명 FROM ERPSVR.ERPDB.DBO.설비자료 X WHERE X.설비코드 = B.설비코드)                                           AS 설비명  																						
																						, CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':',''))                                               AS 작업시간										 																																
																						, P.사이즈 													
																			FROM ERPSVR.ERPDB.DBO.조립작업지시 A
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적 B                       ON A.지시번호 = B.지시번호
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립생산실적현황 D                 ON B.지시번호 = D.지시번호             AND B.공정코드 = D.공정코드
																						LEFT JOIN ERPSVR.ERPDB.DBO.조립불량실적 F                       ON D.실적현황순번 = F.실적현황순번
																						LEFT JOIN ERPSVR.ERPDB.DBO.공정코드 C                            ON C.공정코드 = B.공정코드
																						INNER JOIN ERPSVR.ERPDB.DBO.PRODUCT P                        ON A.품목코드 = P.PRODCD																							
																						--LEFT JOIN CURLING_LINE               TM                               ON A.지시번호 = TM.지시번호 	          AND D.지시번호 = TM.지시번호	                              -- 앞에서 설정한 커링기준 라인설정 TABLE																			  
																			WHERE 1=1														
																			    AND NOT A.비고 LIKE 'NAIS%'
																				AND       D.작업일자 BETWEEN @FromDt AND  @ToDt 																				
																				AND NOT B.설비코드 = 'VNEP03010'
																				--AND        P.사이즈 = '1840'

																				
																				--AND D.작업일자 BETWEEN '2019-08-26 08:30:00' and '2019-08-27 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
																				--AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),D.작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '주간' = '전체' THEN '%' ELSE '주간' END																																		
																			GROUP BY A.지시일자, A.지시번호, B.작업시작시간, B.작업종료시간, A.품목코드,P.PRODNM, P.PRODSP, B.공정코드, C.공정명, D.작업자 , B.순번, B.작업구분 , D.실적 , D.작업일자 , D.비고 , B.설비코드																						
																						--, TM.라인명		
																						, P.사이즈	
																			---- A		  							  
																		) A								
																WHERE 1=1							  
																GROUP BY 품목코드
																			 , 품명
																			 , 지시번호	 							
																			 , 설비명																				 
																			 , 사이즈		
																			 , 작업구분
																			 , A.공정코드
																) ZZ		
													GROUP BY 사이즈				
																, 공정코드
																, 라인코드
																									                                                  												      
													UNION 
																
													-- NAIS 추가부분 (주간+야간)
														--SELECT  SP.사이즈                                                                                                      AS 규격
														--		, CASE WHEN A.InputShiftCode = '1'  THEN  (SUM(A.ProdQty) - SUM(A.DefectQty)) ELSE 0 END AS 주간수량
														--		, CASE WHEN A.InputShiftCode = '2'  THEN  (SUM(A.ProdQty) - SUM(A.DefectQty)) ELSE 0 END AS 야간수량
														--	 -- , (SUM(A.ProdQty) - SUM(A.DefectQty))                                                                     AS 전체수량	
														--		, A.InputLineCode																			                   AS 공정코드
														--FROM STB_SetInfo A     
														--		LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
														--	WHERE 1=1
														--		AND A.CreateDateTime BETWEEN @FromDt AND @ToDt
														--		--AND A.CreateDateTime BETWEEN '2019-08-26 08:30:00' AND '2019-08-27 20:30:00'																								 																								 
														--		--AND A.InputShiftCode = '1'   -- 주야간구분이므로 주석처리
														--GROUP BY A.InputLineCode 
														--			, SP.사이즈		
														--			, A.InputShiftCode	
														--			, A.InputLineCode		
																	
														SELECT ZZ.규격
															   , ZZ.공정코드
															   , ZZ.라인코드  AS 라인코드
															   , SUM(ZZ.주간수량) AS 주간수량
															   , SUM(ZZ.야간수량) AS 야간수량
														FROM (								
																	SELECT  --SP.사이즈                                                                                                    AS 규격
																	           CASE WHEN A.LineCode	 = 'ASSYLINE-05' THEN SP.사이즈 + 'L'  ELSE SP.사이즈 END      AS 규격
																			,  A.RouteCode                                                                                                AS 공정코드
																			, A.LineCode																									  AS 라인코드
																			, CASE WHEN A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
																			, CASE WHEN A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량																			
																	FROM STB_ProdRouteSummary A                                                                                                -- SELECT JOBDATE, * FROM STB_ProdRouteSummary
																			LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
																		WHERE 1=1							
																		   AND A.TIMECODE <> 'E'																																																			   
																			AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), @FromDt, 121), 0, 11)    --           SELECT SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 0, 11)    
																			--AND A.JobDate = '2019-09-08'					
																			--AND 		SP.사이즈 = '1840'																															                                        -->   꼭 지울것!!
																	GROUP BY A.RouteCode 
																				, SP.사이즈		
																				, A.ShiftCode	
																				, A.LineCode																				
															    )  ZZ
														GROUP BY  ZZ.규격
																	,  ZZ.공정코드	
																	, ZZ.라인코드	

																	
														--	SELECT ZZ.규격
														--	   , ZZ.공정코드
														--	   , SUM(ZZ.주간수량) AS 주간수량
														--	   , SUM(ZZ.야간수량) AS 야간수량
														--FROM (								
														--			SELECT  SP.사이즈                                                                                                        AS 규격
														--					,  PRH.RouteCode                                                                                                AS 공정코드
														--					, CASE WHEN SI.InputShiftCode = '1'  THEN  (SUM(SI.ProdQty) - SUM(SI.DefectQty)) ELSE 0 END  AS 주간수량
														--					, CASE WHEN SI.InputShiftCode = '2'  THEN  (SUM(SI.ProdQty) - SUM(SI.DefectQty)) ELSE 0 END  AS 야간수량																			
														--			FROM STB_SetInfo SI     
														--					LEFT OUTER JOIN STB_ProdRouteHist           PRH	 ON SI.ControlNo = PRH.ControlNo
														--					LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON SI.MaterialCode = SP.PRODCD																							
														--				WHERE 1=1							
														--				 --  AND SI.TIMECODE <> 'E'																																																			   
														--				    AND SI.CreateDateTime BETWEEN  @FromDt AND  @ToDt 
														--					--AND SI.CreateDateTime BETWEEN '2019-09-18 08:30:00'and '2019-09-19 08:30:00'
														--			GROUP BY PRH.RouteCode 
														--						, SP.사이즈		
														--						, SI.InputShiftCode	
														--						, PRH.LineCode																				
														--	    )  ZZ
														--GROUP BY  ZZ.규격
														--			,  ZZ.공정코드										
																	
																	
																	
																	
																	
																																																																					
												   --  실적수량파악 END   														  							
                              ) AA
							  WHERE 1=1                                             
							     -- AND 규격 = '1840'                                  --추가부분 (나중에 꼭 지울것!!!)
							  GROUP BY  규격
							             ,  공정코드
                                         , 라인코드
							   
             ) SS	ON   SS.규격 = GG.사이즈
			       AND SS.공정코드 = GG.공정코드
				   AND SS.라인코드 = GG.LineCode              --추가

ORDER BY GG.사이즈 


--- 주요 INSERT문 ------------------------------------------------------
---- INSERT INTO MEDIUM_PROD 
 --SELECT  기준일자, 라인코드, 정렬라인명, 일일총수량  
  --FROM #TEMP_TABLE100
  
 -- 전일실적 UPDATE부분 --

   DECLARE @sqlStr VARCHAR(1000)
--DECLARE @ToDay VARCHAR(10) = '08'

   --SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈]                                            AND 기준년월 = ''201909''   AND CompanyCode = ''VNT''    '
    -- SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''201909''   AND CompanyCode = ''VNT''    '
	-- SET @sqlStr = '   UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''201910'' AND RouteCode = ''' + @RouteCode + '''  AND CompanyCode = ''VNT''    '
	 SET @sqlStr = '   UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''201910'' AND RouteCode = ''' + @RouteCode + '''  AND CompanyCode = ''VNT''  AND A.LineCode = B.라인코드  '
   EXECUTE  (@sqlStr)



-- TEMP TABLE삭제
    DELETE FROM  #TEMP_TABLE51 
    --DROP TABLE    #TEMP_TABLE52                                       --> 베트남관련 TEMP_TABLE

 END


 --  SELECT * FROM MEDIUM_PROD WHERE 기준년월 = '201909'
 


  --BEGIN TRAN
 ---- COMMIT
 -- UPDATE MEDIUM_PROD   
 --SET DAY31 = ISNULL(B.[일일총수량], 0)    
 -- FROM MEDIUM_PROD A     
 --INNER JOIN #TEMP_TABLE100 B  ON A.ASSYLINE-05 = B.ASSYLINE-05 
 --                                        AND A.기준년월 = B.기준년월
	--									 AND  CompanyCode = 'VNT'
	--									 AND RouteCode = B.RouteCode