-- Procedure: usp_Cell_DashBoard2_get
-- ==================================================================
-- Author      : kilee
-- Create date : 2019-09-25
-- Browsable   : true
-- Group       : Dash Board용
-- Description :  
-- Modified    : 
---[실행문]    EXEC usp_Cell_DashBoard2_get 'ASSYLINE-05'
-- ==================================================================


CREATE PROC [dbo].[usp_Cell_DashBoard2_get] 					
				--@pToMonth Datetime,
				--@pCompanyCode VARCHAR(20) = NULL,                                             				
				@pLineCode VARCHAR(20) = NULL                                            				
				--@pSizeCode VARCHAR(04) = Null      	
AS

BEGIN
	SET NOCOUNT ON;

	--DECLARE @ToMonth             VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')                   select         SUBSTRING(CONVERT(VARCHAR(10), getdate(), 121), 1, 11)                     
	--DECLARE @CompanyCode       VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @LineCode             VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '*' ELSE @pLineCode END
	--DECLARE @SizeCode             VARCHAR(8)  = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode    END


	SELECT  A.WorkerName + ' , ' +  B.WorkerName                               AS WorkerName
		   ,      SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)  AS TIME 
FROM            
          ( 
		    SELECT  TOP 1 SPH.WorkerCode
					--, 	( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SPH.WorkerCode) AS WorkerName2
					, 	( SELECT EMP.EMPNM FROM  ERPSVR.ERPDB.DBO.EMPMST EMP WHERE EMP.EMPCD = SPH.WorkerCode) AS WorkerName
					-- ,  SPH.*
					, ROW_NUMBER() OVER(ORDER BY SPH.WorkerCode DESC) AS RNUM
				FROM STB_ProdRouteHist  SPH          
				WHERE 1=1
				AND SPH.JobDate = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)    
				--AND LINECODE =  'ASSYLINE-12'
				AND ((@LineCode = '*')     OR (SPH.LineCode = @LineCode)) 
				AND RouteCode in ('E-22', 'E-23', 'E-24')						
				GROUP BY SPH.WorkerCode
				)  A
         LEFT JOIN 
			  (
				SELECT  TOP 1 SPH.WorkerCode
					--, 	( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SPH.WorkerCode) AS WorkerName2
					, 	( SELECT EMP.EMPNM FROM  ERPSVR.ERPDB.DBO.EMPMST EMP WHERE EMP.EMPCD = SPH.WorkerCode) AS WorkerName
					-- ,  SPH.*
					, ROW_NUMBER() OVER(ORDER BY SPH.WorkerCode ASC) AS RNUM
				FROM STB_ProdRouteHist  SPH          
				WHERE 1=1
				AND SPH.JobDate = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)    
				--AND LINECODE =  'ASSYLINE-12'
				AND ((@LineCode = '*')     OR (SPH.LineCode = @LineCode)) 
				AND RouteCode in ('E-22', 'E-23', 'E-24')		
				--AND RNUM =2
				GROUP BY SPH.WorkerCode
				) B			ON A.RNUM =B.RNUM


--SELECT CASE WHEN Z.RNUM =1 THEN Z.WorkerName ELSE '' END AS FIRST
--        , CASE WHEN Z.RNUM =2 THEN Z.WorkerName ELSE '' END AS SECOND
--		, getdate() AS TIME
--FROM 
--         ( 
--			SELECT  SPH.WorkerCode
--				   --, 	( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SPH.WorkerCode) AS WorkerName2
--				   , 	( SELECT EMP.EMPNM FROM  ERPSVR.ERPDB.DBO.EMPMST EMP WHERE EMP.EMPCD = SPH.WorkerCode) AS WorkerName
--				  -- ,  SPH.*
--				  , ROW_NUMBER() OVER(ORDER BY SPH.WorkerCode DESC) AS RNUM
--			  FROM STB_ProdRouteHist  SPH          
--			 WHERE 1=1
--				AND SPH.JobDate = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)    
--				AND LINECODE =  'ASSYLINE-12'
--				AND RouteCode in ('E-22', 'E-23', 'E-24')		
--				GROUP BY SPH.WorkerCode
--			)  Z
--PIVOT (      FOR  
         
--		 )
--		 S


--SELECT BB.FIRST
--       , BB.SECOND
--FROM (           
--						SELECT  AA.WorkerName AS FIRST
--						       ,  '' AS SECOND
--						FROM 
--								 ( 
--									SELECT  SPH.WorkerCode
--										   --, 	( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SPH.WorkerCode) AS WorkerName2
--										   , 	( SELECT EMP.EMPNM FROM  ERPSVR.ERPDB.DBO.EMPMST EMP WHERE EMP.EMPCD = SPH.WorkerCode) AS WorkerName
--										  -- ,  SPH.*
--										  , ROW_NUMBER() OVER(ORDER BY SPH.WorkerCode DESC) AS RNUM
--									  FROM STB_ProdRouteHist  SPH          
--									 WHERE 1=1
--										AND SPH.JobDate = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)    
--										AND LINECODE =  'ASSYLINE-12'
--										AND RouteCode in ('E-22', 'E-23', 'E-24')					
--										GROUP BY SPH.WorkerCode
--									) AA
--						WHERE AA.RNUM ='1'

--						UNION ALL

--						SELECT  '' AS FIRST
--						         , AA.WorkerName AS SECOND
--						FROM 
--								 ( 
--									SELECT  SPH.WorkerCode
--										   --, 	( SELECT SU.UserName FROM  SmartFramework.DBO.STB_UserInfo SU WHERE SU.UserID = SPH.WorkerCode) AS WorkerName2
--										   , 	( SELECT EMP.EMPNM FROM  ERPSVR.ERPDB.DBO.EMPMST EMP WHERE EMP.EMPCD = SPH.WorkerCode) AS WorkerName
--										  -- ,  SPH.*
--										  , ROW_NUMBER() OVER(ORDER BY SPH.WorkerCode DESC) AS RNUM
--									  FROM STB_ProdRouteHist  SPH          
--									 WHERE 1=1
--										AND SPH.JobDate = SUBSTRING(CONVERT(VARCHAR(10), GETDATE(), 121), 1, 11)    
--										AND LINECODE =  'ASSYLINE-12'
--										AND RouteCode in ('E-22', 'E-23', 'E-24')					
--										GROUP BY SPH.WorkerCode
--									) AA
--						WHERE AA.RNUM ='2'
--	 ) BB



 END  




GO

