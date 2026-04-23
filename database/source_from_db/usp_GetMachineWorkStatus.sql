

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 생산관리
-- Description:	설비가동현황 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMachineWorkStatus]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
				
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @CurrentDateTime DATETIME = GETDATE()
	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(@CurrentDateTime, @CompanyCode, @WorkCenterCode, NULL, NULL, NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)
	
	;WITH Capacity AS
	(
		SELECT
				MC.MoldNumber,
				AVG(ISNULL(MC.CT,0)) AS CT
		FROM		
				STB_MachineCapacity MC WITH(NOLOCK)
				LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
					ON MBI.MoldNumber = MC.MoldNumber
		WHERE
				MBI.WorkCenterCode = @WorkCenterCode
		GROUP BY
				MC.MoldNumber
	), MoldCurrentProd AS
	(
		SELECT
				MPH.DayPlanNo,
				MPM.MachineCode,
				MPM.MoldProdNo,
				MPH.StartDateTime,
				MPH.ShotQty,
				MPH.MoldNumber,
				DPP.PlanQty,
				CAPA.CT
		FROM
				STB_MoldProductMachine MPM WITH(NOLOCK)
				INNER JOIN STB_MachineMaster MCM WITH(NOLOCK)
					ON MCM.MachineCode = MPM.MachineCode
				INNER JOIN STB_MoldProdHist MPH WITH(NOLOCK)
					ON MPH.MoldProdNo = MPM.MoldProdNo
				LEFT OUTER JOIN STB_DayProdPlan DPP WITH(NOLOCK)
					ON DPP.DayPlanNo = MPH.DayPlanNo
				LEFT OUTER JOIN Capacity CAPA
					ON CAPA.MoldNumber = MPH.MoldNumber
		WHERE
				MCM.CompanyCode LIKE @CompanyCode AND
				MCM.WorkCenterCode LIKE @WorkCenterCode AND
				MPH.JobDate = @JobDate AND
				MPH.ShiftCode = @ShiftCode
	), MoldCurrentProdHist AS
	(
		SELECT
				MCP.MachineCode,
				SUM(MPPH.ProdQty) - SUM(MPPH.TryQty) AS ProdQty,
				SUM(MPPH.DefectQty) AS DefectQty,
				SUM(MPPH.TryQty) AS TryQty
		FROM
				STB_MoldProductProdHist MPPH WITH(NOLOCK)
				INNER JOIN MoldCurrentProd MCP
					ON MCP.MoldProdNo = MPPH.MoldProdNo
		GROUP BY
				MCP.MachineCode
	), MoldProdList AS
	(
		SELECT
				MPH.DayPlanNo,
				MPH.MoldProdNo,
				MPH.MachineCode
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
		WHERE
				MPH.JobDate = @JobDate AND
				MPH.ShiftCode = @ShiftCode
	), MoldPlan AS
	(
		SELECT
				DPP.MachineCode,
				SUM(DPP.PlanQty) AS PlanQty
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE
				DPP.DayPlanNo IN (SELECT DayPlanNo FROM MoldProdList)
		GROUP BY
				DPP.MachineCode
	), MoldProdHist AS
	(
		SELECT
				MPH.MachineCode,
				SUM(MPH.ShotQty) AS ShotQty
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
				INNER JOIN MoldProdList MPL
					ON MPL.MoldProdNo = MPH.MoldProdNo
		GROUP BY
				MPH.MachineCode
	), MoldProductProdHist AS
	(
		SELECT
				MPL.MachineCode,
				SUM(MPPH.ProdQty) - SUM(MPPH.TryQty) AS ProdQty,
				SUM(MPPH.DefectQty) AS DefectQty,
				SUM(MPPH.TryQty) AS TryQty
		FROM
				STB_MoldProductProdHist MPPH WITH(NOLOCK)
				INNER JOIN MoldProdList MPL
					ON MPL.MoldProdNo = MPPH.MoldProdNo
		GROUP BY
				MPL.MachineCode
	)
		SELECT
				MPM.WorkCenterCode,
				WCI.WorkCenterName,
				MPM.MachineCode,
				MPM.MachineName,
				CASE 
					WHEN MPM.RunMode = 'S' THEN ''	--(SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = 'S') 
					ELSE CASE
							WHEN MPM.RunMode = 'R' AND MPM.IsMachineAlarm = 1 THEN ''	--(SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = 'A')--'설비알람'
							ELSE ''	--(SELECT ImageData FROM STB_StatusImageInfo WHERE ImageValue = 'R')
						END
				END AS Status,
				CASE
					WHEN MPM.RunMode = 'R' AND MPM.IsMachineAlarm = 0 THEN '가동'
					WHEN MPM.RunMode = 'R' AND MPM.IsMachineAlarm = 1 THEN '알람'
					WHEN MPM.RunMode = 'S' AND MPM.IsMachineAlarm = 0 THEN '정지'
					WHEN MPM.RunMode = 'S' AND MPM.IsMachineAlarm = 1 THEN '정지'
				END AS MachineStatusMessage,
				CASE
					WHEN MPM.RunMode = 'R' AND MPM.IsMachineAlarm = 0 THEN '정상가동중'
					WHEN MPM.RunMode = 'R' AND MPM.IsMachineAlarm = 1 THEN '정상가동중-알람발생'
					WHEN MPM.RunMode = 'S' AND MPM.IsMachineAlarm = 0 THEN '설비정지:' --+ CONVERT(VARCHAR(5), LH.LossStartTime, 108) + ' ' + ISNULL(LTI.BasicLossName,'')
					WHEN MPM.RunMode = 'S' AND MPM.IsMachineAlarm = 1 THEN '설비정지:' --+ CONVERT(VARCHAR(5), LH.LossStartTime, 108) + ' ' + ISNULL(LTI.BasicLossName,'') +':알람발생'
				END AS MachineStatusMessage1,
				MCP.DayPlanNo,		-- 현재생산중인계획번호
				@CurrentDateTime AS CurrentDateTime,
				MDBI.MoldCategory1 AS CarType,
				MDBI.MoldCategory2 AS MirrorType,
				MDBI.MoldCategory3 AS Spec,
				dbo.fnConvertDateTimeToVarchar('yyyy-MM-dd HH:mi',MCP.StartDateTime) AS StartDateTime,
				CASE
					WHEN MCP.PlanQty < MCP.ShotQty THEN 0
					ELSE (MCP.PlanQty - MCP.ShotQty) * MCP.CT / 60.0
				END AS RemainTime,
				MCP.PlanQty,
				MCP.ShotQty,
				MCPH.DefectQty,
				CASE
					WHEN ISNULL(MCP.PlanQty,0) = 0 THEN 0.0
					ELSE ISNULL(ROUND(MCP.ShotQty / MCP.PlanQty * 100,1),0.0)
				END AS AchievementRate,		-- 달성율
				CASE
					WHEN ISNULL(MCPH.ProdQty,0) - ISNULL(MCPH.TryQty,0) = 0 THEN 0
					ELSE ISNULL(ROUND(MCPH.DefectQty / MCPH.ProdQty * 1000000,0),0)
				END AS DefectPPM,			-- 불량율 PPM
				CASE
					WHEN ISNULL(MCPH.ProdQty,0) - ISNULL(MCPH.TryQty,0) = 0 THEN 0
					ELSE ISNULL(ROUND(MCPH.DefectQty / MCPH.ProdQty * 100,0),0)
				END AS DefectRate,
				MP.PlanQty AS TodayPlanQty,
				MPH.ShotQty AS TodayShotQty,
				MPPH.DefectQty AS TodayDefectQty,
				CASE
					WHEN ISNULL(MP.PlanQty,0) = 0 THEN 0.0
					ELSE ISNULL(ROUND(MPH.ShotQty / MP.PlanQty * 100,1),0)
				END AS TodayAchievementRate,
				CASE
					WHEN ISNULL(MPPH.ProdQty,0) = 0 THEN 0.0
					ELSE ISNULL(ROUND(MPPH.DefectQty / MPPH.ProdQty * 1000000,0),0)
				END AS TodayDefectPPM,
				CASE
					WHEN ISNULL(MPPH.ProdQty,0) = 0 THEN 0.0
					ELSE ISNULL(ROUND(MPPH.DefectQty / MPPH.ProdQty * 100,0),0)
				END AS TodayDefectRate
		FROM
				STB_MoldProductMachine MPM WITH(NOLOCK)
				LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
					ON WCI.WorkCenterCode = MPM.WorkCenterCode
				LEFT OUTER JOIN MoldCurrentProd MCP
					ON MCP.MachineCode = MPM.MachineCode
				LEFT OUTER JOIN STB_MoldBasicInfo MDBI WITH(NOLOCK)
					ON MDBI.MoldNumber = MCP.MoldNumber
				LEFT OUTER JOIN MoldCurrentProdHist MCPH
					ON MCPH.MachineCode = MPM.MachineCode
				LEFT OUTER JOIN MoldProdHist MPH
					ON MPH.MachineCode = MPM.MachineCode
				LEFT OUTER JOIN MoldProductProdHist MPPH
					ON MPPH.MachineCode = MPM.MachineCode
				LEFT OUTER JOIN MoldPlan MP
					ON MP.MachineCode = MPM.MachineCode
		ORDER BY
				MPM.DisplayIndex
END