
-- ==============================================================================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2022-02-28
-- Browsable : True
-- Group : 생산관리 > 생산현황관리 > 생산현황 > 
-- Description: 
-- Modified:  권취 시간별 문자메세지

--집계기준일 : 2021-02-28 
--집계기준시간 : 08:30 ~ 12:30
--라인명 : VPC 1라인
--목표수량 : 10,000
--생산수량 : 8,730

-- 프로시저 실행:  usp_WindingDataByTime  'kilee2','Korean', 'E-22', '2022-02-28 08:30:00' ,'2022-03-01 08:29:59'
-- ===============================================================================================
CREATE PROCEDURE [dbo].[usp_WindingDataByTime]
									@pProcessUserID VARCHAR(20),
									@pProcessLanguage VARCHAR(20),
									--@pRouteCode VARCHAR(20) = Null,
									@pFromDate DATE = NULL,
									@pToDate DATE = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	--DECLARE @RouteCode VARCHAR(50) = CASE WHEN ISNULL(@pRouteCode,'') = '' THEN '*' ELSE @pRouteCode END
	--DECLARE @RouteName VARCHAR(50)
	DECLARE @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	DECLARE @ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
	--DECLARE @DiffDate INT = DATEDIFF(DAY,@FromDate,@ToDate)
	--DECLARE @PlanQtyName NVARCHAR(100)
	--DECLARE @ProdPriorName NVARCHAR(100)
	--DECLARE @PlanCTName NVARCHAR(100)
	

SELECT   
		 PRH.RouteCode
		, RI.RouteName
		, PRH.ProdDateTime
		, ISNULL(PRH.MachineCode, PM.MachineCode) AS MachineCode
		, CASE WHEN RI.RouteCode = 'E-22' AND (MM.MachineName IS NULL OR MM.MachineName = '' OR MM.MachineName = '권취1호기' OR MM.MachineName = '셀#5 권취기' OR MM.MachineName = '셀#1 커링&슬리브기') THEN '셀#1 권취기'			        
				 ELSE ISNULL(MM.MachineName, MM3.MachineName) END AS MachineName
		, DPP.PlanQty
		, PRH.ProdQty AS InputProdQty
		, ISNULL(DRI.DefectQty, 0) AS DefectQty 
		, (PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		, Case When PRH.ShiftCode 	= '1' Then '주간' When PRH.ShiftCode = '2' Then '야간' Else '기타' End ShiftCode
	FROM STB_SetInfo SI WITH(NOLOCK) 
			LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo
			LEFT OUTER JOIN STB_ProdRouteHist  PRH	WITH(NOLOCK)	ON SI.ControlNo = PRH.ControlNo
			LEFT OUTER JOIN STB_RouteInfo      RI	WITH(NOLOCK)    ON PRH.RouteCode = RI.RouteCode
			LEFT OUTER JOIN STB_MachineMaster  MM    WITH(NOLOCK)	ON PRH.MachineCode = MM.MachineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI   WITH(NOLOCK)    ON PRH.WorkerCode = PWI.WorkerCode
			LEFT OUTER JOIN STB_MaterialMaster MM2   WITH(NOLOCK)    ON SI.MaterialCode = MM2.MaterialCode
			LEFT OUTER JOIN STB_LineInfo       LI	WITH(NOLOCK)    ON SI.InputLineCode = LI.LineCode					  
			LEFT OUTER JOIN ( SELECT DRI2.ControlNo
								,DRI2.FindRouteCode
								,MAX(PRH2.MachineCode) AS MachineCode
								,SUM(DRI2.DefectQty) AS DefectQty 
							FROM STB_DefectRepairInfo DRI2  WITH(NOLOCK) 
							LEFT OUTER JOIN STB_ProdRouteHist PRH2
								ON DRI2.ControlNo = PRH2.ControlNo
							AND DRI2.FindRouteCode = PRH2.RouteCode
							WHERE RepairType = 'NONE'
							AND DefectCode NOT IN ('E-22_X03','E-22_X12')
							--AND PRH2.ProdDateTime BETWEEN '2022-02-28 08:30:00' AND '2022-03-01 08:29:29'
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
	--AND PRH.ProdDateTime BETWEEN '2022-02-28 08:30:00' AND '2022-03-01 08:29:29'
	AND PRH.ProdDateTime BETWEEN @FromDate AND @ToDate
	AND PRH.MaterialCode = 'LIVT38-018'
	AND PRH.RouteCode IN ('E-22', 'E-25')
	ORDER BY PRH.RouteCode
	            , PRH.LineCode


END