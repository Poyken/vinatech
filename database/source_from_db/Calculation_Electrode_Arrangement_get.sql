-- =============================================
-- Author:	    kilee
-- Create date: 2019-10-27
-- Browsable : true
-- Group : 생산계획
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[Calculation_Electrode_Arrangement_get]
	--@pProcessUserID     VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	--@pAQL                 VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @AQL VARCHAR(10) = CASE WHEN ISNULL(@pAQL,'') = '' THEN '*' ELSE @pAQL END

    
	 SELECT    K.SIZE
					,  SUM(K.BATCH_PLUS)     AS BATCH_PLUS
					,  SUM(K.BATCH_MINUS) 	AS BATCH_MINUS
			FROM 
						(	
							SELECT A.SIZE                  AS SIZE
									, SUM(B.월간계획)       AS PLAN_QTY
									, A.PLUS                  AS ONE_BATCH_PLUS
									, A.MINUS	               AS ONE_BATCH_MINUS
       
									--, (SUM(B.월간계획) / A.PLUS)                   AS BATCH_PLUS
									--, (SUM(B.월간계획) / A.MINUS)                AS BATCH_MINUS	   	    
									, ROUND(SUM(B.월간계획) / Convert(Float, A.PLUS), 0)   AS BATCH_PLUS
									, ROUND(SUM(B.월간계획) / Convert(Float,A.MINUS), 0)  AS BATCH_MINUS	   	    	   
							FROM SIZE_UNIT A
									LEFT OUTER JOIN [MEDIUM_PLAN] B ON B.사이즈 =A.SIZE
							WHERE 1=1
								--AND A.SIZE = '0813'
								AND B.공정코드 IN ('E-22', 'V-22')
								AND B.CompanyCode = 'VVT'
								AND B.기준년월 = '201910'
							GROUP BY A.PLUS, A.MINUS, A.SIZE

							UNION ALL


							SELECT A.SIZE                  AS SIZE
									, SUM(B.월간계획)       AS PLAN_QTY
									, A.PLUS                  AS ONE_BATCH_PLUS
									, A.MINUS	               AS ONE_BATCH_MINUS
       
									--, (SUM(B.월간계획) / A.PLUS)                   AS BATCH_PLUS
									--, (SUM(B.월간계획) / A.MINUS)                AS BATCH_MINUS	   	    
									, ROUND(SUM(B.월간계획) / Convert(Float, A.PLUS), 0)   AS BATCH_PLUS
									, ROUND(SUM(B.월간계획) / Convert(Float,A.MINUS), 0)  AS BATCH_MINUS	   	    	   
							FROM SIZE_UNIT A
									LEFT OUTER JOIN [MEDIUM_PLAN] B ON B.사이즈 =A.SIZE
							WHERE 1=1
								--AND A.SIZE = '0813'
								AND B.공정코드  IN ('E-22', 'V-22')
								AND B.CompanyCode = 'VNT'
								AND B.기준년월 = '201910'
							GROUP BY A.PLUS, A.MINUS, A.SIZE
						)  K
			GROUP BY K.SIZE

END
