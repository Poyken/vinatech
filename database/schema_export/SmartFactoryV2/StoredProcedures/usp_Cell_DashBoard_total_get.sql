-- Procedure: usp_Cell_DashBoard_total_get
-- ==================================================================
-- Author      : kilee
-- Create date : 2019-09-25
-- Browsable   : true
-- Group       : Dash Board용
-- Description :  
-- Modified    : 
---[실행문]    usp_Cell_DashBoard_total_get 'ASSYLINE-12'
--               usp_Cell_DashBoard_total_get ''
-- ==================================================================


CREATE PROC [dbo].[usp_Cell_DashBoard_total_get] 					
				@pToMonth Datetime,
				--@pCompanyCode VARCHAR(20) = NULL,                                             				
				@pLineCode VARCHAR(20) = NULL                                            				
				--@pSizeCode VARCHAR(04) = Null      	
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ToMonth             VARCHAR(10) =  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 7), '-', '')                                  
	--DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @LineCode             VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	--DECLARE @SizeCode             VARCHAR(8)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode    END



SELECT  SUM(MPL.월간계획)         AS 계획수량
		--, (SELECT MPL.월간계획 FROM MEDIUM_PLAN MPL WHERE MPL.CompanyCode = MPO.CompanyCode  AND MPL.공정코드 = MPO.RouteCode   AND MPL.기준년월 = MPO.기준년월   AND MPL.공정코드 = 'E-28') AS 계획수량
	   , SUM(MPO.월누적수량)     AS 월누계수량   		
	   , CONVERT(NUMERIC(20,5), SUM(MPO.월누적수량)) / CONVERT(NUMERIC(20,5), SUM(MPL.월간계획)) * 100.0    AS 달성율
		--, MPO.*
    --   , SPB.WorkerCode  AS 작업자명
	   --SELECT  FROM STB_ProdWorkerInfo SPW WHERE SPW.WorkerCode = SPB.WorkerCode
  FROM MEDIUM_PROD MPO
         LEFT OUTER JOIN MEDIUM_PLAN      MPL  ON MPL.CompanyCode = MPO.CompanyCode  AND MPL.공정코드 = MPO.RouteCode   AND MPL.기준년월 = MPO.기준년월    AND MPL.사이즈 = MPO.사이즈   
	     -- LEFT OUTER JOIN STB_ProdRouteHist  SPB  ON SPB.RouteCode = MPO.RouteCode           AND  SPB.RouteCode = MPL.공정코드  
 WHERE 1=1
    AND MPO.기준년월 = @ToMonth  
	--AND MPO.기준년월 = '201909'
	AND MPO.CompanyCode = 'VNT'
	--AND MPO.사이즈 = '1030'
	AND MPO.RouteCode = 'E-24'
	--AND MPO.LineCode = 'ASSYLINE-12'
   --AND 기준년월 LIKE @ToMonth + '%'
   --AND 기준년월 = '201909'
   --AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode)) 
   AND ((@LineCode = '*')     OR (MPO.LineCode = @LineCode)) 
    
--ORDER BY MPO.LineCode 

--UNION 


--SELECT ''       AS 라인코드	    
--		, ''        AS 사이즈		
--	   , 100        AS 계획수량		
--	   , ''    AS 월누계수량   		
--	   , 100   AS 달성율		
--  FROM MEDIUM_PROD MPO
--         LEFT OUTER JOIN MEDIUM_PLAN      MPL  ON MPL.CompanyCode = MPO.CompanyCode  AND MPL.공정코드 = MPO.RouteCode   AND MPL.기준년월 = MPO.기준년월    AND MPL.사이즈 = MPO.사이즈   	     
-- WHERE 1=1
--    AND MPO.기준년월 = '201909'
--	AND MPO.CompanyCode = 'VNT'	
--	AND MPO.RouteCode = 'E-28'
--	AND MPO.LineCode = 'ASSYLINE-12'   




 END  


--SELECT 기준년월, 월간계획, * FROM MEDIUM_PLAN WHERE 기준년월 = '201909' AND CompanyCode = 'VNT' AND 사이즈 = '1030'


--SELECT * FROM MEDIUM_PROD  WHERE 기준년월 = '201909' AND CompanyCode = 'VNT' AND 사이즈 = '1030'

GO

