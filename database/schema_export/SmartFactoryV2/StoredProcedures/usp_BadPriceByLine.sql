-- Procedure: usp_BadPriceByLine

---- ===========================================================================
---- Author      :	kilee
---- Create date : 2019-03-20
---- Browsable   : true
---- Group       : 정보분석팀 엑셀요청자료
---- Description :	[2번 Sheet 공정이상금액]
---- Modified    : 2019.02.02  지시번호별로 라인 다시 간추림 (TEMP_TABLE생성하여)
---- ===========================================================================

/*
작업불량내역 조립
20130813 최진용
select * from 조립불량실적     where 지시번호 = 'vjdn023r050705'
select * from 조립생산실적     where 지시번호 = 'VJDQ022R710601'
select * from 조립생산실적현황 where 작업일자 BETWEEN '2015-12-14 8:30' AND '2015-12-15 8:30' AND 품목코드 = 'ECVT27-163'





 EXEC [usp_BadPriceByLine] '2019-02-01 08:30:00',   '2019-02-20 23:59:59',         '2019-02-01 08:30:00',        '2019-02-20 23:59:59',    '전체'   
 
 EXEC [usp_BadPriceByLine] 'kilee', 'Korean', '',  '2019-03-20 08:30:00',   '2019-03-25 23:59:59',         '2019-03-20 08:30:00',        '2019-03-25 23:59:59',    '전체'                    -- 프로파일러 확인

 EXEC [usp_BadPriceByLine] 'kilee', 'Korean', '',  '2019-03-01 08:30:00',   '2019-04-01 23:59:59',         '2019-03-27 08:30:00',        '2019-04-01 23:59:59',    '전체'                    -- 프로파일러 확인
*/


CREATE PROC [dbo].[usp_BadPriceByLine] 

				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pCalendarCode VARCHAR(10) = NULL,
				@pOrderfromDt DATETIME, 
				@pOrdertoDt DATETIME, 
				@pWorkfromDt DATETIME, 
				@pWorktoDt DATETIME, 
				@pShift VARCHAR(10)  = '전체'
AS
	BEGIN
	   -- Declare @fromDt VARCHAR(20), @toDt VARCHAR(20), @dn VARCHAR(10)
		--Declare @OrderfromDt VARCHAR(19)
		--         , @OrdertoDt VARCHAR(19)				 
		--		 , @WorkfromDt VARCHAR(19)				 
		--		 , @WorktoDt VARCHAR(19) 				 
		--		 , @Shift VARCHAR(19)
				

		SET @pOrderfromDt = @pOrderfromDt                                                                   + ' 08:30:00'
		SET @pOrdertoDt = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pOrdertoDt)), 121) + ' 08:30:00'
		SET @pWorkfromDt = @pWorkfromDt                                                                   + ' 08:30:00'
		SET @pWorktoDt = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pWorktoDt)), 121) + ' 08:30:00'


	
					
--- [이후 SELECT문]
	SELECT ISNULL(지시번호, '') AS 지시번호							 
						     , CASE WHEN MAX(라인명) LIKE '%셀99%' THEN '셀10' 
	                                WHEN MAX(라인명) LIKE '%셀%'   THEN MAX(라인명) ELSE '드라이룸'  END    AS 라인명

					   INTO #TEMP_TABLE22                      -- TENP_TABLE부분 (테스트시 주석처리부분)

					    FROM (
								SELECT Z.지시번호				        AS  지시번호
								--	, CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀%'  THEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 =  Z.설비코드), 3), '')  ELSE '드라이룸' END    AS 라인명
								     , CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀10%'  THEN '셀99'
			                                WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = Z.설비코드), 3), '') LIKE '%셀%'    THEN  ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 =  Z.설비코드), 3), '')  
					                             ELSE '드라이룸'                                                                                              END    AS 라인명

								FROM 
									(
												SELECT 지시번호
														, 설비코드														
														--, CASE WHEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = A.설비코드), 2), '') LIKE '%셀%'  THEN ISNULL(LEFT((SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 =  A.설비코드), 2), '')  ELSE '드라이룸' END AS 라인명
														, (SELECT X.설비명 FROM  ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = A.설비코드) AS 설비명
													                                     
													FROM ERPSVR.erpdb.DBO.조립생산실적 A
													WHERE 1=1	
													 AND 작업일자 BETWEEN @pWorkfromDt AND @pWorktoDt
                    						         AND CASE WHEN (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND (CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN @pShift = '전체' THEN '%' ELSE @pShift END  
					  
													--AND 작업일자 BETWEEN '2018-01-01 08:30:00' and '2019-02-15 08:30:00'                                  -- @dt1 (엑셀의 FROMDATE) and @dt2 (엑셀의 TODATE+1)
													--AND CASE WHEN ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) > 830) AND ( CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20),작업일자,121),12,5),':','')) <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN '전체' = '전체' THEN '%' ELSE '전체' END 

													AND 공정코드 IN ('E-22', 'E-24')						
												--  AND A.지시번호 = 'VJJK063R010516'						
										) Z
								) Q
					GROUP BY  지시번호 			




--- [이후 SELECT문]

			SELECT 불량순번,
				   실적현황순번,
				   품목코드,
				   품명 = p.prodnm, 
				   규격 = p.prodsp, 
				   사이즈 = p.사이즈,
				   LotNo = 지시번호,
				   수량,
				   공정 = k.공정명,
				   aa.공정코드,
				   aa.불량코드,
				   작업수량, 
				   실적,
				   불량명,
				   불량수량,
				   e.name   AS 작업자
				 , ISNULL(s.설비명, 'A')  AS 설비명
				 , 작업일자
				 , 지시일자
				 , CASE WHEN ISNULL(라인명, '')  = '셀1' THEN '셀01라인'
				        WHEN ISNULL(라인명, '')  = '셀2' THEN '셀02라인'
						WHEN ISNULL(라인명, '')  = '셀3' THEN '셀03라인'
						WHEN ISNULL(라인명, '')  = '셀4' THEN '셀04라인'
						WHEN ISNULL(라인명, '')  = '셀5' THEN '셀05라인'
						WHEN ISNULL(라인명, '')  = '셀6' THEN '셀06라인'
						WHEN ISNULL(라인명, '')  = '셀7' THEN '셀07라인'
						WHEN ISNULL(라인명, '')  = '셀8' THEN '셀08라인'
						WHEN ISNULL(라인명, '')  = '셀9' THEN '셀09라인'
						ELSE ISNULL(라인명, '')                     END AS 라인명
				 
				 --, ISNULL(라인명, '') 	AS 라인명	       -- 추가


				 , 금액				 
			  INTO #임시저장
			  FROM (
						SELECT 품목코드 = (SELECT 품목코드 
											FROM ERPSVR.erpdb.DBO.조립작업지시
										    WHERE 지시번호 = a.지시번호)
							 , 불량순번,a.실적현황순번,a.지시번호,a.공정코드,불량코드
							 , 불량수량 = ISNULL(a.수량, 0)
							 , 불량명 = (select name from ERPSVR.erpdb.DBO.nameref where nmgbn = '불량/E' and nmcd = a.불량코드)
							 , 작업일자 = js.작업일자						  
			    
							 , jj.수량
							 , 실적 = js.실적
							 , 작업수량 = ISNULL((select ISNULL(sum(x.수량),0) from ERPSVR.erpdb.DBO.조립불량실적 x where x.실적현황순번 = js.실적현황순번) + isnull(js.실적,0),0)
							 , 설비코드 = js.설비코드
							 , 작업자 = js.작업자
							 , 지시일자 
							 
							 --, ISNULL(TM.라인명, '')                                                                                      AS 라인명  --추가 -> 원본백업
							, CASE WHEN (FM.라인명) LIKE '셀10%'                             THEN '셀10' 
							      -- WHEN (FM.라인명) <> '셀10' AND (FM.라인명) LIKE '%셀%' THEN ISNULL(TM.라인명, '') 
								  ELSE  ISNULL(TM.라인명, '')  END    AS 라인명  --수정본
							 , (gd.PROD_UNIT_PRICE + gd.CASE_PRICE) * a.수량                                                    AS 금액   
							 , (SELECT ISNULL(X.설비명, 'A') FROM ERPSVR.erpdb.DBO.설비자료 X WHERE X.설비코드 = js.설비코드)            AS 설비명                                                                                              
							 , CONVERT(INT,REPLACE(SUBSTRING(CONVERT(VARCHAR(20), js.작업일자,121),12,5),':',''))               AS 작업시간

						  from ERPSVR.erpdb.DBO.조립불량실적 a
						  left join ERPSVR.erpdb.DBO.조립작업지시 jj    on a.지시번호 = jj.지시번호
						  left join ERPSVR.erpdb.DBO.조립생산실적 jx    on a.지시번호 = jx.지시번호 and a.공정코드 = jx.공정코드
						  left join ERPSVR.erpdb.DBO.조립생산실적현황 js on a.실적현황순번 = js.실적현황순번  


						  LEFT join ERPSVR.erpdb.DBO.product pd                  on jx.품목코드 = pd.PRODCD
						  left join ERPSVR.erpdb.DBO.VECS_UNITCONVERT_MAPPING gd on a.공정코드     = gd.PROCESS_CODE  AND gd.prod_size = pd.사이즈       -- 금액TABLE

						  and exists (
									   SELECT * 
										from ERPSVR.erpdb.DBO.조립작업지시               A11 
											 LEFT JOIN ERPSVR.erpdb.DBO.조립생산실적     B11 ON A11.지시번호 = B11.지시번호 
											 LEFT JOIN ERPSVR.erpdb.DBO.조립생산실적현황 D11 ON B11.지시번호 = D11.지시번호 AND B11.공정코드 = D11.공정코드 
									   where D11.실적현황순번 = a.실적현황순번
									  )

                        --  LEFT JOIN ERPSVR.erpdb.DBO.TEST_LINE                 TM ON A.지시번호 = TM.지시번호 	        --AND js.지시번호 = TM.지시번호
						 LEFT JOIN #TEMP_TABLE22                           TM ON A.지시번호 = TM.지시번호 	        AND js.지시번호 = TM.지시번호
						 LEFT JOIN ERPSVR.erpdb.DBO.LINE_FIX            FM ON A.지시번호 = FM.지시번호 	        --AND js.지시번호 = FM.지시번호    --AND TM.지시번호 = FM.지시번호

						 where 1=1
						   --AND a.지시번호 like isnull(@지시번호,'') + '%' 
						   --AND TM.라인명 LIKE '셀%'

					) AA
							left join ERPSVR.erpdb.DBO.product p  on aa.품목코드 = p.prodcd
							left join ERPSVR.erpdb.DBO.공정코드 k on aa.공정코드 = k.공정코드
							left join ERPSVR.erpdb.DBO.empref  e  on aa.작업자    = e.sabun
							left join ERPSVR.erpdb.DBO.설비자료 s on aa.설비코드 = s.설비코드
					 WHERE 1=1
					   AND 지시일자 BETWEEN @pOrderfromDt AND @pOrdertoDt
					   AND 작업일자 BETWEEN @pWorkfromDt AND @pWorktoDt
                       AND CASE WHEN (AA.작업시간 > 830) AND (AA.작업시간 <= 2030) THEN '주간' ELSE '야간' END LIKE CASE WHEN @pShift = '전체' THEN '%' ELSE @pShift END					    
   			--	     AND 지시일자 between '2019-02-01 08:30:00' and '2019-02-03 08:30:00'
					 --AND 작업일자 between '2019-02-01 08:30:00' and '2019-02-03 08:30:00'

					   AND 품목코드    like ISNULL('','') + '%'
					   AND aa.공정코드 like ISNULL('','') + '%'
					ORDER BY 작업일자
					            , 지시번호
								, AA.공정코드
 


					SELECT *            
					 INTO  #최종                    
					 FROM  #임시저장 A
   



   --- [전체적인 SELECT문]

		  
		  
		  SELECT 
		          ISNULL(라인명, 'AAA')                              AS 라인명										
				, ISNULL(SUM(권취소자_불량수), 0)                  AS 권취소자_불량수
				, ISNULL(SUM(권취소자_불량금액), 0)                AS 권취소자_불량금액				
				, ISNULL(SUM(고무전삽입소자_불량수), 0)            AS 고무전삽입소자_불량수
				, ISNULL(SUM(고무전삽입소자_불량금액), 0)          AS 고무전삽입소자_불량금액
				, ISNULL(SUM(커링소자_불량수), 0)                  AS 커링소자_불량수
				, ISNULL(SUM(커링소자_불량금액), 0)                AS 커링소자_불량금액
				, ISNULL(SUM(에이징소자_불량수), 0)                AS 에이징소자_불량수
				, ISNULL(SUM(에이징소자_불량금액), 0)              AS 에이징소자_불량금액
				, ISNULL(SUM(외관소자_불량수), 0)                 AS 외관소자_불량수
				, ISNULL(SUM(외관소자_불량금액), 0)               AS 외관소자_불량금액				
				, ISNULL(SUM(총합), 0)                           AS 총합
		FROM (


			 SELECT ISNULL(A.공정, '')     AS 공정
				  , ISNULL(A.공정코드, '') AS 공정코드
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-22' THEN 불량수량 ELSE 0 END), 0)  AS 권취소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-22' THEN 금액     ELSE 0 END), 0)  AS 권취소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-23' THEN 불량수량 ELSE 0 END), 0)  AS 고무전삽입소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-23' THEN 금액     ELSE 0 END), 0)  AS 고무전삽입소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-24' THEN 불량수량 ELSE 0 END), 0)  AS 커링소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-24' THEN 금액     ELSE 0 END), 0)  AS 커링소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-26' THEN 불량수량 ELSE 0 END), 0)  AS 에이징소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-26' THEN 금액     ELSE 0 END), 0)  AS 에이징소자_불량금액		
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-27' THEN 불량수량 ELSE 0 END), 0)  AS 외관소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-27' THEN 금액     ELSE 0 END), 0)  AS 외관소자_불량금액		
				  , ISNULL(SUM(금액), 0)                                                    AS 총합   
				  --, SUM(a.불량수량)				                      AS  불량수량
				  --, ISNULL(A.설비명, 'A')                              AS 설비명				  
				  --, ISNULL(A.라인명, '')                              AS 라인명				   
				  ,  CASE WHEN A.라인명 = '' THEN '드라이룸' ELSE A.라인명    END        AS 라인명	
			   FROM #최종 A  
			   GROUP BY  A.공정
				       , A.공정코드
				       --, A.설비명
				       , A.라인명
			           , A.금액

		    ) A

			WHERE 1=1	 
		   GROUP BY A.라인명
		   --ORDER BY A.라인명

		   UNION ALL


		    SELECT 
		         ''                                                             AS 라인명										
				, ISNULL(SUM(권취소자_불량수), 0)                  AS 권취소자_불량수
				, ISNULL(SUM(권취소자_불량금액), 0)                AS 권취소자_불량금액				
				, ISNULL(SUM(고무전삽입소자_불량수), 0)            AS 고무전삽입소자_불량수
				, ISNULL(SUM(고무전삽입소자_불량금액), 0)          AS 고무전삽입소자_불량금액
				, ISNULL(SUM(커링소자_불량수), 0)                  AS 커링소자_불량수
				, ISNULL(SUM(커링소자_불량금액), 0)                AS 커링소자_불량금액
				, ISNULL(SUM(에이징소자_불량수), 0)                AS 에이징소자_불량수
				, ISNULL(SUM(에이징소자_불량금액), 0)              AS 에이징소자_불량금액
				, ISNULL(SUM(외관소자_불량수), 0)                 AS 외관소자_불량수
				, ISNULL(SUM(외관소자_불량금액), 0)               AS 외관소자_불량금액				
				, ISNULL(SUM(총합), 0)                           AS 총합
		FROM (


			 SELECT ISNULL(A.공정, '')     AS 공정
				  , ISNULL(A.공정코드, '') AS 공정코드
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-22' THEN 불량수량 ELSE 0 END), 0)  AS 권취소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-22' THEN 금액     ELSE 0 END), 0)  AS 권취소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-23' THEN 불량수량 ELSE 0 END), 0)  AS 고무전삽입소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-23' THEN 금액     ELSE 0 END), 0)  AS 고무전삽입소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-24' THEN 불량수량 ELSE 0 END), 0)  AS 커링소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-24' THEN 금액     ELSE 0 END), 0)  AS 커링소자_불량금액
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-26' THEN 불량수량 ELSE 0 END), 0)  AS 에이징소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-26' THEN 금액     ELSE 0 END), 0)  AS 에이징소자_불량금액		
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-27' THEN 불량수량 ELSE 0 END), 0)  AS 외관소자_불량수
				  , ISNULL(SUM(CASE WHEN A.공정코드 = 'E-27' THEN 금액     ELSE 0 END), 0)  AS 외관소자_불량금액		
				  , ISNULL(SUM(금액), 0)                                                    AS 총합   			   
				  ,  CASE WHEN A.라인명 = '' THEN '드라이룸' ELSE A.라인명    END        AS 라인명	
			   FROM #최종 A  
			   GROUP BY  A.공정
				       , A.공정코드		
			           , A.금액
		    ) A
			WHERE 1=1	 
	
		   


	
	-- 2019. 03. 25 추가부분

		--SELECT
		--	DISTINCT
		--	'권취' AS BandName,
		--	'NumericField' AS NumericField,
		--	'double' AS DataType			





	
		-- [TEMP 테이블 삭제부분]
			DROP TABLE #TEMP_TABLE22



	END

GO

