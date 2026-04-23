-- ==================================================================
-- Author      : kilee
-- Create date : 2019-04-11
-- Browsable   : true
-- Group       :  생산현황 > [B751]일일실적보고 > Grid 첫번째 SUMMART부분
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 일일실적보고 Summary 부분  
--                  2019-11-14 대대적인 개편           
-- ==================================================================

--  EXEC [usp_CurlingLine_Total] '','', '2019-11-16 08:30:00', '', 'VNT'                                             ---> 소스에서는 BETWEEN '2019-04-01 08:30:00' and '2019-04-02 08:30:00'  

CREATE PROC [dbo].[usp_CurlingLine_Total] 
				@pProcessUserID     VARCHAR(20),
				@pProcessLanguage VARCHAR(20),	
				@pToDt                 Datetime,
				@pRouteCode VARCHAR(20) = NULL,
				@pCompanyCode VARCHAR(20) = NULL                    -- 추가
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @FromDt              VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 08:30:00'                                                              --  SELECT  CONVERT(VARCHAR(10), '2019-10-26 17:50:55', 121) + ' 08:30:00'                                         
	DECLARE @ToDt                 VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDt)), 121) + ' 08:30:00'        --  SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime,  '2019-11-14 08:00:00')), 121) + ' 08:30:00'
	--DECLARE @ChangeTime       VARCHAR(19) = CONVERT(VARCHAR(10), @pToDt, 121) + ' 20:30:00'    
	DECLARE @ToDay               VARCHAR(02) =  SUBSTRING(CONVERT(VARCHAR(10), @pToDt, 121), 9, 2)                                                       --  1일부터 금일까지 일수  (5월 8일이면.. 08일)            --> SELECT SUBSTRING(CONVERT(VARCHAR(10), '2019-10-08 08:00:00', 121), 9, 2)    
    
	DECLARE @DayCnt              VARCHAR(02) = DatePart(dd,DateAdd(Day,-1,DateAdd(Month,-2,DateAdd(Day,-DatePart(dd, @pToDt)+1, @pToDt))))       --  해당월의 일수 (31일 or 30일)  -->  SELECT DatePart(DD,DateAdd(Day,-1,DateAdd(Month,-2,DateAdd(Day,-DatePart(DD, '2019-11-15')+1, '2019-11-15')))) 
	
	DECLARE @RouteCode         VARCHAR(20)        = CASE WHEN ISNULL(@pRouteCode,'')         = '' THEN '%'       ELSE @pRouteCode        END
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode                    END

 ----  [합계부분]

SELECT  SUM(월간계획) / @DayCnt                                                        AS 일일목표               -- 전체목표에서 / 일수(31일이나 30일)  -> @DayCnt
         , SUM(전체수량)                                                                      AS 일일실적               -- 전체수량 (주간+야간)
	  -- , SUM(전체수량)   /  (SUM(월간계획)  / @DayCnt) *  100                      AS 일일달성율                                                                     -- (일일실적/일일목표) * 100	         		 
		 , CASE WHEN  SUM(월간계획) = 0 THEN 0 ELSE  SUM(전체수량)   /  (SUM(월간계획)  / @DayCnt) *  100  END              AS 일일달성율            -- (일일실적/일일목표) * 100	         		 
		 , SUM(누계목표)                                                                      AS 누계목표
		 , SUM(누계생산)                                                                      AS 누계실적
	   --, SUM(누계생산) /   SUM(누계목표)  * 100                                       AS 누계달성율            -- (%)		 		 		
		 , CASE WHEN   SUM(누계목표)  = 0 THEN 0 ELSE  (SUM(누계생산) /   SUM(누계목표) ) * 100    END                    AS 누계달성율            -- (%)				 		
FROM  (

				SELECT 						
					  ISNULL(GG.월간계획, 0)                                                        AS 월간계획
				    , (ISNULL(GG.월간계획, 0) / @DayCnt  * (@ToDay + 6))                    AS 누계목표 		-- 월간계획 / 일수 X 금일일수                       ex)  
				  --, ISNULL(GG.월간계획, 0) /           31 * (14 + 6)                     AS 누계목표   

					, ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0)                       AS 누계생산         -- 1일부터 현재일까지의 생산량도 추가
					
					, CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay + 6 ))  * 100  END  AS 누계달성율		        -- 누계생산 / 누계목표	
				  --, CASE WHEN ISNULL(GG.월간계획, 0) / @DayCnt  * 100 = 0 THEN 0 ELSE  (ISNULL(SS.전체수량, 0) + ISNULL(GG.월누적수량, 0))  / (ISNULL(GG.월간계획, 0) / @DayCnt * (@ToDay+6))  * 100   END  AS 누계달성율		-- 누계생산 / 누계목표		
																		 										
	                , CASE WHEN ISNULL(GG.월간계획, 0)                * 100 = 0 THEN 0 ELSE  (ISNULL(SS.일일총수량, 0) + ISNULL(GG.월누적수량, 0))  / ISNULL(GG.월간계획, 0)    * 100                                   END  AS 누계진도율


					, ISNULL(SS.일일총수량, 0)                     AS 전체수량					
				FROM 
						(  
							-- GG START  
										SELECT  BB.*
												, AA.월누적수량      AS 월누적수량													
										FROM 
										(
												SELECT 라인코드
														, 월누적수량      AS 월누적수량
														, 사이즈           AS 사이즈		
														, RouteCode      AS 공정코드		
														, CompanyCode                         --추가
												FROM CURLING_PROD        -- [커링_일별실적]
											   WHERE 1=1			
																																							
												  --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 	
																			AND 기준년월 = '201912'																							
												   AND RouteCode LIKE @RouteCode	
												   AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가

												   --AND  기준년월 = '201911'
												   --AND RouteCode = 'E-28'
												   --AND CompanyCode = 'VNT'

											GROUP BY  RouteCode																	
														, 라인코드
														, 월누적수량												
														, 사이즈	
														, RouteCode	
														, CompanyCode															
										) AA

										LEFT OUTER JOIN (
																	SELECT LineCode
																			, 사이즈																			
																			, 월간계획																			
																			, 특이사항
																			, 공정코드
																			, CompanyCode  --추가
																		FROM MEDIUM_PLAN
																		WHERE 1=1
																		   --AND 기준년월 = REPLACE(SUBSTRING(CONVERT(VARCHAR(10),  @pToDt , 121), 0, 8), '-', '') 	
																			AND 기준년월 = '201912'	
																			AND ((@CompanyCode = '*') OR (CompanyCode = @CompanyCode))                                                --추가
																			AND 공정코드 LIKE @RouteCode	
																			
																			--AND 기준년월 = '201911'
																			-- AND 공정코드 = 'E-28'																			 																		 																			
																			--AND CompanyCode = 'VNT'
																		    																		   																		  																   
																		   													
															) BB		    ON AA.라인코드 = BB.LineCode  AND AA.공정코드 = BB.공정코드  AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode
															            --ON AA.라인코드 = BB.LineCode  AND AA.사이즈 = BB.사이즈 AND AA.공정코드 = BB.공정코드															            
							    -- [GG END]
						 )   GG


			LEFT JOIN 	(	
			                   -- [SS START]
								   SELECT 
								             라인코드                                                                                         AS 라인코드											
											 , CASE WHEN 라인코드 LIKE '%ASSYLINE-05%' THEN 규격 + 'L'  ELSE 규격 END    AS 규격       -- 1030L 문제로 추가된 사항
											--, SUM(전체수량)                                                                                 AS 전체수량
											, SUM(주간수량) + SUM(야간수량)                                                             AS 일일총수량
											, 공정코드                                                                                        AS 공정코드											
									FROM (																																																										
													SELECT  SP.사이즈                                                                                                    AS 규격																	          
															,  A.RouteCode                                                                                                AS 공정코드
															, A.LineCode																									  AS 라인코드
															, CASE WHEN A.ShiftCode = '1'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 주간수량
															, CASE WHEN A.ShiftCode = '2'  THEN  (SUM(A.OutputQty) - SUM(A.DefectQty)) ELSE 0 END   AS 야간수량
															, (SUM(A.OutputQty) - SUM(A.DefectQty))                                                                 AS 전체수량																				
													FROM STB_ProdRouteSummary A                                                                                                
															LEFT OUTER JOIN ERPSVR.ERPDB.DBO.product  SP	 ON A.MaterialCode = SP.PRODCD																							
														WHERE 1=1							
															AND A.TIMECODE <> 'E'		
																																																																   																																
															AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12),@FromDt, 121), 0, 11)                        --  SELECT SUBSTRING(CONVERT(VARCHAR(12), '2019-10-28', 121), 0, 11)    
															AND A.RouteCode  LIKE @RouteCode		                                                                 --  SELECT SUBSTRING(CONVERT(VARCHAR(12), '2019-10-28', 121), 0, 11)    
															AND ((@CompanyCode = '*') OR (A.CompanyCode = @CompanyCode)) 

															--AND A.JobDate = SUBSTRING(CONVERT(VARCHAR(12), '2019-11-14', 121), 0, 11)              
															--AND A.RouteCode = 'E-28'
															--AND A.CompanyCode = 'VNT'

													GROUP BY A.RouteCode 
																, SP.사이즈		
																, A.ShiftCode	
																, A.LineCode				

											--  주간+야간 END
											) AA
											GROUP BY 규격, 공정코드, 라인코드
                             
								 ) SS	 ON  SS.라인코드 = GG.LineCode   AND SS.규격 = GG.사이즈  AND SS.공정코드 = GG.공정코드								 											
)   PP								
where 1=1
 

 END