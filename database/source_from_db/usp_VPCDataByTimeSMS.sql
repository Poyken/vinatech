
-- ==============================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-02-28
-- Browsable : True
-- Group : 생산관리 > 생산현황관리 > 생산현황 > 
-- Description: 
-- Modified:  권취 시간별 문자메세지

-- 집계 기준일 : 2022-02-28 
-- 집계 기준시간 : 08:30 ~ 12:30
-- 라인명 : VPC 1라인
-- 목표수량 : 10,000
-- 권취 생산수량 : 8,730
-- 슬리브 생산수량 : 

-- [대상] 생산팀, 품질팀, 임원, 
-- 기존 프로시저명  usp_WindingDataByTime  'kilee2','Korean',  '2022-02-28 08:30:00' ,'2022-03-01 08:29:59'

-- 프로시저 실행 :    usp_VPCDataByTimeSMS  'kilee2','Korean'
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_VPCDataByTimeSMS]
									@pProcessUserID VARCHAR(20),
									@pProcessLanguage VARCHAR(20)
									--@pFromDate Date = NULL,
									--@pToDate Date = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
 --DECLARE @FromDate DateTime = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
 --DECLARE @ToDate    DateTime = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	DECLARE @FromDate DateTime = CONVERT(VARCHAR(10), GetDate(), 121) + ' 08:30:00'
	DECLARE @ToDate    DateTime = CONVERT(VARCHAR(10), DATEADD(Day, 1, GetDate()), 121) + ' 08:29:59'


	DECLARE @StandardTime  VARCHAR(50) = '오전 08:30 ~ 12:30'

    DECLARE @PlanQty NVARCHAR(MAX)
	DECLARE @ProdQty NVARCHAR(MAX)
	DECLARE @PlanQty2 NVARCHAR(MAX)
	DECLARE @ProdQty2 NVARCHAR(MAX)

	DECLARE @InputProdQty INT 
	DECLARE @ProdDateTime Char(10)
	DECLARE @LineCode VARCHAR(20) 
	DECLARE @LineName VARCHAR(20) 
	DECLARE @RouteName VARCHAR(20) 
	DECLARE @MachineName VARCHAR(40) 
	DECLARE @DefectQty INT 
	DECLARE @DefectRate Numeric(20,2)
	DECLARE @LineMessage NVARCHAR(MAX)



	--DECLARE @Cnt  INT
	-- DECLARE @i    INT 

	-- 1. 권취  SELECT 문
  SELECT  @ProdDateTime =  CONVERT(CHAR(10), FIN.ProdDateTime, 121) 
	      , @RouteName = CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
		  --, @MachineName = ISNULL(FIN.MachineName, '소계') 
		  , @PlanQty = CONVERT(BIGINT, SUM(FIN.PlanQty)) 
		  , @InputProdQty = CONVERT(BIGINT, SUM(FIN.InputProdQty)) 
		  , @ProdQty = CONVERT(BIGINT, SUM(FIN.ProdQty)) 
		  , @DefectQty =  CONVERT(BIGINT, SUM(FIN.DefectQty)) 
		  , @DefectRate = CONVERT(NUMERIC(20,2), SUM(FIN.DefectQty) / SUM(FIN.InputProdQty) * 100) 
		  , @LineCode = LineCode
		  , @LineName =  LineName
		 -- , @Cnt = Count(*)
	FROM (
				SELECT TOP 100000   PRH.RouteCode
						, RI.RouteName
						, PRH.ProdDateTime
					    , LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
						--, ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
						--, CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'			        
						--			ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
						, DPP.PlanQty as PlanQty
						, PRH.ProdQty AS InputProdQty
						, ISNULL(DRI.DefectQty, 0) AS DefectQty 
						, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
						--, Case When PRH.ShiftCode 	= '1' Then '주간' When PRH.ShiftCode = '2' Then '야간' Else '기타' End ShiftCode
						, SI.InputLineCode AS LineCode
						, LI.LineName As LineName
					FROM STB_SetInfo SI WITH(NOLOCK) 
							LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo
							LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
							LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
							--LEFT OUTER JOIN STB_MachineMaster  MM    WITH(NOLOCK)	ON PRH.MachineCode = MM.MachineCode
							LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
							LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
							LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
							LEFT OUTER JOIN ( SELECT DRI2.ControlNo
														,DRI2.FindRouteCode
														,MAX(PRH2.MachineCode) AS MachineCode
														,SUM(DRI2.DefectQty) AS DefectQty 
													FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
													LEFT OUTER JOIN STB_ProdRouteHist PRH2								ON DRI2.ControlNo = PRH2.ControlNo							AND DRI2.FindRouteCode = PRH2.RouteCode
													WHERE RepairType = 'NONE'
													AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')					
													AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
													GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
												) DRI 						 ON PRH.ControlNo = DRI.ControlNo						AND PRH.RouteCode = DRI.FindRouteCode						AND PRH.MachineCode = DRI.MachineCode
						LEFT OUTER JOIN (
												SELECT RouteCode, MIN(MachineCode) AS MachineCode
													FROM STB_ProductMachine
													GROUP BY RouteCode
												) PM                  ON PM.RouteCode = PRH.RouteCode
						LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode
					WHERE 1=1
						AND PRH.CompanyCode = 'VNT'
						AND PRH.WorkCenterCode = 'VNT_F1'
						AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
						AND PRH.MaterialCode = 'LIVT38-018'
						AND PRH.RouteCode = 'E-22'
					ORDER BY PRH.RouteCode
								, PRH.LineCode
) FIN
	WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
	  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
	  AND FIN.RouteCode ='E-22'    --권취만
	GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
	        , CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
			--, FIN.MachineName 
			, LineCode
			, LineName
	HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
	ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
	        ,   CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
							WHEN '권취' THEN '01'
							WHEN '슬리브' THEN '02'  ELSE '99' END

---- 2. 슬리브 실적수량

--  SELECT  
--		   @PlanQty2 = CONVERT(BIGINT, SUM(FIN.PlanQty)) 		
--		  , @ProdQty2 = CONVERT(BIGINT, SUM(FIN.ProdQty)) 
		  
--	FROM (
--				SELECT TOP 100000   PRH.RouteCode
--						, RI.RouteName
--						, PRH.ProdDateTime
--					    , LAG(PRH.ProdDateTime) OVER(ORDER BY SI.Barcode ,CASE WHEN PRH.RouteCode = 'E-28' 	THEN 'E-99' ELSE PRH.RouteCode END) AS PrevProdDateTime
--						, ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
--						, CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'			        
--									ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
--						, DPP.PlanQty as PlanQty
--						, PRH.ProdQty AS InputProdQty
--						, ISNULL(DRI.DefectQty, 0) AS DefectQty 
--						, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
--						, Case When PRH.ShiftCode 	= '1' Then '주간' When PRH.ShiftCode = '2' Then '야간' Else '기타' End ShiftCode
--						, SI.InputLineCode AS LineCode
--						, LI.LineName As LineName
--					FROM STB_SetInfo SI WITH(NOLOCK) 
--							LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo
--							LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
--							LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
--							LEFT OUTER JOIN STB_MachineMaster  MM    WITH(NOLOCK)	ON PRH.MachineCode = MM.MachineCode
--							LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
--							LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
--							LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
--							LEFT OUTER JOIN ( SELECT DRI2.ControlNo
--														,DRI2.FindRouteCode
--														,MAX(PRH2.MachineCode) AS MachineCode
--														,SUM(DRI2.DefectQty) AS DefectQty 
--													FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
--													LEFT OUTER JOIN STB_ProdRouteHist PRH2								ON DRI2.ControlNo = PRH2.ControlNo							AND DRI2.FindRouteCode = PRH2.RouteCode
--													WHERE RepairType = 'NONE'
--													AND DefectCode NOT IN ('E-22_X03','E-22_X12','E-24_X03','E-24_X12')					
--													AND PRH2.ProdDateTime BETWEEN @FromDate AND @ToDate
--													GROUP BY DRI2.ControlNo, DRI2.FindRouteCode
--												) DRI 						 ON PRH.ControlNo = DRI.ControlNo						AND PRH.RouteCode = DRI.FindRouteCode						AND PRH.MachineCode = DRI.MachineCode
--						LEFT OUTER JOIN (
--												SELECT RouteCode, MIN(MachineCode) AS MachineCode
--													FROM STB_ProductMachine
--													GROUP BY RouteCode
--												) PM                  ON PM.RouteCode = PRH.RouteCode
--						LEFT OUTER JOIN STB_MachineMaster MM3                 ON MM3.MachineCode = PM.MachineCode
--					WHERE 1=1
--						AND PRH.CompanyCode = 'VNT'
--						AND PRH.WorkCenterCode = 'VNT_F1'
--						AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
--						AND PRH.MaterialCode = 'LIVT38-018'
--						AND PRH.RouteCode = 'E-25'
--					ORDER BY PRH.RouteCode
--								, PRH.LineCode
--) FIN
--	WHERE (ABS(DATEDIFF(day, FIN.PrevProdDateTime, FIN.ProdDateTime)) < 20 OR FIN.PrevProdDateTime IS NULL)
--	  AND (ABS(DATEDIFF(ms, FIN.PrevProdDateTime, FIN.ProdDateTime)) > 10000 OR FIN.PrevProdDateTime IS NULL)
--	  AND FIN.RouteCode ='E-25'    --슬리만
--	GROUP BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
--	        , CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END
--			, FIN.MachineName 
--			, LineCode
--			, LineName
--	HAVING CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END IS NOT NULL
--	ORDER BY CONVERT(CHAR(10), FIN.ProdDateTime, 121)
--	        ,   CASE CASE WHEN FIN.RouteName = '커링' THEN '조립(커링)' ELSE FIN.RouteName END 
--							WHEN '권취' THEN '01'
--							WHEN '슬리브' THEN '02'  ELSE '99' END

-- 2번끝




			SET @LineMessage = 'VPC 금일실적 공유드립니다.' 
	                    + ' [기준일] : ' + ISNULL(@ProdDateTime,'') + '<br>'
						+ ' [기준시간] : ' + ISNULL(@StandardTime,'') + '<br>'
						+ ' [라인명] : ' + ISNULL(@LineName,'') + '<br>'
						+ ' [공정명] : ' + ISNULL(@RouteName,'') + '<br>'
						+ ' [목표수량] : ' + ISNULL(@PlanQty,'') + '<br>'
						--+ ' / [실적수량] : ' + ISNULL(@ProdQty,'')
						+ ' [권취] : ' + ISNULL(@ProdQty,'') + '<br>' 						
						+ ' [슬리브] : ' + ISNULL(@ProdQty2,'') + '<br>'					
			
					
		    Exec usp_DoSendSMS 'kilee', 'Korean', '01023207233', @LineMessage , ''                   -- SMS 실행 프로시저 (나만)
          --  Exec usp_DoSendSMS 'kilee', 'Korean', '01023207233,01032226697,01020601714', @LineMessage , ''                   -- SMS실행 프로시저
		  --Exec usp_DoSendSMS 'kilee', 'Korean', '01023207233,01041347351', @LineMessage , ''                   -- SMS실행 프로시저

		 -- exec usp_DoSendSMS '', '', '01023207233', @msg,''
	
	--  SET @i = 0


	--WHILE(@i < @Cnt)   
	--BEGIN
	
 --     SET @i = @i + 1

	--  End

END


/*
 집계 기준일 : 2022-02-28 
 집계 기준시간 : 08:30 ~ 12:30
 라인명 : VPC 1라인
 목표수량 : 10,000
 권취 생산수량 : 8,730
 슬리브 생산수량 : 
*/