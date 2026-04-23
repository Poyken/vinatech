

CREATE PROC [dbo].[usp_Size_Day_Total_CEO_NEW_TV] --exec usp_Size_Day_Total_CEO_NEW_TV '','','2020-08-01 00:00:00', '', 'VVT'
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = NULL,
				@pCompanyCode VARCHAR(20) = NULL                                           
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
    DECLARE @Month                VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                           -- 전일자 두자리                       SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 		
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth-1, 121), 0, 11)                                                            --    SELECT SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 0, 11) 	 
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                       -- 어제날짜        ex) 20200111      SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	


      -- [1. 전일실적_상세부분] 		
if @CompanyCode='VNT' 
begin


			SELECT CASE WHEN AA.CompanyCode LIKE '%VNT%' THEN '전주본사' 
					         WHEN AA.CompanyCode LIKE '%VVT%' THEN '베트남'   ELSE '기타' END      AS 사업장    
					  , AA.Size                    AS 사이즈          
					  , SUM(ISNULL(AA.수량,0))   AS  AQty
					  , SUM(ISNULL(BB.수량,0))   AS  BQty	  
					  , CASE WHEN SUM(ISNULL(AA.수량,0)) = 0 OR SUM(ISNULL(BB.수량,0)) = 0  OR SUM(ISNULL(BB.수량,0)) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(ISNULL(BB.수량,0))  ) / CONVERT(NUMERIC(20,5), SUM(ISNULL(AA.수량,0)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			FROM 		 
					( 
					 SELECT 기준년월 AS Names
							,사이즈 AS Size
							,공정코드 AS 공정코드					
						   , RIGHT(기준일,2)  AS 기준일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30, Day31)
							) AS UPT					
						WHERE 1=1
						AND 기준년월  =  '202008'								
                            AND  RIGHT(기준일,2)  = @ToDay						
					  )  AA
								  LEFT OUTER JOIN 
								  ( 

								   SELECT 기준년월
											,사이즈
											, RouteCode AS 공정코드										
											, RIGHT(기준일, 2)  AS 기준일
											,수량
											, CompanyCode
											, LineCode
										  FROM MEDIUM_PROD
										 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																			   ,Day06, Day07, Day08, Day09, Day10
																			   ,Day11, Day12, Day13, Day14, Day15
																			   ,Day16, Day17, Day18, Day19, Day20
																			   ,Day21, Day22, Day23, Day24, Day25
																			   ,Day26, Day27, Day28, Day29, Day30
																			   ,Day31)
										) AS UPT			
																			 
									WHERE 1=1
									  AND 기준년월  = '202008'
										
                            AND  RIGHT(기준일,2)  = @ToDay		
							
					  )  BB  on AA.Names = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.Size = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

			WHERE 1=1
		    
			   AND AA.Names =  '202008'

	
              AND  RIGHT(AA.기준일,2)  = @ToDay

			  AND AA.공정코드 IN ( 'E-28', 'V-28')
			  
			AND AA.Size   like @SizeCode  			   
			AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           --추가
		

			 GROUP BY AA.CompanyCode 
						 , AA.Size           
		

UNION ALL


       ---- [2. 전일실적_합계부분] 
			SELECT   '합계'                        AS 사업장
					 ,  ' '                            AS 사이즈          
					 , SUM(ISNULL(AA.수량,0))   AS  '일 생산계획 (PCS)'  
					 , SUM(ISNULL(BB.수량,0))    AS '일 생산수량 (PCS)'	    					 
		            , CASE WHEN SUM(ISNULL(AA.수량,0)) = 0 OR SUM(ISNULL(BB.수량,0)) = 0  OR SUM(ISNULL(BB.수량,0)) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(ISNULL(BB.수량,0))  ) / CONVERT(NUMERIC(20,5), SUM(ISNULL(AA.수량,0)) ) * 100.0  END  		 AS '달성율 (%)'				 		  		  
			FROM 		 
					( 
					 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드
								--	,기준년월 + RIGHT(기준일,2)  AS 기준년월일
						   , RIGHT(기준일,2)  AS 기준일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30
																   ,Day31)
							) AS UPT					  
						WHERE 1=1
						  AND 기준년월  =  (                                                                                                
													SELECT  Replace(BaseMonth, '-', '')		
													FROM STB_AggregationPeriod
												WHERE 1=1									
													AND  FromDate  <= @OneDay
													AND  ToDate     >= @OneDay
												)      						  							
                            AND  RIGHT(기준일,2)  = @ToDay		
						AND 공정코드  IN ( 'E-28', 'V-28')                                                          -- 추가사항

						
					  )  AA
							 LEFT OUTER JOIN 
									  ( 
									   SELECT 기준년월
												,사이즈
												, RouteCode AS 공정코드											 
												, RIGHT(기준일,2)  AS 기준일
												, 수량
												, CompanyCode
												, LineCode
											  FROM MEDIUM_PROD
											 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																				   ,Day06, Day07, Day08, Day09, Day10
																				   ,Day11, Day12, Day13, Day14, Day15
																				   ,Day16, Day17, Day18, Day19, Day20
																				   ,Day21, Day22, Day23, Day24, Day25
																				   ,Day26, Day27, Day28, Day29, Day30
																				   ,Day31)
											) AS UPT			
																					 
										 WHERE 1=1
										   AND 기준년월  = '202008'

										  --AND 기준년월  =  (                                                                                                
												--	SELECT  Replace(BaseMonth, '-', '')		
												--	FROM STB_AggregationPeriod
												--WHERE 1=1									
												--	AND  FromDate  <= @OneDay
												--	AND  ToDate     >= @OneDay
												--)      							
                            AND  RIGHT(기준일,2)  = @ToDay		
																						
					  )  BB  on AA.기준년월 = BB.기준년월 AND AA.공정코드 = BB.공정코드 AND AA.사이즈 = BB.사이즈 AND AA.CompanyCode = BB.CompanyCode AND AA.LineCode = BB.LineCode 

			WHERE 1=1

			  AND AA.공정코드 IN ( 'E-28', 'V-28')
			     AND AA.기준년월 = '202008'
			   --AND AA.기준년월 = (
						--				 SELECT  Replace(BaseMonth, '-', '')									  
						--				 FROM STB_AggregationPeriod
						--				 WHERE 1=1										   
						--				   AND  FromDate  <= @OneDay
						--				   AND  ToDate     >= @OneDay
						--				)
			AND AA.사이즈  LIKE @SizeCode  			   
			AND ((@CompanyCode = '*') OR (AA.CompanyCode = @CompanyCode))                                           
			AND RIGHT(AA.기준일,2) =@ToDay                                                                                         -- 2020.01.21 추가




end



















--for Vietnam only because Manual Lines have PLAN LineCode <> PRODUCTION lineCode       usp_Size_Day_Total_CEO '','','2020-07-14', '', 'VVT'
DECLARE @jodate     varchar(10)= convert(varchar(10),CONVERT(datetime,@Month+@ToDay,120),120)
DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @jodate),120) + '-25'
DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @jodate),120) + '-26'

if(@ToDay>'25') begin
	select @jodate = convert( varchar(10),DATEADD(MONTH,-1, @jodate),120) 
end


--select @jodate = convert( varchar(10), GETDATE(),120) 


if @CompanyCode='VVT' 
begin
			
		with data1 as (
		select CompanyCode,k1.MaterialCode,substring(MaterialName,CHARINDEX('(',MaterialName)+1,CHARINDEX(')',MaterialName)-CHARINDEX('(',MaterialName)-1 ) as MaterialName
		,/*,LineCode,,RouteCode,*/(outputqty) as outputqty,(defectqty) as defectqty
		 from	STB_ProdRouteSummary k1 join STB_MaterialMaster k2 on k1.MaterialCode=k2.MaterialCode
		  where JobDate>@jodatefrom and JobDate<@jodateto and companycode='VVT' and routecode='V-28' and JobDate=@jodate
		 --group by CompanyCode,k1.MaterialCode,MaterialName--,LineCode--,RouteCode
		 ),
		 data2 as ( 
		 select
		'베트남' as 사업장,  MaterialName as 사이즈, sum(outputqty) as '일 생산수량 (PCS)'	 --, 
		--, CASE WHEN SUM(ISNULL(AA.수량,0)) = 0 OR SUM(ISNULL(BB.수량,0)) = 0  OR SUM(ISNULL(BB.수량,0)) IS NULL THEN 0 ELSE  CONVERT(NUMERIC(20,1), SUM(ISNULL(BB.수량,0))  ) / CONVERT(NUMERIC(20,5), SUM(ISNULL(AA.수량,0)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
		 from data1
		 group by /*CompanyCode,*/MaterialName
		 ), 
		 data3 as (
						 SELECT 기준년월
							,사이즈
							,공정코드 AS 공정코드
								--	,기준년월 + RIGHT(기준일,2)  AS 기준년월일
						   , /*RIGHT(기준일,2)  AS*/ 기준일
							,수량
							, CompanyCode
							, LineCode
					  FROM MEDIUM_PLAN
							 UNPIVOT ( 수량 FOR 기준일 IN (Day01, Day02, Day03, Day04, Day05
																   ,Day06, Day07, Day08, Day09, Day10
																   ,Day11, Day12, Day13, Day14, Day15
																   ,Day16, Day17, Day18, Day19, Day20
																   ,Day21, Day22, Day23, Day24, Day25
																   ,Day26, Day27, Day28, Day29, Day30
																   ,Day31)
							) AS UPT	
							where 기준년월=@Month and 공정코드='V-28' and   CompanyCode='VVT' and 기준일='Day'+@ToDay
						), 
						data4 as (
						select 기준년월
							,사이즈
							--, 공정코드
							--, 기준일
							,sum(수량) as  '일 생산계획 (PCS)'
							--, CompanyCode
							--, LineCode
							from data3
							group by 기준년월
							,사이즈
							, 공정코드
							, 기준일
							, CompanyCode
							--, LineCode
							)
			--),
			,
			data6 as (
			select 
			'베트남' as 사업장
			,isnull(data2.사이즈,data4.사이즈) as 사이즈
			,( case when "일 생산계획 (PCS)"=0 then "일 생산수량 (PCS)" else isnull("일 생산계획 (PCS)","일 생산수량 (PCS)") end ) as "일 생산계획 (PCS)"
			,isnull("일 생산수량 (PCS)",0) as "일 생산수량 (PCS)"			
			 ,CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",0)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			 from data2 full join data4 on data2.사이즈=data4.사이즈
			 ),
			 datalast as(
			 select 
			'베트남' as 사업장
			 ,사이즈
			 ,isnull("일 생산계획 (PCS)","일 생산수량 (PCS)") as "일 생산계획 (PCS)"
			 ,"일 생산수량 (PCS)"			
			 , CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",0)) ) * 100.0  END  		 AS '달성율 (%)'		  					 		  		  
			 from data6 
			 )
			 select 
			'베트남' as A
			 ,사이즈 as Size
			 ,"일 생산계획 (PCS)" AS AQty
			 ,"일 생산수량 (PCS)"	 AS BQty		
			 , CASE WHEN (ISNULL("일 생산수량 (PCS)",0)) = 0 OR (ISNULL("일 생산계획 (PCS)",0)) = 0 THEN 0 ELSE  CONVERT(NUMERIC(20,1), (ISNULL("일 생산수량 (PCS)",0))  ) / CONVERT(NUMERIC(20,5), (ISNULL("일 생산계획 (PCS)",0)) ) * 100.0  END  		 AS Ratio	  					 		  		  
			 ,'VVT' as CompanyCode
			 from datalast 
	union all
			select 
			 '합계'                        AS 사업장
			,' ' as 사이즈
			 ,sum("일 생산계획 (PCS)") as "일 생산계획 (PCS)"
			 ,sum("일 생산수량 (PCS)"	) as "일 생산수량 (PCS)"
			 ,CONVERT(NUMERIC(20,1), sum("일 생산수량 (PCS)")  ) / CONVERT(NUMERIC(20,5), sum("일 생산계획 (PCS)") ) * 100.0 as Ratio
			 ,'VVT' as CompanyCode
			 from datalast 				
			 			 
end








 END