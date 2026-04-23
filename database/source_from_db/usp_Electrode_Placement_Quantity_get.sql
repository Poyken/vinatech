-- =============================================
-- Author:	    kilee
-- Create date: 2019-10-27
-- Browsable : true
-- Group : 생산계획 > 전극소요량
-- Description:	Grid2. 법인별 배치소요량 계산
-- Modified:

-- 실행 Test :   usp_Electrode_Placement_Quantity_get
-- =============================================
CREATE PROCEDURE [dbo].[usp_Electrode_Placement_Quantity_get]
	--@pProcessUserID     VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	--@pAQL                 VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @AQL VARCHAR(10) = CASE WHEN ISNULL(@pAQL,'') = '' THEN '*' ELSE @pAQL END

    
	 --SELECT    K.SIZE
		--			,  SUM(K.BATCH_PLUS)     AS BATCH_PLUS
		--			,  SUM(K.BATCH_MINUS) 	AS BATCH_MINUS
		--	FROM 
		--				(	
		--					SELECT A.SIZE                  AS SIZE
		--							, SUM(B.월간계획)       AS PLAN_QTY
		--							, A.PLUS                  AS ONE_BATCH_PLUS
		--							, A.MINUS	               AS ONE_BATCH_MINUS
       
		--							--, (SUM(B.월간계획) / A.PLUS)                   AS BATCH_PLUS
		--							--, (SUM(B.월간계획) / A.MINUS)                AS BATCH_MINUS	   	    
		--							, ROUND(SUM(B.월간계획) / Convert(Float, A.PLUS), 0)   AS BATCH_PLUS
		--							, ROUND(SUM(B.월간계획) / Convert(Float,A.MINUS), 0)  AS BATCH_MINUS	   	    	   
		--					FROM SIZE_UNIT A
		--							LEFT OUTER JOIN [MEDIUM_PLAN] B ON B.사이즈 =A.SIZE
		--					WHERE 1=1
		--						--AND A.SIZE = '0813'
		--						AND B.공정코드 IN ('E-22', 'V-22')
		--						AND B.CompanyCode = 'VVT'
		--						AND B.기준년월 = '201911'
		--					GROUP BY A.PLUS, A.MINUS, A.SIZE

		--					--UNION ALL


		--					--SELECT A.SIZE                  AS SIZE
		--					--		, SUM(B.월간계획)       AS PLAN_QTY
		--					--		, A.PLUS                  AS ONE_BATCH_PLUS
		--					--		, A.MINUS	               AS ONE_BATCH_MINUS
       
		--					--		--, (SUM(B.월간계획) / A.PLUS)                   AS BATCH_PLUS
		--					--		--, (SUM(B.월간계획) / A.MINUS)                AS BATCH_MINUS	   	    
		--					--		, ROUND(SUM(B.월간계획) / Convert(Float, A.PLUS), 0)   AS BATCH_PLUS
		--					--		, ROUND(SUM(B.월간계획) / Convert(Float,A.MINUS), 0)  AS BATCH_MINUS	   	    	   
		--					--FROM SIZE_UNIT A
		--					--		LEFT OUTER JOIN [MEDIUM_PLAN] B ON B.사이즈 =A.SIZE
		--					--WHERE 1=1
		--					--	--AND A.SIZE = '0813'
		--					--	AND B.공정코드  IN ('E-22', 'V-22')
		--					--	AND B.CompanyCode = 'VNT'
		--					--	AND B.기준년월 = '201910'
		--					--GROUP BY A.PLUS, A.MINUS, A.SIZE
		--				)  K
		--	GROUP BY K.SIZE


		SELECT K.SIZE                                                                         AS SIZE	 
		            , K.KIND                                                                    AS KIND 
		, ROUND(SUM(K.본사계획량)   / Convert(Float, K.ONE_BATCH_PLUS),   0)   AS VNT_BATCH_PLUS
		, ROUND(SUM(K.본사계획량)    / Convert(Float, K.ONE_BATCH_MINUS), 0)  AS VNT_BATCH_MINUS	
		, ROUND(SUM(K.베트남계획량) / Convert(Float, K.ONE_BATCH_PLUS),   0)   AS VVT_BATCH_PLUS
		, ROUND(SUM(K.베트남계획량) / Convert(Float, K.ONE_BATCH_MINUS), 0)  AS VVT_BATCH_MINUS	
FROM 
  	      (
					-- SELECT GG.사이즈       AS SIZE
					--        , SS.KIND    
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

ORDER BY K.SIZE, K.KIND

END
