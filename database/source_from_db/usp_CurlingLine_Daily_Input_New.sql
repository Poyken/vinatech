-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-09
-- Browsable   : true
-- Group       : 2019-04-05 오전 08:31 자동실행  (매일 1번 자동실행)
-- Description :  (DB명 : [SmartFactoryV2]
-- Modified    : 매일 아침 8시30분기준으로 전일자 일일실적현황을 자동으로 계산해서 넣어준다.  (오늘이 10일이면 9일 실적을 9일에 자동입력)
--                   2019-04-09 정상실행   

---[실행문]    EXEC usp_CurlingLine_Daily_Input_New             
-- ==================================================================

CREATE PROC [dbo].[usp_CurlingLine_Daily_Input_New]
	--@pDate DATE
	--, @pRouteCode VARCHAR(20)
AS

BEGIN
	SET NOCOUNT ON;

	--Declare @Date         DATE = @pDate
	--Declare @RouteCode VARCHAR(20) = @pRouteCode
	Declare @RouteCode VARCHAR(20) = 'E-28'
	Declare @ExistRow    INT = 0

 --[기존형식]
    DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                                                                             -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10), GetDate(),    121) + ' 08:30:00'                                                                             -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	DECLARE @ToDay      VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                                        -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)


	--DECLARE @FromDt     VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, -1, @Date), 121) + ' 08:30:00'                                                                             -- 전일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate()-1, 121) + ' 08:30:00'                       
	--DECLARE @ToDt        VARCHAR(19) = CONVERT(VARCHAR(10), @Date,    121) + ' 08:30:00'                                                                             -- 금일 오전 8시반       SELECT CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	--DECLARE @ToDay      VARCHAR(02) = SUBSTRING(@FromDt, 9, 2)    

	

-- [수동으로 실행시 -> 지우지말것]	
	--DECLARE @FromDt             VARCHAR(19) =  '2019-10-05 08:30:00'            -- 전일                    
	--DECLARE @ToDt                VARCHAR(19) =  '2019-10-06 08:30:00'            -- 금일
	--DECLARE @ToDay              VARCHAR(02) =   '05'                                -- 전일자로 넣음

	DECLARE @BaseYm VARCHAR(6) = LEFT(@FromDt, 4) + SUBSTRING(@FromDt, 6, 2)                                                                                 -- ex) 201910     -->  SELECT  LEFT('2019-10-09 08:30:00', 4) + SUBSTRING('2019-10-09 08:30:00', 6, 2) 
	----DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'                                                                                --> SELECT  CONVERT(VARCHAR(10), '2019-09-01 08:30:00', 121) + ' 20:30:00'  

	
--  SELECT * FROM CURLING_PROD               --> 일자별
--  SELECT * FROM CURLING_PLAN               --> 월별계획
--  SELECT * FROM CURLING_LINE WHERE 라인명 = '베트남'

  --BEGIN TRAN
  ---- COMMIT
  --UPDATE CURLING_PROD
  --SET DAY09 = '0'
  
	-- 데이터 업데이트를 위한 빈행이 존재하는지 확인 후 생성
	--SELECT @ExistRow = COUNT(*) FROM CURLING_PROD WHERE 기준년월 = @BaseYm AND RouteCode = @RouteCode

	---- 계획테이블에 RouteCode 추가 후 활성화 할 것.
	
	--IF @ExistRow = 0 BEGIN
	--	INSERT INTO CURLING_PROD (기준년월, 라인코드, 라인명, RouteCode) 
	--		SELECT 기준년월, 라인코드, 라인명, RouteCode
	--		  FROM CURLING_PLAN
	--		 WHERE 기준년월 = @BaseYm 
	--		   AND RouteCode = @RouteCode
	--END
	

	
 --  [조회 QUERY]  *****************************************************************************************************************************************
 
 SELECT GG.라인명                         AS 라인명        
         , GG.사이즈                         AS 규격
	     , GG.월간계획                      AS 월간계획
		 , (GG.월간계획/30)                 AS 누계목표 		 
		 , ( SS.일일총수량 + GG.월누적수량 )                                                    AS 누계생산             -- 1일부터 현재일까지의 생산량도 추가
		 , (   ( SS.일일총수량 + GG.월누적수량 )   /   (GG.월간계획/30) * 100 )            AS 누계달성율		   -- 누계생산 / 누계목표
		 , (  ( ( SS.일일총수량 + GG.월누적수량 )   /   GG.월간계획) * 100)                 AS 누계진도율       -- 누계생산 / 월간계획 		
		, CASE WHEN SS.주간수량 IS NULL THEN 0 ELSE    SS.주간수량 END              AS 주간수량
		, CASE WHEN SS.야간수량 IS NULL THEN 0 ELSE    SS.야간수량 END              AS 야간수량		
		, GG.특이사항                                                                                AS 특이사항
		, SS.일일총수량                                                                              AS 일일총수량	 
		, CONVERT(VARCHAR(10),  GetDate()-1, 121)                                           AS 기준일자                                                                                           -- 금일날짜
		, GG.LineCode                                                                                AS 라인코드		
  INTO #TEMP_TABLE100                                                                                                                                                                                    -- 주석아닙니다.
  FROM 
				(  
				 -- GG START
								SELECT  BB.*
										 , AA.월누적수량 AS 월누적수량
								FROM 
											(
												SELECT  (SELECT LineName FROM STB_LineInfo SL WHERE SL.LineCode = MP.LineCode)  AS 라인명													  														 
														, CP.라인코드    AS 라인코드
														, CP.월누적수량 AS 월누적수량
														, CP.사이즈      AS 사이즈
														, CP.RouteCode      AS RouteCode
														, MP.CompanyCode AS CompanyCode
												FROM MEDIUM_PLAN   MP                                                                                                               -- 월별계획 Table
														LEFT OUTER JOIN CURLING_PROD CP ON   CP.라인코드 = MP.LineCode    AND CP.사이즈 = MP.사이즈    AND CP.RouteCode = MP.공정코드   AND CP.기준년월 = MP.기준년월                          -- 일별실적 Table (라인명으로 Join)
												WHERE 1=1												
													--AND PL.기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 				    
													--AND  MP.공정코드 =   
													AND MP.기준년월 = '201910'                                                                                                                  -- TEST부분			       
													AND MP.공정코드 = 'E-28'
													AND MP.CompanyCode = 'VNT'
												GROUP BY CP.라인코드	
															, CP.월누적수량
															, CP.사이즈
															, MP.LineCode
															, CP.RouteCode
															, MP.CompanyCode
											) AA
					 LEFT OUTER JOIN (
												SELECT LineCode                                                                                      AS LineCode
														, (SELECT LineName FROM STB_LineInfo SL WHERE SL.LineCode = MP.LineCode)  AS 라인명
														, 사이즈																					      AS 사이즈                                                                                     
														, 월간계획
														--, 라인별칭
														, 특이사항
														, 공정코드
														, CompanyCode AS CompanyCode
												FROM MEDIUM_PLAN MP
											   WHERE 1=1																																																		 
												 --AND 기준년월 = 	'201910'
												 --AND MP.공정코드 LIKE  'E-28%'	
												AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  GETDATE() , 121), 0, 8), '-', '') 		
												AND 공정코드 = @RouteCode	
												AND CompanyCode = 'VNT'
										) BB	ON AA.라인코드 = BB.LineCode  AND AA.RouteCode = BB.공정코드  AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode
				          -- GG END
			     )  GG                                                      --> GG 테이블 기준으로 

LEFT JOIN    (	                             

					 SELECT 라인명                                  AS 라인명
						     , 규격                                     AS 규격
							 , SUM(주간수량)                        AS 주간수량
							 , SUM(야간수량)                        AS 야간수량 
							 , SUM(주간수량) + SUM(야간수량)   AS 일일총수량
						FROM (
										-- 주간 START											
											SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = A.InputLineCode ) AS 라인명
												 -- , A.InputLineCode AS 라인코드			 
													, SP.사이즈                                    AS 규격
													, (SUM(A.ProdQty) - SUM(A.DefectQty))  AS 주간수량
													, 0                                              AS 야간수량
												FROM STB_SetInfo A     
														LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
												WHERE 1=1
												   AND A.InputShiftCode = '1'
												   AND  A.CreateDateTime BETWEEN @FromDt AND  @ToDt 													
												  --AND A.CreateDateTime BETWEEN '2019-10-01 08:30:00'and '2019-10-01 20:30:00'																								 																								 													
											GROUP BY A.InputLineCode 
														, SP.사이즈		
                                         --  주간 END

											UNION 

										-- 야간 START												
											SELECT  (SELECT B.LineName FROM STB_LineInfo B WHERE B.LineCode = A.InputLineCode ) AS 라인명																									
													, SP.사이즈                                              AS 규격
													, 0                                                        AS 주간수량
													, (SUM(A.ProdQty) - SUM(A.DefectQty))             AS 야간수량
												FROM STB_SetInfo A     
														LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
												WHERE 1=1		
												    AND A.InputShiftCode = '2'
													AND A.CreateDateTime BETWEEN @FromDt AND  @ToDt 																						 													
													--AND A.CreateDateTime BETWEEN '2019-10-01 20:30:00'and '2019-10-02 08:30:00'			            													
											GROUP BY A.InputLineCode 
														, SP.사이즈			
										--- 야간실적 END
                              ) AA
							  GROUP BY 라인명, 규격
            -- 실적부분 END

             ) SS	ON  SS.라인명 = GG.라인명 
			        AND SS.규격 = GG.사이즈

ORDER BY GG.라인명 


--- 주요 INSERT문 ------------------------------------------------------
---- INSERT INTO CURLING_PROD 
 --SELECT  기준일자, 라인코드, 정렬라인명, 일일총수량  
  --FROM #TEMP_TABLE100
  
 -- 전일실적 UPDATE부분 --
   DECLARE @sqlStr VARCHAR(1000) 

         SET @sqlStr = '  UPDATE CURLING_PROD   SET DAY' + @ToDay + ' = ISNULL(B.[일일총수량], 0)    FROM CURLING_PROD A   INNER JOIN #TEMP_TABLE100 B  ON A.[라인코드] = B.[라인코드] AND RouteCode = ''' + @RouteCode + '''  AND 기준년월 = ''' + @BaseYm + '''    '
  
   EXECUTE  (@sqlStr)

-- TEMP TABLE삭제
    DELETE FROM  #TEMP_TABLE100      

 END
