-- =============================================
-- Author:	    kilee
-- Create date: 2019-10-27
-- Browsable : true
-- Group : 생산계획 > 전극소요량계산
-- Description: Grid3. 전극종류별 소요량 계산
-- Modified:

--  EXEC usp_Electrode_Requirements_get
-- =============================================
CREATE PROCEDURE [dbo].[usp_Electrode_Requirements_get]
	--@pProcessUserID     VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	--@pAQL                 VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @AQL VARCHAR(10) = CASE WHEN ISNULL(@pAQL,'') = '' THEN '*' ELSE @pAQL END



				SELECT K.SIZE                                                                                 AS SIZE	    
				        , K.KIND																				AS KIND
						, ROUND(SUM(K.본사계획량)   / Convert(Float, K.ONE_BATCH_PLUS),   0)   AS VNT_BATCH_PLUS
						, ROUND(SUM(K.본사계획량)    / Convert(Float, K.ONE_BATCH_MINUS), 0)  AS VNT_BATCH_MINUS	
						, ROUND(SUM(K.베트남계획량) / Convert(Float, K.ONE_BATCH_PLUS),   0)   AS VVT_BATCH_PLUS
						, ROUND(SUM(K.베트남계획량) / Convert(Float, K.ONE_BATCH_MINUS), 0)  AS VVT_BATCH_MINUS	
                INTO #TEMP_TABLE488
				FROM 
  						  (
									-- SELECT GG.사이즈       AS SIZE
									--       , SS.KIND             AS KIND
									--		, SS.FARAD
									--		, SS.WIDTH
									--		, SS.PLUS                   AS ONE_BATCH_PLUS
									--		, SS.MINUS                 AS ONE_BATCH_MINUS
									--		, GG.본사_생산계획량     AS 본사계획량
									--		, GG.베트남_생산계획량   AS 베트남계획량      
									--FROM
									--				 (


									--					 SELECT  CASE WHEN PP.사이즈 = '' OR PP.사이즈 = NULL OR PP.사이즈 IS NULL THEN QQ.사이즈 ELSE PP.사이즈 END    AS 사이즈
									--							 , ISNULL(PP.본사_월간계획, 0)     AS 본사_생산계획량
									--							 , ISNULL(QQ.베트남_월간계획, 0)  AS 베트남_생산계획량
									--					 FROM 
									--					 (
									--					 SELECT AA.사이즈
									--						   , CASE WHEN AA.CompanyCode = 'VNT' THEN SUM(AA.월간계획)   ELSE 0 END 본사_월간계획	
									--						   , 	0 AS 	         베트남_월간계획	
									--					FROM (						
									--										SELECT 	사이즈							      
									--													,  CompanyCode 
									--													,  SUM(월간계획)   AS 월간계획
									--											FROM Medium_Plan MP									
									--											WHERE 1=1
									--												--AND 기준년월 LIKE @ToMonth + '%'
									--												AND  기준년월 = '201911'
									--												AND MP.공정코드 IN ( 'E-22', 'V-22')                           -- 안제헌대리가 권취공정수량
									--												-- AND MP.사이즈 = '0820'
									--												AND MP.CompanyCode = 'VNT'
									--											GROUP BY  사이즈, CompanyCode						                 												
									--											 ) AA                    
									--								GROUP BY Companycode, 사이즈
									--							)    PP

									--					FULL OUTER JOIN (
									--											 SELECT AA.사이즈
									--												  , 0 AS 본사_월간계획
									--												   , CASE WHEN AA.CompanyCode = 'VVT' THEN SUM(AA.월간계획)   ELSE 0 END AS 베트남_월간계획			         
									--											FROM (						
									--																SELECT 	사이즈							      
									--																			,  CompanyCode 
									--																			,  SUM(월간계획)   AS 월간계획
									--																	FROM Medium_Plan MP									
									--																	WHERE 1=1
									--																		--AND 기준년월 LIKE @ToMonth + '%'
									--																		AND  기준년월 = '201911'
									--																		AND MP.공정코드 IN ( 'E-22', 'V-22')                           -- 안제헌대리가 권취공정수량
									--																		-- AND MP.사이즈 = '0820'
									--																		AND MP.CompanyCode = 'VVT'
									--																	GROUP BY  사이즈, CompanyCode							                 												
									--													) AA                    
									--												GROUP BY Companycode, 사이즈
									--											) QQ
									--					ON PP.사이즈 = QQ.사이즈
									--				) GG
									--			 LEFT OUTER JOIN SIZE_UNIT  SS ON SS.SIZE = GG.사이즈

					SELECT SS.SIZE       AS SIZE
					        , SS.KIND                  
							, SS.FARAD
							, SS.WIDTH
							, SS.PLUS                   AS ONE_BATCH_PLUS
							, SS.MINUS                 AS ONE_BATCH_MINUS
							, ISNULL(SS.VNT_PLAN_QTY, 0)     AS 본사계획량
							, ISNULL(SS.VVT_PLAN_QTY, 0)    AS 베트남계획량      
					FROM		 SIZE_UNIT   SS

				) K
				GROUP BY K.ONE_BATCH_PLUS, K.ONE_BATCH_MINUS, K.SIZE, K.KIND	

				ORDER BY K.SIZE


-- 이부분부터 전극소요량 계산부분
SELECT 'Y116'                             AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)      AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)        AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)      AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	AND SIZE IN ( '0813', '0820')
	AND KIND = 'YP'

UNION ALL
				    
SELECT 'Y200'                             AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)      AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)        AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)      AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	--AND SIZE IN ( '1020', '1025','1030', '1320','1325','1625','1840','2245','3562','3567','3572','3582')
	 AND SIZE = (CASE WHEN SIZE = '1020' AND KIND = 'YP' THEN '1020'  ELSE '0' END)
	   OR SIZE = (CASE WHEN SIZE = '1025' AND KIND = 'YP' THEN '1025'  ELSE '0' END)	   
	   OR SIZE = (CASE WHEN SIZE = '1030' AND KIND = 'YP' THEN '1030'  ELSE '0' END)	   
	   OR SIZE = (CASE WHEN SIZE = '1325' AND KIND = 'YP' THEN '1325'  ELSE '0' END)	    
	   OR SIZE = (CASE WHEN SIZE = '1840' AND KIND = 'YP' THEN '1840'  ELSE '0' END)	    
	   OR SIZE = (CASE WHEN SIZE = '2245' AND KIND = 'YP' THEN '2245'  ELSE '0' END)	    
	   OR SIZE IN ('1320','1625','3562','3567','3572','3582')

UNION ALL

SELECT 'C120'                             AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)      AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)        AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)      AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	   AND SIZE = (CASE WHEN SIZE = '0820' AND KIND = 'CEP' THEN '0820'  ELSE '0' END)
	     OR SIZE IN ('0825','0830')

UNION ALL

SELECT 'C200'                             AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)      AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)        AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)      AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	AND SIZE = (CASE WHEN SIZE = '1020' AND KIND = 'CEP' THEN '1020'  ELSE '0' END)
	  OR SIZE = (CASE WHEN SIZE = '1025' AND KIND = 'CEP' THEN '1025'  ELSE '0' END)
	  OR SIZE = (CASE WHEN SIZE = '1325' AND KIND = 'CEP' THEN '1325'  ELSE '0' END)

UNION ALL

SELECT 'M120'                            AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)    AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)       AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)     AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	AND SIZE = (CASE WHEN SIZE = '0820' AND KIND = 'MSP' THEN '0820'  ELSE '0' END)

UNION ALL

SELECT 'M200'                             AS UNIT
		, SUM(VNT_BATCH_PLUS)       AS VNT_BATCH_PLUS
        , SUM(VNT_BATCH_MINUS)     AS VNT_BATCH_MINUS
		, SUM(VVT_BATCH_PLUS)        AS VVT_BATCH_PLUS
		, SUM(VVT_BATCH_MINUS)      AS VVT_BATCH_MINUS
		, SUM(VNT_BATCH_PLUS) + SUM(VNT_BATCH_MINUS)  + SUM(VVT_BATCH_PLUS) + SUM(VVT_BATCH_MINUS)      AS Total
	FROM #TEMP_TABLE488
	WHERE 1=1
	AND SIZE = (CASE WHEN SIZE = '1325' AND KIND = 'MSP' THEN '1325'  ELSE '0' END)
	  OR SIZE = (CASE WHEN SIZE = '2245' AND KIND = 'MSP'   THEN '2245'  ELSE '0' END)
	  OR SIZE IN ( '1346','1859','2570')


					 
END


--            EXEC usp_Electrode_Requirements_get