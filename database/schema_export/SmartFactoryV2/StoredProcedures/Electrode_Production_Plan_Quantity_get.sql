-- Procedure: Electrode_Production_Plan_Quantity_get
-- =============================================
-- Author:	    kilee
-- Create date: 2019-10-27
-- Browsable : true
-- Group : 생산계획 > [B488] 전극종류별 Batch 수량계산 
-- Description:	Grid-1 법인별 생산계획수량
-- Modified:
-- 실행 test :   EXEC Electrode_Production_Plan_Quantity_get '','',''
-- =============================================
CREATE PROCEDURE [dbo].[Electrode_Production_Plan_Quantity_get]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pToMonth Datetime
	--@pAQL                 VARCHAR(10) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
	--DECLARE @AQL VARCHAR(10) = CASE WHEN ISNULL(@pAQL,'') = '' THEN '*' ELSE @pAQL END
	DECLARE @ToMonth             VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')                                   -- 금일 6자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2019-05-17 08:30:00', 121), 1, 7), '-', '')     --> '201905'
    
	    --2019.10.31 Backup
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
					--							 , ISNULL(PP.본사_월간계획, 0)                                                                                                       AS 본사_생산계획량
					--							 , ISNULL(QQ.베트남_월간계획, 0)                                                                                                   AS 베트남_생산계획량
					--					 FROM 
					--				(
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
					--											SELECT AA.사이즈
					--												, 0 AS 본사_월간계획
					--												, CASE WHEN AA.CompanyCode = 'VVT' THEN SUM(AA.월간계획)   ELSE 0 END AS 베트남_월간계획			         
					--										FROM (						
					--															SELECT 	사이즈							      
					--																		,  CompanyCode 
					--																		,  SUM(월간계획)   AS 월간계획
					--																FROM Medium_Plan MP									
					--																WHERE 1=1
					--																	--AND 기준년월 LIKE @ToMonth + '%'
					--																	AND  기준년월 = '201911'
					--																	AND MP.공정코드 IN ( 'E-22', 'V-22')                           -- 안제헌대리가 권취공정수량
					--																	-- AND MP.사이즈 = '0820'
					--																	AND MP.CompanyCode = 'VVT'
					--																GROUP BY  사이즈, CompanyCode							                 												
					--												) AA                    
					--											GROUP BY Companycode, 사이즈
					--										) QQ
					--											ON PP.사이즈 = QQ.사이즈
					--										) GG
					--			 LEFT OUTER JOIN SIZE_UNIT  SS ON SS.SIZE = GG.사이즈

					
					 SELECT SS.SIZE       AS SIZE
					        , SS.KIND                  
							, SS.FARAD
							, SS.WIDTH
							, SS.PLUS                   AS ONE_BATCH_PLUS
							, SS.MINUS                 AS ONE_BATCH_MINUS
							, ISNULL(SS.VNT_PLAN_QTY, 0)     AS VNT_PLAN_QTY
							, ISNULL(SS.VVT_PLAN_QTY, 0)    AS VVT_PLAN_QTY      
					FROM		 SIZE_UNIT   SS
					ORDER BY SS.SIZE, SS.KIND


END


--
--SELECT 	*
--FROM Medium_Plan MP									
--WHERE 1=1
--    --AND 기준년월 LIKE @ToMonth + '%'
--	AND  기준년월 = '201911'
--	AND MP.공정코드 IN ( 'E-22', 'V-22')                           -- 안제헌대리가 권취공정수량
--	AND MP.사이즈 = '0820'
				
GO

