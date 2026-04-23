-- ==================================================================
-- Author      : kilee
-- Create date : 2019-05-09
-- Browsable   : true
-- Group       : 2019-05-10 오전 08:31 자동실행  (매일 1번 자동실행)
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 매일 아침 8시30분기준으로 전일자 일일실적현황을 자동으로 계산해서 넣어준다.  (오늘이 10일이면 9일 실적을 9일에 자동입력)
--                   2019-04-09 정상실행     
--                   2019-09-04 ERP + NAIS 실적 추가
--                   2020-03-26 베트남 법인도 추가
---[실행문]     EXEC usp_Medium_Daily_Input_20200326  '',''                               --  EXEC usp_Medium_Daily_Input_20200326  '2020-03-26', 'V-22'
-- ==================================================================
CREATE PROC [dbo].[usp_Medium_Daily_Input] 		
				@pDate DATE,
				@pRouteCode VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;
		

  Declare @Date         DATE           = @pDate
	       ,@RouteCode VARCHAR(20) = @pRouteCode
		   ,@ExistRow    INT             = 0

 --[기존형식]
 --	DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                                                                   -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	--DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10), GetDate(),    121) + ' 08:30:00'                                                                -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	--DECLARE @ToDay      VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                           -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)

-- [이게원본]
    DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), DateAdd(Day, -1, @Date), 121) + ' 08:30:00'                                                  -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), DATEADD(day, -1, @Date), 121) + ' 08:30:00'                       
	DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10)                      , @Date, 121) + ' 08:30:00'                                                 -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	DECLARE @ToDay      VARCHAR(02) = SUBSTRING(@FromDt, 9, 2)                                                                                                    --  SELECT SUBSTRING('2019-09-30 08:30:00', 9, 2)

  --DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10)                      ,  '2020-01-25', 121) + ' 08:30:00'                                                  -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), DATEADD(day, -1, '2020-01-27'), 121) + ' 08:30:00'                       
  --DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10)                       ,  '2020-01-26', 121) + ' 08:30:00'                                                 -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), '2020-01-28', 121) + ' 08:30:00'
  --DECLARE @ToDay      VARCHAR(02) = SUBSTRING(@FromDt, 9, 2)                                                                                                    --  SELECT SUBSTRING('2019-09-30 08:30:00', 9, 2)

	DECLARE @ToDay2     VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), @ToDt, 121), 9, 2)                                                                  -- 1일부터 금일까지 일수  (5월 8일이면.. 08일)            --> SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-05-08 08:00:00', 121), 9, 2)    
	DECLARE @DayCnt     VARCHAR(02) = DatePart(dd,dateadd(day,-1,DateAdd(month,1,DateAdd(day,-DatePart(dd, @ToDt)+1, @ToDt))))                    -- 해당월의 일수 (31일 or 30일)  --> SELECT datepart(dd,dateadd(day,-1,dateadd(month,1,dateadd(day,-datepart(dd, '2019-05-08')+1,'2019-05-08'))))	

-- 이부분부터 수정	
	--DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)  *** 문제는 이전데이터 들어갈때가 문제임!!!
	DECLARE @OneDay    VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11)                                                     -- 오늘날짜   ex) 2020-01-12    SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11)  *** 문제는 이전데이터 들어갈때가 문제임!!!

  --DECLARE @BaseYm    VARCHAR(6)   = LEFT(@FromDt, 4) + SUBSTRING(@FromDt, 6, 2)                                                                         -- ex) 201909                       --> SELECT LEFT('2019-09-26 08:40:00', 4) + SUBSTRING('2019-09-26 08:40:00', 6, 2)
    DECLARE @BaseYm    VARCHAR(06)
												
    DECLARE @CompanyCode      VARCHAR(20) 
															
		--- 기준년월 (26일부터 ~ 다음달 25일까지)
			SELECT @BaseYm = Replace(BaseMonth, '-', '') 																		
			FROM STB_AggregationPeriod
  			WHERE 1=1									
			  AND  FromDate  <= @OneDay
			  AND  ToDate     >= @OneDay
  																	
																	
		 --  SELECT  Replace(BaseMonth, '-', '') 																		
			--FROM STB_AggregationPeriod
  	--		WHERE 1=1									
			--  AND  FromDate  <= GETDATE()
			--  AND  ToDate     >= GETDATE()																													
																																																																										
 --  [조회 QUERY]  *****************************************************************************************************************************************
 SELECT
           GG.사이즈                                                                       AS 사이즈
	     , GG.월간계획                                                                     AS 월간계획
	  -- , (GG.월간계획/@DayCnt)                                                       AS 누계목표 		 -- 월간계획 / 일수(30일 or 31일)
		 , (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0) )                 AS 누계생산          -- 1일부터 현재일까지의 생산량도 추가
		, CASE WHEN SS.주간수량 IS NULL THEN 0 ELSE SS.주간수량 END       AS 주간수량
		, CASE WHEN SS.야간수량 IS NULL THEN 0 ELSE SS.야간수량 END       AS 야간수량		
		, GG.특이사항                                                                      AS 특이사항
		, ISNULL(SS.일일총수량,0)                                                        AS 일일총수량	 
		, CONVERT(VARCHAR(10),  GetDate(), 121)                                    AS 기준일자         -- 금일날짜
		, GG.공정코드                                                                      AS 공정코드  
		, GG.LineCode                                                                     AS 라인코드          --추가
		, GG.CompanyCode                                                              AS  CompanyCode

  INTO #TEMP_TABLE51     -- 주석아님!!!

  FROM 
				(  
				 -- GG START
								SELECT  BB.*
										, AA.월누적수량 AS 월누적수량									  
								FROM 
										(
											SELECT  PL.사이즈
													, SUM(PO.월누적수량)  AS 월누적수량
													, PL.공정코드
													, PL.LineCode             AS 라인코드    --추가
											FROM MEDIUM_PLAN PL                                                                                                                        -- 월별계획 Table
													LEFT OUTER JOIN MEDIUM_PROD PO ON   PO.사이즈 = PL.사이즈  AND PO.RouteCode = PL.공정코드                   -- 일별실적 Table (사이즈, 공정코드 Join)
											WHERE 1=1											
												--AND PL.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @FromDt , 121), 0, 8), '-', '') 			
                                                --AND PL.기준년월 = '202001'
												 AND PL.기준년월 = (
																								SELECT  Replace(BaseMonth, '-', '')		
																								FROM STB_AggregationPeriod
																							WHERE 1=1									
																								AND  FromDate  <= @OneDay
																								AND  ToDate     >= @OneDay
										    						   )
												--AND PO.CompanyCode = 'VNT'                                                             -- 원본 (2020.03.27 주석처리)										

											GROUP BY  PL.사이즈 , PL.공정코드	
											            , PL.LineCode								  --추가
										) AA
									,	(
												SELECT  사이즈												
														, 월간계획												
														, 특이사항
														, 공정코드
														, LineCode
														, CompanyCode
													FROM MEDIUM_PLAN                                      
													WHERE 1=1 
													   --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 
													   --AND 기준년월 = '202001'   
													    AND 기준년월 = (
																				SELECT  Replace(BaseMonth, '-', '')		
																				FROM STB_AggregationPeriod
																			WHERE 1=1									
																				AND  FromDate  <= @OneDay
																				AND  ToDate     >= @OneDay
										    								)            
										) BB
							WHERE 1=1
							   AND AA.사이즈   = BB.사이즈
							   AND AA.공정코드 = BB.공정코드
							   AND AA.라인코드 = BB.LineCode     --추가
				-- GG END
			   ) GG

LEFT JOIN (	--> GG 테이블 기준으로 

-- [SS부분]
					 SELECT  CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  
					                   --WHEN 라인코드 LIKE '%ASSYLINE-09%' AND 규격 = '1030' THEN 규격 + 'L'  
									   --WHEN 라인코드 LIKE '%ASSYLINE-09%' AND 규격 = '1030' THEN 규격 
									   WHEN 라인코드 LIKE '%ASSYLINE-11%' AND 규격 = '1840' THEN 규격 + '-수동'  
									   WHEN 라인코드 LIKE '%ASSYLINE-13%' AND 규격 = '1840' THEN 규격 + '-자동'  							   
									                                                                                                      ELSE 규격 END     AS 규격    
							 , SUM(주간수량)                       AS 주간수량
							 , SUM(야간수량)                       AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량)  AS 일일총수량
							 , 공정코드                               AS 공정코드
							 , 라인코드                               AS 라인코드
							  , CompanyCode
						FROM (

								--  실적수량파악 START (ERP + NAIS)
												  SELECT   사이즈             AS 규격   
												            , 공정코드          AS 공정코드	
															, 라인코드          AS 라인코드
															, SUM(주간수량)   AS 주간수량		
															, SUM(야간수량)   AS 야간수량			
															, CompanyCode																												
													FROM
													(																																	
																	
																	SELECT  SP.사이즈                                                                                                    AS 사이즈																	          
																	--SELECT  CASE WHEN SP.사이즈 LIKE '1030%' AND  A.MaterialCode IN ('ECVT30-293', 'ECVT27-370') THEN '1030-L'
																	--                  WHEN SP.사이즈 LIKE '1030%' AND  A.MaterialCode IN ('ECVT27-343', 'ECVT30-247') THEN '1030' ELSE SP.사이즈  END  AS 사이즈																	          
																			,  A.RouteCode                                                                                              AS 공정코드
																			, A.LineCode																									AS 라인코드
																			, Case When A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
																			, Case When A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량	
																			, 		CompanyCode																			
																	FROM							   STB_ProdRouteSummary  A                                                                                                
																			--LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP  ON A.MaterialCode = SP.PRODCD
																			LEFT OUTER JOIN 
																			(																			
																			 select RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) as 사이즈
																			       , ModelCode AS ModelCode
																			  from STB_ModelBasicInfo
																			 where modelcode like 'ECVT%'																			
																			)  SP  ON A.MaterialCode = SP.ModelCode
																		WHERE 1=1							
																		   AND A.TIMECODE <> 'E'																																																			   																			
																			AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), @FromDt, 121), 0, 11)               -- SELECT SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 0, 11)     
																			--AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), '2020-01-27', 121), 0, 11)       
																			--AND  A.MaterialCode IN ('ECVT30-293', 'ECVT27-370', 'ECVT27-343', 'ECVT30-247')
																	GROUP BY A.RouteCode 
																				, SP.사이즈		
																				, A.ShiftCode	
																				, A.LineCode		
																				--, A.MaterialCode		
																				, CompanyCode																
															    )  ZZ
														GROUP BY  ZZ.사이즈
																	,  ZZ.공정코드	
																	, ZZ.라인코드	
																	, ZZ.CompanyCode																																																																																																																																					
												   --  실적수량파악 END   														  							
                              ) AA
							  WHERE 1=1                                             							    
							  GROUP BY  규격
							             ,  공정코드
                                         , 라인코드
										 , CompanyCode		
							   

             ) SS	ON   SS.규격 = GG.사이즈
			       AND SS.공정코드 = GG.공정코드
				   AND SS.라인코드 = GG.LineCode              --추가
				   AND SS.CompanyCode = GG.CompanyCode

ORDER BY GG.사이즈 


--- 주요 INSERT문 ------------------------------------------------------

  
-- -- 전일실적 UPDATE부분 --
    DECLARE @sqlStr VARCHAR(1000)
--	   -- SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''' + @BaseYm + ''' AND A.RouteCode = ''' + @RouteCode + '''  AND A.LineCode = B.라인코드 '                                                                      -- 2020.03.02 수정 (법인추가)
--  	  --  SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''' + @BaseYm + ''' AND A.RouteCode = ''' + @RouteCode + '''  AND A.CompanyCode = ''VNT''  AND A.LineCode = B.라인코드 '                               -- 2020.02.04 수정
	      SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''' + @BaseYm + '''  AND A.RouteCode = ''' + @RouteCode + '''  AND A.CompanyCode = B.[CompanyCode]  AND A.LineCode = B.라인코드 '       -- 2020.03.26 수정
--	   -- SET @sqlStr = ' UPDATE MEDIUM_PROD  SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)  FROM MEDIUM_PROD A INNER JOIN  #TEMP_TABLE51 B ON A.[사이즈] = B.[사이즈] AND A.[RouteCode] = B.[공정코드] AND 기준년월 = ''202002''             AND A.RouteCode = ''' + @RouteCode + '''  AND A.CompanyCode = ''VNT''  AND A.LineCode = B.라인코드 '

    EXECUTE (@sqlStr)
    --SELECT (@sqlStr)    -- 지우지말것

---- TEMP TABLE삭제
   DELETE FROM  #TEMP_TABLE51                                       --  위에 있는 테이블  

 END  