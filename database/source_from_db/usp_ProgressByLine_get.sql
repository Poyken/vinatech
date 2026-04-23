
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-08-18
-- Browsable : True
-- Group : 생산관리 > 생산현황 > 라인별 도식화 현황판중에서 진행율(%)
-- Description: 
-- Modified: 
 -- usp_ProgressByLine_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProgressByLine_get]	
							@pCompanyCode VARCHAR(20) = NULL,  			
							@pRouteCode VARCHAR(20) = NULL,
							@pLineCode VARCHAR(20) = NULL,				
							@pMaterialCode VARCHAR(30) = NULL
AS

	   DECLARE @CompanyCode   VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	-- DECLARE @FromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	-- DECLARE @ToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 121) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	   DECLARE	@RouteCode       VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	   DECLARE	@LineCode         VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END	
	   DECLARE	@MaterialCode    VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN


SELECT MPR.LineCode
        , Case When MPL.월간계획 = '' Then IsNull(DPP.PlanQty, 0) Else IsNull(MPL.월간계획, 0) End   AS 월간계획		
        , MPR.월누적수량
        , Case When MPL.월간계획 = '' Then  IsNull((MPR.월누적수량/ Round(DPP.PlanQty, 0)) * 100, 0)
 		         When (MPR.월누적수량/ Round(DPP.PlanQty, 0)) * 100 = 0 Then  IsNull(MPR.월누적수량, 1) / Isnull(MPL.월간계획, 1)
		         When MPR.월누적수량 = 0 Then 0 	  
				 When MPL.월간계획= 0     Then  0 	  
				 When MPR.월누적수량 = 0 Then  0 	  
				    Else IsNull((MPR.월누적수량/ Round(DPP.PlanQty, 0)) * 100, 0)  End   AS 진행율				 				   
   FROM MEDIUM_PLAN MPL
             Left Outer Join MEDIUM_PROD MPR ON MPR.기준년월 = MPL.기준년월 AND MPR.CompanyCode = MPL.CompanyCode  AND MPR.LineCode = MPL.LineCode And MPR.RouteCode = MPL.공정코드
			 Left Outer Join (
									 select  Sum(PlanQty) As  PlanQty
											  ,  LineCode
									   from  STB_DayProdPlan 
									   where 1=1
										and  PlanDate Between '2020-08-26' and '2020-09-25'
									Group by  LineCode
			                      )   DPP  On DPP.LineCode = MPL.LineCode
WHERE 1=1
   AND MPR.기준년월 = '202009'
   --AND MPR.LineCode = 'ASSYLINE-05'
   AND MPR.RouteCode IN ('E-28', 'V-28')   
   AND ((@CompanyCode = '*') OR (MPR.CompanyCode = @CompanyCode))  


 End